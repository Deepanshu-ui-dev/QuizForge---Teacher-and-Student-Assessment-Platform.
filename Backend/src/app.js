const express= require('express');
const cors=require('cors');
const helmet=require('helmet');
const morgan=require('morgan');

const app=express();


/*---- Middlewares --*/
app.use(cors());
app.use(helmet());
app.use(morgan('common'));
app.use(express.json());



const userRoute=require('./routes/user_route');

app.use("/users",userRoute);

app.get('/',(req,res)=>{
    res.send("quiz microservices backend is running");
})

module.exports=app;