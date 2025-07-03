// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

interface IEmissary {
    /**
     * @notice Verify a claim. Called from The Compact as part of claim processing.
     * @param sponsor    The sponsor of the claim.
     * @param digest     The message digest representing the claim on the notarized chain.
     * @param claimHash  The message hash representing the claim.
     * @param signature  The signature to verify.
     * @param lockTag    The lock tag containing allocator ID, reset period, and scope.
     * @return           Must return the function selector (0xf699ba1c).
     */
    function verifyClaim(address sponsor, bytes32 digest, bytes32 claimHash, bytes calldata signature, bytes12 lockTag)
        external
        view
        returns (bytes4);
}
