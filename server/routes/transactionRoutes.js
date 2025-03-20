const express  = require("express")
const router = express.Router();
const Transaction = require("../models/Transaction")


router.post("/add",async (req, res) => {
    try {
        const {title, amount, type, category } = req.body;
        const transaction = new Transaction({title, amount, type, category })
        await transaction.save()
        res.status(201).json({message: "Transaction added Successfully", transaction})
    } catch (error) {
        res.status(500).json({ error: error.message });
    }

})

router.get("/",async (req,res) =>{
    try {
        const transactions = await Transaction.find().populate("category");
        res.json(transactions);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
})

router.delete('/:id', async (req,res) =>{
    try {
        await Transaction.findByIdAndDelete(req.params.id);
        res.join({message: "Transaction deleted"});
    } catch (error) {
        res.status(500).json({error:error.message})
    }
})


module.exports = router;