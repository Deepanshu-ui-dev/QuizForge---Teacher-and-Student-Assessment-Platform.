const { verifyToken } = require("../utils/jwt");

const authenticate = (req, res, next) => {

    try {

        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(401).json({
                success: false,
                message: "Access token required"
            });
        }

        const [scheme, token] = authHeader.split(" ");

        if (scheme !== "Bearer" || !token) {
            return res.status(401).json({
                success: false,
                message: "Invalid access token format"
            });
        }

        const decoded = verifyToken(token);

        req.user = decoded;

        next();

    } catch (error) {

      next(error);

    }

};

module.exports = authenticate;