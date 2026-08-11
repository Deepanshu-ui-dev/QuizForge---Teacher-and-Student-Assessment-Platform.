const ForbiddenError =
    require("../errors/ForbiddenError");

const authorize = (...allowedRoles) => {

    return (req, res, next) => {

        if (!req.user) {

            return next(
                new ForbiddenError(
                    "User not authenticated"
                )
            );
        }


        if (
            !allowedRoles.includes(
                req.user.role
            )
        ) {

            return next(
                new ForbiddenError(
                    "You do not have permission"
                )
            );
        }


        next();
    };
};

module.exports = authorize;