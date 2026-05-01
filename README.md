# 📊 SQL Student Performance Analysis

## 📌 Project Overview

This project is part of a SQL Data Analysis Internship Task. The goal is to extend an existing **Student Management Database** by adding new tables and performing analytical queries.

The project demonstrates how SQL can be used to analyze student performance across different courses using joins, aggregation, and grouping techniques.

---

## 🎯 Objectives

* Extend the database with **Courses** and **Enrollments** tables
* Establish relationships between students and courses
* Perform analytical queries to extract meaningful insights
* Identify top-performing students and course-wise performance

---

## 🗂️ Repository Structure

```
sql-student-performance-analysis/
│
├── task2.sql
└── README.md
```

---

## 🗄️ Database Design

### 🔹 Courses Table

Stores course details.

| Column | Data Type | Description      |
| ------ | --------- | ---------------- |
| id     | INT (PK)  | Unique course ID |
| name   | VARCHAR   | Course name      |

---

### 🔹 Enrollments Table

Represents student-course relationships.

| Column     | Data Type | Description               |
| ---------- | --------- | ------------------------- |
| student_id | INT (FK)  | References students table |
| course_id  | INT (FK)  | References courses table  |
| grade      | INT       | Student marks             |

---

## 🔗 Relationships

* One student can enroll in multiple courses
* One course can have multiple students
* Forms a **many-to-many relationship** using the enrollments table

---

## 📊 SQL Queries

### 1. Students in Each Course

```sql
SELECT s.name, c.name AS course_name
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id;
```

### 2. Average Grade per Course

```sql
SELECT c.name, AVG(e.grade) AS avg_grade
FROM enrollments e
JOIN courses c ON e.course_id = c.id
GROUP BY c.name;
```

### 3. Top 3 Students

```sql
SELECT s.name, AVG(e.grade) AS avg_grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
GROUP BY s.name
ORDER BY avg_grade DESC
LIMIT 3;
```

### 4. Failed Students Count

```sql
SELECT COUNT(*) AS failed_students
FROM enrollments
WHERE grade < 40;
```

---

## 🚀 How to Run

### Requirements

* MySQL / PostgreSQL / SQLite
* Any SQL editor (VS Code, DB Fiddle, etc.)

### Steps

1. Open your SQL environment
2. Create a database
3. Run the `task2.sql` file
4. Execute queries and view results

---

## 📈 Key Insights

* Helps analyze student performance by course
* Identifies top-performing students
* Shows failure rates for improvement analysis

---

## 🎓 Learning Outcomes

* Understanding table relationships
* Writing JOIN queries
* Using GROUP BY and aggregate functions
* Performing basic data analysis with SQL

---

## 🧠 Skills Used

* SQL
* Data Analysis
* Relational Database Design




