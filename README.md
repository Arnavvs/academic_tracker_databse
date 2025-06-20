# academic_tracker_databse

# Academic Progress Tracker – SQL Project

This project is a comprehensive **academic performance tracking system** built in MySQL. It manages student records, grades, attendance, teachers, and subject-wise statistics across multiple semesters.

---

## 📁 Files Included

- `schema.sql`: Contains table definitions, constraints, and all SQL views.
- `data_insertion.sql`: Inserts comprehensive sample data for 20 students, 5 subjects, and 3 semesters, including grades and attendance records.
- `queries.sql`: Provides various SQL queries for data verification, utilizing views, and demonstrating complex features.
- `README.md`: This documentation.

---

## 🧱 Features Implemented

### ✅ Core Features
- **Student Management** (`Students`): Stores and manages student personal details (name, ID, contact info, enrollment date).
- **Subject Management** (`Subjects`): Maintains a list of subjects/courses with relevant details (subject code, name, credits).
- **Semester Support** (`Semesters`): Organizes grades and subjects by academic terms or semesters.
- **Grade Recording** (`Grades`): Records and updates grades for students per subject.
- **Performance Reports**:
  - GPA calculation
  - Semester toppers
  - At-risk students

### ✅ Bonus Features
- **Attendance Tracking** (`Attendance`): Adds tables and queries to track student attendance per subject.
- **Teacher Assignment** (`Teachers`, `Subject_Teachers`): Links subjects to teachers and allows querying of teacher-wise performance.
- **Grade Distribution**: Provides grade distribution statistics per subject.
- **Honors/Distinction**: Identifies students eligible for honors or distinction based on GPA.

---

## 📊 Views Summary

| View Name                | Purpose                                              |
|-------------------------|------------------------------------------------------|
| `GPA_View`              | GPA per student per semester                         |
| `Semester_Toppers`      | Ranked list of students per semester                 |
| `At_Risk_Students`      | Students failing ≥ 2 subjects in a semester          |
| `Grade_Distribution`    | Count of grades per performance range per subject    |
| `Honors_Students`       | Students with GPA ≥ 9                                |
| `Teacher_Performance`   | Avg grades of students per subject per teacher       |
| `Attendance_Percentage` | % attendance per student per subject per semester    |
| `Low_Attendance_Alerts` | Filtered view for attendance < 75%                   |

---

## 📌 Instructions to Run

To set up and explore the database:

1.  **Open MySQL Client:** Use MySQL Workbench, the MySQL command-line client, or your preferred SQL client.
2.  **Create Schema:** Run the `schema.sql` file. This script will create the `academic_progress_tracker` database, all necessary tables, define relationships, and set up the various analytical views.
    ```bash
    # Example using command line:
    mysql -u your_username -p < schema.sql
    ```
3.  **Populate Data:** After the schema is created, run the `q1.sql` file to populate the tables with sample data (20 students, subjects, semesters, grades, and attendance).
    * **Important:** Ensure `q1.sql` runs without syntax errors, especially in the `INSERT` statements for `Attendance`. You might need to manually correct any stray commas or invalid comments within the `VALUES` clauses if you encounter issues.
    ```bash
    # Example using command line:
    mysql -u your_username -p academic_progress_tracker < q1.sql
    ```
4.  **Explore Queries:** Execute the `queries.sql` file to run predefined queries. This file contains basic table checks, queries against the views, and more complex examples to demonstrate the system's capabilities.
    ```bash
    # Example using command line:
    mysql -u your_username -p academic_progress_tracker < queries.sql
    ```
5.  **Manual Exploration:** You can now query the tables and views directly in your MySQL client to explore the data as needed.

---

## 🧠 Assumptions

- Grades are recorded on a 10-point scale.
- Honors cutoff is GPA ≥ 9.00.
- Attendance categories: `Present`, `Absent`, `Excused`.
- Initial sample data includes 5 subjects, 3 semesters, and 20 students.

---

## 📬 Contact

Created by Arnav Vashishtha
