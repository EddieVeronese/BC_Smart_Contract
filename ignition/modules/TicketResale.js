const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("TicketResaleModule", (m) => {
  // Deploy del contratto EventManager
  const eventManager = m.contract("EventManager");

  // Deploy del contratto TicketManager con il riferimento a EventManager
  const ticketManager = m.contract("TicketManager", [eventManager]);

  // Deploy del contratto ResaleManager con il riferimento a TicketManager
  const resaleManager = m.contract("ResaleManager", [ticketManager]);

  return { eventManager, ticketManager, resaleManager };
});
