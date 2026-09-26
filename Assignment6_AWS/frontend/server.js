const express = require("express");
const axios = require("axios");

const app = express();

const PORT = 3000;
const FLASK_BACKEND = "http://backend:5000";

// Middleware
app.use(express.json());
app.use(express.static("public"));

// Serve the frontend
app.get("/", (req, res) => {
    res.sendFile(__dirname + "/public/index.html");
});

// ----------------------------------------
// GET REQUEST
// Express calls Flask /api/hello
// ----------------------------------------

app.get("/api/backend-data", async (req, res) => {
    try {
        const response = await axios.get(
            `${FLASK_BACKEND}/api/hello`
        );

        res.json(response.data);

    } catch (error) {
        console.error(error.message);
        res.status(500).json({
            message: "Could not connect to Flask backend"
        });
    }
});

// ----------------------------------------
// POST REQUEST
// Express sends name to Flask /api/data
// ----------------------------------------

app.post("/api/send-name", async (req, res) => {
    try {
        const response = await axios.post(
            `${FLASK_BACKEND}/api/data`,
            req.body
        );
        res.json(response.data);

    } catch (error) {
        console.error(error.message);
        res.status(500).json({
            message: "Could not send data to Flask backend"
        });
    }
});


// Start Express server
app.listen(PORT, () => {
    console.log(
        `Express frontend running on http://localhost:${PORT}`
    );
});