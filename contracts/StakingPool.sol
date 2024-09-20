// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract StakingPool {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public rewardRate;
    uint256 public totalStaked;
    address public owner;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        bool active;
    }

    mapping(address => Stake) public stakes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier hasStake() {
        require(stakes[msg.sender].active, "No active stake found");
        _;
    }

    constructor(address _stakingToken, address _rewardToken, uint256 _rewardRate) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
        owner = msg.sender;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(stakingToken.transferFrom(msg.sender, address(this), _amount), "Staking failed");

        if (stakes[msg.sender].active) {
            uint256 reward = calculateRewards(msg.sender);
            require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
        }

        stakes[msg.sender] = Stake(_amount, block.timestamp, true);
        totalStaked += _amount;
    }

    function withdraw() external hasStake {
        uint256 stakedAmount = stakes[msg.sender].amount;
        uint256 reward = calculateRewards(msg.sender);
        require(stakingToken.balanceOf(address(this)) >= stakedAmount, "Insufficient staking token balance");
        require(rewardToken.balanceOf(address(this)) >= reward, "Insufficient reward token balance");

        require(stakingToken.transfer(msg.sender, stakedAmount), "Staked token transfer failed");
        require(rewardToken.transfer(msg.sender, reward), "Reward transfer failed");
        totalStaked -= stakedAmount;
        stakes[msg.sender].active = false;
    }

    function calculateRewards(address _staker) public view returns (uint256) {
        Stake memory userStake = stakes[_staker];
        uint256 stakingDuration = block.timestamp - userStake.startTime;
        uint256 rewardAmount = stakingDuration * userStake.amount * rewardRate / 1e18;
        return rewardAmount;
    }

    function fundRewards(uint256 _amount) external onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), _amount), "Funding rewards failed");
    }

    function viewStakes(address _user) external view returns (uint256 amount, uint256 rewards) {
        return (stakes[_user].amount, calculateRewards(_user));
    }
    function checkTheReward(address _sender, address _spender) external view returns(uint) {
        return rewardToken.allowance(_sender,_spender);
    }
    function stakedToken() external view returns(uint) {
        return stakingToken.balanceOf(address(this));
    }

}
