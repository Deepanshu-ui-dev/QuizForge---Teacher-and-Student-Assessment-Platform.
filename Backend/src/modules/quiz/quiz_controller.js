const quizService = require("./quiz_services");

const createQuiz = async (req, res, next) => {
    try {
        const data = await quizService.createQuiz(
            req.body,
            req.user.id
        );

        res.status(201).json({
            success: true,
            message: "Quiz created successfully",
            data
        });
    } catch (error) {
        next(error);
    }
};

const getAllQuizzes = async (req, res, next) => {
    try {
        const result = await quizService.getAllQuizzes(req.query);

        res.status(200).json({
            success: true,
            message: "Quizzes retrieved successfully",
            ...result
        });
    } catch (error) {
        next(error);
    }
};


const getQuizById = async (req, res, next) => {
    try{
        const quizId=req.params.id;
        const result = await quizService.getQuizById(quizId);

        res.status(200).json({
            success: true,
            message: "Quiz retrieved successfully",
            data: result
        });


    }catch(error){
        next(error);
    }
}

const updateQuiz = async (req, res, next) => {
    try {
        const quizId = req.params.id;
        const result = await quizService.updateQuiz(quizId, req.body);

        res.status(200).json({
            success: true,
            message: "Quiz updated successfully",
            data: result
        });
    } catch (error) {
        next(error);
    }
};


const deleteQuiz = async (req, res, next) => {
    try {
        await quizService.deleteQuiz(req.params.id);
        res.status(200).json({ success: true, message: "Quiz deleted successfully" });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    createQuiz,
    getAllQuizzes,
    getQuizById,
    updateQuiz,
    deleteQuiz
};