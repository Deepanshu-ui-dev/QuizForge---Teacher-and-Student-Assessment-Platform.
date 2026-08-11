const {
    getChannel
} = require("../config/rabbitmq");

const EXCHANGE_NAME = "quiz.events";

const startQuizConsumer = async () => {

    const channel = getChannel();

    await channel.assertExchange(
        EXCHANGE_NAME,
        "topic",
        {
            durable: true
        }
    );

    const queue =
        await channel.assertQueue(
            "analytics.queue",
            {
                durable: true
            }
        );

    await channel.bindQueue(
        queue.queue,
        EXCHANGE_NAME,
        "quiz.submitted"
    );

    console.log(
        "Analytics consumer started"
    );

    channel.consume(
        queue.queue,
        (message) => {

            if (!message) {
                return;
            }

            const event =
                JSON.parse(
                    message.content.toString()
                );

            console.log(
                "Received event:",
                event
            );

            channel.ack(message);
        }
    );
};

module.exports = {
    startQuizConsumer
};