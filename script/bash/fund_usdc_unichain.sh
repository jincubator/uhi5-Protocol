source .env
# Transfer USDC from whale to our Account for testing purposes

##  Check Balances
cast call $USDC "balanceOf(address)(uint256)" $OUR_ADDRESS
cast call $USDC "balanceOf(address)(uint256)" $USDC_WHALE_ADDRESS

## Transfer funds
cast rpc anvil_impersonateAccount $USDC_WHALE_ADDRESS
cast send $USDC --from $USDC_WHALE_ADDRESS "transfer(address,uint256)(bool)"  $OUR_ADDRESS 276653586228 --unlocked #Whale has $276,653 USDC

##  Check Balances
cast call $USDC "balanceOf(address)(uint256)" $OUR_ADDRESS
cast call $USDC "balanceOf(address)(uint256)" $USDC_WHALE_ADDRESS