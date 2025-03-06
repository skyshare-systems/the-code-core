// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./Structs.sol";

interface ICode {
    event RewardsClaimed(address user, uint256 round, uint256 amount);
    event NewRoundCreated(uint256 round);
    event RoundCracked(address user, uint256 totalRounds, RoundData roundData);
    event BoughtYellowHint(address user, uint round);
    event BoughtBlueHint(address user, uint round);
    event AttemptSubmitted(address user, bytes32[4] guess, uint256 round);
    event UpdateRewardPool(uint256 currentPool);
    event SetYellowHintsFee(uint256 amount);
    event SetBlueHintsFee(uint256 amount);
    event SetSubmissionFee(uint256 amount);

    function transferInitialTreasury() external;

    function createCode(bytes memory _code) external;

    function submitCode(bytes32[4] memory _code) external;

    function roundCracked(address _winner, bytes32[] memory _answer) external;

    function claimRewards(uint256 _round) external;

    function buyBlueHint() external;

    function buyYellowHints() external;

    function setRegistry(address _registry) external;

    function setYellowHintsFee(uint256 _price) external;

    function setBlueHintsFee(uint256 _price) external;

    function setHintsFee(
        uint256 _yellowHintsPrice,
        uint256 _blueHintsPrice
    ) external;

    function setSubmissionFee(uint256 _submissionPrice) external;

    function setTeamWallet(address _teamWallet) external;
}
