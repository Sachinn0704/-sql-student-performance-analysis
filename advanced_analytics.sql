-- Advanced SQL Student Performance Analytics
-- Assumes: students(id, ...), courses(id, name), enrollments(student_id, course_id, grade)
-- Compatible with modern MySQL 8+, PostgreSQL, and SQLite 3.25+.

-- 1. Student-level performance summary
WITH student_summary AS (
    SELECT
        s.id AS student_id,
        AVG(e.grade) AS avg_grade,
        COUNT(*) AS courses_taken,
        SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS failed_courses
    FROM students s
    JOIN enrollments e ON e.student_id = s.id
    GROUP BY s.id
)
SELECT
    student_id,
    ROUND(avg_grade, 2) AS avg_grade,
    courses_taken,
    failed_courses,
    CASE
        WHEN avg_grade >= 75 THEN 'Excellent'
        WHEN avg_grade >= 60 THEN 'Good'
        WHEN avg_grade >= 40 THEN 'Pass'
        ELSE 'At Risk'
    END AS performance_band
FROM student_summary
ORDER BY avg_grade DESC;

-- 2. Rank students while preserving ties
WITH student_summary AS (
    SELECT
        s.id AS student_id,
        AVG(e.grade) AS avg_grade
    FROM students s
    JOIN enrollments e ON e.student_id = s.id
    GROUP BY s.id
)
SELECT
    student_id,
    ROUND(avg_grade, 2) AS avg_grade,
    DENSE_RANK() OVER (ORDER BY avg_grade DESC) AS performance_rank
FROM student_summary
ORDER BY performance_rank, student_id;

-- 3. Compare every course with the overall course-average baseline
WITH course_summary AS (
    SELECT
        c.id AS course_id,
        c.name AS course_name,
        AVG(e.grade) AS avg_grade
    FROM courses c
    JOIN enrollments e ON e.course_id = c.id
    GROUP BY c.id, c.name
)
SELECT
    course_id,
    course_name,
    ROUND(avg_grade, 2) AS avg_grade,
    ROUND(AVG(avg_grade) OVER (), 2) AS overall_course_avg,
    ROUND(avg_grade - AVG(avg_grade) OVER (), 2) AS variance_from_baseline
FROM course_summary
ORDER BY variance_from_baseline DESC;

-- 4. Quartile segmentation for students
WITH student_summary AS (
    SELECT
        s.id AS student_id,
        AVG(e.grade) AS avg_grade
    FROM students s
    JOIN enrollments e ON e.student_id = s.id
    GROUP BY s.id
)
SELECT
    student_id,
    ROUND(avg_grade, 2) AS avg_grade,
    NTILE(4) OVER (ORDER BY avg_grade DESC) AS performance_quartile
FROM student_summary
ORDER BY performance_quartile, avg_grade DESC;

-- 5. Identify each student's strongest subject
WITH subject_scores AS (
    SELECT
        e.student_id,
        c.name AS course_name,
        e.grade,
        ROW_NUMBER() OVER (
            PARTITION BY e.student_id
            ORDER BY e.grade DESC, c.name
        ) AS subject_position
    FROM enrollments e
    JOIN courses c ON c.id = e.course_id
)
SELECT
    student_id,
    course_name AS strongest_subject,
    grade AS strongest_grade
FROM subject_scores
WHERE subject_position = 1
ORDER BY student_id;

-- 6. Data-quality checks for the enrollment fact table
SELECT
    SUM(CASE WHEN student_id IS NULL THEN 1 ELSE 0 END) AS missing_student_ids,
    SUM(CASE WHEN course_id IS NULL THEN 1 ELSE 0 END) AS missing_course_ids,
    SUM(CASE WHEN grade IS NULL THEN 1 ELSE 0 END) AS missing_grades,
    SUM(CASE WHEN grade < 0 OR grade > 100 THEN 1 ELSE 0 END) AS invalid_grades
FROM enrollments;

-- 7. Referential-integrity checks for orphaned enrollment records
SELECT
    COUNT(*) AS orphaned_student_enrollments
FROM enrollments e
LEFT JOIN students s ON s.id = e.student_id
WHERE s.id IS NULL;

SELECT
    COUNT(*) AS orphaned_course_enrollments
FROM enrollments e
LEFT JOIN courses c ON c.id = e.course_id
WHERE c.id IS NULL;

-- 8. Duplicate enrollment checks
-- A student should normally have at most one enrollment row per course.
SELECT
    student_id,
    course_id,
    COUNT(*) AS duplicate_rows
FROM enrollments
group by student_id, course_id
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, student_id, course_id;

