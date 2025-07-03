// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { TheCompact } from "../../src/TheCompact.sol";
import { MockERC20 } from "../../lib/solady/test/utils/mocks/MockERC20.sol";
import { Compact, BatchCompact, Element } from "../../src/types/EIP712Types.sol";
import { ResetPeriod } from "../../src/types/ResetPeriod.sol";
import { Scope } from "../../src/types/Scope.sol";
import { CompactCategory } from "../../src/types/CompactCategory.sol";
import { DepositDetails } from "../../src/types/DepositDetails.sol";
import { ISignatureTransfer } from "permit2/src/interfaces/ISignatureTransfer.sol";

import { HashLib } from "../../src/lib/HashLib.sol";
import { IdLib } from "../../src/lib/IdLib.sol";

import { AlwaysOKAllocator } from "../../src/test/AlwaysOKAllocator.sol";
import { AlwaysOKEmissary } from "../../src/test/AlwaysOKEmissary.sol";
import { SimpleAllocator } from "../../src/examples/allocator/SimpleAllocator.sol";
import { QualifiedAllocator } from "../../src/examples/allocator/QualifiedAllocator.sol";

import { AllocatedTransfer, Claim } from "../../src/types/Claims.sol";
import { AllocatedBatchTransfer, BatchClaim } from "../../src/types/BatchClaims.sol";

import { MultichainClaim, ExogenousMultichainClaim } from "../../src/types/MultichainClaims.sol";

import { BatchMultichainClaim, ExogenousBatchMultichainClaim } from "../../src/types/BatchMultichainClaims.sol";

import { Component, TransferComponent, ComponentsById, BatchClaimComponent } from "../../src/types/Components.sol";

import { Setup } from "./Setup.sol";

import { CreateClaimHashWithWitnessArgs } from "./TestHelperStructs.sol";

contract TheCompactTest is Setup {
    using IdLib for uint96;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_name() public view {
        string memory name = theCompact.name();
        assertEq(keccak256(bytes(name)), keccak256(bytes("The Compact")));
    }

    function test_domainSeparator() public view {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                compactEIP712DomainHash,
                keccak256(bytes("The Compact")),
                keccak256(bytes("1")),
                block.chainid,
                address(theCompact)
            )
        );
        assertEq(domainSeparator, theCompact.DOMAIN_SEPARATOR());
    }

    function test_domainSeparatorOnNewChain() public {
        uint256 currentChainId = block.chainid;
        uint256 differentChainId = currentChainId + 42;
        bytes32 domainSeparator = keccak256(
            abi.encode(
                compactEIP712DomainHash,
                keccak256(bytes("The Compact")),
                keccak256(bytes("1")),
                differentChainId,
                address(theCompact)
            )
        );
        vm.chainId(differentChainId);
        assertEq(block.chainid, differentChainId);
        assertEq(domainSeparator, theCompact.DOMAIN_SEPARATOR());
        vm.chainId(currentChainId);
        assertEq(block.chainid, currentChainId);
    }

    function test_standardTransfer() public {
        address recipient = 0x1111111111111111111111111111111111111111;
        uint256 amount = 1e18;

        (, bytes12 lockTag) = _registerAllocator(alwaysOKAllocator);

        uint256 id = _makeDeposit(swapper, amount, lockTag);

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(swapper, id), amount);
        assertEq(theCompact.balanceOf(recipient, id), 0);

        vm.prank(swapper);
        bool status = theCompact.transfer(recipient, id, amount);
        assert(status);

        assertEq(address(theCompact).balance, amount);
        assertEq(theCompact.balanceOf(swapper, id), 0);
        assertEq(theCompact.balanceOf(recipient, id), amount);
    }

    function test_allocatorId_leadingZeroes() public pure {
        address allocator1 = address(0x00000000000018DF021Ff2467dF97ff846E09f48);
        uint8 compactFlag1 = IdLib.toCompactFlag(allocator1);
        assertEq(compactFlag1, 9);

        address allocator2 = address(0x0000000000000000000000000000000000000000);
        uint8 compactFlag2 = IdLib.toCompactFlag(allocator2);
        assertEq(compactFlag2, 15);

        address allocator3 = address(0x0009524d380Dd4D95dfB975C50DaF3343BC177D9);
        uint8 compactFlag3 = IdLib.toCompactFlag(allocator3);
        assertEq(compactFlag3, 0);

        address allocator4 = address(0x00002752B69c388ac734CF666fB335588AE92618);
        uint8 compactFlag4 = IdLib.toCompactFlag(allocator4);
        assertEq(compactFlag4, 1);
    }

    function test_fuzz_addressToCompactFlag(address a) public pure {
        uint256 leadingZeroes = _countLeadingZeroes(a);
        uint8 compactFlag = IdLib.toCompactFlag(a);

        /**
         * The full scoring formula is:
         *  - 0-3 leading zero nibbles: 0
         *  - 4-17 leading zero nibbles: number of leading zeros minus 3
         *  - 18+ leading zero nibbles: 15
         */
        if (leadingZeroes < 4) assertEq(compactFlag, 0);
        else if (leadingZeroes <= 18) assertEq(compactFlag, leadingZeroes - 3);
        else assertEq(compactFlag, 15);
    }

    function test_concrete_addressToCompactFlag() public pure {
        address a = address(0x8000000000000000000000000000000000000000);
        uint256 leadingZeroes = _countLeadingZeroes(a);
        assertEq(leadingZeroes, 0);
        uint8 compactFlag = IdLib.toCompactFlag(a);
        assertEq(compactFlag, 0);
    }

    function test_countLeadingZeroes() public pure {
        address addr1 = 0x8000000000000000000000000000000000000000;
        assert(_countLeadingZeroes(addr1) == 0); // Should have 0 leading zeros

        address addr2 = 0x0800000000000000000000000000000000000000;
        assert(_countLeadingZeroes(addr2) == 1); // Should have 1 leading zero

        address addr3 = 0x0000000000000000000000000000000000000001;
        assert(_countLeadingZeroes(addr3) == 39); // Should have 39 leading zeros
    }
}
