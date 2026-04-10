const db = require('../config/db');

const getTeacherDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get teacher info
    const teacherResult = await db.query(
      `SELECT u.name, u.email, t.teacher_id, t.department, t.phone 
       FROM users u 
       JOIN teachers t ON u.id = t.user_id 
       WHERE u.id = $1`,
      [userId]
    );

    if (teacherResult.rows.length === 0) {
      return res.status(404).json({ message: 'Teacher not found' });
    }

    const teacher = teacherResult.rows[0];

    // Get classes count
    const classesResult = await db.query('SELECT COUNT(*) FROM classes');

    // Get total students
    const studentsResult = await db.query('SELECT COUNT(*) FROM students');

    // Get homework assigned by this teacher
    const homeworkResult = await db.query(
      'SELECT COUNT(*) FROM homework WHERE teacher_id = (SELECT id FROM teachers WHERE user_id = $1)',
      [userId]
    );

    res.status(200).json({
      message: 'Welcome to the Teacher Dashboard',
      teacher,
      stats: {
        totalClasses: parseInt(classesResult.rows[0].count),
        totalStudents: parseInt(studentsResult.rows[0].count),
        homeworkAssigned: parseInt(homeworkResult.rows[0].count),
      }
    });
  } catch (error) {
    console.error('Teacher Dashboard Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const getStudentDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get student info with class
    const studentResult = await db.query(
      `SELECT u.name, u.email, s.student_id, s.roll_number, s.parent_name, s.date_of_birth,
              c.name as class_name, c.section 
       FROM users u 
       JOIN students s ON u.id = s.user_id 
       LEFT JOIN classes c ON s.class_id = c.id
       WHERE u.id = $1`,
      [userId]
    );

    if (studentResult.rows.length === 0) {
      return res.status(404).json({ message: 'Student not found' });
    }

    const student = studentResult.rows[0];

    // Get attendance stats
    const attendanceResult = await db.query(
      `SELECT 
        COUNT(*) FILTER (WHERE status = 'present') as present_count,
        COUNT(*) FILTER (WHERE status = 'absent') as absent_count,
        COUNT(*) as total_days
       FROM attendance 
       WHERE student_id = (SELECT id FROM students WHERE user_id = $1)`,
      [userId]
    );

    // Get pending homework
    const homeworkResult = await db.query(
      `SELECT h.title, h.description, h.due_date, sub.name as subject_name
       FROM homework h 
       LEFT JOIN subjects sub ON h.subject_id = sub.id
       WHERE h.class_id = (SELECT class_id FROM students WHERE user_id = $1)
       AND h.due_date >= CURRENT_DATE
       ORDER BY h.due_date ASC
       LIMIT 5`,
      [userId]
    );

    // Get recent marks
    const marksResult = await db.query(
      `SELECT m.marks_obtained, m.total_marks, m.exam_type, sub.name as subject_name
       FROM marks m 
       LEFT JOIN subjects sub ON m.subject_id = sub.id
       WHERE m.student_id = (SELECT id FROM students WHERE user_id = $1)
       ORDER BY m.created_at DESC
       LIMIT 5`,
      [userId]
    );

    const attendance = attendanceResult.rows[0];

    res.status(200).json({
      message: 'Welcome to the Student Dashboard',
      student,
      stats: {
        attendance: {
          present: parseInt(attendance.present_count) || 0,
          absent: parseInt(attendance.absent_count) || 0,
          totalDays: parseInt(attendance.total_days) || 0,
          percentage: attendance.total_days > 0 
            ? Math.round((attendance.present_count / attendance.total_days) * 100) 
            : 0
        },
        pendingHomework: homeworkResult.rows,
        recentMarks: marksResult.rows
      }
    });
  } catch (error) {
    console.error('Student Dashboard Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const getAdminDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    // Get admin info
    const adminResult = await db.query(
      `SELECT u.name, u.email, a.admin_email, a.designation 
       FROM users u 
       JOIN admins a ON u.id = a.user_id 
       WHERE u.id = $1`,
      [userId]
    );

    if (adminResult.rows.length === 0) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    // Get stats overview
    const studentsCount = await db.query('SELECT COUNT(*) FROM students');
    const teachersCount = await db.query('SELECT COUNT(*) FROM teachers');
    const classesCount = await db.query('SELECT COUNT(*) FROM classes');
    const subjectsCount = await db.query('SELECT COUNT(*) FROM subjects');

    res.status(200).json({
      message: 'Welcome to the Admin Dashboard',
      admin: adminResult.rows[0],
      stats: {
        totalStudents: parseInt(studentsCount.rows[0].count),
        totalTeachers: parseInt(teachersCount.rows[0].count),
        totalClasses: parseInt(classesCount.rows[0].count),
        totalSubjects: parseInt(subjectsCount.rows[0].count),
      }
    });
  } catch (error) {
    console.error('Admin Dashboard Error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { getTeacherDashboard, getStudentDashboard, getAdminDashboard };