-- 9. Course-level pass-rate analysis for reporting.
-- A grade of 40 is treated as the minimum passing score.
SELECT
    c.id AS course_id,
    c.name AS course_name,
    COUNT(*) AS enrolled_students,
    SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) AS passed_students,
    SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS failed_students,
    ROUND(
        100.0 * SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS pass_rate_pct
FROM courses c
JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.name
ORDER BY pass_rate_pct DESC, c.name;

-- 10. Flag students who may need academic support.
-- Students with an average below 50 or at least two failed courses are flagged.
WITH student_summary AS (
    SELECT
        s.id AS student_id,
        AVG(e.grade) AS avg_grade,
        SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS failed_courses
    FROM students s
    JOIN enrollments e ON e.student_id = s.id
    GROUP BY s.id
)
SELECT
    student_id,
    ROUND(avg_grade, 2) AS avg_grade,
    failed_courses,
    CASE
        WHEN avg_grade < 50 OR failed_courses >= 2 THEN 'Needs Support'
        ELSE 'On Track'
    END AS support_status
FROM student_summary
ORDER BY support_status DESC, avg_grade;

-- 11. Course-level grade distribution for dashboard reporting.
-- Groups results into actionable score bands while retaining course totals.
SELECT
    c.id AS course_id,
    c.name AS course_name,
    SUM(CASE WHEN e.grade >= 75 THEN 1 ELSE 0 END) AS excellent_count,
    SUM(CASE WHEN e.grade >= 60 AND e.grade < 75 THEN 1 ELSE 0 END) AS good_count,
    SUM(CASE WHEN e.grade >= 40 AND e.grade < 60 THEN 1 ELSE 0 END) AS pass_count,
    SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS at_risk_count,
    COUNT(*) AS total_enrollments
FROM courses c
JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id, c.name
ORDER BY at_risk_count DESC, c.name;

-- 12. Workload-aware student risk analysis.
-- Highlights students whose lower performance coincides with a heavier course load.
WITH student_summary AS (
    SELECT
        s.id AS student_id,
        AVG(e.grade) AS avg_grade,
        COUNT(*) AS courses_taken,
        SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS failed_courses
    FROM students s
    JOIN enrollments e ON e.student_id = s.id
    GROUP BY s.id
), workload_benchmarks AS (
    SELECT
        AVG(courses_taken) AS avg_course_load
    FROM student_summary
)
SELECT
    ss.student_id,
    ss.courses_taken,
    ROUND(ss.avg_grade, 2) AS avg_grade,
    ss.failed_courses,
    ROUND(wb.avg_course_load, 2) AS avg_course_load,
    CASE
        WHEN ss.avg_grade < 50 AND ss.courses_taken > wb.avg_course_load
            THEN 'High Load - High Risk'
        WHEN ss.avg_grade < 50
            THEN 'High Risk'
        WHEN ss.courses_taken > wb.avg_course_load AND ss.avg_grade >= 75
            THEN 'High Load - Strong Performance'
        ELSE 'Standard'
    END AS workload_profile
FROM student_summary ss
CROSS JOIN workload_benchmarks wb
ORDER BY
    CASE
        WHEN ss.avg_grade < 50 AND ss.courses_taken > wb.avg_course_load THEN 1
        WHEN ss.avg_grade < 50 THEN 2
        WHEN ss.courses_taken > wb.avg_course_load AND ss.avg_grade >= 75 THEN 3
        ELSE 4
    END,
    ss.avg_grade,
    ss.student_id;

-- 13. Course risk ranking for dashboard prioritization.
-- Ranks courses by low pass rate, then by average grade, so the highest-risk
-- courses appear first for targeted academic intervention.
WITH course_metrics AS (
    SELECT
        c.id AS course_id,
        c.name AS course_name,
        COUNT(*) AS enrolled_students,
        AVG(e.grade) AS avg_grade,
        100.0 * SUM(CASE WHEN e.grade >= 40 THEN 1 ELSE 0 END) / COUNT(*) AS pass_rate_pct,
        SUM(CASE WHEN e.grade < 40 THEN 1 ELSE 0 END) AS failed_students
    FROM courses c
    JOIN enrollments e ON e.course_id = c.id
    GROUP BY c.id, c.name
)
SELECT
    course_id,
    course_name,
    enrolled_students,
    ROUND(avg_grade, 2) AS avg_grade,
    ROUND(pass_rate_pct, 2) AS pass_rate_pct,
    failed_students,
    DENSE_RANK() OVER (
        ORDER BY pass_rate_pct ASC, avg_grade ASC
    ) AS risk_rank
FROM course_metrics
ORDER BY risk_rank, course_name;
