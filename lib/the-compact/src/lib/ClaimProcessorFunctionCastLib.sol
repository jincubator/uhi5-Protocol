// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Claim } from "../types/Claims.sol";

import { BatchClaim } from "../types/BatchClaims.sol";

import { MultichainClaim, ExogenousMultichainClaim } from "../types/MultichainClaims.sol";

import { BatchMultichainClaim, ExogenousBatchMultichainClaim } from "../types/BatchMultichainClaims.sol";

/**
 * @title ClaimProcessorFunctionCastLib
 * @notice Library contract implementing function casts used in ClaimProcessorLogic.
 * The input function operates on a function that takes some argument that differs
 * from what is currently available. The output function modifies one or more
 * argument types so that they match the arguments that are being used to call the
 * function. Note that from the perspective of the function being modified, the
 * original type is still in force; great care should be taken to preserve offsets
 * and general structure between the two structs.
 */
library ClaimProcessorFunctionCastLib {
    /**
     * @notice Function cast to provide a Claim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processSimpleClaim`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processClaim`.
     */
    function usingClaim(function(bytes32, uint256, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, Claim calldata, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processSimpleBatchClaim`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processBatchClaim`.
     */
    function usingBatchClaim(function(bytes32, uint256, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, BatchClaim calldata, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a MultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processSimpleClaim`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processMultichainClaim`.
     */
    function usingMultichainClaim(function(bytes32, uint256, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, MultichainClaim calldata, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a BatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processSimpleBatchClaim`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processBatchMultichainClaim`.
     */
    function usingBatchMultichainClaim(function(bytes32, uint256, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, BatchMultichainClaim calldata, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processClaimWithSponsorDomain`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processExogenousMultichainClaim`.
     */
    function usingExogenousMultichainClaim(function(bytes32, uint256, bytes32, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, ExogenousMultichainClaim calldata, bytes32, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }

    /**
     * @notice Function cast to provide a ExogenousBatchMultichainClaim calldata struct while
     * treating it as a uint256 representing a calldata pointer location.
     * @param fnIn   Function pointer to `ClaimProcessorLib.processBatchClaimWithSponsorDomain`.
     * @return fnOut Modified function used in `ClaimProcessorLogic._processExogenousBatchMultichainClaim`.
     */
    function usingExogenousBatchMultichainClaim(function(bytes32, uint256, bytes32, bytes32, bytes32) internal fnIn)
        internal
        pure
        returns (function(bytes32, ExogenousBatchMultichainClaim calldata, bytes32, bytes32, bytes32) internal fnOut)
    {
        assembly ("memory-safe") {
            fnOut := fnIn
        }
    }
}
