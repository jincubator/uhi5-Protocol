// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ForcedWithdrawalStatus } from "../types/ForcedWithdrawalStatus.sol";
import { EmissaryStatus } from "../types/EmissaryStatus.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";
import { Scope } from "../types/Scope.sol";
import { CompactCategory } from "../types/CompactCategory.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";
import { AllocatedTransfer } from "../types/Claims.sol";
import { DepositDetails } from "../types/DepositDetails.sol";
import { AllocatedBatchTransfer } from "../types/BatchClaims.sol";

/**
 * @title The Compact — Core Interface
 * @custom:version 1
 * @author 0age (0age.eth)
 * @custom:coauthor mgretzke (mgretzke.eth)
 * @custom:coauthor ccashwell (ccashwell.eth)
 * @custom:coauthor reednaa (reednaa.eth)
 * @custom:coauthor zeroknots (zeroknots.eth)
 * @custom:security-contact security@uniswap.org
 * @notice The Compact is an ownerless ERC6909 contract that facilitates the voluntary
 * formation and mediation of reusable "resource locks." This interface contract specifies
 * external functions for making deposits, for performing allocated transfers and
 * withdrawals, for initiating and performing forced withdrawals, and for registering
 * compact claim hashes and typehashes directly. It also contains methods for registering
 * allocators and for enabling allocators to consume nonces directly. Finally, it specifies
 * a number of view functions, events and errors.
 */
interface ITheCompact {
    /**
     * @notice Event indicating that a claim has been processed for a given compact.
     * @param sponsor   The account sponsoring the claimed compact.
     * @param allocator The account mediating the resource locks utilized by the claim.
     * @param arbiter   The account verifying and initiating the settlement of the claim.
     * @param claimHash A bytes32 hash derived from the details of the claimed compact.
     * @param nonce     The nonce (scoped to the allocator) on the claimed compact.
     */
    event Claim(
        address indexed sponsor, address indexed allocator, address indexed arbiter, bytes32 claimHash, uint256 nonce
    );

    /**
     * @notice Event indicating that a nonce has been consumed directly.
     * @param allocator The account mediating the nonces.
     * @param nonce     The nonce (scoped to the allocator) in question.
     */
    event NonceConsumedDirectly(address indexed allocator, uint256 nonce);

    /**
     * @notice Event indicating a change in forced withdrawal status.
     * @param account        The account for which the withdrawal status has changed.
     * @param id             The ERC6909 token identifier of the associated resource lock.
     * @param activating     Whether the forced withdrawal is being activated or has been deactivated.
     * @param withdrawableAt The timestamp when tokens become withdrawable if it is being activated.
     */
    event ForcedWithdrawalStatusUpdated(
        address indexed account, uint256 indexed id, bool activating, uint256 withdrawableAt
    );

    /**
     * @notice Event indicating that a compact has been registered directly.
     * @param sponsor   The address registering the compact in question.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the registered compact.
     */
    event CompactRegistered(address indexed sponsor, bytes32 claimHash, bytes32 typehash);

    /**
     * @notice Event indicating that an emissary has been assigned for a given sponsor and lock tag.
     * @param sponsor  The address for which the emissary has been assigned.
     * @param lockTag  The lock tag for which the emissary has been assigned.
     * @param emissary The account of the emissary that has been assigned.
     */
    event EmissaryAssigned(address indexed sponsor, bytes12 indexed lockTag, address indexed emissary);

    /**
     * @notice Event indicating that a new emissary assignment has been scheduled for a given sponsor
     * and lock tag. Note that this is only required when a previous emissary has already been assigned
     * for the given combination of sponsor and lock tag.
     * @param sponsor      The address for which the emissary assignment has been scheduled.
     * @param lockTag      The lock tag for which the emissary assignment has been scheduled.
     * @param assignableAt The block timestamp at which a new emissary may be assigned.
     */
    event EmissaryAssignmentScheduled(address indexed sponsor, bytes12 indexed lockTag, uint256 assignableAt);

    /**
     * @notice Event indicating an allocator has been registered.
     * @param allocatorId The unique identifier assigned to the allocator.
     * @param allocator   The address of the registered allocator.
     */
    event AllocatorRegistered(uint96 allocatorId, address allocator);

