// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IRegistry {
    event RegisterContract(bytes32 name, address contractAddress);

    function initialize() external;

    function setContractAddress(bytes32  _name, address _address) external;

    function getContractAddress(
        bytes32  _name
    ) external view returns (address);
}
