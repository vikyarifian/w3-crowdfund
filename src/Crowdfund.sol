// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfund {
    struct Campaign {
        uint256 id;
        address payable creator;
        string title;
        string description;
        uint256 targetAmount;
        uint256 totalRaised;
        uint256 deadline;
        bool claimed;
        bool active;
    }

    uint256 public campaignCount;

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event CampaignCreated(
        uint256 indexed id,
        address indexed creator,
        string title,
        uint256 targetAmount,
        uint256 deadline
    );
    event ContributionReceived(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );
    event FundsClaimed(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 amount
    );
    event RefundClaimed(
        uint256 indexed campaignId,
        address indexed contributor,
        uint256 amount
    );

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _targetAmount,
        uint256 _durationInDays
    ) public returns (uint256) {
        require(_targetAmount > 0, "Target amount must be greater than zero");
        require(_durationInDays > 0, "Duration must be at least 1 day");

        campaignCount++;
        uint256 newId = campaignCount;
        uint256 deadline = block.timestamp + (_durationInDays * 1 days);

        campaigns[newId] = Campaign({
            id: newId,
            creator: payable(msg.sender),
            title: _title,
            description: _description,
            targetAmount: _targetAmount,
            totalRaised: 0,
            deadline: deadline,
            claimed: false,
            active: true
        });

        emit CampaignCreated(newId, msg.sender, _title, _targetAmount, deadline);
        return newId;
    }

    function contribute(uint256 _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.active, "Campaign is not active");
        require(block.timestamp < campaign.deadline, "Campaign deadline has passed");
        require(msg.value > 0, "Contribution must be greater than zero");

        contributions[_campaignId][msg.sender] += msg.value;
        campaign.totalRaised += msg.value;

        emit ContributionReceived(_campaignId, msg.sender, msg.value);
    }

    function claimFunds(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(msg.sender == campaign.creator, "Only campaign creator can claim");
        require(campaign.totalRaised >= campaign.targetAmount, "Target amount not reached");
        require(!campaign.claimed, "Funds already claimed");

        campaign.claimed = true;
        campaign.active = false;
        uint256 amount = campaign.totalRaised;

        (bool sent, ) = campaign.creator.call{value: amount}("");
        require(sent, "Failed to send ETH to creator");

        emit FundsClaimed(_campaignId, campaign.creator, amount);
    }

    function refund(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");
        require(campaign.totalRaised < campaign.targetAmount, "Target was reached, no refund");

        uint256 amount = contributions[_campaignId][msg.sender];
        require(amount > 0, "No contribution to refund");

        contributions[_campaignId][msg.sender] = 0;
        campaign.totalRaised -= amount;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send ETH for refund");

        emit RefundClaimed(_campaignId, msg.sender, amount);
    }

    function getCampaign(uint256 _campaignId) external view returns (Campaign memory) {
        return campaigns[_campaignId];
    }

    function getContribution(
        uint256 _campaignId,
        address _contributor
    ) external view returns (uint256) {
        return contributions[_campaignId][_contributor];
    }
}
