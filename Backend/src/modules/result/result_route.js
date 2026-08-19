const express = require("express");

const router = express.Router();

const authenticate =
    require("../../middleware/auth_middleware");

const authorize =
    require("../../middleware/role_middleware");

const validate =
    require("../../middleware/validator_middleware");

const resultController =
    require("./result_controller");

const {
    submitQuizSchema
} = require("./result_validator");

router.post(

    "/quizzes/:quizId/attempts",

    authenticate,

    validate(submitQuizSchema),

    resultController.submitQuiz
);

router.get(

    "/quizzes/:quizId/results",

    authenticate,

    authorize("ADMIN"),

    resultController.getQuizResults
);

router.get(

    "/results",

    authenticate,

    resultController.getAllResults
);

router.get(

    "/results/my",

    authenticate,

    resultController.getMyResults
);

router.get(

    "/results/stats",

    authenticate,

    resultController.getMyStats
);

router.get(

    "/results/:id",

    authenticate,

    resultController.getResultById
);


module.exports = router;
