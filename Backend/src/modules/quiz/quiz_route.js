const express = require("express");

const router = express.Router();

const authenticate = require("../../middleware/auth_middleware");
const authorize = require("../../middleware/role_middleware");
const validate = require("../../middleware/validator_middleware");

const quizController = require("./quiz_controller");

const {
    createQuizSchema,
    queryParamsSchema
} = require("./quiz_validator");

// GET all quizzes with pagination, search, filter, and sort
router.get(
    "/",
    authenticate,
    validate(queryParamsSchema),
    quizController.getAllQuizzes
);

// POST create quiz (admin only)
router.post(
    "/",
    authenticate,
    authorize("ADMIN"),
    validate(createQuizSchema),
    quizController.createQuiz
);


router.get("/:id", authenticate, quizController.getQuizById);

module.exports = router;