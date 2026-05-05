import mongoose from "mongoose";
import { required } from "zod/mini";

const userSchema=new mongoose.Schema({
    
    email:{
        type:String,
        required:[true,"email is required"],
        unique:true
    },
    password:{
        type:String,
        required:[true,"password is required"],
    },

})

const User=mongoose.models.users||mongoose.model("users",userSchema);

export default User;