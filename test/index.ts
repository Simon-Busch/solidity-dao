/* eslint-disable no-unused-expressions */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { ProjectDao } from "../typechain";

describe("Tests for the Project DAO ---------", function () {
  let ProjectDao;
  let projectDaoContract: ProjectDao;
  let owner: SignerWithAddress[];
  beforeEach(async () => {
    ProjectDao = await ethers.getContractFactory("ProjectDao");
    projectDaoContract = await ProjectDao.deploy();
    await projectDaoContract.deployed();
    owner = await ethers.getSigners();
  });

  describe("Contributor ----", function () {
    it("Creator of the contract should be a contributor", async function () {
      const isContri: boolean = await projectDaoContract.isContributor();
      expect(isContri).to.be.true;
    });

    it("Contributor initial balance should be 10", async function () {
      const initialBalance: BigNumber =
        await projectDaoContract.getContributorBalance();
      expect(initialBalance).to.be.equal(10);
    });
  });

  describe("Stakeholder ----", function () {
    it("Creator of the contract should be a stakeholder", async function () {
      const isStake: boolean = await projectDaoContract.isStakeholder();
      expect(isStake).to.be.true;
    });

    it("Contributor initial balance should be 10", async function () {
      const initialBalance: BigNumber =
        await projectDaoContract.getStakeholderBalance();
      expect(initialBalance).to.be.equal(10);
    });
  });

  describe("Verify constants", function () {
    it("Minimum voting period should be a week", async function () {
      const votingPeriod: number =
        await projectDaoContract.MINIMUM_VOTING_PERIOD();
      expect(votingPeriod / 60 / 60 / 7).to.be.equal(24);
    });
  });

  describe("Proposals ----", function () {
    let proposalList;
    beforeEach(async () => {
      await projectDaoContract.createProposal(
        "make me king",
        "0x8887d92b863ACc546cd7372B4627de39548F85c4",
        20
      );
      proposalList = await projectDaoContract.getProposals();
    });
    it("Creation should be restricted to the stakeholder", async function () {
      const isStake: boolean = await projectDaoContract
        .connect(owner[1])
        .isStakeholder();
      expect(isStake).to.be.false;
    });
    it("Should be able to create a proposal", async function () {
      expect(proposalList.length).to.be.greaterThan(0);
    });
    it("Should have an id of 0", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.id.toNumber()).to.be.equal(0);
    });
    it("Should have an requested amount of votes equal to 20", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.amount.toNumber()).to.be.equal(20);
    });
    it("Should have a live period of minimum one week", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.livePeriod.toNumber() / 60 / 60 / 7).to.be.greaterThan(
        24
      );
    });
    it("Should have an initial about of votes -for- of 0", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.votesFor.toNumber()).to.be.equal(0);
    });
    it("Should have an initial about of votes -again- of 0", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.votesAgainst.toNumber()).to.be.equal(0);
    });
    it("Should have a description", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.description).to.be.equal("make me king");
    });
    it("Should not be accepted yet", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.votingPassed).to.be.false;
    });
    it("Should not be paid yet", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.paid).to.be.false;
    });
    it("Should have an address for the project", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.projectAddress).to.be.equal(
        "0x8887d92b863ACc546cd7372B4627de39548F85c4"
      );
    });
    it("Should have a proposer", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.proposer).to.be.equal(owner[0].address);
    });
    it("Should have a zero address for paidBy", async function () {
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.paidBy).to.be.equal(
        "0x0000000000000000000000000000000000000000"
      );
    });
  });

  describe("Voting -----", function () {
    it("should be able to vote for a project", async function () {
      await projectDaoContract.vote(0, true);
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.votesFor).to.be.equal(1);
    });

    it("should be able to against a project", async function () {
      await projectDaoContract.vote(0, false);
      const firstProp = await projectDaoContract.getProposal(0);
      expect(firstProp.votesAgainst).to.be.equal(1);
    });
  });
});
