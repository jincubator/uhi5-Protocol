// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Scope } from "../types/Scope.sol";
import { ResetPeriod } from "../types/ResetPeriod.sol";

/**
 * @title EfficiencyLib
 * @notice Library contract implementing logic for efficient value comparisons,
 * conversions, typecasting, and sanitization. Also provides functions to prevent
 * the function specializer from being triggered when using static arguments.
 */
library EfficiencyLib {
    /**
     * @notice Internal view function to convert the provided account address to the caller if that
     *         address is the null address (0x0).
     * @dev    Uses bitwise operations to avoid branching, making this function more gas efficient
     *         than using a traditional if-else statement. The implementation follows the pattern
     *         `result = xor(a, mul(xor(a, b), condition))` which resolves to either a or b based
     *         on the condition; as the condition in this case is contingent on the first argument
     *         having a value of zero, the nested xor can safely be omitted.
     * @param  account               The address to check and potentially replace.
     * @return accountOrCallerIfNull The original address if non-zero, otherwise msg.sender.
     */
    function usingCallerIfNull(address account) internal view returns (address accountOrCallerIfNull) {
        assembly ("memory-safe") {
            accountOrCallerIfNull := xor(account, mul(caller(), iszero(account)))
        }
    }

    /**
     * @notice Internal pure function that performs a bitwise AND on two booleans.
     * Avoids Solidity's conditional evaluation of logical AND. Only safe when
     * inputs are known to be exactly 0 or 1 with no dirty bits.
     * @param a  The first boolean value.
     * @param b  The second boolean value.
     * @return c The result of the bitwise AND.
     */
    function and(bool a, bool b) internal pure returns (bool c) {
        assembly ("memory-safe") {
            c := and(a, b)
        }
    }

    /**
     * @notice Internal pure function that performs a bitwise OR on two booleans.
     * Avoids Solidity's conditional evaluation of logical OR. Only safe when
     * inputs are known to be exactly 0 or 1 with no dirty bits.
     * @param a  The first boolean value.
     * @param b  The second boolean value.
     * @return c The result of the bitwise OR.
     */
    function or(bool a, bool b) internal pure returns (bool c) {
        assembly ("memory-safe") {
            c := or(a, b)
        }
    }

    /**
     * @notice Internal pure function that sanitizes an address by clearing the
     * upper 96 bits. Used for ensuring consistent address handling.
     * @param accountValue The value to sanitize.
     * @return account     The sanitized address.
     */
    function asSanitizedAddress(uint256 accountValue) internal pure returns (address account) {
        assembly ("memory-safe") {
            account := shr(96, shl(96, accountValue))
        }
    }

    /**
     * @notice Internal pure function that checks if an address has its lower 160
     * bits set to zero.
     * @param account The address to check.
     * @return isNull Whether the address is null.
     */
    function isNullAddress(address account) internal pure returns (bool isNull) {
        assembly ("memory-safe") {
            isNull := iszero(shl(96, account))
        }
    }

    /**
     * @notice Internal pure function that converts a boolean to a uint256.
     * @param a  The boolean to convert.
     * @return b The resulting uint256.
     */
    function asUint256(bool a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that converts a uint96 to a uint256.
     * @param a  The uint96 to convert.
     * @return b The resulting uint256.
     */
    function asUint256(uint96 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that converts a bytes12 to a uint256.
     * @param a  The bytes12 to convert.
     * @return b The resulting uint256.
     */
    function asUint256(bytes12 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that converts a Scope enum to a uint256.
     * @param a  The Scope enum to convert.
     * @return b The resulting uint256.
     */
    function asUint256(Scope a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that converts an address to a uint256.
     * @param a  The address to convert.
     * @return b The resulting uint256.
     */
    function asUint256(address a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that converts a ResetPeriod enum to a uint256.
     * @param a  The ResetPeriod enum to convert.
     * @return b The resulting uint256.
     */
    function asUint256(ResetPeriod a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := a
        }
    }

    /**
     * @notice Internal pure function that prevents the function specializer from
     * optimizing uint256 arguments. XORs the value with calldatasize(), which
     * will always be non-zero in a real call.
     * @param a  The uint256 value to make stubborn.
     * @return b The original value, preventing specialization.
     */
    function asStubborn(uint256 a) internal pure returns (uint256 b) {
        assembly ("memory-safe") {
            b := or(iszero(calldatasize()), a)
        }
    }

    /**
     * @notice Internal pure function that prevents the function specializer from
     * inlining functions that take fixed boolean arguments. Since calldatasize()
     * will always be non-zero when making a standard function call, an OR
     * against iszero(calldatasize()) will always result in the original value.
     * @param a  The boolean value to make stubborn.
     * @return b The original value, preventing specialization.
     */
    function asStubborn(bool a) internal pure returns (bool b) {
        assembly ("memory-safe") {
            b := or(iszero(calldatasize()), a)
        }
    }
}
