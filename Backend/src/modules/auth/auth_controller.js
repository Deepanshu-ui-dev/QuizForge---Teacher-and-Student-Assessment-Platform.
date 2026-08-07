const authService = require('./auth_services');

const register= async(req,res)=>{
    try{
        const user=await authService.register(req.body);

        res.status(201).json({
            sucess: true,
            data:user
        })
    }
    catch(error){
        res.status(400).json({
            sucess: false,
            message: error.message
        })
    }
}

const login = async (req, res) => {

    try {

        const result = await authService.login(req.body);

        res.status(200).json({
            success: true,
            data: result
        });

    } catch (error) {

        res.status(401).json({
            success: false,
            message: error.message
        });

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