// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./interface/IRegistry.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract Registry is Initializable, OwnableUpgradeable, IRegistry {
    mapping(bytes32 => address) public registry;

    function initialize() external initializer {
        __Ownable_init(msg.sender);
    }

    function setContractAddress(
        bytes32  _name,
        address _address
    ) external onlyOwner {
        registry[_name] = _address;

        emit RegisterContract(_name, _address);
    }

    function getContractAddress(
        bytes32  _name
    ) external view returns (address) {
        require(registry[_name] != address(0), "Registry :: Address not found");
        return registry[_name];
    }
}
