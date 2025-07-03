# Protocol

## Overview

Jincubator IntentSwapHook allows swaps to be created with a delay period before execution, enabling solvers to find a more efficient trade and provide higher-return tokens to the swapper.

## Design

### Actors

1. Liquidity Providers(LP): Provides Liquidity in one of 3 Forms
   1. Liquidity Provided to a specific Pool
   2. Liquidity Provided for general use by Solvers in Pools
   3. Liquidity Provided for general use by Solvers in intent swaps
2. Swappers: Requests swaps on a pool
3. Solvers: Find the most effective swap for solvers
4. Off Chain Worker (OCW): Responsible for monitoring IntentSwap Deadlines and closing open intents.

For simplicity for UHI5 the Liquidity Provider and Solver will be the same.
See Future work for the additional roles used in the Intent Management System.

## Process Flow

Here we will walk through a sample swap for 1 ETH to USDC.
The profits are likely exaggerated for ease of understanding.
Fees are illustrative and can be configured in the protocol

In this example the pool offers a return of $2400 USDC for 1 ETH.
The solver finds a more efficient trade returning $2450 USDC for 0.9 ETH.
The solver executes the trade (using LP funds and incurring gas costs).
The solver then sends $2450 to the pool (also incurring gas costs).
The pool sends the $2450 to the swapper (improving their return on their trade).
The pool sends 1 ETH to the solver (making them a profit of 0.1 ETH minus gas costs)
The solver returns the 0.9045 ETH to the LP = original 0.9 ETH plus 0.0045 ETH (an LP fee of 0.5% of 0.9 ETH)
The solver makes 0.0955 ETH Profit = 1 ETH - 0.0955 ETH (minus gas costs)

If no solver submits a more efficient trade by the deadline the Off Chain Worker (OCW)attempts to execute trade on the pool.
If successful $2400 USDC is distributed to the swapper.
If unsuccessful (e.g. due to slippage) the 1 ETH is unlocked and returned to the swapper.

If the deadline passes with no trade being executed the swapper the 1 ETH is unlocked and returned to the swapper.

### Intent Swap Flow

For simplicity for UHI5 we will only look at Exact In Swaps

1. Swapper requests a swap on Pool specifying
   1. Exact Amount In of Input Token
   2. Expected Amount out of Output Token
   3. Slippage Amount Allowed
   4. Deadline (optional) for solvers to find a more efficient trade
   5. Solver Deadline (optional) calculated from Deadline - X is the time when the OCW can close the trade if no more efficient trade has been found by solvers.
2. The Pool via the IntentSwapHook
   1. Creates An IntentSwapHash that is used to track this trade
   2. Marks the IntentSwap as Open
   3. Creates an IntentSwapCreated event notifying solvers of the opportunity and OffChain Worker of IntentSwap and Deadline
3. Solver finds a more efficient trade and executes the trade
4. Solver calls Provide Liquidity for the Output Token
   1. Current Tick is specified
   2. IntentSwapHash is specified - notifying the Pool which IntentSwap the funds are for
   3. TokenAmount is specified (must be greater than the Expected Amount - Slippage Amount)
5. The Pool via the IntentSwapHook
   1. Checks the IntentSwap is Open
   2. Checks the Funds provided are greater than the Expected Amount - Slippage Amount
   3. Sends the Output Tokens to the Swapper
   4. Sends the Input Tokens to the Solver
   5. Creates an IntentSwapClosed event notifying the OffChainWork
6. Off Chain Worker(OCW) closes IntentSwap (if no more efficient trade was found by solver)
   1. OCW - monitors open intents whose solver deadline has expired
   2. Calls Swap specifying IntentSwapHash
7. The Pool via the IntentSwapHook
   1. Checks the IntentSwap is Open
   2. Checks the Solver Deadline has expired
   3. Checks the Deadline has not expired
   4. Attempts to execute the swap

## Key Concepts

For the initial submission for UHI5

1. Intent Swaps are only valid for Exact In Swaps.
2. Swap Deadline is specified on the trade (an example may be 10 seconds)
3. If no swap deadline is specified then the trade is just a regular swap (i.e. solvers do not get an opportunity to find a more efficient trade)
4. Solver Deadline is calculated from the Swap Deadline minus a configurable time period.
5. Solver needs to execute the trade and send the funds to the pool before the deadline in order to claim the output tokens.
6. Off Chain Worker (OCW) is responsible for monitoring open IntentSwaps and executing them after the SolverDeadline has passed.

## Key concepts

## Future Work

See [Future Work](./FUTURE-WORK.md)

### Get Started

### Requirements

The protocol is designed to work with Foundry (stable). If you are using Foundry Nightly, you may encounter compatibility issues. You can update your Foundry installation to the latest stable version by running:

```
foundryup
```

**Installation**
To set up the project, run the following commands in your terminal to install dependencies and run the tests:

```bash
forge install
forge test
```

**Coverage reporting**

```bash
forge coverage
```

**Documentation**

Private deepwiki is [here](https://app.devin.ai/wiki/jincubator/protocol).

To generate forge docs use

```bash
forge doc --serve --port 4000
```

### Local Development

Other than writing unit tests (recommended!), you can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/) locally. Scripts are available in the `script/` directory, which can be used to deploy hooks, create pools, provide liquidity and swap tokens. The scripts support both local `anvil` environment as well as running them directly on a production network.

**Local Testing on Anvil**

**Run Anvil in window 1**

```bash
# Local run of anvil
anvil
```

or if running a unichain fork

```bash
# Local fork of unichain
# set $UNICHAIN_RPC_URL to alchemy or another unichain provider and
source .env
# Run anvil fok of UNICHAIN
anvil --fork-url $UNICHAIN_RPC_URL --fork-block-number 19949655

# in a separate window provision USDC to our account
# We transfer frund from a whale account to us
# we use the --fork-block-number above to ensure the whale has USDC
./script/bash/fund_usdc_unichain.sh
```

** Deploy Hook, Create and Initialize Pool, Provide Liquidity and do swap**
Note for local testing we will be prompted for our private-key and we use Anvil's account 0 default `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`

```bash
# set environment variables
source .env

# Deploy UniswapHook
forge script --chain unichain script/00_DeployHook.s.sol --rpc-url $RPC_URL --broadcast  -vvvv --interactives 1

# Create Pool and add Liquidity
forge script --chain unichain script/01_CreatePoolAndAddLiquidity.s.sol --rpc-url $RPC_URL --broadcast  -vvvv --interactives 1

# Perform a swap
forge script --chain unichain script/03_Swap.s.sol --rpc-url $RPC_URL --broadcast  -vvvv --interactives 1

```

**Local testing on Anvil fork of Unichain**

**Deploying and Testing on Testnet**

**Deploying and testing on Mainnet**
