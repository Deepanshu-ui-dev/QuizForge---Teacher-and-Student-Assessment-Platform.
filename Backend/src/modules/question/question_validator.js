const { z } = require("zod");

const createQuestionSchema = z.object({
	quizId: z.number().int().positive("Quiz ID must be greater than 0"),
	question: z.string().min(3, "Question must be at least 3 characters"),
	optionA: z.string().min(1, "Option A is required"),
	optionB: z.string().min(1, "Option B is required"),
	optionC: z.string().min(1, "Option C is required"),
	optionD: z.string().min(1, "Option D is required"),
	correctAnswer: z.enum(["A", "B", "C", "D"]),
	marks: z.number().int().positive("Marks must be greater than 0")
});

const updateQuestionSchema = z.object({
	question: z.string().min(3, "Question must be at least 3 characters").optional(),
	optionA: z.string().min(1, "Option A is required").optional(),
	optionB: z.string().min(1, "Option B is required").optional(),
	optionC: z.string().min(1, "Option C is required").optional(),
	optionD: z.string().min(1, "Option D is required").optional(),
	correctAnswer: z.enum(["A", "B", "C", "D"]).optional(),
	marks: z.number().int().positive("Marks must be greater than 0").optional()
}).strict();

module.exports = {
	createQuestionSchema,
	updateQuestionSchema
};
