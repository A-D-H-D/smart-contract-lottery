// SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    // now get the Raffle and helperconfig by calling deployContrct
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    // users -> make addresses based on as string
    address public PLAYER = makeAddr("player");
    uint256 constant STARTING_PLAYER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;

        vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnoughEth() public {
        vm.prank(PLAYER);

        vm.expectRevert(Raffle.Raffle__SendMoreEnoughEthToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public{
        //Assert
        vm.prank(PLAYER);

        //Act
        raffle.enterRaffle{value: entranceFee}();

        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testMultipleUSersCanEnter() public{
        // adding two new players here
        address player2 = makeAddr("player2");
        address player3 = makeAddr("player3");

        vm.deal(player2, STARTING_PLAYER_BALANCE);
        vm.deal(player3, STARTING_PLAYER_BALANCE);

        //playerone enters
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        // playeer two enters
        vm.prank(player2);
        raffle.enterRaffle{value: entranceFee}();

        //player three enters
        vm.prank(player3);
        raffle.enterRaffle{value: entranceFee}();

        //assert the players
        assert(raffle.getPlayer(0) == PLAYER);
        assert(raffle.getPlayer(1) == player2);
        assert(raffle.getPlayer(2) == player3);

    }
}
