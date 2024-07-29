-include .env

# Build contracts
build :; forge build

# Run tests
run-tests :; forge test

# Clean build contracts
clean :; forge clean

# Generate coverage stats using lcov and genhtml
# See https://github.com/hyperlane-xyz/hyperlane-monorepo/blob/main/solidity/coverage.sh
tests-coverage :; ./coverage.sh

# Deploy the {InvoiceModule} contracts deterministically to Base Sepolia 
# See Sablier V2 deployments on Base Sepolia: https://docs.sablier.com/contracts/v2/deployments#base-sepolia
# Update the {PRIVATE_KEY} .env variable with the deployer private key
deploy-deterministic-base-sepolia-invoice-module: 
					forge script script/DeployInvoiceModule.s.sol:DeployInvoiceModule $(CREATE2SALT) \
					0xFE7fc0Bbde84C239C0aB89111D617dC7cc58049f 0xb8c724df3eC8f2Bf8fA808dF2cB5dbab22f3E68c 0x85E094B259718Be1AF0D8CbBD41dd7409c2200aa \
					--sig "run(string,address,address,address)" --rpc-url base_sepolia --private-key $(PRIVATE_KEY) --etherscan-api-key $(BASESCAN_API_KEY) 
					--broadcast --verify

# Deploy the {InvoiceModule} contracts deterministically to Base 
# See Sablier V2 deployments on Base Sepolia: https://docs.sablier.com/contracts/v2/deployments#base
# Update the {PRIVATE_KEY} .env variable with the deployer private key
deploy-deterministic-base-invoice-module: 
					forge script script/DeployInvoiceModule.s.sol:DeployInvoiceModule $(CREATE2SALT) \
					0x4CB16D4153123A74Bc724d161050959754f378D8 0xf4937657Ed8B3f3cB379Eed47b8818eE947BEb1e 0x85E094B259718Be1AF0D8CbBD41dd7409c2200aa \
					--sig "run(string,address,address,address)" --rpc-url base_sepolia --private-key $(PRIVATE_KEY) --etherscan-api-key $(BASESCAN_API_KEY) 
					--broadcast --verify