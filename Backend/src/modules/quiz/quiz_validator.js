const { z } = require("zod");

const createQuizSchema = z.object({
    title: z
        .string()
        .min(3, "Title must be at least 3 characters"),

    description: z
        .string()
        .min(10, "Description must be at least 10 characters"),

    duration: z
        .number()
        .positive("Duration must be greater than 0"),

    difficulty: z.enum([
        "EASY",
        "MEDIUM",
        "HARD"
    ])
});

const queryParamsSchema = z.object({
    page: z.string().regex(/^\d+$/, "Page must be a number").optional(),
    limit: z.string().regex(/^\d+$/, "Limit must be a number").optional(),
    search: z.string().max(100, "Search must be less than 100 characters").optional(),
    difficulty: z.enum(["EASY", "MEDIUM", "HARD"]).optional(),
    sortBy: z.enum(["title", "difficulty", "duration", "createdAt"]).optional(),
    sortOrder: z.enum(["ASC", "DESC"]).optional()
}).strict();

module.exports = {
    createQuizSchema,
    queryParamsSchema
};