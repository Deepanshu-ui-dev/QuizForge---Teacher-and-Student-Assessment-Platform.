const errorMiddleware = (err, req, res, next) => {

    console.error(err);

    let statusCode = err.statusCode || 500;

    let message =
        err.message ||
        "Internal Server Error";

    if (err.code === "P2002") {

        statusCode = 409;

        message =
            "A record with this value already exists";
    }


    if (err.code === "P2025") {

        statusCode = 404;

        message =
            "Requested record was not found";
    }


    res.status(statusCode).json({

        success: false,

        message

    });
};

module.exports = errorMiddleware;