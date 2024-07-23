// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./EventManager.sol";

contract TicketManager {
    EventManager eventManager;

    struct Ticket {
        uint eventId;
        uint ticketId;
        address owner;
    }

    uint public ticketCounter = 0;
    mapping(uint => Ticket) public tickets;
    mapping(uint => uint[]) public eventTickets;

    constructor(address _eventManagerAddress) {
        eventManager = EventManager(_eventManagerAddress);
    }

    modifier onlyTicketOwner(uint _ticketId) {
        require(tickets[_ticketId].owner == msg.sender, "Not authorized");
        _;
    }

    function buyTicket(uint _eventId) public payable {
        EventManager.Event memory eventDetails = eventManager.getEvent(_eventId);
        require(eventDetails.ticketCount > 0, "No tickets available");
        require(msg.value == eventDetails.ticketPrice, "Incorrect amount sent");

        ticketCounter++;
        tickets[ticketCounter] = Ticket(_eventId, ticketCounter, msg.sender);
        eventTickets[_eventId].push(ticketCounter);

        // Transfer funds to the event creator
        payable(eventDetails.creator).transfer(msg.value);

        // Decrease the ticket count
        eventManager.updateTicketCount(_eventId, eventDetails.ticketCount - 1);
    }

    function getTicket(uint _ticketId) public view returns (Ticket memory) {
        return tickets[_ticketId];
    }

    function updateTicketOwner(uint _ticketId, address _newOwner) public onlyTicketOwner(_ticketId) {
        tickets[_ticketId].owner = _newOwner;
    }
}
