const amqp = require("amqplib");

let connection;
let channel;

const connectRabbitMQ = async () => {

    connection = await amqp.connect(
        process.env.RABBITMQ_URL
    );

    channel = await connection.createChannel();

    console.log("RabbitMQ connected");
};

const getChannel = () => {

    if (!channel) {
        throw new Error(
            "RabbitMQ channel is not initialized"
        );
    }

    return channel;
};

module.exports = {
    connectRabbitMQ,
    getChannel
};