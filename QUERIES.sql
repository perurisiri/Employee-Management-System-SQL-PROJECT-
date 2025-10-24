CREATE DATABASE projects;
SHOW DATABASES;
USE projects;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);

--- 1. How many unique employees are currently in the system?

SELECT COUNT(DISTINCT Emp_ID) AS Total_Unique_Employees
FROM Employee;

----- 2.Which departments have the highest number of employees?

SELECT j.jobdept, COUNT(*) AS total_employees FROM Employee e JOIN  JobDepartment j ON e.Job_ID = j.Job_ID GROUP BY j.jobdept ORDER BY total_employees DESC LIMIT 0, 1000;

-- 3What is the average salary per department?--

SELECT j.jobdept AS Department_Name,
ROUND(AVG(s.amount), 2) AS Average_Salary
FROM JobDepartment j
JOIN Salary_Bonus s ON j.JobID = s.JobID
GROUP BY j.jobdept
ORDER BY Average_Salary DESC;

--- 4.Who are the top 5 highest-paid employees?
SELECT firstname, lastname, amount AS salary FROM Employee e JOIN Salary_Bonus s ON 
e.JobID= s.JobID ORDER BY salary DESC LIMIT 5;

-- 5What is the total salary expenditure across the company? --
 SELECT SUM(amount) AS total_salary FROM Salary_Bonus;

-- 6How many different job roles exist in each department? --
SELECT jobdept, COUNT(DISTINCT name) AS Job_Role_Count
FROM JobDepartment
GROUP BY jobdept
ORDER BY Job_Role_Count DESC;

-- 7What is the average salary range per department? --
SELECT jobdept, ROUND(
        AVG(
            (
                CAST(REPLACE(REPLACE(SUBSTRING_INDEX(salaryrange, '-', 1), '$', ''), ' ', '') AS UNSIGNED)
                +
                CAST(REPLACE(REPLACE(SUBSTRING_INDEX(salaryrange, '-', -1), '$', ''), ' ', '') AS UNSIGNED)
            ) / 2
        ), 2
    ) AS Avg_Salary_Range
FROM JobDepartment GROUP BY jobdept ORDER BY Avg_Salary_Range DESC;

-- 8Which job roles offer the highest salary? --
SELECT j.jobdept, j.name, ROUND(AVG(s.Amount), 2) AS Average_Salary
FROM JobDepartment j
JOIN Salary_Bonus s ON j.JobID = s.JobID
GROUP BY j.jobdept, j.name
ORDER BY Average_Salary DESC
LIMIT 5;

-- 9Which departments have the highest total salary allocation? --
SELECT j.jobdept, SUM(s.Amount) AS Total_Salary
FROM JobDepartment j
JOIN Salary_Bonus s ON j.JobID = s.JobID
GROUP BY j.jobdept
ORDER BY Total_Salary DESC;

--- 10.How many employees have at least one qualification listed?
SELECT 
COUNT(
DISTINCT EmpID) AS Employees_With_Qualifications 
FROM Qualification;

-- 11 Which positions require the most qualifications? --
SELECT q.EmpID,CONCAT(e.FirstName, ' ', e.LastName) AS Employee_Name,COUNT(q.QualID) AS Qualification_Count  FROM Qualification q LEFT JOIN Employee e ON 
q.EmpID = e.EmpID GROUP BY q.EmpID, Employee_Name ORDER BY Qualification_Count DESC;

--- 12. Which year had the most employees taking leaves?
SELECT 
    YEAR(Date) AS Year, 
    COUNT(DISTINCT EmpID) AS Total_Employees
FROM 
    Leaves
GROUP BY 
    YEAR(Date)
ORDER BY 
    Total_Employees DESC
LIMIT 1;

--- 13. What is the average number of leave days taken by its employees per department? 
SELECT    JD.jobdept, 
CAST(COUNT(L.leaveID) AS REAL) / COUNT(DISTINCT E.empID) AS Avg_Leave_Days_Per_Employee FROM    Employee E 
INNER JOIN    JobDepartment JD ON E.JobID = JD.JobIDLEFT JOIN    Leaves L ON E.empID = L.empID GROUP BY  
  JD.jobdept ORDER BY    Avg_Leave_Days_Per_Employee DESC;

-- 14. Which employees have taken the most leaves?
SELECT e.EmpID, e.firstname, COUNT(l.leaveID) AS Total_Leaves FROM Leaves l JOIN Employee e ON l.EmpID = e.EmpID GROUP BY e.EmpID, e.firstname ORDER BY Total_Leaves DESCLIMIT 10;

--- 15.What is the total number of leave days taken company-wide? 
SELECT COUNT(LeaveID) AS Total_Leave_Days
FROM Leaves;

--- 16.What is the total monthly payroll processed?
select count(EmpId) as total_employees,sum(totalamount) as total_payroll_to_employees FROM payroll ;

-- 17.What is the average bonus given per department?
SELECT JD.jobdept, AVG(SB.bonus) AS AverageBonus FROM JobDepartment JD JOIN SalaryBonus SB ON JD.Job_ID = SB.Job_ID GROUP BY JD.jobdept ORDER BY AverageBonus DESC;

--- 18 .Which department receives the highest total bonuses? 
SELECT JD.jobdept, SUM(SB.bonus) AS TotalBonuses FROM Employee E JOIN JobDepartment JD ON E.JobID = JD.JobID JOIN Salary_Bonus SB ON 
E.JobID = SB.JobID GROUP BY JD.jobdept ORDER BY TotalBonuses DESC;