-include .env
# to include .env variable in our makefile

.PHONY : all test deploy
# targets for our main file

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "make deploy [ARGS=...]"

# @echo works like a console log

update:; forge update

build:; forge build
buildVia:; forge build --via-ir
# :; is equivalent of putting this in new line
# "make build" command, "build" is the keyword here, runs the forge build command

install:; forge install Cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit && forge install transmissions11/solmate@v6 --no-commit

test:; forge test


NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

# if --network sepolia is used, then use sepolia stuff otherwise use anvil stuff
ifeq ($(findstring --network sepolia,$(ARGS)), --network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHEREUM_API_KEY) -vvvv
endif
# ":=" is used to set the value

deploy:; @forge script script/DeployRaffle.s.sol:DeployRaffle ${NETWORK_ARGS} --via-ir

# IN MAKE FILE, use ${NETWORK_ARGS} to use .env variables
# @ hide the actual command along with RPC_URL , PRIVATE_KEY and ETHEREUM_API_KEY