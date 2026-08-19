const authService = require('./auth_services');

const register = async (req, res, next) => {
    try {
        const user = await authService.register(req.body);

        res.status(201).json({
            success: true,
            data: user
        });
    } catch (error) {
        next(error);
    }
};

const login = async (req, res, next) => {
    try {
        const result = await authService.login(req.body);

        res.status(200).json({
            success: true,
            data: result
        });
    } catch (error) {
        next(error);
    }
};

const profile = async (req, res) => {

    res.json({
        success: true,
        data: req.user
    });

};

module.exports={
    register,
    login,
    profile
}