// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script{

    function createSubscriptionUsingConfig() public returns(uint64){
        HelperConfig helperConfig = new HelperConfig();
        (,,address _vrfCoordinator,,,,) = helperConfig.activeNetworkConfig();
        return createSubscription(_vrfCoordinator)
    }

    function createSubscription(address _vrfCoordinator) public returns(uint64){
        console.log("Creating subscription on ChainID: ", block.chainId);
        vm.startBroadcast();
        uint64 subId =  VRFCoordinatorV2Mock(_vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is: ", subId);
        console.log("Please update subscriptionId in HeplerConfig.s.sol");
        return subId;
    }


    function run() external returns(uint64) {
        retrun createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (,,address _vrfCoordinator,,uint64 _subscriptionId,,address _link) = helperConfig.activeNetworkConfig();
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}