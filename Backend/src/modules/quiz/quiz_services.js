const prisma = require("../../config/prisma");
const { mapQuizToResponse, mapPaginatedResponse, mapQuizDetailedToResponse } = require("./quiz.mapper");
const BadRequestError = require("../../errors/BadRequestError");
const NotFoundError = require("../../errors/NotFoundError");
const { getCache, setCache, deleteCache } = require("../../utils/cache");

const createQuiz = async (quizData, userId) => {
    const quiz = await prisma.quiz.create({
        data: {
            ...quizData,
            createdBy: userId
        },
        include: {
            creator: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            }
        }
    });
    return mapQuizToResponse(quiz);
};

const getAllQuizzes = async (query) => {
    const page = Math.max(Number(query.page) || 1, 1);
    const limit = Math.max(Math.min(Number(query.limit) || 10, 100), 1);
    const search = query.search || "";
    const difficulty = query.difficulty;
    const sortBy = query.sortBy || "createdAt";
    const sortOrder = query.sortOrder?.toUpperCase() === "DESC" ? "desc" : "asc";

    const skip = (page - 1) * limit;

    const where = {};

    if (search.trim()) {
        where.OR = [
            {
                title: {
                    contains: search,
                    mode: "insensitive"
                }
            },
            {
                description: {
                    contains: search,
                    mode: "insensitive"
                }
            }
        ];
    }

    if (difficulty && ["EASY", "MEDIUM", "HARD"].includes(difficulty)) {
        where.difficulty = difficulty;
    }

    const orderBy = {};
    if (["title", "difficulty", "duration", "createdAt"].includes(sortBy)) {
        orderBy[sortBy] = sortOrder;
    } else {
        orderBy.createdAt = "desc";
    }

    const total = await prisma.quiz.count({ where });

    const quizzes = await prisma.quiz.findMany({
        where,
        select: {
            id: true,
            title: true,
            description: true,
            duration: true,
            difficulty: true,
            createdAt: true,
            creator: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            },
            _count: {
                select: {
                    questions: true,
                    results: true
                }
            }
        },
        orderBy,
        skip,
        take: limit
    });

    const pagination = {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
    };

    return mapPaginatedResponse(quizzes, pagination);
};


const getQuizById=async(quizId)=>{
    const parsedQuizId = Number(quizId);

    if (Number.isNaN(parsedQuizId)) {
        throw new BadRequestError("Invalid quiz id");
    }

    const cacheKey = `quiz:${parsedQuizId}`;
    const cachedQuiz = await getCache(cacheKey);

    if (cachedQuiz) {
        return cachedQuiz;
    }

    const quiz=await prisma.quiz.findUnique({
        where:{
            id:parsedQuizId
        },
        select:{
            id:true,
            title:true,
            description:true,
            duration:true,
            difficulty:true,
            createdAt:true,
            creator:{
                select:{
                    id:true,
                    name:true,
                    email:true
                }
            },
            _count:{
                select:{
                    questions:true,
                    results:true
                }
            }
        }
    });

    if(!quiz){
        throw new NotFoundError("Quiz not found");
    }

    const mappedQuiz = mapQuizToResponse(quiz);
    await setCache(cacheKey, mappedQuiz, 300);

    return mappedQuiz;
}

const updateQuiz = async (id, data) => {

    const quizId = Number(id);

    if (Number.isNaN(quizId)) {
        throw new BadRequestError("Invalid quiz id");
    }

    const existingQuiz = await prisma.quiz.findUnique({
        where: {
            id: quizId
        }
    });

    if (!existingQuiz) {
        throw new NotFoundError("Quiz not found");
    }

    const updatedQuiz = await prisma.quiz.update({
        where: {
            id: quizId
        },
        data,
        include: {
            creator: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            },
            _count: {
                select: {
                    questions: true,
                    results: true
                }
            }
        }
    });

    await deleteCache(`quiz:${quizId}`);

    return mapQuizDetailedToResponse(updatedQuiz);
};

const deleteQuiz = async (id) => {
    const quizId = Number(id);

    if (Number.isNaN(quizId)) {
        throw new BadRequestError("Invalid quiz id");
    }

    const existingQuiz = await prisma.quiz.findUnique({
        where: { id: quizId }
    });

    if (!existingQuiz) {
        throw new NotFoundError("Quiz not found");
    }

    await prisma.$transaction([
        prisma.attemptAnswer.deleteMany({
            where: { result: { quizId } }
        }),
        prisma.result.deleteMany({ where: { quizId } }),
        prisma.question.deleteMany({ where: { quizId } }),
        prisma.quiz.delete({ where: { id: quizId } })
    ]);

    await deleteCache(`quiz:${quizId}`);
};

module.exports = {
    createQuiz,
    getAllQuizzes,
    getQuizById,
    updateQuiz,
    deleteQuiz
};      