    /**
     * @notice External payable function for depositing native tokens into a resource lock with
     * custom reset period and scope parameters. The ERC6909 token amount received by the recipient
     * will match the amount of native tokens sent with the transaction. Note that supplying the
     * null address for the recipient will result in the caller being applied as the recipient.
     * @param lockTag   The lock tag containing allocator ID, reset period, and scope.
     * @param recipient The address that will receive the corresponding ERC6909 tokens.
     * @return id       The ERC6909 token identifier of the associated resource lock.
     */
    function depositNative(bytes12 lockTag, address recipient) external payable returns (uint256 id);

    /**
     * @notice External function for depositing ERC20 tokens into a resource lock with custom reset
     * period and scope parameters. The caller must directly approve The Compact to transfer a
     * sufficient amount of the ERC20 token on its behalf. The ERC6909 token amount received by
     * the recipient is derived from the difference between the starting and ending balance held
     * in the resource lock, which may differ from the amount transferred depending on the
     * implementation details of the respective token.  Note that supplying the null address for
     * the recipient will result in the caller being applied as the recipient.
     * @param token     The address of the ERC20 token to deposit.
     * @param lockTag   The lock tag containing allocator ID, reset period, and scope.
     * @param amount    The amount of tokens to deposit.
     * @param recipient The address that will receive the corresponding ERC6909 tokens.
     * @return id       The ERC6909 token identifier of the associated resource lock.
     */
    function depositERC20(address token, bytes12 lockTag, uint256 amount, address recipient)
        external
        returns (uint256 id);

    /**
     * @notice External payable function for depositing multiple tokens in a single transaction.
     * The first entry in idsAndAmounts can optionally represent native tokens by providing the
     * null address and an amount matching msg.value. For ERC20 tokens, the caller must directly
     * approve The Compact to transfer sufficient amounts on its behalf. The ERC6909 token amounts
     * received by the recipient are derived from the differences between starting and ending
     * balances held in the resource locks, which may differ from the amounts transferred depending
     * on the implementation details of the respective tokens.  Note that supplying the null
     * address for the recipient will result in the caller being applied as the recipient.
     * @param idsAndAmounts Array of [id, amount] pairs indicating resource locks & amounts to deposit.
     * @param recipient     The address that will receive the corresponding ERC6909 tokens.
     * @return              Whether the batch deposit was successfully completed.
     */
    function batchDeposit(uint256[2][] calldata idsAndAmounts, address recipient) external payable returns (bool);

    /**
     * @notice External function for depositing ERC20 tokens using Permit2 authorization. The
     * depositor must approve Permit2 to transfer the tokens on its behalf unless the token in
     * question automatically grants approval to Permit2. The ERC6909 token amount received by the
     * recipient is derived from the difference between the starting and ending balance held
     * in the resource lock, which may differ from the amount transferred depending on the
     * implementation details of the respective token. The Permit2 authorization signed by the
     * depositor must contain a CompactDeposit witness containing the allocator, the reset period,
     * the scope, and the intended recipient of the deposit.
     * @param permit    The permit data signed by the depositor.
     * @param depositor The account signing the permit2 authorization and depositing the tokens.
     * @param lockTag   The lock tag containing allocator ID, reset period, and scope.
     * @param recipient The address that will receive the corresponding the ERC6909 tokens.
     * @param signature The Permit2 signature from the depositor authorizing the deposit.
     * @return id       The ERC6909 token identifier of the associated resource lock.
     */
    function depositERC20ViaPermit2(
        ISignatureTransfer.PermitTransferFrom calldata permit,
        address depositor,
        bytes12 lockTag,
        address recipient,
        bytes calldata signature
    ) external returns (uint256 id);

