// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Registry} from "../../src/Registry.sol";
import {Code} from "../../src/Code.sol";
import {CodeToken} from "../../src/CodeToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DeploymentTest is Test {
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

        registryProxyInstance.setContractAddress(
            "Registry",
            address(registryProxyInstance)
        );
        registryProxyInstance.setContractAddress(
            "CodeToken",
            address(codeTokenProxyInstance)
        );
        registryProxyInstance.setContractAddress(
            "Code",
            address(codeProxyInstance)
        );

        codeProxyInstance.setRegistry(address(registryProxyInstance));

        codeProxyInstance.setTeamWallet(team);

        uint256 price = 10 ether;
        codeProxyInstance.setYellowHintsFee(price);
        codeProxyInstance.setBlueHintsFee(price);
        codeProxyInstance.setSubmissionFee(price);

        codeTokenProxyInstance.approve(
            address(codeProxyInstance),
            type(uint256).max
        );

        codeProxyInstance.transferInitialTreasury();
    }

    function test_set_code(
        string memory g1,
        string memory g2,
        string memory g3,
        string memory g4,
        uint256 salt
    ) public {
        bytes32 hashedG1 = keccak256(
            abi.encodePacked(g1, Strings.toString(salt))
        );
        bytes32 hashedG2 = keccak256(
            abi.encodePacked(g2, Strings.toString(salt))
        );
        bytes32 hashedG3 = keccak256(
            abi.encodePacked(g3, Strings.toString(salt))
        );
        bytes32 hashedG4 = keccak256(
            abi.encodePacked(g4, Strings.toString(salt))
        );

        bytes32 concatenatedHash = keccak256(
            abi.encodePacked(hashedG1, hashedG2, hashedG3, hashedG4)
        );
        bytes32 hashedCode = keccak256(abi.encodePacked(concatenatedHash));

        codeProxyInstance.createCode(abi.encode(hashedCode));
        assertEq(codeProxyInstance.totalRounds(), 1);
    }
}
