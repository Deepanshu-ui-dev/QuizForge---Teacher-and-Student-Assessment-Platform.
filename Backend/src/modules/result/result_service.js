const prisma = require("../../config/prisma");

const BadRequestError = require("../../errors/BadRequestError");
const NotFoundError = require("../../errors/NotFoundError");

const {
    mapResultResponse,
    mapResultsResponse,
    mapResultDetailedResponse
} = require("./result_mapper");

const submitQuiz = async (quizId, userId, answers) => {

    const id = Number(quizId);

    if (!Number.isInteger(id) || id <= 0) {
        throw new BadRequestError(
            "Invalid quiz ID"
        );
    }

    const quiz = await prisma.quiz.findUnique({
        where: {
            id
        }
    });

    if (!quiz) {
        throw new NotFoundError(
            "Quiz not found"
        );
    }

    const questions = await prisma.question.findMany({
        where: {
            quizId: id
        }
    });

    if (questions.length === 0) {
        throw new BadRequestError(
            "Quiz has no questions"
        );
    }

    if (answers.length !== questions.length) {
        throw new BadRequestError(
            "All questions must be answered"
        );
    }

    const questionMap = new Map(
        questions.map(question => [
            question.id,
            question
        ])
    );

    const submittedQuestionIds = new Set();

    let score = 0;
    let correctAnswers = 0;
    let wrongAnswers = 0;

    const attemptAnswers = [];

    for (const submittedAnswer of answers) {

        if (
            submittedQuestionIds.has(
                submittedAnswer.questionId
            )
        ) {
            throw new BadRequestError(
                "Duplicate question submitted"
            );
        }

        submittedQuestionIds.add(
            submittedAnswer.questionId
        );

        const question = questionMap.get(
            submittedAnswer.questionId
        );

        if (!question) {
            throw new BadRequestError(
                `Question ${submittedAnswer.questionId} does not belong to this quiz`
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

            questionId: question.id,

            selectedAnswer:
                submittedAnswer.answer,

            correctAnswer:
                question.correctAnswer,

            isCorrect,

            marksAwarded

        });
    }

    const totalMarks = questions.reduce(
        (total, question) =>
            total + question.marks,
        0
    );


    const percentage =
        (score / totalMarks) * 100;

    const result = await prisma.$transaction(
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

                data: attemptAnswers.map(answer => ({

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
                }))
            });


            return createdResult;
        }
    );


    return mapResultResponse(result);
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

const getResultById = async (
    resultId,
    userId
) => {

    const id = Number(resultId);


    if (!Number.isInteger(id) || id <= 0) {

        throw new BadRequestError(
            "Invalid result ID"
        );
    }


    const result =
        await prisma.result.findFirst({

            where: {

                id,

                userId
            },


            include: {

                quiz: {
                    select: {
                        id: true,
                        title: true,
                        difficulty: true
                    }
                },

                answers: {

                    include: {

                        question: {
                            select: {
                                id: true,
                                question: true
                            }
                        }
                    },


                    orderBy: {
                        questionId: "asc"
                    }
                }
            }
        });


    if (!result) {

        throw new NotFoundError(
            "Result not found"
        );
    }


    return mapResultDetailedResponse(
        result
    );
};

const getMyStats = async (userId) => {

    const stats =
        await prisma.result.aggregate({

            where: {
                userId
            },


            _avg: {

                percentage: true,

                score: true
            },


            _max: {

                percentage: true,

                score: true
            },


            _count: {

                id: true
            }
        });


    return {

        totalAttempts:
            stats._count.id,

        averagePercentage:
            stats._avg.percentage || 0,

        averageScore:
            stats._avg.score || 0,

        bestPercentage:
            stats._max.percentage || 0,

        bestScore:
            stats._max.score || 0
    };
};


module.exports = {

    submitQuiz,

    getMyResults,

    getResultById,

    getMyStats
};