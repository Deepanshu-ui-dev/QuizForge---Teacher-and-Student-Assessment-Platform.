const prisma = require("../../config/prisma");
const bcrypt = require("bcrypt");
const { generateToken } = require("../../utils/jwt");

const register = async (userData) => {

    const { name, email, password } = userData;

    const existingUser = await prisma.user.findUnique({
        where: {
            email
        }
    });

    if (existingUser) {
        throw new Error("Email already exists");
    }
    const hashedPass= await bcrypt.hash(password,10);

    const user = await prisma.user.create({
        data: {
            name,
            email,
            password: hashedPass,
            role:"USER"
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
        throw new Error("Invalid email or password");
    }

    const isMatch = await bcrypt.compare(
        password,
        user.password
    );

    if (!isMatch) {
        throw new Error("Invalid email or password");
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