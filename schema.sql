-- --- SCHEMA + VIEWS.sql ---
-- Normalized schema with performance and analysis views

-- Reset and initialize
DROP DATABASE IF EXISTS academic_progress_tracker;
CREATE DATABASE academic_progress_tracker;
USE academic_progress_tracker;

-- Students
CREATE TABLE Students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subjects
CREATE TABLE Subjects (
    subject_code VARCHAR(10) PRIMARY KEY,
    subject_name VARCHAR(100) UNIQUE NOT NULL,
    credits DECIMAL(3,1) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Semesters
CREATE TABLE Semesters (
    semester_id INT PRIMARY KEY AUTO_INCREMENT,
    semester_name VARCHAR(50) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date > start_date),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grades (normalized)
CREATE TABLE Grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    semester_id INT NOT NULL,
    grade_value DECIMAL(4,2) NOT NULL,
    CHECK (grade_value >= 0.00 AND grade_value <= 10.00),
    UNIQUE (student_id, subject_code, semester_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_code) REFERENCES Subjects(subject_code) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teachers
CREATE TABLE Teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subject_Teachers (with semester context)
CREATE TABLE Subject_Teachers (
    subject_code VARCHAR(10) NOT NULL,
    teacher_id INT NOT NULL,
    semester_id INT NOT NULL,
    PRIMARY KEY (subject_code, teacher_id, semester_id),
    FOREIGN KEY (subject_code) REFERENCES Subjects(subject_code) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id) ON DELETE CASCADE
);

-- Attendance
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_code VARCHAR(10) NOT NULL,
    semester_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Excused') NOT NULL,
    UNIQUE (student_id, subject_code, attendance_date),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_code) REFERENCES Subjects(subject_code) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------
-- VIEWS FOR BONUS FEATURES
-- ------------------------------

-- GPA per student per semester
CREATE VIEW GPA_View AS
SELECT 
    g.student_id,
    g.semester_id,
    ROUND(SUM(g.grade_value * s.credits) / SUM(s.credits), 2) AS gpa
FROM Grades g
JOIN Subjects s ON g.subject_code = s.subject_code
GROUP BY g.student_id, g.semester_id;

-- Honors/distinction list (GPA >= 9.0)
CREATE VIEW Honors_Students AS
SELECT 
    g.student_id,
    CONCAT(st.first_name, ' ', st.last_name) AS student_name,
    g.semester_id,
    GPA_View.gpa
FROM GPA_View g
JOIN Students st ON g.student_id = st.student_id
WHERE GPA_View.gpa >= 9.0;

-- Grade distribution per subject
CREATE VIEW Grade_Distribution AS
SELECT 
    subject_code,
    COUNT(CASE WHEN grade_value BETWEEN 9 AND 10 THEN 1 END) AS range_9_10,
    COUNT(CASE WHEN grade_value BETWEEN 8 AND 8.99 THEN 1 END) AS range_8_9,
    COUNT(CASE WHEN grade_value BETWEEN 7 AND 7.99 THEN 1 END) AS range_7_8,
    COUNT(CASE WHEN grade_value BETWEEN 6 AND 6.99 THEN 1 END) AS range_6_7,
    COUNT(CASE WHEN grade_value < 6 THEN 1 END) AS range_fail
FROM Grades
GROUP BY subject_code;

-- Teacher-wise performance: avg student grade in subjects taught
CREATE VIEW Teacher_Performance AS
SELECT 
    t.teacher_id,
    CONCAT(t.first_name, ' ', t.last_name) AS teacher_name,
    st.semester_id,
    se.semester_name,
    ROUND(AVG(g.grade_value), 2) AS average_grade
FROM Subject_Teachers st
JOIN Teachers t ON st.teacher_id = t.teacher_id
JOIN Grades g ON g.subject_code = st.subject_code AND g.semester_id = st.semester_id
JOIN Semesters se ON st.semester_id = se.semester_id
GROUP BY t.teacher_id, st.semester_id;

-- Optional: Failed Students (flagged)
CREATE VIEW At_Risk_Students AS
SELECT student_id, semester_id, COUNT(*) AS failed_subjects
FROM Grades
WHERE grade_value < 6
GROUP BY student_id, semester_id
HAVING COUNT(*) >= 2;

-- Additional: Semester-wise Rank of Students
CREATE VIEW Semester_Toppers AS
SELECT
    student_id,
    semester_id,
    gpa,
    RANK() OVER (PARTITION BY semester_id ORDER BY gpa DESC) AS rank_in_semester
FROM GPA_View;

-- Additional: Average Attendance % per subject per student
CREATE VIEW Attendance_Percentage AS
SELECT 
    student_id,
    subject_code,
    semester_id,
    ROUND(SUM(status = 'Present') * 100.0 / COUNT(*), 2) AS attendance_percentage
FROM Attendance
GROUP BY student_id, subject_code, semester_id;

-- Additional: Low Attendance Alert (<75%)
CREATE VIEW Low_Attendance_Alerts AS
SELECT * FROM Attendance_Percentage
WHERE attendance_percentage < 75;

-- View to calculate attendance percentage for each student per subject per semester
CREATE OR REPLACE VIEW Attendance_Percentage AS
SELECT
    student_id,
    subject_code,
    semester_id,
    ROUND(SUM(status = 'Present') * 100.0 / COUNT(*), 2) AS attendance_percentage
FROM Attendance
GROUP BY student_id, subject_code, semester_id;
