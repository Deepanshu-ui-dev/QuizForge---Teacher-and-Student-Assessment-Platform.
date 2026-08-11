

const mapQuizToResponse = (quiz) => {
    if (!quiz) return null;

    return {
        id: quiz.id,
        title: quiz.title,
        description: quiz.description,
        duration: quiz.duration,
        difficulty: quiz.difficulty,
        createdAt: quiz.createdAt,
        creator: quiz.creator ? {
            id: quiz.creator.id,
            name: quiz.creator.name,
            email: quiz.creator.email
        } : null,
        stats: quiz._count ? {
            totalQuestions: quiz._count.questions,
            totalResults: quiz._count.results
        } : {
            totalQuestions: 0,
            totalResults: 0
        }
    };
};

const mapQuizzesToResponse = (quizzes) => {
    return quizzes.map(mapQuizToResponse);
};


const mapQuizDetailedToResponse = (quiz) => {
    const baseResponse = mapQuizToResponse(quiz);
    return {
        ...baseResponse,
        updatedAt: quiz.updatedAt || quiz.createdAt,
    };
};


const mapPaginatedResponse = (quizzes, pagination) => {
    return {
        data: mapQuizzesToResponse(quizzes),
        pagination: {
            page: pagination.page,
            limit: pagination.limit,
            total: pagination.total,
            pages: pagination.pages,
            hasNext: pagination.page < pagination.pages,
            hasPrev: pagination.page > 1
        }
    };
};

module.exports = {
    mapQuizToResponse,
    mapQuizzesToResponse,
    mapQuizDetailedToResponse,
    mapPaginatedResponse
};
