# BaseHook
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/base/BaseHook.sol)

**Inherits:**
[IBaseHook](/src/interfaces/IBaseHook.sol/interface.IBaseHook.md)

*Base hook implementation.
This contract defines all hook entry points, as well as security and permission helpers.
Based on the https://github.com/Uniswap/v4-periphery/blob/main/src/base/hooks/BaseHook.sol[Uniswap v4 periphery implementation].
NOTE: Hook entry points must be overiden and implemented by the inheriting hook to be used. Their respective
flags must be set to true in the `getHookPermissions` function as well.
WARNING: This is experimental software and is provided on an "as is" and "as available" basis. We do
not give any warranties and will not be liable for any losses incurred through any use of this code
base.
_Available since v0.1.0_*


## State Variables
### poolManager

```solidity
IPoolManager public immutable poolManager;
```


## Functions
### constructor

*Set the pool manager and check that the hook address matches the expected permissions and flags.*


```solidity
constructor(IPoolManager _poolManager);
```

### onlyPoolManager

Only allow calls from the `PoolManager` contract


```solidity
modifier onlyPoolManager();
```

### onlySelf

*Restrict the function to only be callable by the hook itself.*


```solidity
modifier onlySelf();
```

### onlyValidPools

*Restrict the function to only be called for a valid pool.*


```solidity
modifier onlyValidPools(IBaseHook hooks);
```

### getHookPermissions

*Get the hook permissions to signal which hook functions are to be implemented.
Used at deployment to validate the address correctly represents the expected permissions.*


```solidity
function getHookPermissions() public pure virtual returns (Hooks.Permissions memory permissions);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`permissions`|`Hooks.Permissions`|The hook permissions.|


### validateHookAddress

*Validate the hook address against the expected permissions.*


```solidity
function validateHookAddress(BaseHook hook) internal pure;
```

### beforeInitialize

The hook called before the state of a pool is initialized


```solidity
function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96)
    external
    virtual
    onlyPoolManager
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the initialize call|
|`key`|`PoolKey`|The key for the pool being initialized|
|`sqrtPriceX96`|`uint160`|The sqrt(price) of the pool as a Q64.96|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _beforeInitialize

*Hook implementation for `beforeInitialize`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _beforeInitialize(address, PoolKey calldata, uint160) internal virtual returns (bytes4);
```

### afterInitialize

The hook called after the state of a pool is initialized


```solidity
function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick)
    external
    virtual
    onlyPoolManager
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the initialize call|
|`key`|`PoolKey`|The key for the pool being initialized|
|`sqrtPriceX96`|`uint160`|The sqrt(price) of the pool as a Q64.96|
|`tick`|`int24`|The current tick after the state of a pool is initialized|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _afterInitialize

*Hook implementation for `afterInitialize`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _afterInitialize(address, PoolKey calldata, uint160, int24) internal virtual returns (bytes4);
```

### beforeAddLiquidity

The hook called before liquidity is added


```solidity
function beforeAddLiquidity(
    address sender,
    PoolKey calldata key,
    ModifyLiquidityParams calldata params,
    bytes calldata hookData
) external virtual onlyPoolManager returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the add liquidity call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`ModifyLiquidityParams`|The parameters for adding liquidity|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the liquidity provider to be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _beforeAddLiquidity

*Hook implementation for `beforeAddLiquidity`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _beforeAddLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
    internal
    virtual
    returns (bytes4);
```

### beforeRemoveLiquidity

The hook called before liquidity is removed


```solidity
function beforeRemoveLiquidity(
    address sender,
    PoolKey calldata key,
    ModifyLiquidityParams calldata params,
    bytes calldata hookData
) external virtual onlyPoolManager returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the remove liquidity call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`ModifyLiquidityParams`|The parameters for removing liquidity|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the liquidity provider to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _beforeRemoveLiquidity

*Hook implementation for `beforeRemoveLiquidity`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _beforeRemoveLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
    internal
    virtual
    returns (bytes4);
```

### afterAddLiquidity

The hook called after liquidity is added


```solidity
function afterAddLiquidity(
    address sender,
    PoolKey calldata key,
    ModifyLiquidityParams calldata params,
    BalanceDelta delta0,
    BalanceDelta delta1,
    bytes calldata hookData
) external virtual onlyPoolManager returns (bytes4, BalanceDelta);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the add liquidity call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`ModifyLiquidityParams`|The parameters for adding liquidity|
|`delta0`|`BalanceDelta`||
|`delta1`|`BalanceDelta`||
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the liquidity provider to be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|
|`<none>`|`BalanceDelta`|BalanceDelta The hook's delta in token0 and token1. Positive: the hook is owed/took currency, negative: the hook owes/sent currency|


### _afterAddLiquidity

