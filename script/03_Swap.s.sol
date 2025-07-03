// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

import {BaseScript} from "./base/BaseScript.sol";
import {LiquidityHelpers} from "./base/LiquidityHelpers.sol";

contract SwapScript is BaseScript, LiquidityHelpers {
    /////////////////////////////////////
    // --- Configure These ---
    /////////////////////////////////////

    function run() external {
        PoolKey memory poolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: lpFee,
            tickSpacing: tickSpacing,
            hooks: hookContract // This must match the pool
        });
        bytes memory hookData = new bytes(0);

        vm.startBroadcast();

        // We'll approve both, just for testing.
        tokenApprovals();
        // token1.approve(address(swapRouter), type(uint256).max);
        // token0.approve(address(swapRouter), type(uint256).max);

        // uint256 ethToSwap = 1 ether;

        // Execute ETH to USDC swap
        swapRouter.swap{value: 1 ether}({
            amountSpecified: -1 ether, // Swap 1 ETH exact amount in.
            // amountIn: ethToSwap, // Swap 1 ETH
            amountLimit: 0, // Very bad, but we want to allow for unlimited price impact
            zeroForOne: true, // we are swapping token0(ETH) for token1 (USDC)
            poolKey: poolKey,
            hookData: hookData,
            // receiver: address(this),
            receiver: ourAddress,
            deadline: block.timestamp + 3600
        });

        // // Execute Token swap
        // swapRouter.swapExactTokensForTokens({
        //     amountIn: uint256(-ethToSwap), // Swap 1 ETH exact amount in.
        //     // amountIn: ethToSwap, // Swap 1 ETH
        //     amountOutMin: 0, // Very bad, but we want to allow for unlimited price impact
        //     zeroForOne: true, // we are swapping token0(ETH) for token1 (USDC)
        //     poolKey: poolKey,
        //     hookData: hookData,
        //     // receiver: address(this),
        //     receiver: ourAddress,
        //     deadline: block.timestamp + 1
        // });

        vm.stopBroadcast();
    }
}
