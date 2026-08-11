require("dotenv").config();
const app = require("./app");
const PORT = process.env.PORT || 3000;
const { connectRedis } = require("./config/redis");

const startServer = async () => {

    try {

        await connectRedis();

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