// file: vulnerable.js

const express = require('express');
const mysql = require('mysql2');
const app = express();

app.use(express.json());

// Create a connection to the database
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password',
    database: 'testdb',
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err);
        return;
    }
    console.log('Connected to the database.');
});

// Vulnerable route
app.get('/search', (req, res) => {
    const userInput = req.query.username;

    // SQL Injection vulnerability: user input is directly included in the query
    const query = `SELECT * FROM users WHERE username = '${userInput}'`;

    db.query(query, (err, results) => {
        if (err) {
            console.error('Database query error:', err);
            res.status(500).send('Internal server error');
            return;
        }
        res.json(results);
    });
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
