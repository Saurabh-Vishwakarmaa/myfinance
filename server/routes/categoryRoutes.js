const express = require("express");
const router = express.Router();
const Category = require("../models/Category");

// Add a new category
router.post("/add", async (req, res) => {
    try {
        const { name } = req.body;
        const category = new Category({ name });
        await category.save();
        res.status(201).json({ message: "Category added successfully", category });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all categories
router.get("/", async (req, res) => {
    try {
        const categories = await Category.find();
        res.json(categories);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
