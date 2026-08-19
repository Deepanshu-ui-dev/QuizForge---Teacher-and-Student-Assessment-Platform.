const prisma = require("../../config/prisma");

const BadRequestError =
    require("../../errors/BadRequestError");

const NotFoundError =
    require("../../errors/NotFoundError");

const ForbiddenError =
    require("../../errors/ForbiddenError");

const {
    publishEvent
} = require("../../events/publisher");

const {
    mapResultResponse,
    mapResultsResponse,
    mapResultDetailedResponse
} = require("./result_mapper");


const submitQuiz = async (
    quizId,
    userId,
    answers
) => {


    const id = Number(quizId);

    if (
        !Number.isInteger(id) ||
        id <= 0
    ) {
        throw new BadRequestError(
            "Invalid quiz ID"
        );
    }



    const quiz =
        await prisma.quiz.findUnique({
            where: {
                id
            }
        });

    if (!quiz) {
        throw new NotFoundError(
            "Quiz not found"
        );
    }



    const questions =
        await prisma.question.findMany({
            where: {
                quizId: id
            }
        });


    if (questions.length === 0) {

        throw new BadRequestError(
            "Quiz has no questions"
        );
    }



    if (
        !Array.isArray(answers) ||
        answers.length !== questions.length
    ) {

        throw new BadRequestError(
            "All questions must be answered"
        );
    }



    const questionMap =
        new Map(
            questions.map(question => [
                question.id,
                question
            ])
        );



    const submittedQuestionIds =
        new Set();


    let score = 0;
    let correctAnswers = 0;
    let wrongAnswers = 0;


    const attemptAnswers = [];


    for (
        const submittedAnswer of answers
    ) {

        const questionId =
            Number(
                submittedAnswer.questionId
            );

        if (
            submittedQuestionIds.has(
                questionId
            )
        ) {

            throw new BadRequestError(
                "Duplicate question submitted"
            );
        }


        submittedQuestionIds.add(
            questionId
        );

        const question =
            questionMap.get(questionId);


        if (!question) {

            throw new BadRequestError(
                `Question ${questionId} does not belong to this quiz`
            );
        }


        const isCorrect =
            submittedAnswer.answer ===
            question.correctAnswer;


        const marksAwarded =
            isCorrect
                ? question.marks
                : 0;


        if (isCorrect) {

            score += question.marks;

            correctAnswers++;

        } else {

            wrongAnswers++;
        }


        attemptAnswers.push({

            questionId,

            selectedAnswer:
                submittedAnswer.answer,

            correctAnswer:
                question.correctAnswer,

            isCorrect,

            marksAwarded,

            question: {
                question: question.question
            }
        });
    }


    const totalMarks =
        questions.reduce(
            (total, question) =>
                total + question.marks,
            0
        );



    const percentage =
        totalMarks > 0
            ? (score / totalMarks) * 100
            : 0;



    const result =
        await prisma.$transaction(
            async (tx) => {

                const createdResult =
                    await tx.result.create({
                        data: {
                            userId,
                            quizId: id,
                            score,
                            totalMarks,
                            percentage,
                            correctAnswers,
                            wrongAnswers
                        }
                    });


                await tx.attemptAnswer.createMany({

                    data:
                        attemptAnswers.map(
                            answer => ({

                                resultId:
                                    createdResult.id,

                                questionId:
                                    answer.questionId,

                                selectedAnswer:
                                    answer.selectedAnswer,

                                correctAnswer:
                                    answer.correctAnswer,

                                isCorrect:
                                    answer.isCorrect,

                                marksAwarded:
                                    answer.marksAwarded
                            })
                        )
                });


                return createdResult;
            }
        );


    try {
        publishEvent(
            "quiz.submitted",
            {
                resultId: result.id,
                userId,
                quizId: id,
                score,
                totalMarks,
                percentage,
                correctAnswers,
                wrongAnswers
            }
        );
    } catch (error) {
        console.error(
            "Failed to publish quiz.submitted event:",
            error.message
        );
    }


    return mapResultDetailedResponse({
        ...result,
        quiz: {
            id: quiz.id,
            title: quiz.title,
            difficulty: quiz.difficulty
        },
        answers: attemptAnswers
    });
};


const getMyResults = async (userId) => {

    const results = await prisma.result.findMany({
        where: {
            userId
        },
        include: {
            quiz: {
                select: {
                    id: true,
                    title: true,
                    difficulty: true
                }
            }
        },
        orderBy: {
            submittedAt: "desc"
        }
    });

    return mapResultsResponse(results);
};


const getResultById = async (id, user) => {

    const resultId = Number(id);

    if (!Number.isInteger(resultId) || resultId <= 0) {
        throw new BadRequestError("Invalid result ID");
    }

    const result = await prisma.result.findUnique({
        where: {
            id: resultId
        },
        include: {
            quiz: {
                select: {
                    id: true,
                    title: true,
                    difficulty: true
                }
            },
            user: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            },
            answers: {
                include: {
                    question: {
                        select: {
                            question: true
                        }
                    }
                }
            }
        }
    });

    if (!result) {
        throw new NotFoundError("Result not found");
    }

    if (result.userId !== user.id && user.role !== "ADMIN") {
        throw new ForbiddenError("You cannot view this result");
    }

    return mapResultDetailedResponse(result);
};


const getMyStats = async (userId) => {

    const aggregates = await prisma.result.aggregate({
        where: {
            userId
        },
        _count: {
            id: true
        },
        _avg: {
            percentage: true
        },
        _max: {
            percentage: true
        },
        _sum: {
            correctAnswers: true,
            wrongAnswers: true,
            score: true
        }
    });

    return {
        totalAttempts: aggregates._count.id,
        averagePercentage: aggregates._avg.percentage ?? 0,
        highestPercentage: aggregates._max.percentage ?? 0,
        totalCorrectAnswers: aggregates._sum.correctAnswers ?? 0,
        totalWrongAnswers: aggregates._sum.wrongAnswers ?? 0,
        totalScore: aggregates._sum.score ?? 0
    };
};


const getQuizResults = async (quizId) => {

    const id = Number(quizId);

    if (!Number.isInteger(id) || id <= 0) {
        throw new BadRequestError("Invalid quiz ID");
    }

    const quiz = await prisma.quiz.findUnique({
        where: {
            id
        }
    });

    if (!quiz) {
        throw new NotFoundError("Quiz not found");
    }

    const results = await prisma.result.findMany({
        where: {
            quizId: id
        },
        include: {
            quiz: {
                select: {
                    id: true,
                    title: true,
                    difficulty: true
                }
            },
            user: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            }
        },
        orderBy: {
            submittedAt: "desc"
        }
    });

    return mapResultsResponse(results);
};


const getAllResults = async (user) => {

    if (user.role === "ADMIN") {
        const results = await prisma.result.findMany({
            include: {
                quiz: {
                    select: {
                        id: true,
                        title: true,
                        difficulty: true
                    }
                },
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            },
            orderBy: {
                submittedAt: "desc"
            }
        });

        return mapResultsResponse(results);
    }

    return getMyResults(user.id);
};


module.exports = {
    submitQuiz,
    getMyResults,
    getResultById,
    getMyStats,
    getQuizResults,
    getAllResults
};
