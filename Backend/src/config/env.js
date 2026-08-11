const requiredEnv = [
    "DATABASE_URL",
    "JWT_SECRET"
];

for (const key of requiredEnv) {

    if (!process.env[key]) {

        throw new Error(
            `${key} environment variable is missing`
        );
    }
}

module.exports = {
    port: Number(process.env.PORT) || 5000,

    nodeEnv:
        process.env.NODE_ENV || "development"
};