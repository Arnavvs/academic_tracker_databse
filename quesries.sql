-- --- queries.sql ---
-- SQL Queries for Academic Progress Tracker Project

USE academic_progress_tracker;

-- =============================================================
-- SECTION 1: Basic Queries for All Tables
-- =============================================================

-- 1.1 Select all data from Students table
SELECT * FROM Students;

-- 1.2 Count of records in Students table
SELECT COUNT(*) AS total_students FROM Students;

-- 1.3 Select all data from Subjects table
SELECT * FROM Subjects;

-- 1.4 Count of records in Subjects table
SELECT COUNT(*) AS total_subjects FROM Subjects;

-- 1.5 Select all data from Semesters table
SELECT * FROM Semesters;

-- 1.6 Count of records in Semesters table
SELECT COUNT(*) AS total_semesters FROM Semesters;

-- 1.7 Select all data from Teachers table
SELECT * FROM Teachers;

-- 1.8 Count of records in Teachers table
SELECT COUNT(*) AS total_teachers FROM Teachers;

-- 1.9 Select all data from Subject_Teachers table
SELECT * FROM Subject_Teachers;

-- 1.10 Count of records in Subject_Teachers table
SELECT COUNT(*) AS total_subject_teachers FROM Subject_Teachers;

-- 1.11 Select all data from Grades table
SELECT * FROM Grades;

-- 1.12 Count of records in Grades table
SELECT COUNT(*) AS total_grades FROM Grades;

-- 1.13 Select all data from Attendance table
SELECT * FROM Attendance;

-- 1.14 Count of records in Attendance table
SELECT COUNT(*) AS total_attendance_records FROM Attendance;

-- =============================================================
-- SECTION 2: Queries for All Views
-- =============================================================

-- 2.1 View: GPA per student per semester
SELECT * FROM GPA_View;

-- 2.2 View: Ranked list of students per semester
SELECT * FROM Semester_Toppers;

-- 2.3 View: Students failing >= 2 subjects in a semester
SELECT * FROM At_Risk_Students;

-- 2.4 View: Count of grades per performance range per subject
SELECT * FROM Grade_Distribution;

-- 2.5 View: Students with GPA >= 9
SELECT * FROM Honors_Students;

-- 2.6 View: Average grades of students per subject per teacher
SELECT * FROM Teacher_Performance;

-- 2.7 View: Percentage attendance per student per subject per semester
SELECT * FROM Attendance_Percentage;

-- 2.8 View: Filtered view for attendance < 75%
SELECT * FROM Low_Attendance_Alerts;


-- =============================================================
-- SECTION 3: More Complex / Specific Queries
-- =============================================================

-- 3.1 Get full details of students enrolled after a specific date (e.g., '2022-07-20')
SELECT student_id, first_name, last_name, email, enrollment_date
FROM Students
WHERE enrollment_date > '2022-07-20'
ORDER BY enrollment_date;

-- 3.2 List all subjects taught by a specific teacher (e.g., 'A. Sharma')
SELECT
    t.first_name,
    t.last_name,
    s.subject_name,
    sem.semester_name
FROM Teachers t
JOIN Subject_Teachers st ON t.teacher_id = st.teacher_id
JOIN Subjects s ON st.subject_code = s.subject_code
JOIN Semesters sem ON st.semester_id = sem.semester_id
WHERE t.first_name = 'A. Sharma';

-- 3.3 Get the average grade for a specific subject (e.g., 'CS101') across all semesters
SELECT
    sub.subject_name,
    AVG(g.grade_value) AS average_grade
FROM Grades g
JOIN Subjects sub ON g.subject_code = sub.subject_code
WHERE sub.subject_code = 'CS101'
GROUP BY sub.subject_name;

-- 3.4 Find the student with the highest GPA in 'Semester 1'
SELECT
    s.first_name,
    s.last_name,
    g.gpa
FROM Semester_Toppers g
JOIN Students s ON g.student_id = s.student_id
WHERE g.semester_id = 1
ORDER BY g.rank_in_semester ASC
LIMIT 1;

-- 3.5 List all students who have ever been 'Absent' for 'MA102'
SELECT DISTINCT
    s.first_name,
    s.last_name
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
WHERE a.subject_code = 'MA102' AND a.status = 'Absent';

-- 3.6 Find semesters that have an average attendance percentage below 80% across all subjects
SELECT
    sem.semester_name,
    AVG(ap.attendance_percentage) AS overall_semester_attendance
FROM Attendance_Percentage ap
JOIN Semesters sem ON ap.semester_id = sem.semester_id
GROUP BY sem.semester_name
HAVING AVG(ap.attendance_percentage) < 80;

-- 3.7 Get the number of students taught by each teacher per semester
SELECT
    t.first_name,
    t.last_name,
    sem.semester_name,
    COUNT(DISTINCT g.student_id) AS number_of_students_taught
FROM Teachers t
JOIN Subject_Teachers st ON t.teacher_id = st.teacher_id
JOIN Grades g ON st.subject_code = g.subject_code AND st.semester_id = g.semester_id
JOIN Semesters sem ON st.semester_id = sem.semester_id
GROUP BY t.teacher_id, sem.semester_id
ORDER BY t.first_name, sem.semester_name;

-- 3.8 Identify students who passed all subjects (grade_value >= 6) in a specific semester (e.g., Semester 1)
SELECT
    s.first_name,
    s.last_name
FROM Students s
WHERE s.student_id NOT IN (
    SELECT g.student_id
    FROM Grades g
    WHERE g.semester_id = 1 AND g.grade_value < 6
)
AND s.student_id IN (
    SELECT DISTINCT g.student_id
    FROM Grades g
    WHERE g.semester_id = 1
);

-- 3.9 Get students who are 'Present' for all their 'CS101' classes in Semester 1
SELECT
    s.first_name,
    s.last_name
FROM Students s
WHERE s.student_id IN (
    SELECT a.student_id
    FROM Attendance a
    WHERE a.subject_code = 'CS101'
      AND a.semester_id = 1
    GROUP BY a.student_id
    HAVING COUNT(*) = SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0)
);

-- 3.10 Calculate the total credits a student has completed (assuming passing grades for credits)
SELECT
    s.first_name,
    s.last_name,
    SUM(sub.credits) AS total_credits_completed
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
JOIN Subjects sub ON g.subject_code = sub.subject_code
WHERE g.grade_value >= 6 -- Assuming 6 is the passing grade
GROUP BY s.student_id
ORDER BY total_credits_completed DESC;