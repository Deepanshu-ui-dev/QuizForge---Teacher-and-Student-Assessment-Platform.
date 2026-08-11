const { z } = require("zod");

const submitQuizSchema = z.object({
    answers: z
        .array(
            z.object({
                questionId: z.number().int().positive(),

                answer: z.enum([
                    "A",
                    "B",
                    "C",
                    "D"
                ])
            })
        )
        .min(1)
});

module.exports = {
    submitQuizSchema
};