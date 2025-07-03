# IntentSwapHook
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/IntentSwapHook.sol)

**Inherits:**
[BaseHook](/src/base/BaseHook.sol/abstract.BaseHook.md), [IIntentSwapHook](/src/interfaces/IIntentSwapHook.sol/interface.IIntentSwapHook.md), [IHookEvents](/src/interfaces/IHookEvents.sol/interface.IHookEvents.md)


IntentSwapHook allows any Exact In swap request to return a better swap through the use of solvers
It does this by
- Swapper creats an IntentSwap which publishes an event which solvers can act on
- The solver finds a more efficient swap and then returns a higher number of output tokens to claim the input tokens
- If the solver deadline expires an OCW can trigger the execution of the swap for the original amount
- For Swaps where the swapper Deadline has expired and the intent has not been executed
a sweep function is called to return the funds to the user

*Design Notes for Prototype*
1) A salt is used to generate uniqueness of intents.
2) Storage of intentSwap information is currently done in the IntentSwapHook this could be changed to
store just the storageHash with IntentInformation managed off-chain which would reduce gas costs
3) Swapper is currently passing potentially redundant fields in the IntentSwap structure and the SwapParams
moving forward these fields should be reviewed and potentially reduced.
4) swapDeadliine and solverDeadline currently take a timestamp but moving forward
should pass in a number of milliseconds and calculate the timeline
5) Enhance security with modifiers for onlyValidPools and onlySelf
6) Improve Swapper Address Checking catering for which contract calls addLiquidity vs end user swapping
7) An alternate approach for solving, executing and potentially sweeping would be using beforeAddLiquidity
8) Clean up interfaces grouping all events together
9) Revisit the use of Status for IntentSwap currently actions are deadline validated and driven*


## State Variables
### intentSwapsForPool

```solidity
mapping(PoolId => mapping(bytes32 => IntentSwap intentSwap)) public intentSwapsForPool;
```


## Functions
### validSolveDeadline

*Ensure the solve deadline of an IntentSwap is not expired.*


```solidity
modifier validSolveDeadline(uint256 solveDeadline);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`solveDeadline`|`uint256`|Solve Deadline of the request, from the intentSwap|


### validSwapDeadline

*Ensure the swap deadline of an IntentSwap is not expired.*


```solidity
modifier validSwapDeadline(uint256 swapDeadline);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`swapDeadline`|`uint256`|Swap Deadline of the request, from the intentSwap|


### validSolveSwapDeadlines

*Ensure the solve deadline of an IntentSwap is less than the Swap Deadline*


```solidity
modifier validSolveSwapDeadlines(uint256 solveDeadline, uint256 swapDeadline);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`solveDeadline`|`uint256`|Solve Deadline of the request, from the intentSwap|
|`swapDeadline`|`uint256`|Solve Deadline of the request, from the intentSwap|


### constructor


```solidity
constructor(IPoolManager _poolManager) BaseHook(_poolManager);
```

### getHookPermissions


```solidity
function getHookPermissions() public pure override returns (Hooks.Permissions memory);
```

### getSalt

*Helper function to get a unique salt*


```solidity
function getSalt() public view returns (bytes32 salt);
```

### decodeIntentSwap

*Helper function to decode hookdata into IntentSwap*


```solidity
function decodeIntentSwap(bytes calldata hookData) public view returns (IntentSwap memory intentSwap);
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
function getIntentSwapHash(IntentSwap memory intentSwap) public pure returns (bytes32 intentSwapHash);
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
function getIntentSwap(PoolId poolId, bytes32 intentSwapHash) public view returns (IntentSwap memory intentSwap);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`poolId`|`PoolId`|the pool the intent is for|
|`intentSwapHash`|`bytes32`|the hash of the intentSwap|


### createIntentSwap

*IntentSwap creation creates an intentSwap called when intentSwapAction indicates create*


```solidity
function createIntentSwap(PoolKey calldata key, bytes32 intentSwapHash, IntentSwap memory intentSwap)
    public
    validSolveDeadline(intentSwap.solveDeadline)
    validSwapDeadline(intentSwap.swapDeadline)
    validSolveSwapDeadlines(intentSwap.solveDeadline, intentSwap.swapDeadline)
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


### _beforeSwap


```solidity
function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
    internal
    override
    returns (bytes4, BeforeSwapDelta, uint24);
```

### _calculateSwapFee

*Calculate the fee amount for the swap.*


```solidity
function _calculateSwapFee(PoolKey calldata key, uint256 specifiedAmount)
    internal
    virtual
    returns (uint256 feeAmount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`key`|`PoolKey`|The pool key.|
|`specifiedAmount`|`uint256`|The specified amount of the swap.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`feeAmount`|`uint256`|The fee amount for the swap.|


