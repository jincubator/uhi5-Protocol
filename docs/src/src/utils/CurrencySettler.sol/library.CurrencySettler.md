# CurrencySettler
[Git Source](https://github.com/jincubator/protocol/blob/85f1f4b406fe93b3be0808f4f39f0d03e4391578/src/utils/CurrencySettler.sol)

*Library used to interact with the `PoolManager` to settle any open deltas.
To settle a positive delta (a credit to the user), a user may take or mint.
To settle a negative delta (a debt on the user), a user may transfer or burn to pay off a debt.
Based on the https://github.com/Uniswap/v4-core/blob/main/test/utils/CurrencySettler.sol[Uniswap v4 test utils implementation].
NOTE: Deltas are synced before any ERC-20 transfers in [settle](/src/utils/CurrencySettler.sol/library.CurrencySettler.md#settle) function.*


## Functions
### settle

Settle (pay) a currency to the `PoolManager`


```solidity
function settle(Currency currency, IPoolManager poolManager, address payer, uint256 amount, bool burn) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`Currency`|Currency to settle|
|`poolManager`|`IPoolManager`|`PoolManager` to settle to|
|`payer`|`address`|Address of the payer, which can be the hook itself or an external address.|
|`amount`|`uint256`|Amount to send|
|`burn`|`bool`|If true, burn the ERC-6909 token, otherwise transfer ERC-20 to the `PoolManager`|


### take

Take (receive) a currency from the `PoolManager`


```solidity
function take(Currency currency, IPoolManager poolManager, address recipient, uint256 amount, bool claims) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`currency`|`Currency`|Currency to take|
|`poolManager`|`IPoolManager`|`PoolManager` to take from|
|`recipient`|`address`|Address of the recipient of the ERC-6909 or ERC-20 token.|
|`amount`|`uint256`|Amount to receive|
|`claims`|`bool`|If true, mint the ERC-6909 token, otherwise transfer ERC-20 from the `PoolManager` to recipient|


