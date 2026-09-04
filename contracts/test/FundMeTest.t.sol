// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address public OWNER = address(this); // this test contract deploys FundMe
    address public ALICE = makeAddr("alice");
    address public BOB = makeAddr("bob");

    uint256 public constant STARTING_BALANCE = 10 ether;
    uint256 public constant SEND_VALUE = 1 ether;

    function setUp() public {
        fundMe = new FundMe();
        vm.deal(ALICE, STARTING_BALANCE);
        vm.deal(BOB, STARTING_BALANCE);
    }

    function testUserCanFundContract() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getContribution(ALICE), SEND_VALUE);
    }

    /* // ---------- Constructor ----------

    function test_OwnerIsSetCorrectly() public view {
        assertEq(fundMe.i_owner(), OWNER);
    }

    // ---------- fund() ----------

    function test_FundRevertsWithoutEnoughEth() public {
        vm.expectRevert(FundMe.FundMe__NeedsMoreThanZero.selector);
        fundMe.fund{value: 0}();
    }

    function test_FundUpdatesContributionData() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getContribution(ALICE), SEND_VALUE);
    }

    function test_FundAddsFunderToArray() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getFunder(0), ALICE);
        assertEq(fundMe.getFundersCount(), 1);
    }

    function test_MultipleAccountsCanFund() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(BOB);
        fundMe.fund{value: SEND_VALUE}();

        assertEq(fundMe.getFundersCount(), 2);
        assertEq(fundMe.getBalance(), SEND_VALUE * 2);
    }

    function test_OwnerCanAlsoFund() public {
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getContribution(OWNER), SEND_VALUE);
    }

    function test_SameFunderDoesNotDuplicateInArray() public {
        vm.startPrank(ALICE);
        fundMe.fund{value: SEND_VALUE}();
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        assertEq(fundMe.getFundersCount(), 1);
        assertEq(fundMe.getContribution(ALICE), SEND_VALUE * 2);
    }

    function test_FundEmitsEvent() public {
        vm.expectEmit(true, false, false, true, address(fundMe));
        emit FundMe.Funded(ALICE, SEND_VALUE);

        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();
    }

    function test_ReceiveTriggersFund() public {
        vm.prank(ALICE);
        (bool success, ) = address(fundMe).call{value: SEND_VALUE}("");

        assertTrue(success);
        assertEq(fundMe.getContribution(ALICE), SEND_VALUE);
    }

    function test_FallbackTriggersFund() public {
        vm.prank(ALICE);
        (bool success, ) = address(fundMe).call{value: SEND_VALUE}(hex"1234");

        assertTrue(success);
        assertEq(fundMe.getContribution(ALICE), SEND_VALUE);
    }

    // ---------- withdraw() ----------

    function test_OnlyOwnerCanWithdraw() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(ALICE);
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);
        fundMe.withdraw();
    }

    function test_WithdrawRevertsIfNoBalance() public {
        vm.expectRevert(FundMe.FundMe__NoBalance.selector);
        fundMe.withdraw();
    }

    function test_OwnerCanWithdrawFullBalanceSingleFunder() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        uint256 ownerStartingBalance = OWNER.balance;
        uint256 fundMeStartingBalance = fundMe.getBalance();

        fundMe.withdraw();

        assertEq(fundMe.getBalance(), 0);
        assertEq(OWNER.balance, ownerStartingBalance + fundMeStartingBalance);
    }

    function test_OwnerCanWithdrawFullBalanceMultipleFunders() public {
        uint160 numberOfFunders = 5;
        for (uint160 i = 1; i <= numberOfFunders; i++) {
            address funder = address(i);
            hoax(funder, STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 ownerStartingBalance = OWNER.balance;
        uint256 fundMeStartingBalance = fundMe.getBalance();

        fundMe.withdraw();

        assertEq(fundMe.getBalance(), 0);
        assertEq(OWNER.balance, ownerStartingBalance + fundMeStartingBalance);
        assertEq(fundMe.getFundersCount(), 0);
    }

    function test_WithdrawResetsContributions() public {
        vm.prank(ALICE);
        fundMe.fund{value: SEND_VALUE}();

        fundMe.withdraw();

        assertEq(fundMe.getContribution(ALICE), 0);
    }

    function test_WithdrawEmitsEvent() public {
        fundMe.fund{value: SEND_VALUE}();

        vm.expectEmit(true, false, false, true, address(fundMe));
        emit FundMe.Withdrawn(OWNER, SEND_VALUE);

        fundMe.withdraw();
    }

    // ---------- withdrawTo() ----------

    function test_OnlyOwnerCanWithdrawTo() public {
        fundMe.fund{value: SEND_VALUE}();

        vm.prank(ALICE);
        vm.expectRevert(FundMe.FundMe__NotOwner.selector);
        fundMe.withdrawTo(ALICE, SEND_VALUE);
    }

    function test_WithdrawToRevertsIfAmountExceedsBalance() public {
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert(FundMe.FundMe__NoBalance.selector);
        fundMe.withdrawTo(ALICE, SEND_VALUE + 1);
    }

    function test_WithdrawToSendsCorrectAmount() public {
        fundMe.fund{value: SEND_VALUE}();

        uint256 aliceStartingBalance = ALICE.balance;
        fundMe.withdrawTo(ALICE, SEND_VALUE);

        assertEq(ALICE.balance, aliceStartingBalance + SEND_VALUE);
        assertEq(fundMe.getBalance(), 0);
    }

    // ---------- Fuzz ----------

    function testFuzz_AnyoneCanFundAnyAmount(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(ALICE, amount);

        vm.prank(ALICE);
        fundMe.fund{value: amount}();

        assertEq(fundMe.getContribution(ALICE), amount);
    } */
}