// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract CrowdfundTest is Test {
    Crowdfund public crowdfund;
    address public bendahara = address(0x1);

    function setUp() public {
        crowdfund = new Crowdfund();
    }

    function testCreateCampaign() public {
        vm.prank(bendahara);
        // foundry limitation with vm.warp resetting block timestamp during test execution, setting base timestamp explicitly
        vm.warp(1700000000);

        uint256 id = crowdfund.createCampaign(
            "Patungan Futsal Q2",
            "Uang sewa lapangan dan minum",
            1000000000000000000,
            7
        );

        assertEq(id, 1);
        assertEq(crowdfund.campaignCount(), 1);
    }
}
