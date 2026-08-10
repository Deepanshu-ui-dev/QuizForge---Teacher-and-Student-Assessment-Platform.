const mapQuestionAdminResponse = (question) => {

    if (!question) return null;

    return {
        id: question.id,

        question: question.question,

        options: {
            A: question.optionA,
            B: question.optionB,
            C: question.optionC,
            D: question.optionD
        },

        correctAnswer: question.correctAnswer,

        marks: question.marks,

        quizId: question.quizId
    };
};


const mapQuestionStudentResponse = (question) => {

    if (!question) return null;

    return {
        id: question.id,

        question: question.question,

        options: {
            A: question.optionA,
            B: question.optionB,
            C: question.optionC,
            D: question.optionD
        },

        marks: question.marks
    };
};


const mapQuestions = (questions, mapper) => {
    return questions.map(mapper);
};


module.exports = {
    mapQuestionAdminResponse,
    mapQuestionStudentResponse,
    mapQuestions
};