--  Sample employee database 
--  See changelog table for details
--  Copyright (C) 2007,2008, MySQL AB
--  
--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
-- This work is licensed under the 
-- Creative Commons Attribution-Share Alike 3.0 Unported License. 
-- To view a copy of this license, visit 
-- http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
-- Creative Commons, 171 Second Street, Suite 300, San Francisco, 
-- California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.
-- 

DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;
USE employees;

SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';

DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries, 
                     employees, 
                     departments;

/*!50503 set default_storage_engine = InnoDB */;
/*!50503 select CONCAT('storage engine: ', @@default_storage_engine) as INFO */;

CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,    
    hire_date   DATE            NOT NULL,
    PRIMARY KEY (emp_no)
);

CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),
    UNIQUE  KEY (dept_name)
);

CREATE TABLE dept_manager (
   emp_no       INT             NOT NULL,
   dept_no      CHAR(4)         NOT NULL,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
   PRIMARY KEY (emp_no,dept_no)
); 

CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE titles (
    emp_no      INT             NOT NULL,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,title, from_date)
) 
; 

CREATE TABLE salaries (
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
) 
; 

CREATE OR REPLACE VIEW dept_emp_latest_date AS
    SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
    FROM dept_emp
    GROUP BY emp_no;

# shows only the current department for each employee
CREATE OR REPLACE VIEW current_dept_emp AS
    SELECT l.emp_no, dept_no, l.from_date, l.to_date
    FROM dept_emp d
        INNER JOIN dept_emp_latest_date l
        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;


-- Add auto_increment to emp_no from employees
SET FOREIGN_KEY_CHECKS = 0; 
ALTER TABLE employees MODIFY COLUMN emp_no INT AUTO_INCREMENT;
SET FOREIGN_KEY_CHECKS = 1;

-- Insert 15 employees in the employee table
INSERT INTO employees (birth_date, first_name, last_name, gender, hire_date) 
VALUES 
	('1990-06-06', 'John', 'Doe', 'M', '2022-09-27'),
    ('1990-09-09', 'Jane', 'Doe', 'F', '2022-09-26'),
    ('1989-07-06', 'Jim', 'Smith', 'M', '2020-09-27'),
    ('1990-08-06', 'Jack', 'Smith', 'M', '2022-09-27'),
    ('1990-09-06', 'John', 'García', 'M', '2022-09-27'),
    ('1990-10-06', 'Jolene', 'García', 'F', '2022-09-27'),
    ('1990-11-06', 'Jake', 'Sequel', 'M', '2022-09-27'),
    ('1990-12-06', 'John', 'Sequel', 'M', '2022-09-27'),
    ('1991-01-06', 'Jonnah', 'Fennel', 'M', '2022-09-27'),
    ('1983-02-06', 'Jeff', 'Fennel', 'M', '2015-09-27'),
    ('1988-03-06', 'Janet', 'Johnson', 'F', '2022-09-27'),
    ('1991-04-06', 'Judith', 'Johnson', 'F', '2021-09-27'),
    ('1991-05-06', 'Jenny', 'Williams', 'F', '2022-09-27'),
    ('1991-06-08', 'Patata', 'Williams', 'F', '2022-09-27'),
    ('1991-06-15', 'Patatita', 'Brown', 'M', '2022-09-27');
 
-- Insert salaries for each employee ID
INSERT INTO salaries (emp_no, salary, from_date, to_date) 
VALUES 
	(1, 5100,   '2022-09-27', '2023-03-01'),
    (2, 5100,   '2022-09-27', '2023-03-01'),
    (3, 15600,  '2022-09-27', '2024-03-01'),
    (4, 12500,  '2022-09-27', '2023-10-01'),
    (5, 10500,  '2022-09-27', '2023-10-01'),
    (6, 5100,   '2022-09-27', '2023-03-01'),
    (7, 5100,   '2022-09-27', '2023-03-01'),
    (8, 12500,  '2022-09-27', '2023-10-01'),
    (9, 5100,   '2022-09-27', '2023-03-01'),
    (10, 24800, '2022-09-27', '2024-10-01'),
    (11, 15600, '2022-09-27', '2024-03-01'),
    (12, 5100,  '2022-09-27', '2023-03-01'),
	(13, 5100,  '2022-09-27', '2023-03-01'),
    (14, 12500, '2022-09-27', '2023-10-01'),
    (15, 5100,  '2022-09-27', '2023-03-01');

