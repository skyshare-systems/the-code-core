// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

struct RoundData {
    uint256 totalGuesses;
    bytes code;
    address winner;
    uint256 totalReward;
    uint256 vestingIterations;
    uint256 totalClaimed;
    uint256 vestingStart;
    bytes32[] answer;
}
