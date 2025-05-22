const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

dotenv.config();
const app = express();

// ✅ Middleware
app.use(express.json()); // Parse JSON
app.use(cors({ origin: '*' }));
app.options('*', cors());

// ✅ PostgreSQL connection (Railway)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

const JWT_SECRET = process.env.JWT_SECRET;

// ✅ Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// ✅ Register route
app.post('/register', async (req, res) => {
  console.log('Received body:', req.body); // ✅ log incoming data

  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Missing email or password' });
  }

  try {
    const hash = await bcrypt.hash(password, 10);

    await pool.query(
      'INSERT INTO users (email, password) VALUES ($1, $2)',
      [email, hash]
    );

    return res.status(200).json({ success: true, message: 'User registered' }); // ✅ clean response
  } catch (e) {
    console.error('Register error:', e.message);
    return res.status(400).json({
      success: false,
      message: 'User already exists or DB error',
      details: e.message,
    });
  }
});

// ✅ Login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Missing email or password' });
  }

  try {
    const result = await pool.query(
      'SELECT password FROM users WHERE email = $1',
      [email]
    );

    const user = result.rows[0];

    if (user && await bcrypt.compare(password, user.password)) {
      const token = jwt.sign({ email }, JWT_SECRET, { expiresIn: '1h' });
      return res.json({ token });
    }

    return res.status(401).json({ error: 'Invalid credentials' });
  } catch (e) {
    return res.status(500).json({ error: 'Server error' });
  }
});

// ✅ Delete account
app.delete('/delete', async (req, res) => {
  const auth = req.headers.authorization || '';
  const token = auth.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const { email } = jwt.verify(token, JWT_SECRET);
    await pool.query('DELETE FROM users WHERE email = $1', [email]);
    res.send('Account deleted');
  } catch (err) {
    res.status(403).json({ error: 'Invalid token' });
  }
});

// ✅ DB test
app.get('/db-test', async (_req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({ time: result.rows[0].now });
  } catch (err) {
    res.status(500).json({ error: 'Database connection failed', details: err.message });
  }
});

// ✅ Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend API running on http://0.0.0.0:${PORT}`);
});
