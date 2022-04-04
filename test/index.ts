/* eslint-disable no-unused-expressions */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
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
  });

  describe("Stakeholder ----", function () {
    it("Creator of the contract should be a stakeholder", async function () {
      const isStake: boolean = await projectDaoContract.isStakeholder();
      expect(isStake).to.be.true;
    });
  });

  describe("Verify constants", function () {
    it("Minimum voting period should be a week", async function () {
      const votingPeriod: number =
        await projectDaoContract.MINIMUM_VOTING_PERIOD();
      expect(votingPeriod / 60 / 60 / 7).to.be.equal(24);
    });
  });
});