*Hook implementation for `afterAddLiquidity`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _afterAddLiquidity(
    address,
    PoolKey calldata,
    ModifyLiquidityParams calldata,
    BalanceDelta,
    BalanceDelta,
    bytes calldata
) internal virtual returns (bytes4, BalanceDelta);
```

### afterRemoveLiquidity

The hook called after liquidity is removed


```solidity
function afterRemoveLiquidity(
    address sender,
    PoolKey calldata key,
    ModifyLiquidityParams calldata params,
    BalanceDelta delta0,
    BalanceDelta delta1,
    bytes calldata hookData
) external virtual onlyPoolManager returns (bytes4, BalanceDelta);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the remove liquidity call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`ModifyLiquidityParams`|The parameters for removing liquidity|
|`delta0`|`BalanceDelta`||
|`delta1`|`BalanceDelta`||
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the liquidity provider to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|
|`<none>`|`BalanceDelta`|BalanceDelta The hook's delta in token0 and token1. Positive: the hook is owed/took currency, negative: the hook owes/sent currency|


### _afterRemoveLiquidity

*Hook implementation for `afterRemoveLiquidity`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _afterRemoveLiquidity(
    address,
    PoolKey calldata,
    ModifyLiquidityParams calldata,
    BalanceDelta,
    BalanceDelta,
    bytes calldata
) internal virtual returns (bytes4, BalanceDelta);
```

### beforeSwap

The hook called before a swap


```solidity
function beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
    external
    virtual
    onlyPoolManager
    returns (bytes4, BeforeSwapDelta, uint24);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the swap call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`SwapParams`|The parameters for the swap|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the swapper to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|
|`<none>`|`BeforeSwapDelta`|BeforeSwapDelta The hook's delta in specified and unspecified currencies. Positive: the hook is owed/took currency, negative: the hook owes/sent currency|
|`<none>`|`uint24`|uint24 Optionally override the lp fee, only used if three conditions are met: 1. the Pool has a dynamic fee, 2. the value's 2nd highest bit is set (23rd bit, 0x400000), and 3. the value is less than or equal to the maximum fee (1 million)|


### _beforeSwap

*Hook implementation for `beforeSwap`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _beforeSwap(address, PoolKey calldata, SwapParams calldata, bytes calldata)
    internal
    virtual
    returns (bytes4, BeforeSwapDelta, uint24);
```

### afterSwap

The hook called after a swap


```solidity
function afterSwap(
    address sender,
    PoolKey calldata key,
    SwapParams calldata params,
    BalanceDelta delta,
    bytes calldata hookData
) external virtual onlyPoolManager returns (bytes4, int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the swap call|
|`key`|`PoolKey`|The key for the pool|
|`params`|`SwapParams`|The parameters for the swap|
|`delta`|`BalanceDelta`|The amount owed to the caller (positive) or owed to the pool (negative)|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the swapper to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|
|`<none>`|`int128`|int128 The hook's delta in unspecified currency. Positive: the hook is owed/took currency, negative: the hook owes/sent currency|


### _afterSwap

*Hook implementation for `afterSwap`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _afterSwap(address, PoolKey calldata, SwapParams calldata, BalanceDelta, bytes calldata)
    internal
    virtual
    returns (bytes4, int128);
```

### beforeDonate

The hook called before donate


```solidity
function beforeDonate(address sender, PoolKey calldata key, uint256 amount0, uint256 amount1, bytes calldata hookData)
    external
    virtual
    onlyPoolManager
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the donate call|
|`key`|`PoolKey`|The key for the pool|
|`amount0`|`uint256`|The amount of token0 being donated|
|`amount1`|`uint256`|The amount of token1 being donated|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the donor to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _beforeDonate

*Hook implementation for `beforeDonate`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _beforeDonate(address, PoolKey calldata, uint256, uint256, bytes calldata) internal virtual returns (bytes4);
```

### afterDonate

The hook called after donate


```solidity
function afterDonate(address sender, PoolKey calldata key, uint256 amount0, uint256 amount1, bytes calldata hookData)
    external
    virtual
    onlyPoolManager
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|The initial msg.sender for the donate call|
|`key`|`PoolKey`|The key for the pool|
|`amount0`|`uint256`|The amount of token0 being donated|
|`amount1`|`uint256`|The amount of token1 being donated|
|`hookData`|`bytes`|Arbitrary data handed into the PoolManager by the donor to be be passed on to the hook|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|bytes4 The function selector for the hook|


### _afterDonate

*Hook implementation for `afterDonate`, to be overriden by the inheriting hook. The
flag must be set to true in the `getHookPermissions` function.*


```solidity
function _afterDonate(address, PoolKey calldata, uint256, uint256, bytes calldata) internal virtual returns (bytes4);
```

