const {
    getChannel
} = require("../config/rabbitmq");

const EXCHANGE_NAME = "quiz.events";

const publishEvent = (
    eventName,
    data
) => {

    try {
        const channel = getChannel();

        channel.assertExchange(
            EXCHANGE_NAME,
            "topic",
            {
                durable: true
            }
        );

        const message = {
            event: eventName,
            timestamp: new Date().toISOString(),
            data
        };

        channel.publish(
            EXCHANGE_NAME,
            eventName,
            Buffer.from(
                JSON.stringify(message)
            ),
            {
                persistent: true
            }
        );

        console.log(
            `Event published: ${eventName}`
        );
    } catch (error) {
        console.error(
            `Failed to publish event ${eventName}:`,
            error.message
        );
    }
};

module.exports = {
    publishEvent
};
