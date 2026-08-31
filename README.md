# SQL Student Performance Analysis

A SQL data-analysis project that extends a student database with course and enrollment data and uses relational queries to evaluate academic performance.

## Project Summary

The project demonstrates how SQL can connect students with courses, calculate course-level averages, identify top performers, and count failing results.

## Database Model

### Students
Stores student information from the existing student database.

### Courses
Stores course identifiers and course names.

### Enrollments
Connects students and courses and stores grades.

The `enrollments` table creates a many-to-many relationship between students and courses.

## Main Analysis

1. List students enrolled in each course.
2. Calculate the average grade for every course.
3. Find the top three students by average grade.
4. Count enrollment records with grades below 40.

## Example Query

```sql
SELECT c.name, AVG(e.grade) AS avg_grade
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.name;
```

## How to Run

1. Open MySQL, PostgreSQL, SQLite, or another compatible SQL environment.
2. Create or select the student-management database.
3. Run `task2.sql`.
4. Execute the analytical queries.
5. Review the returned results by course and student.

## Repository Structure

```text
.
├── task2.sql
└── README.md
```

## Skills Demonstrated

- SQL JOINs
- GROUP BY and aggregate functions
- Many-to-many relational design
- Filtering and ranking
- Basic academic data analysis
