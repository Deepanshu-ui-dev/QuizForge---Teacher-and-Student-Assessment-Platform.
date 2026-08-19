const express = require("express");

const router = express.Router();

const authenticate = require("../../middleware/auth_middleware");
const authorize = require("../../middleware/role_middleware");
const validate = require("../../middleware/validator_middleware");

const quizController = require("./quiz_controller");

const {
    createQuizSchema,
    updateQuizSchema,
    queryParamsSchema
} = require("./quiz_validator");

router.get(
    "/",
    authenticate,
    validate(queryParamsSchema, "query"),
    quizController.getAllQuizzes
);

router.post(
    "/",
    authenticate,
    authorize("ADMIN"),
    validate(createQuizSchema),
    quizController.createQuiz
);

router.get("/:id", authenticate, quizController.getQuizById);

router.patch(
    "/:id",
    authenticate,
    authorize("ADMIN"),
    validate(updateQuizSchema),
    quizController.updateQuiz
);

router.delete(
    "/:id",
    authenticate,
    authorize("ADMIN"),
    quizController.deleteQuiz
);

module.exports = router;