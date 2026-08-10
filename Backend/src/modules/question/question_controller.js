const questionService = require('./question_server');

const createQuestion = async (req, res, next) => {
    try {
        const { quizId, ...questionData } = req.body;
        const createdQuestion = await questionService.createQuestion(quizId, questionData);

        res.status(201).json({
            success: true,
            data: createdQuestion
        });
    } catch (error) {
        next(error);
    }
};

const getAllQuestions = async (req, res, next) => {
    try {
        const questions = await questionService.getAllQuestions(req.user.role);

        res.status(200).json({
            success: true,
            data: questions
        });
    } catch (error) {
        next(error);
    }
};


const getQuestionsByQuiz = async (req, res, next) => {

    try {

        const questions = await questionService.getQuestionsByQuiz(
            req.params.quizId,
            req.user.role
        );

        res.status(200).json({
            success: true,
            data: questions
        });

    } catch (error) {
        next(error);
    }
};

const getQuestionById = async (req, res, next) => {

    try {

        const question = await questionService.getQuestionById(
            req.params.id,
            req.user.role
        );

        res.status(200).json({
            success: true,
            data: question
        });

    } catch (error) {
        next(error);
    }
};

const updateQuestion = async (req, res, next) => {
    try {
        const updatedQuestion = await questionService.updateQuestion(req.params.id, req.body);

        res.status(200).json({
            success: true,
            data: updatedQuestion
        });
    } catch (error) {
        next(error);
    }
};

const deleteQuestion = async (req, res, next) => {

    try {

        await questionService.deleteQuestion(
            req.params.id
        );

        res.status(204).send();

    } catch (error) {
        next(error);
    }
};

module.exports = {
    createQuestion,
    getAllQuestions,
    getQuestionsByQuiz,
    getQuestionById,
    updateQuestion,
    deleteQuestion
};