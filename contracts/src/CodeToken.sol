// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract CodeToken is ERC20Upgradeable, OwnableUpgradeable {
    function initialize() external initializer {
        __Ownable_init(msg.sender);
        __ERC20_init("$CODE", "CODE Token");
        _mint(msg.sender, 10000000000 ether);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