    /**
     * @notice External payable function for depositing multiple tokens using Permit2
     * authorization in a single transaction. The first token id can optionally represent native
     * tokens by providing the null address and an amount matching msg.value. The depositor must
     * approve Permit2 to transfer the tokens on its behalf unless the tokens automatically
     * grant approval to Permit2. The ERC6909 token amounts received by the recipient are derived
     * from the differences between starting and ending balances held in the resource locks,
     * which may differ from the amounts transferred depending on the implementation details of
     * the respective tokens. The Permit2 authorization signed by the depositor must contain a
     * CompactDeposit witness containing the allocator, the reset period, the scope, and the
     * intended recipient of the deposits.
     * @param depositor The account signing the permit2 authorization and depositing the tokens.
     * @param permitted The permit data signed by the depositor.
     * @param details   The details of the deposit.
     * @param recipient The address that will receive the corresponding ERC6909 tokens.
     * @param signature The Permit2 signature from the depositor authorizing the deposits.
     * @return ids      Array of ERC6909 token identifiers for the associated resource locks.
     */
    function batchDepositViaPermit2(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        DepositDetails calldata details,
        address recipient,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids);

    /**
     * @notice Transfers or withdraws ERC6909 tokens to multiple recipients with allocator approval.
     * @param transfer A Transfer struct containing the following:
     *  -  allocatorData Authorization signature from the allocator.
     *  -  nonce         Parameter enforcing replay protection, scoped to the allocator.
     *  -  expires       Timestamp after which the transfer cannot be executed.
     *  -  id            The ERC6909 token identifier of the resource lock.
     *  -  recipients    A Component array, each containing:
     *     -  claimant   The account that will receive tokens.
     *     -  amount     The amount of tokens the claimant will receive.
     * @return           Boolean indicating whether the transfer or withdrawal was successful.
     */
    function allocatedTransfer(AllocatedTransfer calldata transfer) external returns (bool);

    /**
     * @notice Transfers or withdraws ERC6909 tokens from multiple resource locks to multiple
     *         recipients with allocator approval.
     * @param transfer A BatchTransfer struct containing the following:
     *  -  allocatorData  Authorization signature from the allocator.
     *  -  nonce          Parameter enforcing replay protection, scoped to the allocator.
     *  -  expires        Timestamp after which the transfer cannot be executed.
     *  -  transfers      Array of ComponentsById, each containing:
     *     -  id          The ERC6909 token identifier of the resource lock.
     *     -  portions    A Component array, each containing:
     *        -  claimant The account that will receive tokens.
     *        -  amount   The amount of tokens the claimant will receive.
     * @return            Boolean indicating whether the transfer was successful.
     */
    function allocatedBatchTransfer(AllocatedBatchTransfer calldata transfer) external returns (bool);

    /**
     * @notice External function to register a claim hash and its associated EIP-712 typehash.
     * The registered claim hash will remain valid until the allocator consumes the nonce.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the registered claim hash.
     * @return          Boolean indicating whether the claim hash was successfully registered.
     */
    function register(bytes32 claimHash, bytes32 typehash) external returns (bool);

    /**
     * @notice External function to register multiple claim hashes and their associated EIP-712
     * typehashes in a single call. Each registered claim hash will remain valid until the allocator
     * consumes the nonce.
     * @param claimHashesAndTypehashes Array of [claimHash, typehash] pairs for registration.
     * @return                         Boolean indicating whether all claim hashes were successfully registered.
     */
    function registerMultiple(bytes32[2][] calldata claimHashesAndTypehashes) external returns (bool);

    /**
     * @notice Register a claim on behalf of a sponsor with their signature.
     * @param typehash         The EIP-712 typehash associated with the registered compact.
     * @param arbiter          The account tasked with verifying and submitting the claim.
     * @param sponsor          The address of the sponsor for whom the claim is being registered.
     * @param nonce            A parameter to enforce replay protection, scoped to allocator.
     * @param expires          The time at which the claim expires.
     * @param lockTag          The lock tag containing allocator ID, reset period, and scope.
     * @param token            The address of the token associated with the claim.
     * @param amount           The amount of tokens associated with the claim.
     * @param witness          Hash of the witness data.
     * @param sponsorSignature The signature from the sponsor authorizing the registration.
     * @return claimHash       Hash for verifying that the expected compact was registered.
     */
    function registerFor(
        bytes32 typehash,
        address arbiter,
        address sponsor,
        uint256 nonce,
        uint256 expires,
        bytes12 lockTag,
        address token,
        uint256 amount,
        bytes32 witness,
        bytes calldata sponsorSignature
    ) external returns (bytes32 claimHash);

