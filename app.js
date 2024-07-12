const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
const port = process.env.PORT || 3000;

// Replace with your actual database credentials
const pool = mysql.createPool({
  host: 'mysql-2f0ea9d3-abhinavppradeep-253c.i.aivencloud.com',
  user: 'avnadmin',
  password: 'AVNS_34uivaQ7o-mOeYQmmyf',
  database: 'defaultdb',
  port: '27710',
});

app.use(express.json()); // Parse incoming JSON data

// Endpoint to insert attendance data
app.post('/api/attendance', async (req, res) => {
  const { name, action } = req.body;

  if (!name || !action) {
    return res.status(400).send({ message: 'Please provide name and action (IN or OUT)' });
  }

  try {
    const singaporeDate = new Date(); // Assuming server is in Singapore timezone
    const formattedDate = singaporeDate.toISOString().slice(0, 19).replace('T', ' ');

    // Insert attendance record into 'attendance' table
    const [rows, fields] = await pool.query('INSERT INTO attendance (name, timestamp, action) VALUES (?, ?, ?)', [name, formattedDate, action]);

    res.status(201).send({ message: 'Attendance record inserted successfully' });
  } catch (error) {
    console.error('Error inserting attendance record:', error);
    res.status(500).send({ message: 'Error inserting attendance record' });
  }
});

// Endpoint to get all attendance records
app.get('/api/attendance', async (req, res) => {
  try {
    const [rows, fields] = await pool.query('SELECT * FROM attendance');

    // Transform data to a custom JSON format if needed
    const attendanceRecords = rows.map(row => ({
      id: row.id,
      name: row.name,
      timestamp: row.timestamp.toLocaleString(), // Convert timestamp to a readable format
      action: row.action,
    }));

    res.json({ attendanceRecords });
  } catch (error) {
    console.error('Error fetching attendance records:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Endpoint to get last 10 attendance records
app.get('/api/last-10-attendance', async (req, res) => {
  try {
    const [rows, fields] = await pool.query('SELECT * FROM attendance ORDER BY id DESC LIMIT 10');
    res.json(rows);
  } catch (error) {
    console.error('Error fetching last 10 attendance records:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Change the server to listen on the specified IP address and port
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
