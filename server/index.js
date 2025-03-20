const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const cors = require("cors");

dotenv.config();
const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// MongoDB Connection
const DB = 'mongodb+srv://saurabh:saurabh@cluster0.af3sf.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0'
mongoose.connect(DB, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log("✅ MongoDB Connection Successful"))
    .catch((e) => console.log("❌ MongoDB Connection Error:", e.message));

// Import Routes
const transactionRoutes = require("./routes/transactionRoutes");
const categoryRoutes = require("./routes/categoryRoutes");

// Use Routes
app.use("/api/transactions", transactionRoutes);
app.use("/api/categories", categoryRoutes);

// Start Server
app.listen(port, () => {
    console.log(`🚀 Server is running on port ${port}`);
});
