# Protocol

## Overview

Jincubator (working title) is an organization used for building out a project for [Uniswap Hook Incubator 5](https://atrium.academy/uniswap).
The majority of development is still being worked on in stealth mode using private repositories.
As this moves forward more content will become available on https://jincubator.com.

### Project Name: Jincubator

### Project Description

Jincubator (Working Name) provides infrastructure and services for multi-chain, intent-based protocols, leveraging hooks built on Uniswap V4.

It aims to provide the following

#### Pool Functionality

- JIT Liquidity Provisioning
- Dynamic Fees to reduce arbitrage
- Gas Manager allows users to pay for gas using their swap token instead of the native token
- Incentivization Tools for Pools to incentivize Liquidity Providers

#### Order Flow

Intent Solving infrastructure providing traders with the best value for their swap
SlowTrack and Fastrak - Settlement Options

#### Capital Efficiency

- Settlement Layer with Dynamic Rebalancing of Capital Across Chains
- JIT provisioning of liquidity to pools as needed which integrates with Yield Earning Protocols.
- Arbitraging Liquidity across Pools, Protocols, and Chains

### Team

Development is being lead by John Whitton, below are some handy links about him.

- [github](https://github.com/johnwhitton): Johns github profile
- [johnwhitton.com](https://johnwhitton.com): All about John, his work, writing, research etc.
- [My Resume](https://resume.johnwhitton.com): One-page resume in pdf format.
- [Overview](https://overview.johnwhitton.com): A little infographic of John's history
- [Writing](https://johnwhitton.com/posts.html) and [Research](https://johnwhitton.com/research.html): Some writing and research John has done (a little outdated)
- [Uniswap v4](https://github.com/johnwhitton/uhi5-exercises): Completed exercises and references for the Uniswap Hook Incubator

## Overview

## Design

## TODO

- [x] Review [Reference Code Bases](./REFERENCE.md)
- [x] Deploy Pool and Hook to Unichain Mainnet fork on anvil
  - [x] Update to latest v4-template
- [x] Create SWAP
  - [x] New Pool with UniswapHook
- [ ] Create Async Intent SWAP which uses V3 Pool
  - [ ] Take Input Token
  - [ ] Publish Event
  - [ ] Give Permission to Solver for Input Token
  - [ ] Solver Executes Solve
  - [ ] Provides Output Tokens to Swapper
- [ ] Update Quoting Functionality
  - [ ] Add price Oracle
  - [ ] Create Swap Request
  - [ ] Create Intent Request
- [ ] Create Asset Locking Functionality
- [ ] Add Intent Creation
- [ ] Add Intent Listener and Solver Logic
- [ ] Add Intent Execution
- [ ] Add JIT Provisioning (Rehypothecation)
- [ ] Add Booster Pool with Paymaster Functionality
- [ ] Multichain Swap from Ink to Op using Uniswap as the Hub
- [ ] Add AVS Functionality for Solver, Indexer and Oracle Updates
- [ ] Add Incentives Design with Flaunch for Initial Load
- [ ] Deploy to Mainnet (Unichain, Ink, Base)
- [ ] Incorporate https://github.com/Uniswap/briefcase
- [ ] Review testing approach
  - [ ] from https://github.com/euler-xyz/euler-vault-kit
  - [ ] https://github.com/axiom-crypto/axiom-v1-contracts/pull/4
  - [ ] from https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/.github/workflows/rust.yml
  - [ ] https://app.codecov.io/gh/hyperlane-xyz/hyperlane-monorepo/tree/main/solidity%2Fcontracts
- [ ] Update Router to use https://github.com/z0r0z/v4-router
- [ ] Create UHI5 Branch and Publish Loom and Deck

### Questions

[OpenZeppelin 6 questions to ask before writing a Uniswap v4 Hook](https://x.com/openzeppelin/status/1932441300550177122)

1. How many pools can call into this hook?
2. Does this hook initiate calls to the PoolManager?
3. Does this hook call modifyLiquidity?
4. Do the swap callbacks exhibit some kind of symmetry?
5. Does this hook support native tokens?
6. How is Access Control Implemented in Your Hook?

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
