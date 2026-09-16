const express = require("express");
const path = require("path");
const axios = require("axios");

const app = express();

const PORT = 5000;

// Flask backend URL
// Docker Compose will set this to http://backend:5001
const BACKEND_URL =
    process.env.BACKEND_URL || "http://localhost:5001";

// Middleware to read form data
app.use(express.urlencoded({ extended: true }));

// Serve files from public folder
app.use(express.static(path.join(__dirname, "public")));

// Home page
app.get("/", (req, res) => {
    res.sendFile(
        path.join(__dirname, "public", "index.html")
    );
});

// Submit form to Flask backend
app.post("/submit", async (req, res) => {

    const formData = new URLSearchParams();

    formData.append("name", req.body.name);
    formData.append("age", req.body.age);
    formData.append("city", req.body.city);

    try {

        const response = await axios.post(
            `${BACKEND_URL}/submit`,
            formData.toString(),
            {
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                }
            }
        );

        // Flask sends back the success page
        res.send(response.data);

    } catch (error) {

        console.error(
            "Error connecting to Flask backend:",
            error.message
        );

        res.status(500).send(`
            <h2>Error connecting to backend</h2>
            <p>${error.message}</p>
            <a href="/">Go Back</a>
        `);
    }
});

// Display submitted data
app.get("/data", async (req, res) => {

    try {

        // Ask Flask for submitted data
        const response = await axios.get(
            `${BACKEND_URL}/data`
        );

        const students = response.data;

        // Create table rows
        const rows = students.map(student => `
            <tr>
                <td>${student.name}</td>
                <td>${student.age}</td>
                <td>${student.city}</td>
            </tr>
        `).join("");

        // Send data.html with the rows inserted
        res.send(`
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport"
                    content="width=device-width, initial-scale=1.0">

                <title>Submitted Data</title>

                <link rel="stylesheet" href="/style.css">
            </head>

            <body>

                <div class="container data-container">

                    <h1>Submitted Data</h1>

                    ${
                        students.length > 0
                        ? `
                            <table>
                                <tr>
                                    <th>Name</th>
                                    <th>Age</th>
                                    <th>City</th>
                                </tr>

                                ${rows}
                            </table>
                        `
                        : `
                            <p class="no-data">
                                No student data submitted yet.
                            </p>
                        `
                    }

                    <a class="data-link" href="/">
                        ← Back to Form
                    </a>

                </div>

            </body>
            </html>
        `);

    } catch (error) {

        console.error(
            "Error fetching data:",
            error.message
        );

        res.status(500).send(`
            <h2>Error fetching data</h2>
            <p>${error.message}</p>
            <a href="/">Go Back</a>
        `);
    }
});

// Start Express server
app.listen(PORT, "0.0.0.0", () => {
    console.log(`Frontend running on port ${PORT}`);
});

