const express=require('express');

const router=express.Router();

const authenticate=require('../../middleware/auth_middleware');
const authorize=require('../../middleware/role_middleware');
const validate=require('../../middleware/validator_middleware');

const questionController=require('./question_controller');

const {createQuestionSchema, updateQuestionSchema}=require('./question_validator');

router.post('/', authenticate, authorize('ADMIN'), validate(createQuestionSchema), questionController.createQuestion);

router.get('/', authenticate, questionController.getAllQuestions);

router.get(
    "/quizzes/:quizId/questions",
    authenticate,
    questionController.getQuestionsByQuiz
);

router.patch(
    "/questions/:id",
    authenticate,
    authorize("ADMIN"),
    validate(updateQuestionSchema),
    questionController.updateQuestion
);

router.get('/:id', authenticate, questionController.getQuestionById);

router.put('/:id', authenticate, authorize('ADMIN'), validate(updateQuestionSchema), questionController.updateQuestion);

router.delete('/:id', authenticate, authorize('ADMIN'), questionController.deleteQuestion);

module.exports=router;