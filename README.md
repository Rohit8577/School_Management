# school_management

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



<br>
<br>
<br>




# Educational Management System

### Project Overview

This project is a full-stack Educational Management System designed to manage multiple schools within a single platform. It provides role-based access for different users and allows efficient management of students, teachers, and academic data.

The system follows a multi-tenant architecture, meaning multiple schools can use the same application while keeping their data secure and isolated.

### User Roles
Super Admin → Manages all schools
School Admin → Manages teachers and students of a school
Teacher → Manages attendance and marks
Student → Views personal data (profile, marks, attendance)

## Key Features

### Authentication & Authorization
- JWT-based login system
Secure password handling
### Multi-School Management
- One platform supports multiple schools
- Data isolation using school_id
### Role-Based Access Control (RBAC)
- Controlled access for each user type
### Academic Management
- Student & teacher management
- Attendance tracking
- Marks management
### Dashboard & Data Handling
- Role-specific data views
- Structured and secure APIs
### Tech Stack
- Backend
- Node.js
- Express.js
- PostgreSQL
- JWT, bcrypt
- Frontend (Mobile App)
Flutter


## System Architecture
Flutter App → REST APIs → Node.js Backend → PostgreSQL Database