const prisma = require("../../config/prisma");

const BadRequestError =
    require("../../errors/BadRequestError");

const NotFoundError =
    require("../../errors/NotFoundError");

const {
    publishEvent
} = require("../../events/publisher");


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

            marksAwarded
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


    return result;
};


module.exports = {
    submitQuiz
};