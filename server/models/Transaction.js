const mongoose =  require("mongoose")

const transactionSchema = new mongoose.Schema({

    title:{
        type: String,
        required: true,
    },
    amount:{
     type:  Number,
     required: true,
    },
    type: {
type: String,
enum: ["income","expense"], required: true
    },

    category: {
        type : mongoose.Schema.Types.ObjectId,
        ref : "Category"
    },
    date: {
        type: Date,
        default: Date.now
    }



})


const Transaction = mongoose.model("Transaction", transactionSchema);
module.exports = Transaction;