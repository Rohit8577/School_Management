const express = require('express');
const router = express.Router();
const { getTeacherDashboard, getStudentDashboard, getAdminDashboard } = require('../controllers/dashboardController');
const { authMiddleware, restrictTo } = require('../middleware/authMiddleware');

// Protect all routes
router.use(authMiddleware);

router.get('/teacher', restrictTo('teacher'), getTeacherDashboard);
router.get('/student', restrictTo('student'), getStudentDashboard);
router.get('/admin', restrictTo('admin'), getAdminDashboard);

module.exports = router;
