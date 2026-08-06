const express =require('express');

const router=express.Router();

const prisma=require('../config/prisma');

router.post("/",async(req,res)=>{
   try {
        const { name, email, password } = req.body;

        const user = await prisma.user.create({
            data: {
                name,
                email,
                password
            }
        });

        res.status(201).json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({
            message: "Internal Server Error"
        });
    }

});

router.get("/", async (req, res) => {
    try {
        const users = await prisma.user.findMany();

        res.json(users);

    } catch (error) {
        res.status(500).json({
            message: "Internal Server Error"
        });
    }
});


router.get("/:id",async (req, res) => {
    try {
        const id = Number(req.params.id);
        const user = await prisma.user.findUnique({
            where: {
                id: id
            }
        });

        if (!user) {
            return res.status(404).json({
                message: "User not found"
            });
        }

        res.json(user);
    } catch (error) {
        res.status(500).json({
            message: "Internal Server Error"
        });
    }
});

router.put("/:id", async (req, res) => {

    const id = Number(req.params.id);

    const { name } = req.body;

    const user = await prisma.user.update({
        where: {
            id
        },
        data: {
            name
        }
    });

    res.json(user);
});


router.delete("/:id", async (req, res) => {

    const id = Number(req.params.id);

    await prisma.user.delete({
        where: {
            id
        }
    });

    res.json({
        message: "User deleted"
    });
});


module.exports=router;