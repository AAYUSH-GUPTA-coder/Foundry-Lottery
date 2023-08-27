// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__NotEnoughEthSent();

/**
 * @title A sample Raffle Contract
 * @author Aayush Gupta
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle {
    uint256 private constant NUM_WORDS = 1;

    uint256 private s_requestConfirmations = 3;
    uint256 private s_entranceFee;
    uint256 private s_interval;
    uint256 private s_lastTimeStamp;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private s_subscriptionId;
    uint32 private s_callbackGasLimit;

    event EnteredRaffle(address indexed player);

    constructor(
        uint256 _entranceFee,
        uint256 _interval,
        address _vrfCoordinator,
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) {
        s_entranceFee = _entranceFee;
        s_interval = _interval;
        s_entranceFee = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_gasLane = _gasLane;
        s_subscriptionId = _subscriptionId;
        s_callbackGasLimit = _callbackGasLimit;
    }

    function enterRaffle() public payable {
        if (msg.value < s_entranceFee) {
            revert Raffle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public {
        if ((block.timestamp - s_lastTimeStamp) < s_interval) {
            revert();
        }

        // Will revert if subscription is not set and funded.
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            s_subscriptionId,
            s_requestConfirmations,
            s_callbackGasLimit,
            NUM_WORDS
        );
    }

    function getEntranceFee() public view returns (uint256) {
        return s_entranceFee;
    }
}