-- Set departments 
INSERT INTO departments (dept_no, dept_name) 
VALUES
	('A&F', 'accounting and finance'),
    ('IT', 'information technology'),
	('HR', 'human resources'),
    ('SALE', 'sles'),
    ('MRKT', 'marketing');

-- Set managers 
INSERT INTO dept_manager (dept_no, emp_no, from_date, to_date) 
VALUES
	('A&F', 10,  '2022-09-27', CURDATE()),
    ('IT', 11,   '2022-09-27', CURDATE()),
	('HR', 4,    '2022-09-27', CURDATE()),
    ('SALE', 3,  '2022-09-27', CURDATE()),
    ('MRKT', 14, '2022-09-27', CURDATE());
    
-- Assign employees to each department 
INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date) 
VALUES
	(10, 'A&F',  '2022-09-27', CURDATE()),
    (11, 'IT',   '2022-09-27', CURDATE()),
	(4, 'HR',    '2022-09-27', CURDATE()),
    (3, 'SALE',  '2022-09-27', CURDATE()),
    (14, 'MRKT', '2022-09-27', CURDATE()),
    (1, 'MRKT',  '2022-09-27', CURDATE()),
    (1, 'SALE',  '2022-09-27', CURDATE()),
    (2, 'MRKT',  '2022-09-27', CURDATE()),
    (2, 'SALE',  '2022-09-27', CURDATE()),
    (5, 'IT',    '2022-09-27', CURDATE()),
    (5, 'A&F',   '2022-09-27', CURDATE()),
    (6, 'IT',    '2022-09-27', CURDATE()),
    (6, 'MRKT',  '2022-09-27', CURDATE()),
    (7, 'HR',    '2022-09-27', CURDATE()),
    (7, 'IT',    '2022-09-27', CURDATE()),
    (8, 'A&F',   '2022-09-27', CURDATE()),
    (8, 'IT',    '2022-09-27', CURDATE()),
    (9, 'IT',    '2022-09-27', CURDATE()),
    (9, 'MRKT',  '2022-09-27', CURDATE()),
    (12, 'HR',   '2022-09-27', CURDATE()),
    (12, 'SALE', '2022-09-27', CURDATE()),
    (13, 'HR',   '2022-09-27', CURDATE()),
    (13, 'IT',   '2022-09-27', CURDATE()),
    (15, 'A&F',  '2022-09-27', CURDATE()),
    (15, 'SALE', '2022-09-27', CURDATE());

-- Assign titles to employees
INSERT INTO titles (emp_no, title, from_date, to_date) 
VALUES
	(1, 'degree',  '2015-09-27', '2020-03-01'),
    (2, 'degree',  '2016-09-27', '2021-03-01'),
    (3, 'degree',  '2013-09-27', '2020-03-01'),
    (4, 'degree',  '2016-09-27', '2021-10-01'),
    (5, 'degree',  '2012-09-27', '2017-10-01'),
    (6, 'degree',  '2014-09-27', '2018-03-01'),
    (7, 'degree',  '2016-09-27', '2020-03-01'),
    (8, 'degree',  '2010-09-27', '2018-10-01'),
    (9, 'degree',  '2012-09-27', '2016-03-01'),
    (10, 'degree', '2011-09-27', '2015-10-01'),
    (11, 'degree', '2013-09-27', '2017-03-01'),
    (12, 'degree', '2013-09-27', '2018-03-01'),
	(13, 'degree', '2015-09-27', '2020-03-01'),
    (14, 'degree', '2015-09-27', '2020-10-01'),
    (15, 'degree', '2015-09-27', '2020-03-01');

-- Update an employee's name
SET SQL_SAFE_UPDATES = 0;
UPDATE employees 
SET first_name = 'Jane' 
WHERE first_name = 'John' AND last_name = 'García' AND birth_date = '1990-09-06';
SET SQL_SAFE_UPDATES = 1;

-- Update name of all departments
UPDATE departments
SET dept_name = 'Accounting and Finance'
WHERE dept_no = 'A&F';

UPDATE departments
SET dept_name = 'Information Technology'
WHERE dept_no = 'IT';

