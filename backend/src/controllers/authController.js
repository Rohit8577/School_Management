const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

const register = async (req, res) => {
  try {
    const { name, email, password, role, roleId, department, phone, classId, rollNumber, parentName, parentPhone, dateOfBirth } = req.body;

    // Validation
    if (!name || !email || !password || !role) {
      return res.status(400).json({ message: 'Please provide name, email, password and role' });
    }

    if (!['student', 'teacher', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role. Must be student, teacher, or admin.' });
    }

    // Check if user already exists
    const userExists = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ message: 'User with this email already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Insert base user
    const newUser = await db.query(
      'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id, name, email, role',
      [name, email, hashedPassword, role]
    );

    const userId = newUser.rows[0].id;

    // Insert into role-specific table
    if (role === 'student') {
      const studentId = roleId || `STU${userId.toString().padStart(5, '0')}`;
      await db.query(
        'INSERT INTO students (user_id, student_id, class_id, roll_number, parent_name, parent_phone, date_of_birth) VALUES ($1, $2, $3, $4, $5, $6, $7)',
        [userId, studentId, classId || null, rollNumber || null, parentName || null, parentPhone || null, dateOfBirth || null]
      );
    } else if (role === 'teacher') {
      const teacherId = roleId || `TCH${userId.toString().padStart(5, '0')}`;
      await db.query(
        'INSERT INTO teachers (user_id, teacher_id, department, phone) VALUES ($1, $2, $3, $4)',
        [userId, teacherId, department || null, phone || null]
      );
    } else if (role === 'admin') {
      await db.query(
        'INSERT INTO admins (user_id, admin_email) VALUES ($1, $2)',
        [userId, email]
      );
    }

    // Generate token
    const token = jwt.sign(
      { id: userId, role: role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: newUser.rows[0],
      token
    });

  } catch (error) {
    console.error('Registration Error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

const login = async (req, res) => {
  try {
    const { identifier, password, role } = req.body;

    if (!identifier || !password || !role) {
      return res.status(400).json({ message: 'Please provide identifier, password, and role' });
    }

    let user;

    if (role === 'student') {
      // Login with student_id
      const result = await db.query(
        `SELECT u.*, s.student_id, s.class_id, s.roll_number 
         FROM users u 
         JOIN students s ON u.id = s.user_id 
         WHERE s.student_id = $1 AND u.role = 'student'`,
        [identifier]
      );
      user = result.rows[0];
    } else if (role === 'teacher') {
      // Login with teacher_id
      const result = await db.query(
        `SELECT u.*, t.teacher_id, t.department 
         FROM users u 
         JOIN teachers t ON u.id = t.user_id 
         WHERE t.teacher_id = $1 AND u.role = 'teacher'`,
        [identifier]
      );
      user = result.rows[0];
    } else if (role === 'admin') {
      // Login with admin email
      const result = await db.query(
        `SELECT u.*, a.admin_email, a.designation 
         FROM users u 
         JOIN admins a ON u.id = a.user_id 
         WHERE a.admin_email = $1 AND u.role = 'admin'`,
        [identifier]
      );
      user = result.rows[0];
    } else {
      return res.status(400).json({ message: 'Invalid role' });
    }

    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    // Remove password from response
    const { password: _, ...userData } = user;

    res.status(200).json({
      message: 'Login successful',
      user: userData,
      token
    });

  } catch (error) {
    console.error('Login Error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
};

module.exports = { register, login };