    /**
     * @notice Register a batch claim on behalf of a sponsor with their signature.
     * @param typehash          The EIP-712 typehash associated with the registered compact.
     * @param arbiter           The account tasked with verifying and submitting the claim.
     * @param sponsor           The address of the sponsor for whom the claim is being registered.
     * @param nonce             A parameter to enforce replay protection, scoped to allocator.
     * @param expires           The time at which the claim expires.
     * @param idsAndAmountsHash Hash of array of [id, amount] pairs per resource lock.
     * @param witness           Hash of the witness data.
     * @param sponsorSignature  The signature from the sponsor authorizing the registration.
     * @return claimHash        Hash for verifying that the expected compact was registered.
     */
    function registerBatchFor(
        bytes32 typehash,
        address arbiter,
        address sponsor,
        uint256 nonce,
        uint256 expires,
        bytes32 idsAndAmountsHash,
        bytes32 witness,
        bytes calldata sponsorSignature
    ) external returns (bytes32 claimHash);

    /**
     * @notice Register a multichain claim on behalf of a sponsor with their signature.
     * @param typehash         The EIP-712 typehash associated with the registered compact.
     * @param sponsor          The address of the sponsor for whom the claim is being registered.
     * @param nonce            A parameter to enforce replay protection, scoped to allocator.
     * @param expires          The time at which the claim expires.
     * @param elementsHash     Hash of elements (arbiter, chainId, idsAndAmounts, & mandate) per chain.
     * @param notarizedChainId Chain ID of the domain used to sign the multichain compact.
     * @param sponsorSignature The signature from the sponsor authorizing the registration.
     * @return claimHash       Hash for verifying that the expected compact was registered.
     */
    function registerMultichainFor(
        bytes32 typehash,
        address sponsor,
        uint256 nonce,
        uint256 expires,
        bytes32 elementsHash,
        uint256 notarizedChainId,
        bytes calldata sponsorSignature
    ) external returns (bytes32 claimHash);

    /**
     * @notice External payable function for depositing native tokens into a resource lock
     * and simultaneously registering a compact. The allocator, the claim hash, and the typehash
     * used for the claim hash are provided as additional arguments, and the default reset period
     * (ten minutes) and scope (multichain) will be used for the resource lock. The ERC6909 token
     * amount received by the caller will match the amount of native tokens sent with the transaction.
     * @param lockTag   The lock tag containing allocator ID, reset period, and scope.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the registered compact.
     * @return id       The ERC6909 token identifier of the associated resource lock.
     */
    function depositNativeAndRegister(bytes12 lockTag, bytes32 claimHash, bytes32 typehash)
        external
        payable
        returns (uint256 id);

    /**
     * @notice External payable function for depositing native tokens and simultaneously registering a
     * compact on behalf of someone else. The amount of the claim must be explicitly provided otherwise
     * a wrong claim hash may be derived.
     * @param recipient  The recipient of the ERC6909 token.
     * @param lockTag    The lock tag containing allocator ID, reset period, and scope.
     * @param arbiter    The account tasked with verifying and submitting the claim.
     * @param nonce      A parameter to enforce replay protection, scoped to allocator.
     * @param expires    The time at which the claim expires.
     * @param typehash   The EIP-712 typehash associated with the registered compact.
     * @param witness    Hash of the witness data.
     * @return id        The ERC6909 token identifier of the associated resource lock.
     * @return claimHash Hash for verifying that the expected compact was registered.
     */
    function depositNativeAndRegisterFor(
        address recipient,
        bytes12 lockTag,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness
    ) external payable returns (uint256 id, bytes32 claimHash);

    /**
     * @notice External function for depositing ERC20 tokens and simultaneously registering a
     * compact. The default reset period (ten minutes) and scope (multichain) will be used. The
     * caller must directly approve The Compact to transfer a sufficient amount of the ERC20 token
     * on its behalf. The ERC6909 token amount received back by the caller is derived from the
     * difference between the starting and ending balance held in the resource lock, which may differ
     * from the amount transferred depending on the implementation details of the respective token.
     * @param token     The address of the ERC20 token to deposit.
     * @param lockTag   The lock tag containing allocator ID, reset period, and scope.
     * @param amount    The amount of tokens to deposit.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the registered compact.
     * @return id       The ERC6909 token identifier of the associated resource lock.
     */
    function depositERC20AndRegister(
        address token,
        bytes12 lockTag,
        uint256 amount,
        bytes32 claimHash,
        bytes32 typehash
    ) external returns (uint256 id);

