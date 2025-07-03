# IntentSwap
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/types/IntentSwap.sol)


```solidity
struct IntentSwap {
    bytes32 salt;
    PoolId poolId;
    uint256 swapDeadline;
    uint256 solveDeadline;
    address swapper;
    SwapParams swapParams;
}
```

