// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {Crowdfund} from "../src/Crowdfund.sol";

contract DeployScript is Script {
    function run() external returns (Crowdfund) {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );

        vm.startBroadcast(deployerPrivateKey);

        Crowdfund crowdfund = new Crowdfund();

        vm.stopBroadcast();

        console.log("Crowdfund deployed to:", address(crowdfund));

        return crowdfund;
    }
}