    /**
     * @notice External function for depositing ERC20 tokens and simultaneously registering a
     * compact on behalf of someone else. The caller must directly approve The Compact to transfer
     * a sufficient amount of the ERC20 token on its behalf. The ERC6909 token amount received by
     * designated recipient the caller is derived from the difference between the starting and ending
     * balance held in the resource lock, which may differ from the amount transferred depending on
     * the implementation details of the respective token.
     * @dev The final ERC6909 token amounts will be substituted into the compact which will be
     * registered with the returned registeredAmount instead of the provided amount.
     * Ensure the claim is processed using either the registeredAmount or the ERC6909 transfer event.
     * This is especially important for fee-on-transfer tokens.
     * @param recipient         The recipient of the ERC6909 token.
     * @param token             The address of the ERC20 token to deposit.
     * @param lockTag           Lock tag containing allocator ID, reset period, & scope.
     * @param amount            The amount of tokens to deposit.
     * @param arbiter           The account tasked with verifying and submitting the claim.
     * @param nonce             A parameter to enforce replay protection, scoped to allocator.
     * @param expires           The time at which the claim expires.
     * @param typehash          The EIP-712 typehash associated with the registered compact.
     * @param witness           Hash of the witness data.
     * @return id               The ERC6909 token identifier of the associated resource lock.
     * @return claimHash        Hash for verifying that the expected compact was registered.
     * @return registeredAmount Final registered amount after potential transfer fees.
     */
    function depositERC20AndRegisterFor(
        address recipient,
        address token,
        bytes12 lockTag,
        uint256 amount,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness
    ) external returns (uint256 id, bytes32 claimHash, uint256 registeredAmount);

    /**
     * @notice External payable function for depositing multiple tokens in a single transaction
     * and registering a set of claim hashes. The first entry in idsAndAmounts can optionally
     * represent native tokens by providing the null address and an amount matching msg.value. For
     * ERC20 tokens, the caller must directly approve The Compact to transfer sufficient amounts
     * on its behalf. The ERC6909 token amounts received by the recipient are derived from the
     * differences between starting and ending balances held in the resource locks, which may
     * differ from the amounts transferred depending on the implementation details of the
     * respective tokens. Note that resource lock ids must be supplied in alphanumeric order.
     * @param idsAndAmounts            Array of [id, amount] pairs indicating resource locks & amounts to deposit.
     * @param claimHashesAndTypehashes Array of [claimHash, typehash] pairs for registration.
     * @return                         Boolean indicating whether the batch deposit & claim hash registration was successful.
     */
    function batchDepositAndRegisterMultiple(
        uint256[2][] calldata idsAndAmounts,
        bytes32[2][] calldata claimHashesAndTypehashes
    ) external payable returns (bool);

    /**
     * @notice External function for depositing ERC20 tokens and simultaneously registering a
     * batch compact on behalf of someone else. The caller must directly approve The Compact
     * to transfer a sufficient amount of the ERC20 token on its behalf. The ERC6909 token amount
     * received by designated recipient the caller is derived from the difference between the
     * starting and ending balance held in the resource lock, which may differ from the amount
     * transferred depending on the implementation details of the respective token.
     * @dev The final ERC6909 token amounts will be substituted into the compact which will be
     * registered with the returned registeredAmounts instead of the provided idsAndAmounts.
     * Ensure the claim is processed using either the registeredAmounts or the ERC6909 transfer events.
     * This is especially important for fee-on-transfer tokens.
     * @param recipient          The recipient of the ERC6909 token.
     * @param idsAndAmounts      Array of [id, amount] pairs indicating resource locks & amounts to deposit.
     * @param arbiter            The account tasked with verifying and submitting the claim.
     * @param nonce              A parameter to enforce replay protection, scoped to allocator.
     * @param expires            The time at which the claim expires.
     * @param typehash           The EIP-712 typehash associated with the registered compact.
     * @param witness            Hash of the witness data.
     * @return claimHash         Hash for verifying that the expected compact was registered.
     * @return registeredAmounts Array containing the final minted amount of each id.
     */
    function batchDepositAndRegisterFor(
        address recipient,
        uint256[2][] calldata idsAndAmounts,
        address arbiter,
        uint256 nonce,
        uint256 expires,
        bytes32 typehash,
        bytes32 witness
    ) external payable returns (bytes32 claimHash, uint256[] memory registeredAmounts);

