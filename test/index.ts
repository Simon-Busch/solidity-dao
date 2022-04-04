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

  describe("Creating a proposal", function () {
    it("Should be restricted to the stakeholder", async function () {
      const isStake: boolean = await projectDaoContract
        .connect(owner[1])
        .isStakeholder();
      expect(isStake).to.be.false;
    });
    it("should be able to create a proposal", async function () {
      await projectDaoContract.createProposal(
        "make me king",
        "0x8887d92b863ACc546cd7372B4627de39548F85c4",
        500
      );
      const proposalList = await projectDaoContract.getProposals();
      expect(proposalList.length).to.be.greaterThan(0);
    });
  });
});
