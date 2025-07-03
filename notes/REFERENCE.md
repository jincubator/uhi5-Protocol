# Reference

## Reference Code Bases

- [x] Review Design from
  - [x] Euler
    - [x] https://github.com/euler-xyz/euler-swap
      - [x] https://github.com/euler-xyz/euler-swap/blob/master/src/UniswapHook.sol
    - [x] https://github.com/euler-xyz/reward-streams
    - [x] https://github.com/euler-xyz/euler-price-oracle
    - [x] https://github.com/euler-xyz/euler-vault-kit
    - [x] https://github.com/euler-xyz/liquidation-bot-v2
  - [x] Renzo
    - [x] https://github.com/Renzo-Protocol/foundational-hooks
      - [x] https://github.com/Renzo-Protocol/foundational-hooks/blob/main/src/RenzoStability.sol
      - [x] https://github.com/Renzo-Protocol/foundational-hooks/blob/main/src/PegStabilityHook.sol
    - [x] https://github.com/Renzo-Protocol/contracts-public
  - [x] Bunni - https://blog.bunni.xyz/posts/dawn-of-lp-profitability/
    - [x] https://github.com/Bunniapp/bunni-v2
      - [x] https://github.com/Bunniapp/bunni-v2/blob/main/src/BunniHook.sol
      - [x] https://github.com/Bunniapp/bunni-v2/blob/main/script/DeployHook.s.sol (Deployment using Create3)
      - [x] https://github.com/bunniapp/flood-contracts - Rebalancing
      - [x] https://deepwiki.com/Bunniapp/bunni-v2/8-developer-reference (Hooklet Librargy)
      - [x] https://github.com/Bunniapp/bunni-v2/tree/main/fuzz Fuzz Testing
      - [x] https://docs.bunni.xyz/docs/v2/concepts/rehypothecation
        - [x] https://docs.bunni.xyz/docs/v2/concepts/rebalancing
  - [x] Eigen Layer
    - [x] https://github.com/Layr-Labs/eigenlayer-contracts
  - [x] Aegis
    - [x] https://github.com/labs-solo/AEGIS_DFM
  - [x] Vivdex
    - [x] https://github.com/vixdex/vixdex

### SDK

- https://github.com/shuhuiluo/uniswap-v4-sdk-rs
- https://github.com/malik672/uniswap-sdk-core-rust
- https://deepwiki.com/Uniswap/sdks/5.2-universal-router-sdk
- https://github.com/Rollp0x/revm-trace

### Quoting

- https://github.com/Bunniapp/bunni-v2/blob/main/src/periphery/BunniQuoter.sol
- https://github.com/Uniswap/v4-periphery/blob/main/src/lens/V4Quoter.sol
- https://github.com/euler-xyz/euler-swap/blob/master/src/libraries/QuoteLib.sol

### Routing

- https://uniswapfoundation.mirror.xyz/mbmFs2lrKUrYyAmF7MPFFxPOl3sXBGdUNLQy7rm0LwM
  - https://github.com/z0r0z/v4-router - if only integrating with v4
- https://github.com/Uniswap/smart-order-router (old v3 version?) - Offchain calculating best price
- https://github.com/Uniswap/universal-router - better if building an aggregrator (also integrates with sea port)

### Compact X

- CompactX - https://github.com/uniswap/compactx https://deepwiki.com/Uniswap/CompactX
  - CompactX relies on several key services:
    - [Tribunal](https://github.com/Uniswap/Tribunal) - Settlement and cross-chain messaging (this implementation utilizes Hyperlane)
    - [Calibrator](https://github.com/Uniswap/Calibrator) - Intent parameterization service
    - [Autocator](https://autocator.org/) - Resource lock allocation service with signature / tx-based authentication
    - [Smallocator](https://github.com/Uniswap/Smallocator) - Resource lock allocation service with sign-in-based authentication
    - [Fillanthropist](https://github.com/Uniswap/Fillanthropist) - Manual filler / solver (meant as an illustrative example of how settlement works)
    - [Disseminator](https://github.com/Uniswap/disseminator) - disseminates intents to Fillanthropist as well as any connected websocket clients
  - https://deepwiki.com/Uniswap/the-compact/
  - https://deepwiki.com/Uniswap/arbiters
  - https://deepwiki.com/Uniswap/Tribunal
  - https://deepwiki.com/Uniswap/calibrator
  - https://deepwiki.com/Uniswap/autocator
  - https://deepwiki.com/Uniswap/smallocator
  - https://deepwiki.com/Uniswap/fillanthropist
  - https://deepwiki.com/Uniswap/sc-allocators/
  - https://deepwiki.com/Uniswap/disseminator
  - https://github.com/search?q=org%3AUniswap+TheCompact&type=code&p=1
  - https://docs.onebalance.io/getting-started/introduction
  - https://x.com/OneBalance_io/status/1861857226451009753

## References

- [Design Doc](https://www.notion.so/eavenetwork/UNI-COW-White-paper-20900e0a227980aa9b8bdf4b60ffbab0)
- [Whitpaper](https://www.overleaf.com/project/68238a45e5f229347a895c2c)
- [Docs](https://jincubator.com)
- [Template](./TEMPLATE.md)

## Debugging

Sample errors and signatures for Pool.sol used by

Looking for `0x31e30ad0`

```bash
cast sig "TicksMisordered(int24,int24)"
0xc4433ed5
cast sig "TickLowerOutOfBounds(int24)"
0xd5e2f7ab
cast sig "TickUpperOutOfBounds(int24)"
0x1ad777f8
cast sig "TickLiquidityOverflow(int24)"
0xb8e3c385
cast sig "PoolAlreadyInitialized()"
0x7983c051
cast sig "PoolNotInitialized()"
0x486aa307
cast sig "PriceLimitAlreadyExceeded(uint160, uint160)"
0x7c9c6e8f
cast sig "PriceLimitOutOfBounds(uint160)"
0x9e4d7cc7
cast sig "NoLiquidityToReceiveFees()"
0xa74f97ab
cast sig "InvalidFeeForExactOut()"
0x96206246

```

sample errors for UniswapRouter

Looking for `0xbfb22adf`

```bash
cast sig "V4TooLittleReceived(uint256,uint256)"
0x8b063d73
cast sig "V4TooMuchRequested(uint256,uint256)"
0x12bacdd3
cast sig "InputLengthMismatch()"
0xaaad13f7
cast sig "UnsupportedAction(uint256)"
0x5cda29d7cast sig "DeadlinePassed(uint256)"
0xbfb22adf
```
