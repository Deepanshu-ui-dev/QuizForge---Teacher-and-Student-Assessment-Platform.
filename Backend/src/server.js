const fs = require("fs");
const path = require("path");

require("dotenv").config();

const isDocker = fs.existsSync("/.dockerenv");
const localEnvPath = path.resolve(__dirname, "../.env.local");

if (!isDocker && fs.existsSync(localEnvPath)) {
    require("dotenv").config({ path: localEnvPath, override: true });
}
const app = require("./app");
const PORT = process.env.PORT || 5000;
const { connectRedis } = require("./config/redis");
const { connectRabbitMQ } = require("./config/rabbitmq");
const { startQuizConsumer } = require("./events/consumer");

const startServer = async () => {

    try {

        await connectRedis();
        await connectRabbitMQ();
        await startQuizConsumer();

        app.listen(PORT, () => {

            console.log(
                `Server running on port ${PORT}`
            );

        });

    } catch (error) {

        console.error(
            "Failed to start server:",
            error
        );

        process.exit(1);
    }
};

startServer();