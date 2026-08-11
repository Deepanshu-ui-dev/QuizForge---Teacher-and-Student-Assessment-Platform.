const mapResultResponse = (result) => {

    if (!result) return null;

    return {
        id: result.id,

        quiz: result.quiz
            ? {
                  id: result.quiz.id,
                  title: result.quiz.title,
                  difficulty: result.quiz.difficulty
              }
            : null,

        score: result.score,

        totalMarks: result.totalMarks,

        percentage: result.percentage,

        correctAnswers: result.correctAnswers,

        wrongAnswers: result.wrongAnswers,

        submittedAt: result.submittedAt
    };
};


const mapResultsResponse = (results) => {

    return results.map(mapResultResponse);

};


const mapResultDetailedResponse = (result) => {

    if (!result) return null;

    return {
        id: result.id,

        quiz: result.quiz
            ? {
                  id: result.quiz.id,
                  title: result.quiz.title,
                  difficulty: result.quiz.difficulty
              }
            : null,

        score: result.score,

        totalMarks: result.totalMarks,

        percentage: result.percentage,

        correctAnswers: result.correctAnswers,

        wrongAnswers: result.wrongAnswers,

        submittedAt: result.submittedAt,

        answers: result.answers
            ? result.answers.map(answer => ({
                  questionId: answer.questionId,

                  question: answer.question
                      ? answer.question.question
                      : null,

                  selectedAnswer:
                      answer.selectedAnswer,

                  correctAnswer:
                      answer.correctAnswer,

                  isCorrect:
                      answer.isCorrect,

                  marksAwarded:
                      answer.marksAwarded
              }))
            : []
    };
};


module.exports = {
    mapResultResponse,
    mapResultsResponse,
    mapResultDetailedResponse
};