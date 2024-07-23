const TicketResale = require("../ignition/modules/TicketResale");


async function main() {

    const { eventManager, ticketManager, resaleManager } = await hre.ignition.deploy(TicketResale);

    // Log degli indirizzi dei contratti distribuiti
    console.log(`EventManager deployed to: ${await eventManager.getAddress()}`);
    console.log(`TicketManager deployed to: ${await ticketManager.getAddress()}`);
    console.log(`ResaleManager deployed to: ${await resaleManager.getAddress()}`);
}

main().catch(console.error);
