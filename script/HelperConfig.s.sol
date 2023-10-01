// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
// import mocks for local testing and forking
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 _entranceFee;
        uint256 _interval;
        address _vrfCoordinator;
        bytes32 _gasLane;
        uint64 _subscriptionId;
        uint32 _callbackGasLimit;
        address _link;
        uint256 _deployerKey;
    }

    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                _entranceFee: 0.01 ether,
                _interval: 30,
                _vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                _gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                _subscriptionId: 0,
                _callbackGasLimit: 500_000, // 500,000 gas
                _link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                _deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig._vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 gasPriceLink = 1e9; // 1 gwei LINK

        vm.startBroadcast();
        // deploy new VRFCoordinatorV2Mock contract
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        return
            NetworkConfig({
                _entranceFee: 0.01 ether,
                _interval: 30,
                _vrfCoordinator: address(vrfCoordinatorV2Mock),
                _gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
                _subscriptionId: 0, // our script will add this
                _callbackGasLimit: 500_000, // 500,000 gas
                _link: address(link),
                _deployerKey: DEFAULT_ANVIL_KEY
            });
    }
}
