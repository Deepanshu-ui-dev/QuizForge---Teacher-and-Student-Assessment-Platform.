const jwt = require("jsonwebtoken");

const UnauthorizedError =
    require("../errors/UnauthorizedError");

const authenticate = (req, res, next) => {

    try {

        const authHeader =
            req.headers.authorization;

        if (!authHeader) {

            throw new UnauthorizedError(
                "Authorization header is required"
            );
        }


        const [type, token] =
            authHeader.split(" ");


        if (
            type !== "Bearer" ||
            !token
        ) {

            throw new UnauthorizedError(
                "Invalid authorization format"
            );
        }


        const decoded =
            jwt.verify(
                token,
                process.env.JWT_SECRET
            );


        req.user = decoded;

        next();

    } catch (error) {

        if (
            error.name ===
            "JsonWebTokenError"
        ) {

            return next(
                new UnauthorizedError(
                    "Invalid token"
                )
            );
        }


        if (
            error.name ===
            "TokenExpiredError"
        ) {

            return next(
                new UnauthorizedError(
                    "Token expired"
                )
            );
        }


        next(error);
    }
};

module.exports = authenticate;