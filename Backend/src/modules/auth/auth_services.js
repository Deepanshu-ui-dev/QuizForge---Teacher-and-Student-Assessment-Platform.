const prisma = require("../../config/prisma");
const bcrypt = require("bcrypt");
const { generateToken } = require("../../utils/jwt");
const ConflictError = require("../../errors/ConflictError");
const UnauthorizedError = require("../../errors/UnauthorizedError");

const register = async (userData) => {

    const { name, email, password, role } = userData;

    const existingUser = await prisma.user.findUnique({
        where: {
            email
        }
    });

    if (existingUser) {
        throw new ConflictError("Email already exists");
    }

    const hashedPass = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
        data: {
            name,
            email,
            password: hashedPass,
            role: role === "ADMIN" ? "ADMIN" : "USER"
        }
    });
    delete user.password;

    return user;
};

const login = async ({ email, password }) => {

    const user = await prisma.user.findUnique({
        where: {
            email
        }
    });

    if (!user) {
        throw new UnauthorizedError("Invalid email or password");
    }

    const isMatch = await bcrypt.compare(
        password,
        user.password
    );

    if (!isMatch) {
        throw new UnauthorizedError("Invalid email or password");
    }

    const token = generateToken({
        id: user.id,
        email: user.email,
        role: user.role,
    });

    delete user.password;

    return {
        user,
        token
    };
};

module.exports = {
    register,
    login
};