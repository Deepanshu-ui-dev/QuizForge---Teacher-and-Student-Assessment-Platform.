const validate = (schema, source = "body") => {
    return (req, res, next) => {
        const payload = source === "query" ? req.query : (req.body ?? {});
        const result = schema.safeParse(payload);

        if (!result.success) {
            return res.status(400).json({
                success: false,
                message: result.error.issues[0].message
            });
        }

        if (source === "query") {
            req.query = result.data;
        } else {
            req.body = result.data;
        }

        next();
    };
};

module.exports = validate;
