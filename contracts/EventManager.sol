// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EventManager {
    struct Event {
        uint id;
        string name;
        uint date;
        uint ticketCount;
        uint ticketPrice;
        address creator;
    }

    address public owner;
    mapping(address => bool) public isEventCreator;

    uint public eventCount = 0;
    mapping(uint => Event) public events;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyEventCreator() {
        require(isEventCreator[msg.sender], "Not authorized to create events");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEventCreator(address _account) public onlyOwner {
        isEventCreator[_account] = true;
    }

    function removeEventCreator(address _account) public onlyOwner {
        isEventCreator[_account] = false;
    }

    function createEvent(string memory _name, uint _date, uint _ticketCount, uint _ticketPrice) public onlyEventCreator {
        eventCount++;
        events[eventCount] = Event(eventCount, _name, _date, _ticketCount, _ticketPrice, msg.sender);
    }

    function getEvent(uint _eventId) public view returns (Event memory) {
        return events[_eventId];
    }

    function updateTicketCount(uint _eventId, uint _newTicketCount) public onlyEventCreator {
        require(events[_eventId].creator == msg.sender, "Only the creator can update the ticket count");
        events[_eventId].ticketCount = _newTicketCount;
    }
}