UPDATE departments
SET dept_name = 'Human Resources'
WHERE dept_no = 'HR';

UPDATE departments
SET dept_name = 'Sales'
WHERE dept_no = 'SALE';

UPDATE departments
SET dept_name = 'Marketing'
WHERE dept_no = 'MRKT';

-- Select employees where salary higher than 20k 
SELECT s.emp_no, e.first_name, e.last_name, s.salary
FROM salaries AS s
    LEFT JOIN employees AS e 
    ON s.emp_no = e.emp_no 
WHERE salary > 20000;

-- Select employees where salary lower than 10k
SELECT s.emp_no, e.first_name, e.last_name, s.salary
FROM salaries AS s
    LEFT JOIN employees AS e
    ON s.emp_no = e.emp_no 
WHERE salary < 10000;

-- Select employees where salary between 14k and 50k
SELECT s.emp_no, e.first_name, e.last_name, s.salary
FROM salaries AS s
    LEFT JOIN employees AS e 
    ON s.emp_no = e.emp_no 
WHERE salary > 14000 AND salary < 50000;

-- Total number of employees
SELECT COUNT(emp_no) AS total_emp
FROM employees;

-- Number of employees working in more than 1 department
SELECT COUNT(rep.emp_no) AS emp_2more_depts
FROM (
	SELECT emp_no 
	FROM dept_emp 
	GROUP BY emp_no
	HAVING COUNT(emp_no) > 1
) AS rep;

-- Titles of 2020 
SELECT e.first_name, e.last_name, t.title, t.to_date
FROM titles AS t
    LEFT JOIN employees AS e 
    ON t.emp_no = e.emp_no
WHERE t.to_date > '2019-12-31';

-- Select employees' names in capital letters
SELECT UPPER(first_name), UPPER(last_name) 
FROM employees;

-- Select employees' name and department
SELECT e.first_name, e.last_name, dnames.dept_name
FROM (
    SELECT d.emp_no, dept.dept_name
    FROM dept_emp AS d
        LEFT JOIN departments AS dept 
        ON d.dept_no = dept.dept_no
) AS dnames
    RIGHT JOIN employees AS e 
    ON dnames.emp_no = e.emp_no;

-- Select employees' name and times as manager, excluded never-manager employees
SELECT e.first_name, e.last_name, m.times_manager
FROM (
    SELECT emp_no, COUNT(emp_no) AS times_manager
	FROM dept_manager 
	GROUP BY emp_no
) AS m
    LEFT JOIN employees AS e 
    ON m.emp_no = e.emp_no;

-- Select employee's names but repeated ones
SELECT first_name, last_name
FROM employees
GROUP BY first_name
HAVING COUNT(first_name) < 2;

-- Delete all employees with a salary higher than 20k
SET SQL_SAFE_UPDATES = 0;

DELETE FROM employees
WHERE emp_no = ANY (
    SELECT emp_no
    FROM salaries
    WHERE salary > 20000
);

SET SQL_SAFE_UPDATES = 1;

-- Delete the department with more employees
SET SQL_SAFE_UPDATES = 0;

DELETE depts FROM departments AS depts
    JOIN (
        SELECT dept_no, COUNT(emp_no) AS num_emp 
        FROM dept_emp 
        GROUP BY dept_no
        ORDER BY num_emp DESC
        LIMIT 1
    ) AS d
    ON depts.dept_no = d.dept_no
WHERE depts.dept_no = d.dept_no;

-- DELETE FROM departments     -- ANOTHER OPTION 
--   WHERE dept_no = (
--     SELECT dept_no 
--     FROM dept_emp 
--     GROUP BY dept_no
--     ORDER BY COUNT(DISTINCT emp_no) DESC 
--     LIMIT 1
--   );

SET SQL_SAFE_UPDATES = 1;

-- Number of employees working in more than 1 department and their departments
SELECT e.first_name, e.last_name , d_emp.depts_emp
FROM (
	SELECT de.emp_no, GROUP_CONCAT(d.dept_name) AS depts_emp
	FROM dept_emp AS de
        LEFT JOIN departments AS d
        ON d.dept_no = de.dept_no
	GROUP BY emp_no
	HAVING COUNT(emp_no) > 1
) AS d_emp
	LEFT JOIN employees AS e
    ON e.emp_no = d_emp.emp_no;