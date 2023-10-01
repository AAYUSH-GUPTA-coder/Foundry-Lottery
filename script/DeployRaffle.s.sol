// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interaction.s.sol";
import {AddConsumer} from "./Interaction.s.sol";
import {FundSubscription} from "./Interaction.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 _entranceFee,
            uint256 _interval,
            address _vrfCoordinator,
            bytes32 _gasLane,
            uint64 _subscriptionId,
            uint32 _callbackGasLimit,
            address _link,
            uint256 _deployerKey
        ) = helperConfig.activeNetworkConfig();

        if (_subscriptionId == 0) {
            // Created a subscription
            CreateSubscription createSubscription = new CreateSubscription();
            _subscriptionId = createSubscription.createSubscription(
                _vrfCoordinator,
                _deployerKey
            );

            // Fund the subscription
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                _vrfCoordinator,
                _subscriptionId,
                _link,
                _deployerKey
            );
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            _entranceFee,
            _interval,
            _vrfCoordinator,
            _gasLane,
            _subscriptionId,
            _callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(raffle),
            _vrfCoordinator,
            _subscriptionId,
            _deployerKey
        );
        return (raffle, helperConfig);
    }
}
