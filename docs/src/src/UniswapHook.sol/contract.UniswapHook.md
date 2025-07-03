# UniswapHook
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/UniswapHook.sol)

**Inherits:**
[BaseHook](/src/base/BaseHook.sol/abstract.BaseHook.md)


## State Variables
### beforeSwapCount

```solidity
mapping(PoolId => uint256 count) public beforeSwapCount;
```


### afterSwapCount

```solidity
mapping(PoolId => uint256 count) public afterSwapCount;
```


### beforeAddLiquidityCount

```solidity
mapping(PoolId => uint256 count) public beforeAddLiquidityCount;
```


### beforeRemoveLiquidityCount

```solidity
mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;
```


## Functions
### constructor


```solidity
constructor(IPoolManager _poolManager) BaseHook(_poolManager);
```

### getHookPermissions


```solidity
function getHookPermissions() public pure override returns (Hooks.Permissions memory);
```

### _beforeSwap


```solidity
function _beforeSwap(address, PoolKey calldata key, SwapParams calldata, bytes calldata)
    internal
    override
    returns (bytes4, BeforeSwapDelta, uint24);
```

### _afterSwap


```solidity
function _afterSwap(address, PoolKey calldata key, SwapParams calldata, BalanceDelta, bytes calldata)
    internal
    override
    returns (bytes4, int128);
```

### _beforeAddLiquidity


```solidity
function _beforeAddLiquidity(address, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
    internal
    override
    returns (bytes4);
```

### _beforeRemoveLiquidity


```solidity
function _beforeRemoveLiquidity(address, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
    internal
    override
    returns (bytes4);
```