    /**
     * @notice External function for depositing ERC20 tokens using Permit2 authorization and
     * registering a compact. The depositor must approve Permit2 to transfer the tokens on its
     * behalf unless the token in question automatically grants approval to Permit2. The ERC6909
     * token amount received by the depositor is derived from the difference between the starting
     * and ending balance held in the resource lock, which may differ from the amount transferred
     * depending on the implementation details of the respective token. The Permit2 authorization
     * signed by the depositor must contain an Activation witness containing the id of the resource
     * lock and an associated Compact, BatchCompact, or MultichainCompact payload matching the
     * specified compact category.
     * @param permit          The permit data signed by the depositor.
     * @param depositor       The account signing the permit2 authorization and depositing the tokens.
     * @param lockTag         The lock tag containing allocator ID, reset period, and scope.
     * @param claimHash       A bytes32 hash derived from the details of the compact.
     * @param compactCategory The category of the compact being registered (Compact, BatchCompact, or MultichainCompact).
     * @param witness         Additional data used in generating the claim hash.
     * @param signature       The Permit2 signature from the depositor authorizing the deposit.
     * @return id             The ERC6909 token identifier of the associated resource lock.
     */
    function depositERC20AndRegisterViaPermit2(
        ISignatureTransfer.PermitTransferFrom calldata permit,
        address depositor,
        bytes12 lockTag,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external returns (uint256 id);

    /**
     * @notice External payable function for depositing multiple tokens using Permit2
     * authorization and registering a compact in a single transaction. The first token id can
     * optionally represent native tokens by providing the null address and an amount matching
     * msg.value. The depositor must approve Permit2 to transfer the tokens on its behalf unless
     * the tokens automatically grant approval to Permit2. The ERC6909 token amounts received by
     * the depositor are derived from the differences between starting and ending balances held
     * in the resource locks, which may differ from the amounts transferred depending on the
     * implementation details of the respective tokens. The Permit2 authorization signed by the
     * depositor must contain a BatchActivation witness containing the ids of the resource locks
     * and an associated Compact, BatchCompact, or MultichainCompact payload matching the
     * specified compact category.
     * @param depositor       The account signing the permit2 authorization and depositing the tokens.
     * @param permitted       Array of token permissions specifying the deposited tokens and amounts.
     * @param details         The details of the deposit.
     * @param claimHash       A bytes32 hash derived from the details of the compact.
     * @param compactCategory The category of the compact being registered (Compact, BatchCompact, or MultichainCompact).
     * @param witness         Additional data used in generating the claim hash.
     * @param signature       The Permit2 signature from the depositor authorizing the deposits.
     * @return ids            Array of ERC6909 token identifiers for the associated resource locks.
     */
    function batchDepositAndRegisterViaPermit2(
        address depositor,
        ISignatureTransfer.TokenPermissions[] calldata permitted,
        DepositDetails calldata details,
        bytes32 claimHash,
        CompactCategory compactCategory,
        string calldata witness,
        bytes calldata signature
    ) external payable returns (uint256[] memory ids);

    /**
     * @notice External function to initiate a forced withdrawal for a resource lock. Once
     * enabled, forced withdrawals can be executed after the reset period has elapsed. The
     * withdrawableAt timestamp returned will be the current timestamp plus the reset period
     * associated with the resource lock.
     * @param id              The ERC6909 token identifier for the resource lock.
     * @return withdrawableAt The timestamp at which tokens become withdrawable.
     */
    function enableForcedWithdrawal(uint256 id) external returns (uint256 withdrawableAt);

    /**
     * @notice External function to disable a previously enabled forced withdrawal for a
     * resource lock.
     * @param id The ERC6909 token identifier for the resource lock.
     * @return   Boolean indicating whether the forced withdrawal was successfully disabled.
     */
    function disableForcedWithdrawal(uint256 id) external returns (bool);

    /**
     * @notice External function to execute a forced withdrawal from a resource lock after the
     * reset period has elapsed. The tokens will be withdrawn to the specified recipient in the
     * amount requested. The ERC6909 token balance of the caller will be reduced by the
     * difference in the balance held by the resource lock before and after the withdrawal,
     * which may differ from the provided amount depending on the underlying token in question.
     * @param id        The ERC6909 token identifier for the resource lock.
     * @param recipient The account that will receive the withdrawn tokens.
     * @param amount    The amount of tokens to withdraw.
     * @return          Boolean indicating whether the forced withdrawal was successfully executed.
     */
    function forcedWithdrawal(uint256 id, address recipient, uint256 amount) external returns (bool);

    /**
     * @notice Assigns an emissary for the caller that has authority to authorize claims where that
     * caller is the sponsor. The emissary will utilize a reset period dictated by the reset period
     * on the provided lock tag that blocks reassignment of the emissary for the duration of that
     * reset period. The reset period ensures that once an emissary is assigned, another assignment
     * cannot be made until the reset period has elapsed.
     * @param lockTag  The lockTag the emissary will be assigned for.
     * @param emissary The emissary to assign for the given caller and lock tag.
     * @return         Boolean indicating whether the assignment was successful.
     */
    function assignEmissary(bytes12 lockTag, address emissary) external returns (bool);

    /**
     * @notice Schedules a future emissary assignment for a specific lock tag. The reset period on
     * the lock tag determines how long reassignment will be blocked after this assignment. This
     * allows for a delay before the next assignment can be made. Note that the reset period of the
     * current emissary (if set) will dictate when the next assignment will be allowed.
     * @param lockTag                        The lockTag the emissary assignment is scheduled for.
     * @return emissaryAssignmentAvailableAt The timestamp when the next assignment will be allowed.
     */
    function scheduleEmissaryAssignment(bytes12 lockTag) external returns (uint256 emissaryAssignmentAvailableAt);

    /**
     * @notice External function for consuming allocator nonces. Only callable by a registered
     * allocator. Once consumed, any compact payloads that utilize those nonces cannot be claimed.
     * @param nonces Array of nonces to be consumed.
     * @return       Boolean indicating whether all nonces were successfully consumed.
     */
    function consume(uint256[] calldata nonces) external returns (bool);

    /**
     * @notice External function for registering an allocator. Can be called by anyone if one
     * of three conditions is met: the caller is the allocator address being registered, the
     * allocator address contains code, or a proof is supplied representing valid create2
     * deployment parameters that resolve to the supplied allocator address.
     * @param allocator    The address to register as an allocator.
     * @param proof        An 85-byte value containing create2 address derivation parameters (0xff ++ factory ++ salt ++ initcode hash).
     * @return allocatorId A unique identifier assigned to the registered allocator.
     */
    function __registerAllocator(address allocator, bytes calldata proof) external returns (uint96 allocatorId);

    /**
     * @notice External function to benchmark withdrawal costs to determine the required stipend
     * on the fallback for failing withdrawals when processing claims. The salt is used to derive
     * a cold account to benchmark the native token withdrawal. Note that exactly 2 wei must be
     * provided when calling this function, and that the provided wei will be irrecoverable.
     * @param salt A bytes32 value used to derive a cold account for benchmarking.
     */
    function __benchmark(bytes32 salt) external payable;

    /**
     * @notice External view function for retrieving the details of a resource lock. Returns the
     * underlying token, the mediating allocator, the reset period, and the scope.
     * @param id           The ERC6909 token identifier of the resource lock.
     * @return token       The address of the underlying token (or address(0) for native tokens).
     * @return allocator   The account of the allocator mediating the resource lock.
     * @return resetPeriod The duration after which the resource lock can be reset once a forced withdrawal is initiated.
     * @return scope       The scope of the resource lock (multichain or single chain).
     * @return lockTag     The lock tag containing the allocator ID, the reset period, and the scope.
     */
    function getLockDetails(uint256 id)
        external
        view
        returns (address token, address allocator, ResetPeriod resetPeriod, Scope scope, bytes12 lockTag);

    /**
     * @notice External view function for checking the registration status of a compact. Returns
     * both whether the claim hash is currently active and when it was registered (if relevant).
     * Note that an "active" compact may in fact not be claimable, (e.g. it has expired, the
     * nonce has been consumed, etc).
     * @param sponsor   The account that registered the compact.
     * @param claimHash A bytes32 hash derived from the details of the compact.
     * @param typehash  The EIP-712 typehash associated with the registered claim hash.
     * @return isActive Boolean indicating whether the compact registration is currently active.
     */
    function isRegistered(address sponsor, bytes32 claimHash, bytes32 typehash) external view returns (bool isActive);

    /**
     * @notice External view function for checking the forced withdrawal status of a resource
     * lock for a given account. Returns both the current status (disabled, pending, or enabled)
     * and the timestamp at which forced withdrawals will be enabled (if status is pending) or
     * became enabled (if status is enabled).
     * @param account                      The account to get the forced withdrawal status for.
     * @param id                           The ERC6909 token identifier of the resource lock.
     * @return status                      The current ForcedWithdrawalStatus (disabled, pending, or enabled).
     * @return forcedWithdrawalAvailableAt The timestamp at which tokens become withdrawable if status is pending.
     */
    function getForcedWithdrawalStatus(address account, uint256 id)
        external
        view
        returns (ForcedWithdrawalStatus status, uint256 forcedWithdrawalAvailableAt);

    /**
     * @notice Gets the current emissary status for an allocator. Returns the current status,
     * the timestamp when reassignment will be allowed again (based on reset period), and
     * the currently assigned emissary (if any).
     * @param sponsor                        The address of the sponsor to check.
     * @param lockTag                        The lockTag to check.
     * @return status                        The current emissary assignment status.
     * @return emissaryAssignmentAvailableAt The timestamp when reassignment will be allowed.
     * @return currentEmissary               The currently assigned emissary address (or zero address if none).
     */
    function getEmissaryStatus(address sponsor, bytes12 lockTag)
        external
        view
        returns (EmissaryStatus status, uint256 emissaryAssignmentAvailableAt, address currentEmissary);

    /**
     * @notice External view function for checking whether a specific nonce has been consumed by
     * an allocator. Once consumed, a nonce cannot be reused for claims mediated by that allocator.
     * @param nonce     The nonce to check.
     * @param allocator The account of the allocator.
     * @return consumed Boolean indicating whether the nonce has been consumed.
     */
    function hasConsumedAllocatorNonce(uint256 nonce, address allocator) external view returns (bool consumed);

    /**
     * @notice External view function for getting required stipends for releasing tokens as a
     * fallback on claims where withdrawals do not succeed. Any requested withdrawal is first
     * attempted using half of available gas. If it fails, then a direct 6909 transfer will be
     * performed as long as the remaining gas left exceeds the benchmarked stipend.
     * @return nativeTokenStipend The gas stipend required for native token withdrawals.
     * @return erc20TokenStipend  The gas stipend required for ERC20 token withdrawals.
     */
    function getRequiredWithdrawalFallbackStipends()
        external
        view
        returns (uint256 nativeTokenStipend, uint256 erc20TokenStipend);

    /**
     * @notice External view function for returning the domain separator of the contract.
     * @return domainSeparator A bytes32 representing the domain separator for the contract.
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    /**
     * @notice External pure function for returning the name of the contract.
     * @return A string representing the name of the contract.
     */
    function name() external pure returns (string memory);

    error InvalidToken(address token);
    error Expired(uint256 expiration);
    error InvalidSignature();
    error PrematureWithdrawal(uint256 id);
    error ForcedWithdrawalFailed();
    error ForcedWithdrawalAlreadyDisabled(address account, uint256 id);
    error UnallocatedTransfer(address operator, address from, address to, uint256 id, uint256 amount);
    error InvalidBatchAllocation();
    error InvalidRegistrationProof(address allocator);
    error InvalidBatchDepositStructure();
    error AllocatedAmountExceeded(uint256 allocatedAmount, uint256 providedAmount);
    error InvalidScope(uint256 id);
    error InvalidDepositTokenOrdering();
    error InvalidDepositBalanceChange();
    error Permit2CallFailed();
    error ReentrantCall(address existingCaller);
    error InconsistentAllocators();
    error InvalidAllocation(address allocator);
    error ChainIndexOutOfRange();
    error InvalidEmissaryAssignment();
    error EmissaryAssignmentUnavailable(uint256 assignableAt);
    error InvalidLockTag();
}
