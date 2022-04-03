//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// STAKEHOLDER > CONTRIBUTOR
contract ProjectDao is ReentrancyGuard, AccessControl {
    // as per OpenZepellin ReentrancyGuard and AccessControl here so we should go ahead and import those
    // important security features
    // Users of the DAO will be of two types - Contributors and Stakeholders
    // These constants will be used later to register and differentiate users.

    bytes32 public constant CONTRIBUTOR_ROLE = keccak256("CONTRIBUTOR");
    bytes32 public constant STAKEHOLDER_ROLE = keccak256("STAKEHOLDER");

    // holds the number of days a proposal can be voted on in UNIX time
    uint32 public constant MINIMUM_VOTING_PERIOD = 1 weeks;

    // is incremented every time a new proposal is added
    uint256 public numOfProposals;

    // definition holds the necessary data that makes up each proposal object
    struct ProjectProposal {
        uint256 id;
        uint256 amount; // amount of votes
        uint256 livePeriod; // duration of the project proposal
        uint256 votesFor; // number of votes for the project
        uint256 votesAgainst; // number of vote against the project
        string description;
        bool votingPassed; // voting still on ?
        bool paid; // is it paid ? 
        address payable projectAddress; // address of the project to pay
        address proposer; // person that introducted the project
        address paidBy; // who paid
    }

    // It uses the id of the Proposal as key and the Proposal itself as the value.
    mapping(uint256 => ProjectProposal) private projectProposals;
    // maps the address of a Stakeholder to a list of the Proposals that address has voted on.
    mapping(address => uint256[]) private stakeholderVotes;
    // maps the Contributor addresses and the amounts they have sent into the DAO treasury.
    mapping(address => uint256) private contributors;
    // maps the addresses and balances of Stakeholders.
    mapping(address => uint256) private stakeholders;

    // emitted for every new proposal, new contribution and new payment transfer.
    event ContributionReceived(address indexed fromAddress, uint256 amount);
    event NewProjectProposal(address indexed proposer, uint256 amount);
    event PaymentTransfered(
        address indexed stakeholder,
        address indexed projectAddress,
        uint256 amount
    );

    constructor () payable {
        // set up role for creator of the contract
        stakeholders[msg.sender] = 10;
        contributors[msg.sender] = 10;
        _setupRole(STAKEHOLDER_ROLE, msg.sender);
        _setupRole(CONTRIBUTOR_ROLE, msg.sender);
    }

    modifier onlyStakeholder(string memory message) {
        // hasRole --> openZeppelin AccessControl contract
        require(hasRole(STAKEHOLDER_ROLE, msg.sender), message);
        _;
    }

    modifier onlyContributor(string memory message) {
        // hasRole --> openZeppelin AccessControl contract
        require(hasRole(CONTRIBUTOR_ROLE, msg.sender), message);
        _;
    }

    function createProposal(
        string calldata _description,
        address _projectAddress,
        uint256 _amount
    )
        external
        onlyStakeholder("Only stakeholders are allowed to create proposals")
    {
        uint256 proposalId = numOfProposals++;

        ProjectProposal storage proposal = projectProposals[proposalId];
        proposal.id = proposalId;
        proposal.proposer = payable(msg.sender);
        proposal.description = _description;
        proposal.projectAddress = payable(_projectAddress);
        proposal.amount = _amount;
        proposal.livePeriod = block.timestamp + MINIMUM_VOTING_PERIOD;
        emit NewProjectProposal(msg.sender, _amount);
    }

    function vote(uint256 proposalId, bool supportProposal)
        external
        onlyStakeholder("Only stakeholders are allowed to vote")
    {
        ProjectProposal storage proposal = projectProposals[proposalId];

        _votable(proposal);

        if (supportProposal) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        stakeholderVotes[msg.sender].push(proposal.id);
    }

    function _votable(ProjectProposal storage proposal) private {
        if ( proposal.votingPassed || proposal.livePeriod <= block.timestamp) {
            proposal.votingPassed = true;
            revert("Voting period over");
        }

        uint256[] memory tempVotes = stakeholderVotes[msg.sender];
        for (uint256 votes = 0; votes < tempVotes.length; votes++) {
            if (proposal.id == tempVotes[votes]) {
                revert("Stakeholder already voted");
            }
        }
    }

    // handles payment to the specified address after the voting period of the proposal has ended and is valid
    function payProject(uint256 proposalId)
        external
        onlyStakeholder("Only stakeholders are allowed to make payments")
    {
        ProjectProposal storage proposal = projectProposals[proposalId];
        require(!proposal.paid, "payment already done");
        require(proposal.votesFor > proposal.votesAgainst, "not enough votes");
        
        (bool sent, ) = proposal.projectAddress.call{value: proposal.amount}("");
        require(sent, "Transfer failed");

        proposal.paid = true;
        proposal.paidBy = msg.sender;

        emit PaymentTransfered(
            msg.sender,
            proposal.projectAddress,
            proposal.amount
        );
        // return proposal.projectAddress.transfer(proposal.amount);
    }

    function makeStakeholder(uint256 amount) external {
        address account = msg.sender;
        uint256 amountContributed = amount;
        if (!hasRole(STAKEHOLDER_ROLE, account)) {
            uint256 totalContributed = contributors[account] + amountContributed;
            if (totalContributed >= 5 ether) {
                stakeholders[account] = totalContributed;
                contributors[account] += amountContributed;
                _setupRole(STAKEHOLDER_ROLE, account);
                _setupRole(CONTRIBUTOR_ROLE, account);
            } else {
                contributors[account] += amountContributed;
                _setupRole(CONTRIBUTOR_ROLE, account);
            }
        } else {
            contributors[account] += amountContributed;
            stakeholders[account] += amountContributed;
        }
    }


    function getProposals() public view returns (ProjectProposal[] memory props) {
        //declare an array with the length of numOfProposals which is icremented automatically
        props = new ProjectProposal[](numOfProposals);

        // assign the proposal at the current index to the index in our fixed-size array
        for (uint256 i = 0; i < numOfProposals; i++) {
            props[i] = projectProposals[i];
        }
    }

    function getProposal(uint256 proposalId) public view returns (ProjectProposal memory) {
        return projectProposals[proposalId];
    }

    // returns a list containing the id of all the proposals that a particular stakeholder has voted on.
    function getStakeholderVotes () public view onlyStakeholder("User is not a stakeholder") returns (uint256[]memory) {
        return stakeholderVotes[msg.sender];
    }

    // return the total amount of contribution a stakeholder has contributed to the DAO
    function getStakeholderBalance() public view onlyStakeholder("User is not a stakeholder") returns (uint256) {
        return stakeholders[msg.sender];
    }

    function isStakeholder() public view returns (bool) {
        return stakeholders[msg.sender] > 0;
    }

    function getContributorBalance() public view onlyContributor("User is not a contributor") returns (uint256) {
        return contributors[msg.sender];
    }


    function isContributor() public view returns (bool) {
        return contributors[msg.sender] > 0;
    }

    // This is needed so the contract can receive contributions without throwing an error
    receive() external payable {
        emit ContributionReceived(msg.sender, msg.value);
    }
}
