// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { MultichainClaim, ExogenousMultichainClaim } from "../types/MultichainClaims.sol";

import { BatchMultichainClaim, ExogenousBatchMultichainClaim } from "../types/BatchMultichainClaims.sol";

/**
 * @title ClaimHashFunctionCastLib
 * @notice Library contract implementing function casts used throughout the codebase,
 * particularly as part of processing claims. The input function operates on a
 * function that takes some argument that differs from what is currently available.
 * The output function modifies one or more argument types so that they match the
 * arguments that are being used to call the function. Note that from the perspective
 * of the function being modified, the original type is still in force; great care
 * should be taken to preserve offsets and general structure between the two structs.
 */
library ClaimHashFunctionCastLib {
    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while treating it as a uint256
     * representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimHashAndTypehash`.
     * @return fnOut Modified function used in `ClaimHashLib._toMultichainClaimHashAndTypehash`.
     */
    function usingMultichainClaim(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (MultichainClaim calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaim calldata struct while treating
     * it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimHashAndTypehash`.
     * @return fnOut Modified function used in `ClaimHashLib._toExogenousMultichainClaimHashAndTypehash`.
     */
    function usingExogenousMultichainClaim(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (ExogenousMultichainClaim calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaim calldata struct while treating
     * it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericMultichainClaimHashAndTypehash`.
     * @return fnOut Modified function used in `ClaimHashLib._toBatchMultichainClaimHashAndTypehash`.
     */
    function usingBatchMultichainClaim(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (BatchMultichainClaim calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimHashLib._toGenericBatchMultichainClaimHashAndTypehash`.
     * @return fnOut Modified function used in `ClaimHashLib._toExogenousBatchMultichainClaimHashAndTypehash`.
     */
    function usingExogenousBatchMultichainClaim(
        function (uint256, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
            fnIn
    )
        internal
        pure
        returns (
            function (ExogenousBatchMultichainClaim calldata, uint256, function (uint256, uint256, bytes32, bytes32, uint256) internal view returns (bytes32)) internal view returns (bytes32, bytes32)
                fnOut
        )
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while treating it as a
     * uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `HashLib.toCommitmentsHashFromSingleLock`.
     * @return fnOut Modified function used in `ClaimHashLib._toMultichainClaimHashAndTypehash`.
     */
    function usingMultichainClaim(function (uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (MultichainClaim calldata) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide an ExogenousMultichainClaim calldata struct while treating it
     * as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `CHashLib.toCommitmentsHashFromSingleLock`.
     * @return fnOut Modified function used in `ClaimHashLib._toExogenousMultichainClaimHashAndTypehash`.
     */
    function usingExogenousMultichainClaim(function (uint256) internal pure returns (uint256) fnIn)
        internal
        pure
        returns (function (ExogenousMultichainClaim calldata) internal pure returns (uint256) fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}
