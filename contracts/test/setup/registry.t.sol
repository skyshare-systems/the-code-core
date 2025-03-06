// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Registry} from "../../src/Registry.sol";
import {Code} from "../../src/Code.sol";
import {CodeToken} from "../../src/CodeToken.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract SetupRegistryTest is Test {
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
    TransparentUpgradeableProxy public proxy;

    function setUp() public {

        vm.startPrank(owner);

        registry = new Registry();
        bytes memory registryData = abi.encodeWithSelector(Registry.initialize.selector);
        TransparentUpgradeableProxy registryProxy = new TransparentUpgradeableProxy(address(registry), owner, registryData);
        registryProxyInstance = Registry(address(registryProxy));

        codeToken = new CodeToken();
        bytes memory codeTokenData = abi.encodeWithSelector(CodeToken.initialize.selector);
        TransparentUpgradeableProxy codeTokenProxy = new TransparentUpgradeableProxy(address(registry), owner, codeTokenData);
        codeTokenProxyInstance = CodeToken(address(codeTokenProxy));

        code = new Code();
        bytes memory codeData = abi.encodeWithSelector(code.initialize.selector);
        TransparentUpgradeableProxy codeProxy = new TransparentUpgradeableProxy(address(registry), owner, codeData);
        codeProxyInstance = Code(address(codeProxy));
    }

    function test_set_registry() public {
        registryProxyInstance.setContractAddress("Registry", address(registryProxyInstance));
        assertEq(address(registryProxyInstance), registryProxyInstance.getContractAddress("Registry"));
    }

    function test_set_code_token() public {
        registryProxyInstance.setContractAddress("CodeToken", address(codeTokenProxyInstance));
        assertEq(address(codeTokenProxyInstance), registryProxyInstance.getContractAddress("CodeToken"));
    }

    function test_set_code() public {
        registryProxyInstance.setContractAddress("Code", address(codeProxyInstance));
        assertEq(address(codeProxyInstance), registryProxyInstance.getContractAddress("Code"));
    }

}
