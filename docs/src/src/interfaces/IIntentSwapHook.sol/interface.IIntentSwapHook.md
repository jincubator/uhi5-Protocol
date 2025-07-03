# IIntentSwapHook
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/interfaces/IIntentSwapHook.sol)

**Inherits:**
[IBaseHook](/src/interfaces/IBaseHook.sol/interface.IBaseHook.md)

**Author:**
jincubator

Inteface for IntentSwapHook handling intents on Unichain


## Functions
### getSalt

*Helper function to get a unique salt*


```solidity
function getSalt() external view returns (bytes32 salt);
```

### decodeIntentSwap

*Helper function to decode hookdata into IntentSwap*


```solidity
function decodeIntentSwap(bytes calldata hookData) external view returns (IntentSwap memory intentSwap);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`hookData`|`bytes`|containing encoded intentSwap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`intentSwap`|`IntentSwap`|the decoded intentSwap|


### getIntentSwapHash

*pure function to calculate the intentSwapHash from SwapParams
need to ensure uniqueness by using a salt*


```solidity
function getIntentSwapHash(IntentSwap calldata intentSwap) external pure returns (bytes32 intentSwapHash);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`intentSwap`|`IntentSwap`|IntentSwap Information|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`intentSwapHash`|`bytes32`|bytes 32 value of the keccak256 of the intentSwap|


### getIntentSwap

*view function to retrieve intentSwap Info*


```solidity
function getIntentSwap(PoolId poolId, bytes32 intentSwapHash) external view returns (IntentSwap memory intentSwap);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolId`|`PoolId`|the pool the intent is for|
|`intentSwapHash`|`bytes32`|the hash of the intentSwap|


### createIntentSwap

*IntentSwap creation creates an intentSwap called when intentSwapAction indicates create*


```solidity
function createIntentSwap(PoolKey calldata key, bytes32 intentSwapHash, IntentSwap calldata intentSwap)
    external
    returns (uint256 specifiedAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`PoolKey`||
|`intentSwapHash`|`bytes32`|the kecakk256 of the intent being created used for validation purposes|
|`intentSwap`|`IntentSwap`|contains all the information for the intentSwap|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`specifiedAmount`|`uint256`|the specified currency amount|


## Events
### IntentSwapCreated

```solidity
event IntentSwapCreated(bytes32 indexed intentSwapHash, IntentSwap indexed intentSwap);
```

### IntentSwapSolved

```solidity
event IntentSwapSolved(bytes32 indexed intentSwapHash);
```

### IntentSwapExpired

```solidity
event IntentSwapExpired(bytes32 indexed intentSwapHash);
```

## Errors
### UnableToDecodeIntentSwap

```solidity
error UnableToDecodeIntentSwap();
```

### InvalidIntentSwap

```solidity
error InvalidIntentSwap();
```

### IntentSwapSolverDeadlineExpired

```solidity
error IntentSwapSolverDeadlineExpired(uint256 swapDeadline);
```

### IntentSwapDeadlineExpired

```solidity
error IntentSwapDeadlineExpired(uint256 solveDeadline);
```

### IntentSolvDeadlineGreaterThanSwapDeadline

```solidity
error IntentSolvDeadlineGreaterThanSwapDeadline(uint256 solveDeadline, uint256 swapDeadline);
```

### IntentAlreadyExists

```solidity
error IntentAlreadyExists(bytes32 intentSwapHash);
```

### InvalidIntentSwapAction

```solidity
error InvalidIntentSwapAction(IntentSwapAction intentSwapAction);
```

### IncorrectPoolId

```solidity
error IncorrectPoolId(PoolId poolId, PoolKey key);
```

