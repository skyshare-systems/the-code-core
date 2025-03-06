// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./Registry.sol";
import "./interface/Structs.sol";
import "./interface/ICode.sol";

contract Code is Initializable, OwnableUpgradeable, ERC20Upgradeable, ICode {
    uint256 public totalRounds;
    uint256 public blueHintsPrice;
    uint256 public yellowHintsPrice;
    uint256 public submissionPrice;
    address public teamWallet;
    uint256 public rewardPool;
    Registry public registry;

    mapping(uint256 => RoundData) public rounds;

    function initialize() public initializer {
        __Ownable_init(msg.sender);
    }

    function transferInitialTreasury() external onlyOwner {
        ERC20Upgradeable codeToken = ERC20Upgradeable(
            registry.getContractAddress("CodeToken")
        );
        codeToken.transferFrom(msg.sender, address(this), 100000000 ether);
        rewardPool += 100000000 ether;
        uint256 reward = (rewardPool * 5) / 100;
        emit UpdateRewardPool(reward);
    }

    function createCode(bytes memory _code) external onlyOwner {
        uint256 reward = (rewardPool * 5) / 100;

        rounds[totalRounds].code = _code;
        emit NewRoundCreated(totalRounds);
        emit UpdateRewardPool(reward);
        totalRounds++;
    }

    function submitCode(bytes32[4] memory _code) external {
        ERC20Upgradeable codeToken = ERC20Upgradeable(
            registry.getContractAddress("CodeToken")
        );
        require(
            submissionPrice < codeToken.balanceOf(msg.sender),
            "Insufficient Balance"
        );
        codeToken.transferFrom(msg.sender, address(this), submissionPrice);
        codeToken.transfer(teamWallet, (submissionPrice * 10) / 100);
        rewardPool += (submissionPrice * 90) / 100;
        uint256 reward = (rewardPool * 5) / 100;
        emit UpdateRewardPool(reward);
        emit AttemptSubmitted(msg.sender, _code, totalRounds - 1);
    }

    function roundCracked(
        address winner,
        bytes32[] memory answer
    ) external onlyOwner {
        uint256 reward = (rewardPool * 5) / 100;
        rewardPool -= reward;

        rounds[totalRounds - 1].winner = winner;
        rounds[totalRounds - 1].totalReward = reward;
        rounds[totalRounds - 1].vestingIterations = 12;
        rounds[totalRounds - 1].vestingStart = block.timestamp;
        rounds[totalRounds - 1].totalClaimed = 0;
        rounds[totalRounds - 1].answer = answer;

        emit UpdateRewardPool(reward);
        emit RoundCracked(winner, totalRounds, rounds[totalRounds - 1]);
    }

    function claimRewards(uint256 _round) external {
        require(
            msg.sender == rounds[_round].winner,
            "You are not the winner of this round"
        );

        uint diff = block.timestamp - rounds[_round].vestingStart;
        uint availableIterations = (diff / 30 days) + 1;

        if (availableIterations > rounds[_round].vestingIterations) {
            availableIterations = rounds[_round].vestingIterations;
        }
        uint claimableIterations = availableIterations -
            rounds[_round].totalClaimed;

        require(claimableIterations > 0, "No rewards to claim");
        ERC20Upgradeable codeToken = ERC20Upgradeable(
            registry.getContractAddress("CodeToken")
        );

        uint totalTokensClaimable = rounds[_round].totalReward /
            rounds[_round].vestingIterations;

        if (availableIterations >= rounds[_round].vestingIterations) {
            codeToken.transfer(
                msg.sender,
                rounds[_round].totalReward -
                    (totalTokensClaimable * rounds[_round].totalClaimed)
            );
        } else {
            codeToken.transfer(
                msg.sender,
                totalTokensClaimable * claimableIterations
            );
        }
        rounds[_round].totalClaimed = availableIterations;

        // emit RewardsClaimed(
        //     msg.sender,
        //     availableIterations,
        //     totalTokensClaimable
        // );

        emit RewardsClaimed(msg.sender, _round, rounds[_round].totalClaimed);
    }

    function buyBlueHint() external {
        ERC20Upgradeable codeToken = ERC20Upgradeable(
            registry.getContractAddress("CodeToken")
        );

        codeToken.transferFrom(msg.sender, address(this), blueHintsPrice);
        rewardPool += blueHintsPrice;

        uint256 reward = (rewardPool * 5) / 100;
        emit UpdateRewardPool(reward);
        emit BoughtBlueHint(msg.sender, totalRounds - 1);
    }

    function buyYellowHints() external {
        ERC20Upgradeable codeToken = ERC20Upgradeable(
            registry.getContractAddress("CodeToken")
        );

        codeToken.transferFrom(msg.sender, address(this), yellowHintsPrice);
        rewardPool += yellowHintsPrice;

        uint256 reward = (rewardPool * 5) / 100;
        emit UpdateRewardPool(reward);
        emit BoughtYellowHint(msg.sender, totalRounds - 1);
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = Registry(_registry);
    }

    function setYellowHintsFee(uint256 _price) external onlyOwner {
        yellowHintsPrice = _price;
        emit SetYellowHintsFee(_price);
    }

    function setBlueHintsFee(uint256 _price) external onlyOwner {
        blueHintsPrice = _price;
        emit SetBlueHintsFee(_price);
    }

    function setHintsFee(
        uint256 _yellowHintsPrice,
        uint256 _blueHintsPrice
    ) external onlyOwner {
        blueHintsPrice = _blueHintsPrice;
        yellowHintsPrice = _yellowHintsPrice;

        emit SetYellowHintsFee(_yellowHintsPrice);
        emit SetBlueHintsFee(_blueHintsPrice);
    }

    function setSubmissionFee(uint256 _submissionPrice) external onlyOwner {
        submissionPrice = _submissionPrice;

        emit SetSubmissionFee(_submissionPrice);
    }

    function setTeamWallet(address _teamWallet) external onlyOwner {
        teamWallet = _teamWallet;
    }
}
