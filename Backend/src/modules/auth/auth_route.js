const express=require('express');

const router=express.Router();
const authController=require('./auth_controller');
const authenticate = require("../../middleware/auth_middleware");
const validate=require('../../middleware/validator_middleware');
const { registerSchema } = require("../../validations/auth_validator");

router.get("/profile", authenticate, authController.profile);
router.post('/register',validate(registerSchema),authController.register);
router.post("/login", authController.login);

module.exports=router;