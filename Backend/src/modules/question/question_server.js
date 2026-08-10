const prisma = require("../../config/prisma");

const BadRequestError = require("../../errors/BadRequestError");
const NotFoundError = require("../../errors/NotFoundError");

const {
    mapQuestionAdminResponse,
    mapQuestionStudentResponse
} = require("./question.mapper");


const createQuestion = async (quizId, data) => {

    const id = Number(quizId);

    if (!Number.isInteger(id) || id <= 0) {
        throw new BadRequestError("Invalid quiz ID");
    }

    const quiz = await prisma.quiz.findUnique({
        where: { id }
    });

    if (!quiz) {
        throw new NotFoundError("Quiz not found");
    }

    const question = await prisma.question.create({
        data: {
            question: data.question,
            optionA: data.optionA,
            optionB: data.optionB,
            optionC: data.optionC,
            optionD: data.optionD,
            correctAnswer: data.correctAnswer,
            marks: data.marks,
            quizId: id
        }
    });

    return mapQuestionAdminResponse(question);
};

const getAllQuestions = async (userRole) => {

    const questions = await prisma.question.findMany({
        orderBy: {
            id: "asc"
        }
    });

    if (userRole === "ADMIN") {
        return questions.map(mapQuestionAdminResponse);
    }

    return questions.map(mapQuestionStudentResponse);
};


const getQuestionsByQuiz = async (quizId, userRole) => {

    const id = Number(quizId);

    if (!Number.isInteger(id) || id <= 0) {
        throw new BadRequestError("Invalid quiz ID");
    }

    const quiz = await prisma.quiz.findUnique({
        where: { id }
    });

    if (!quiz) {
        throw new NotFoundError("Quiz not found");
    }

    const questions = await prisma.question.findMany({
        where: {
            quizId: id
        },
        orderBy: {
            id: "asc"
        }
    });

    if (userRole === "ADMIN") {
        return questions.map(mapQuestionAdminResponse);
    }

    return questions.map(mapQuestionStudentResponse);
};

const getQuestionById = async (id, userRole) => {

    const questionId = Number(id);

    if (!Number.isInteger(questionId) || questionId <= 0) {
        throw new BadRequestError("Invalid question ID");
    }

    const question = await prisma.question.findUnique({
        where: {
            id: questionId
        }
    });

    if (!question) {
        throw new NotFoundError(
            `Question with ID ${questionId} not found`
        );
    }

    if (userRole === "ADMIN") {
        return mapQuestionAdminResponse(question);
    }

    return mapQuestionStudentResponse(question);
};


const updateQuestion = async (id, data) => {

    const questionId = Number(id);

    if (!Number.isInteger(questionId) || questionId <= 0) {
        throw new BadRequestError("Invalid question ID");
    }

    const existingQuestion = await prisma.question.findUnique({
        where: {
            id: questionId
        }
    });

    if (!existingQuestion) {
        throw new NotFoundError("Question not found");
    }

    const updatedQuestion = await prisma.question.update({
        where: {
            id: questionId
        },
        data: {
            ...(data.question !== undefined && {
                question: data.question
            }),

            ...(data.optionA !== undefined && {
                optionA: data.optionA
            }),

            ...(data.optionB !== undefined && {
                optionB: data.optionB
            }),

            ...(data.optionC !== undefined && {
                optionC: data.optionC
            }),

            ...(data.optionD !== undefined && {
                optionD: data.optionD
            }),

            ...(data.correctAnswer !== undefined && {
                correctAnswer: data.correctAnswer
            }),

            ...(data.marks !== undefined && {
                marks: data.marks
            })
        }
    });

    return mapQuestionAdminResponse(updatedQuestion);
};


const deleteQuestion = async (id) => {

    const questionId = Number(id);

    if (!Number.isInteger(questionId) || questionId <= 0) {
        throw new BadRequestError("Invalid question ID");
    }

    const question = await prisma.question.findUnique({
        where: {
            id: questionId
        }
    });

    if (!question) {
        throw new NotFoundError("Question not found");
    }

    await prisma.question.delete({
        where: {
            id: questionId
        }
    });
};


module.exports = {
    createQuestion,
    getAllQuestions,
    getQuestionsByQuiz,
    getQuestionById,
    updateQuestion,
    deleteQuestion
};
