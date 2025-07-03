# Scenarios

Gives an Overview of the Actors, Contracts and Scenarios for Jincubator.

## Actors

- Liquidity Provider: Provides Liquidity
- Swapper: Performs Swaps
- Solver: Finds Most Efficient Swaps
- Jincubator: Deploys UniswapHook and Liquidity Pools - may have privileged owner functions for prototyping.

### Contracts

- UniswapHook
- Pools
  - ETH/USD - Reference Pool
  - ETH/USD - Intent Pool using Uniswap Hook

### [The-compact](https://deepwiki.com/jincubator/the-compact)

- [Sponsors(depositors)](https://github.com/jincubator/the-compact?tab=readme-ov-file#sponsors-depositors): Sponsors own the underlying assets and create resource locks to make them available under specific conditions.
  - Swapper
  - Liquidity Provider
- [Arbiters](https://github.com/jincubator/the-compact?tab=readme-ov-file#arbiters--claimants-eg-fillers): Arbiters verify conditions and process claims.
- [Claimants(e.g. Fillers)](https://github.com/jincubator/the-compact?tab=readme-ov-file#arbiters--claimants-eg-fillers): Claimants are the recipients.
- [Relayers](https://github.com/jincubator/the-compact?tab=readme-ov-file#relayers): Relayers can perform certain interactions on behalf of sponsors and/or claimants.
- [Allocators (Infrastructure)](https://github.com/jincubator/the-compact?tab=readme-ov-file#allocators-infrastructure): Allocators are crucial infrastructure for ensuring resource lock integrity.
- [Emmisaries](https://github.com/jincubator/the-compact?tab=readme-ov-file#summary): Sponsors can also optionally assign an emissary to act as a fallback signer for authorizing claims against their compacts. This is particularly helpful for smart contract accounts or other scenarios where signing keys might change.

## Scenarios

### Protocol Deployment

### Liquidity Provisioning

1. Pool (providing tokens to a pool)
2. Pool Manager (providing tokens to the pool manager to be used dynamically)
3. Compact (to be used by Solvers for Swaps using Pools)
4. Compact (to be used by Solvers for Direct Swaps based on Price Oracle and Profit)

#### Pool

#### Yield Earning Vaults (ERC-4626)

#### Assets for Solving Intents

### Intent Swap - No LP Funds

1. Swapper creates Swap which creates a compact for the output tokens required (locks funds)
   1. Pricing comes from ....
2. Solver listens to the event calls simulate and finds the best price (a swap on a pool using Swappers Funds)
3. Solver gets exclusivity
4. Solver executes the swap using swappers funds and returning output tokens to swapper

### Intent Swap - LP funds

1. LP Provides funds for Solving to the-compact and permissions solver
2. Swapper creates Swap which creates a compact for the output tokens required (locks funds)
   1. Pricing comes from ....
3. Solver listens to the event calls simulate and finds the best price
   1. Option 1 - a swap on a pool using Swappers Funds
   2. Option 2 - a direct swap using LP's funds
4. Solver gets exclusivity
5. Solver executes the swap
   1. Option 1 - Using Swappers funds and returning tokens to swapper
   2. Option 2 - Using LP's funds and returning funds to the-compact
6. Settlement
   1. FastTrak
   2. Batch
7. Rebalancing
   1. Rebalancing Job

### Swap Vanilla

### Swap Booster

### Async Swap and then Solve (double spend)

1. Swapper creates a swap on Uniswap v4 Pool (Booster Pool or Vanilla Pool)
2. Input tokens are held based on Time Delay (say 10 blocks)
3. Intent is created by Solver locking LP funds for Input Token and Output Token Amount above - gas fees and profit %
   4a. Intent is executed (note this is outside of Pool, other option is to pass solve calldata to Pool and execute solve in Pool)
   1. LP deposits liquidity in the form of Output Token with intentId (CompactId)
   2. Deposited Output Tokens are given to the original swapper and Locked Input Tokens are given to the Solver
      4b. Intent is not executed and swap is attempted at time of deadline.

### Swap then Solve (lock funds and then double spend)

### Async Swap then Solve

### Swap and Solve (Pass Payload Data In)

### Compact Introduction.

### Swap Intent Based

Swap 1 ETH for max USDC on Unichain

1. Swap is created
   1. Locks ETH on PoolManager
   2. Create compact for Solver to use 1 ETH if they can provide $2470 USDC or more
   3. Emits event for Intent Creation
2. Solver provides Solution
   1. Accesses Funds (provide our own initially)
   2. Does Swap
   3. Proves have satisfied condition

### Cross Chain Swap

### ReHypothecation

### Liquidity Settlement
