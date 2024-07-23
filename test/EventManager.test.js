const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { ethers } = require("hardhat");


describe("EventManager contract", function () {
  async function deployEventManagerFixture() {
    // Ottieni i Signers
    const [owner, addr1, addr2] = await ethers.getSigners();

    // Ottieni il factory del contratto
    const EventManager = await ethers.getContractFactory("EventManager");
    
    // Deploy del contratto
    const eventManager = await EventManager.deploy();

    // Ritorna i valori utili per i test
    return { eventManager, owner, addr1, addr2 };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { eventManager, owner } = await loadFixture(deployEventManagerFixture);
      expect(await eventManager.owner()).to.equal(owner.address);
    });
  });

  describe("Event Management", function () {
    it("Should allow the owner to add an event creator", async function () {
      const { eventManager, owner, addr1 } = await loadFixture(deployEventManagerFixture);
      await eventManager.addEventCreator(addr1.address);
      expect(await eventManager.isEventCreator(addr1.address)).to.be.true;
    });

    it("Should allow event creators to create events", async function () {
      const { eventManager, addr1 } = await loadFixture(deployEventManagerFixture);
      await eventManager.addEventCreator(addr1.address);
      await eventManager.connect(addr1).createEvent("Concerto", Date.now() + 3600, 100, ethers.utils.parseEther("0.1"));
      const event = await eventManager.getEvent(1);
      expect(event.name).to.equal("Concerto");
    });
  });

  describe("Transactions", function () {
    it("Should transfer ownership of an event", async function () {
      const { eventManager, owner, addr1 } = await loadFixture(deployEventManagerFixture);
      await eventManager.addEventCreator(addr1.address);
      await eventManager.connect(addr1).createEvent("Concerto", Date.now() + 3600, 100, ethers.utils.parseEther("0.1"));

      await eventManager.connect(addr1).transferEventOwnership(1, owner.address);
      const event = await eventManager.getEvent(1);
      expect(event.owner).to.equal(owner.address);
    });

    it("Should emit EventCreated events", async function () {
      const { eventManager, addr1 } = await loadFixture(deployEventManagerFixture);
      await eventManager.addEventCreator(addr1.address);

      await expect(
        eventManager.connect(addr1).createEvent("Concerto", Date.now() + 3600, 100, ethers.utils.parseEther("0.1"))
      )
        .to.emit(eventManager, "EventCreated")
        .withArgs(1, addr1.address, "Concerto", Date.now() + 3600, 100, ethers.utils.parseEther("0.1"));
    });

    it("Should fail if a non-creator tries to create an event", async function () {
      const { eventManager, addr2 } = await loadFixture(deployEventManagerFixture);
      await expect(
        eventManager.connect(addr2).createEvent("Concerto", Date.now() + 3600, 100, ethers.utils.parseEther("0.1"))
      ).to.be.revertedWith("Not an event creator");
    });
  });
});
