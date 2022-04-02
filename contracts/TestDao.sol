//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TestDao is ReentrancyGuard, AccessControl {
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

    mapping(uint256 => ProjectProposal) private projectProposal;
    mapping(address => uint256[]) private stakeholderVotes;
    mapping(address => uint256) private contributors;
    mapping(address => uint256) private stakeholders;

}
