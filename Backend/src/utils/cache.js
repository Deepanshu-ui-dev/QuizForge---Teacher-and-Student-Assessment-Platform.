const {
    redisClient
} = require("../config/redis");


const getCache = async (key) => {

    try {

        const data =
            await redisClient.get(key);

        if (!data) {
            return null;
        }

        return JSON.parse(data);

    } catch (error) {

        console.error(
            "Redis GET error:",
            error
        );

        return null;
    }
};


const setCache = async (
    key,
    value,
    expirationInSeconds = 300
) => {

    try {

        await redisClient.set(
            key,
            JSON.stringify(value),
            {
                EX: expirationInSeconds
            }
        );

    } catch (error) {

        console.error(
            "Redis SET error:",
            error
        );
    }
};


const deleteCache = async (key) => {

    try {

        await redisClient.del(key);

    } catch (error) {

        console.error(
            "Redis DELETE error:",
            error
        );
    }
};


module.exports = {
    getCache,
    setCache,
    deleteCache
};