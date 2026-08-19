const resultService =
    require("./result_service");

const submitQuiz = async (
    req,
    res,
    next
) => {

    try {

        const result =
            await resultService.submitQuiz(

                req.params.quizId,

                req.user.id,

                req.body.answers
            );


        res.status(201).json({

            success: true,

            message:
                "Quiz submitted successfully",

            data: result
        });

    } catch (error) {

        next(error);

    }
};

const getMyResults = async (
    req,
    res,
    next
) => {

    try {

        const results =
            await resultService.getMyResults(
                req.user.id
            );


        res.status(200).json({

            success: true,

            data: results
        });

    } catch (error) {

        next(error);

    }
};

const getAllResults = async (
    req,
    res,
    next
) => {

    try {

        const results =
            await resultService.getAllResults(
                req.user
            );


        res.status(200).json({

            success: true,

            data: results
        });

    } catch (error) {

        next(error);

    }
};

const getQuizResults = async (
    req,
    res,
    next
) => {

    try {

        const results =
            await resultService.getQuizResults(
                req.params.quizId
            );


        res.status(200).json({

            success: true,

            data: results
        });

    } catch (error) {

        next(error);

    }
};

const getResultById = async (
    req,
    res,
    next
) => {

    try {

        const result =
            await resultService.getResultById(

                req.params.id,

                req.user
            );


        res.status(200).json({

            success: true,

            data: result
        });

    } catch (error) {

        next(error);

    }
};

const getMyStats = async (
    req,
    res,
    next
) => {

    try {

        const stats =
            await resultService.getMyStats(
                req.user.id
            );


        res.status(200).json({

            success: true,

            data: stats
        });

    } catch (error) {

        next(error);

    }
};


module.exports = {

    submitQuiz,

    getMyResults,

    getAllResults,

    getQuizResults,

    getResultById,

    getMyStats
};
