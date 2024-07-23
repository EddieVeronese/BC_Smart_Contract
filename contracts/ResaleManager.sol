// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TicketManager.sol";

contract ResaleManager {
    TicketManager ticketManager;

    struct Resale {
        uint ticketId;
        uint price;
        address seller;
    }

    mapping(uint => Resale) public resales;

    constructor(address _ticketManagerAddress) {
        ticketManager = TicketManager(_ticketManagerAddress);
    }

    modifier onlyTicketOwner(uint _ticketId) {
        require(ticketManager.getTicket(_ticketId).owner == msg.sender, "Not authorized");
        _;
    }

    function listTicketForResale(uint _ticketId, uint _price) public onlyTicketOwner(_ticketId) {
        resales[_ticketId] = Resale(_ticketId, _price, msg.sender);
    }

    function buyResaleTicket(uint _ticketId) public payable {
        Resale memory resale = resales[_ticketId];
        require(msg.value == resale.price, "Incorrect amount sent");

        // Transfer ticket ownership
        ticketManager.updateTicketOwner(_ticketId, msg.sender);

        // Transfer funds to the seller
        payable(resale.seller).transfer(msg.value);

        // Remove resale listing
        delete resales[_ticketId];
    }
}
