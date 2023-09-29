// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    /* EVENTS */
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 _entranceFee;
    uint256 _interval;
    address _vrfCoordinator;
    bytes32 _gasLane;
    uint64 _subscriptionId;
    uint32 _callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        (
            _entranceFee,
            _interval,
            _vrfCoordinator,
            _gasLane,
            _subscriptionId,
            _callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    //////////////////////////////////////////////////
    //////      ENTER RAFFLE                    //////
    //////////////////////////////////////////////////

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // arrange
        vm.prank(PLAYER);

        // act
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
        // assert
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(PLAYER == playerRecorded);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: _entranceFee}();
    }
}
