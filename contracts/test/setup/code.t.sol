// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Registry} from "../../src/Registry.sol";
import {Code} from "../../src/Code.sol";
import {CodeToken} from "../../src/CodeToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract SetupCodeTest is Test {
    Registry public registry;
    Registry public registryProxyInstance;
    TransparentUpgradeableProxy public registryProxyImplementation;

    CodeToken public codeToken;
    CodeToken public codeTokenProxyInstance;
    TransparentUpgradeableProxy public codeTokenProxyImplementation;

    Code public code;
    Code public codeProxyInstance;
    TransparentUpgradeableProxy public codeProxyImplementation;

    address owner = address(0x123);
    address team = address(0x124);

    function setUp() public {
        vm.startPrank(owner);

        registry = new Registry();
        bytes memory registryData = abi.encodeWithSelector(
            Registry.initialize.selector
        );
        TransparentUpgradeableProxy registryProxy = new TransparentUpgradeableProxy(
                address(registry),
                owner,
                registryData
            );
        registryProxyInstance = Registry(address(registryProxy));

        codeToken = new CodeToken();
        bytes memory codeTokenData = abi.encodeWithSelector(
            CodeToken.initialize.selector
        );
        TransparentUpgradeableProxy codeTokenProxy = new TransparentUpgradeableProxy(
                address(codeToken),
                owner,
                codeTokenData
            );
        codeTokenProxyInstance = CodeToken(address(codeTokenProxy));

        code = new Code();
        bytes memory codeData = abi.encodeWithSelector(
            Code.initialize.selector
        );
        TransparentUpgradeableProxy codeProxy = new TransparentUpgradeableProxy(
            address(code),
            owner,
            codeData
        );
        codeProxyInstance = Code(address(codeProxy));
    }

    function test_set_registry() public {
        codeProxyInstance.setRegistry(address(registryProxyInstance));
        assertEq(
            address(codeProxyInstance.registry()),
            address(registryProxyInstance)
        );
    }

    function test_set_team_wallet() public {
        codeProxyInstance.setTeamWallet(team);
        assertEq(address(codeProxyInstance.teamWallet()), team);
    }

    function test_set_yellow_hint_price(uint256 price) public {
        codeProxyInstance.setYellowHintsFee(price);
        assertEq(codeProxyInstance.yellowHintsPrice(), price);
    }

    function test_set_blue_hint_price(uint256 price) public {
        codeProxyInstance.setBlueHintsFee(price);
        assertEq(codeProxyInstance.blueHintsPrice(), price);
    }

    function test_set_submission_price(uint256 price) public {
        codeProxyInstance.setSubmissionFee(price);
        assertEq(codeProxyInstance.submissionPrice(), price);
    }
}
