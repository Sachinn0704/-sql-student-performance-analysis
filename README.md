# SQL Student Performance Analysis

A SQL data-analysis project that extends a student database with course and enrollment data and uses relational queries to evaluate academic performance.

## Project Summary

The project demonstrates how SQL can connect students with courses, calculate course-level averages, identify top performers, and perform portfolio-style analytical checks.

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
5. Segment students into performance bands and quartiles.
6. Rank students with `DENSE_RANK()` while preserving ties.
7. Compare course averages against an overall baseline.
8. Identify each student's strongest subject.
9. Run enrollment data-quality checks for missing and invalid grades.

## Advanced Analytics

`advanced_analytics.sql` contains reusable analytical queries built with CTEs, window functions, `CASE`, and data-quality checks. It adds:

- Student performance bands
- Dense ranking
- Overall-average variance analysis
- `NTILE(4)` quartile segmentation
- Per-student strongest-subject analysis
- Enrollment validation checks

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
3. Run the base SQL setup from the project archive.
4. Execute the core analytical queries.
5. Run `advanced_analytics.sql` after the `students`, `courses`, and `enrollments` tables are available.
6. Review the returned results by course and student.

## Repository Structure

```text
.
├── advanced_analytics.sql
├── sql_task2_project.zip
└── README.md
```

## Skills Demonstrated

- SQL JOINs
- GROUP BY and aggregate functions
- Many-to-many relational design
- CTEs
- Window functions
- Ranking and quartile analysis
- CASE-based classification
- Data-quality validation
- Portfolio-oriented academic data analysis
