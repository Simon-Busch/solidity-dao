//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Project is ReentrancyGuard, AccessControl {
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
        uint256 amount;
        uint256 livePeriod;
        uint256 votesFor;
        uint256 votesAgainst;
        string description;
        bool votingPassed;
        bool paid;
        address payable projectAddress;
        address proposer;
        address paidBy;
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

    // payProjects

    // make stake holder

    // get all proposals 

    // get a specific proposal

    // get stakeholder votes

    // get stakeholder balance 

    // check if is a stakeholder

    // get contributor balance

    // check if is a contributor 
}
