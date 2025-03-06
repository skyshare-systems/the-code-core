// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CodeToken} from "../src/CodeToken.sol";
import {Code} from "../src/Code.sol";
import {Registry} from "../src/Registry.sol";

contract DeploymentScript is Script {
    function run() external {
        uint256 BLUE_HINTS_FEE = 1 ether;
        uint256 YELLOW_HINTS_FEE = 1 ether;
        uint256 SUBMISSION_HINT_FEE = 1 ether;
        address TEAM_WALLET = 0xdC28726629eB86c2c1a19E3785516f575A93A36E;

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        CodeToken codeToken = new CodeToken();
        codeToken.initialize();
        console.log("CodeToken Address:", address(codeToken));


        Code code = new Code();
        code.initialize();
        console.log("Code Address:", address(code));

        Registry registry = new Registry();
        registry.initialize();
        console.log("Registry Address:", address(registry));

        registry.setContractAddress(
            bytes32(abi.encodePacked("Code")),
            address(code)
        );
        console.log("Register Code to Registry");

        registry.setContractAddress(
            bytes32(abi.encodePacked("CodeToken")),
            address(codeToken)
        );
        console.log("Register CodeToken to Registry");
    
        registry.setContractAddress(
            bytes32(abi.encodePacked("Registry")),
            address(registry)
        );
        console.log("Register Registry to Registry");

        code.setRegistry(address(registry));
        console.log("Set Registry in Code");

        code.setBlueHintsFee(BLUE_HINTS_FEE);
        console.log("Set blue hint fee in Code");

        code.setYellowHintsFee(YELLOW_HINTS_FEE);
        console.log("Set yellow hint fee in Code");
   
        code.setSubmissionFee(SUBMISSION_HINT_FEE);
        console.log("Set submission fee in Code");
   
        code.setTeamWallet(TEAM_WALLET);
        console.log("Set team wallet in Code");

        codeToken.approve(address(code), type(uint256).max);
        console.log("Approve CodeToken to Code");

        code.transferInitialTreasury();
        console.log("Transfer Initial Treasury to Code");

        vm.stopBroadcast();
    }
}
