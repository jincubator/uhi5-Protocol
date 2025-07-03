// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { IdLib } from "./IdLib.sol";
import { TransferBenchmarkLib } from "./TransferBenchmarkLib.sol";

import { SafeTransferLib } from "solady/utils/SafeTransferLib.sol";

/**
 * @title TransferLib
 * @notice Library contract implementing logic for internal functions with
 * low-level shared logic for processing transfers, withdrawals and deposits.
 */
library TransferLib {
    using TransferLib for address;
    using IdLib for uint256;
    using SafeTransferLib for address;
    using TransferBenchmarkLib for address;

    // Storage slot seed for ERC6909 state, used in computing balance slots.
    uint256 private constant _ERC6909_MASTER_SLOT_SEED = 0xedcaa89a82293940;

    // keccak256(bytes("Transfer(address,address,address,uint256,uint256)")).
    uint256 private constant _TRANSFER_EVENT_SIGNATURE =
        0x1b3d7edb2e9c0b0e7c525b20aaaef0f5940d2ed71663c7d39266ecafac728859;

    /**
     * @notice Internal function for transferring ERC6909 tokens between accounts. Updates
     * both balances, checking for overflow and insufficient balance. This function bypasses
     * transfer hooks and allowance checks as it is only called in trusted contexts. Emits
     * a Transfer event.
     * @param from   The account to transfer tokens from.
     * @param to     The account to transfer tokens to.
     * @param id     The ERC6909 token identifier to transfer.
     * @param amount The amount of tokens to transfer.
     */
    function release(address from, address to, uint256 id, uint256 amount) internal {
        assembly ("memory-safe") {
            // Compute the sender's balance slot using the master slot seed.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)

            // Load from sender's current balance.
            let fromBalance := sload(fromBalanceSlot)

            // Revert if amount is zero or exceeds balance.
            if or(iszero(amount), gt(amount, fromBalance)) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }

            // Subtract from current balance and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            // Compute the recipient's balance slot and update balance.
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)

            // Revert if the balance overflows.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }

            // Store the recipient's updated balance.
            sstore(toBalanceSlot, toBalanceAfter)

            // Emit the Transfer event:
            //  - topic1: Transfer event signature
            //  - topic2: sender address (sanitized)
            //  - topic3: recipient address (sanitized)
            //  - topic4: token id
            //  - data: [caller, amount]
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), shr(0x60, shl(0x60, to)), id)
        }
    }

    /**
     * @notice Internal function for burning ERC6909 tokens and withdrawing the underlying
     * tokens. Updates the sender's balance and transfers either native tokens or ERC20
     * tokens to the recipient. For ERC20 withdrawals, the actual amount burned is derived
     * from the balance change. Ensure that a reentrancy guard has been set before calling.
     * Emits a Transfer event. Note that if the withdrawal fails, a direct release of the
     * 6909 tokens in question will be performed instead.
     * @param from   The account to burn tokens from.
     * @param to     The account to send underlying tokens to.
     * @param id     The ERC6909 token identifier to burn.
     * @param amount The amount of tokens to burn and withdraw.
     * @param strict A boolean indicating whether or not to insist that the withdrawal
     * succeeds or to fall back to a 6909 transfer.
     */
    function withdraw(address from, address to, uint256 id, uint256 amount, bool strict) internal {
        // Derive the underlying token from the id of the resource lock.
        address token = id.toAddress();

        // Handle native token withdrawals directly.
        bool withdrawalSucceeded;
        uint256 postWithdrawalAmount = amount;
        if (token == address(0)) {
            // Attempt to transfer the ETH using half of available gas.
            assembly ("memory-safe") {
                withdrawalSucceeded := call(div(gas(), sub(2, strict)), to, amount, codesize(), 0, codesize(), 0)
            }
        } else {
            // For ERC20s, track balance change to determine actual withdrawal amount.
            uint256 initialBalance = token.balanceOf(address(this));

            // Attempt to transfer the tokens using half of available gas.
            assembly ("memory-safe") {
                mstore(0x14, to) // Store the `to` argument.
                mstore(0x34, amount) // Store the `amount` argument.
                mstore(0x00, shl(96, 0xa9059cbb)) // `transfer(address,uint256)`.

                // Perform the transfer using half of available gas & examine the call for failure.
                withdrawalSucceeded :=
                    and( // The arguments of `and` are evaluated from right to left.
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(div(gas(), sub(2, strict)), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )

                mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
            }

            // Check balance after performing the withdrawal.
            uint256 terminalBalance = token.balanceOf(address(this));

            assembly ("memory-safe") {
                // Consider the withdrawal as having succeeded if any amount was withdrawn.
                withdrawalSucceeded := and(withdrawalSucceeded, lt(terminalBalance, initialBalance))

                // Derive the realized withdrawal amount (with a minimum value of zero).
                postWithdrawalAmount := mul(withdrawalSucceeded, sub(initialBalance, terminalBalance))
            }
        }

        // Burn the 6909 tokens if the withdrawal succeeded.
        if (withdrawalSucceeded) {
            from.burn(id, postWithdrawalAmount);
        } else {
            if (strict) {
                // revert ForcedWithdrawalFailed();
                assembly ("memory-safe") {
                    mstore(0, 0x580d4e5e)
                    revert(0x1c, 0x04)
                }
            }

            // Ensure that sufficient additional gas stipend has been supplied.
            token.ensureBenchmarkExceeded();

            // Transfer original amount of associated 6909 tokens directly.
            from.release(to, id, amount);
        }
    }

    /**
     * @notice Internal function for burning ERC6909 tokens. Emits a Transfer event.
     * @param from   The account to burn tokens from.
     * @param id     The ERC6909 token identifier to burn.
     * @param amount The amount of tokens to burn.
     */
    function burn(address from, uint256 id, uint256 amount) internal {
        assembly ("memory-safe") {
            // Compute the sender's balance slot using the master slot seed.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, from)
            mstore(0x00, id)
            let fromBalanceSlot := keccak256(0x00, 0x40)

            // Load from sender's current balance.
            let fromBalance := sload(fromBalanceSlot)

            // Revert if insufficient balance.
            if or(iszero(amount), gt(amount, fromBalance)) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }

            // Subtract from current balance and store the updated balance.
            sstore(fromBalanceSlot, sub(fromBalance, amount))

            // Emit the Transfer event:
            //  - topic1: Transfer event signature
            //  - topic2: sender address (sanitized)
            //  - topic3: address(0) signifying a burn
            //  - topic4: token id
            //  - data: [caller, amount]
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0x00, 0x40, _TRANSFER_EVENT_SIGNATURE, shr(0x60, shl(0x60, from)), 0, id)
        }
    }

    /**
     * @notice Internal function for minting ERC6909 tokens. Updates the recipient's balance,
     * checking for overflow, and emits a Transfer event. This function bypasses transfer
     * hooks and allowance checks as it is only called in trusted deposit contexts.
     * @param to     The address to mint tokens to.
     * @param id     The ERC6909 token identifier to mint.
     * @param amount The amount of tokens to mint.
     */
    function deposit(address to, uint256 id, uint256 amount) internal {
        assembly ("memory-safe") {
            // Compute the recipient's balance slot using the master slot seed.
            mstore(0x20, _ERC6909_MASTER_SLOT_SEED)
            mstore(0x14, to)
            mstore(0x00, id)
            let toBalanceSlot := keccak256(0x00, 0x40)

            // Load current balance and compute new balance.
            let toBalanceBefore := sload(toBalanceSlot)
            let toBalanceAfter := add(toBalanceBefore, amount)

            // Revert on balance overflow.
            if lt(toBalanceAfter, toBalanceBefore) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }

            // Store the updated balance.
            sstore(toBalanceSlot, toBalanceAfter)

            // Emit the Transfer event:
            // - topic1: Transfer event signature
            // - topic2: address(0) signifying a mint
            // - topic3: recipient address (sanitized)
            // - topic4: token id
            // - data: [caller, amount]
            mstore(0x00, caller())
            mstore(0x20, amount)
            log4(0, 0x40, _TRANSFER_EVENT_SIGNATURE, 0, shr(0x60, shl(0x60, to)), id)
        }
    }

    /**
     * @notice Internal function for handling various token operation flows based on the
     * respective lock tags. Determines whether to withdraw, release, or transfer tokens.
     * @param from     The address from which the operation originates.
     * @param id       The ERC6909 token identifier to operate on.
     * @param claimant The identifier representing the claimant entity.
     * @param amount   The amount of tokens involved in the operation.
     */
    function performOperation(address from, uint256 id, uint256 claimant, uint256 amount) internal {
        // Extract lock tags from both token ID and claimant.
        bytes12 lockTag = id.toLockTag();
        bytes12 claimantLockTag = claimant.toLockTag();

        // Extract the recipient address referenced by the claimant.
        address recipient = claimant.toAddress();

        if (claimantLockTag == bytes12(0)) {
            // Case 1: Zero lock tag - perform a standard withdrawal operation
            // to the recipient address referenced by the claimant.
            from.withdraw(recipient, id, amount, false);
        } else if (claimantLockTag == lockTag) {
            // Case 2: Matching lock tags - transfer tokens to the recipient address
            // referenced by the claimant.
            from.release(recipient, id, amount);
        } else {
            // Case 3: Different lock tags - convert the resource lock, burning
            // tokens and minting the same amount with the new token ID to the
            // recipient address referenced by the claimant.

            // Create a new token ID using the original ID with claimant's lock tag.
            uint256 claimantId = id.withReplacedLockTag(claimantLockTag);

            // Verify the allocator ID is registered.
            claimantId.toAllocatorIdIfRegistered();

            // Burn tokens from the original context.
            from.burn(id, amount);

            // Deposit tokens to the claimant's address with the new token ID.
            recipient.deposit(claimantId, amount);
        }
    }
}
