-- Create the customers table
CREATE TABLE Customers
(
    Customer_ID CHAR(8) PRIMARY KEY,
	Bracket_cust_id CHAR(10),
    Customer_Name VARCHAR(255),
    Segment VARCHAR(255),
    Age INT,
	Country VARCHAR(255),
	City VARCHAR(255),
	State VARCHAR(255),
    Postal_Code INT,
	Region VARCHAR(255)
);

-- Create the sales table
CREATE TABLE Sales
(
    Order_line INT,
	Order_ID VARCHAR(255),
	Order_Date DATE,
	Ship_Date DATE,
    Ship_Mode VARCHAR(255),
    Customer_ID CHAR(8),
	Product_ID VARCHAR(255),
	Category VARCHAR(255),
	Sub_Category VARCHAR(255),
	Sales DECIMAL(10,5),
	Quantity INT,
    Discount DECIMAL(4,2),
	Profit DECIMAL(10,5)
);

SELECT * FROM Sales;
SELECT * FROM Customers;

-- Retrieve all columns in the sales table for customers above 60 years old

-- Returns the count of customers
SELECT customer_id, COUNT(*)
FROM sales
	where customer_id in (Select Distinct customer_ID from customers where age>60)
GROUP BY customer_id
ORDER BY COUNT(*) DESC;

-- Write a Join statement to get the name of the cusomers that are above 60 years old
SELECT customers.customer_id, customers.customer_name, count(*) from Customers
join sales on customers.customer_id = sales.customer_id
	where customers.customer_id in (Select Distinct customer_ID from customers where age>60)
GROUP BY customers.customer_id
ORDER BY COUNT(*) DESC;

--Retrieve a list of top 10 customers names living in the west region with highest sales
SELECT customers.customer_id, customers.customer_name, customers.region, Round(Sum(sales.sales),2) from Customers
join sales on customers.customer_id = sales.customer_id
	where customers.customer_id in (Select DISTINCt customer_ID from customers where customers.region ='West')
GROUP BY customers.customer_id,customers.customer_name, customers.region,sales.sales
Order by sales desc
limit 10;

--Retrieve a list of customers that generated more that $1000 in sales in West Region or South Region
select customer_id, round(sum(s.sales),2) from sales as s
where sales > 1000
and customer_id
in (select customer_id from customers
where customers.region = 'west' or customers.region = 'South')
group by customer_id;

-- Exercise 6.2: Find the difference between an employee's average salary
-- and the average salary of all employees
SELECT e.emp_no, e.first_name, e.last_name, a.emp_avg_salary,
(SELECT ROUND(AVG(salary), 2) avg_salary FROM salaries), 
a.emp_avg_salary - (SELECT ROUND(AVG(salary), 2) avg_salary FROM salaries) AS salary_diff
FROM employees e
JOIN (SELECT s.emp_no, ROUND(AVG(salary), 2) AS emp_avg_salary
				   FROM salaries s
				   GROUP BY s.emp_no
				   ORDER BY s.emp_no) a
ON e.emp_no = a.emp_no
ORDER BY emp_no;

-- Exercise 6.3: Find the difference between the maximum salary of employees
-- in the Finance or HR department and the maximum salary of all employees

SELECT e.emp_no, e.first_name, e.last_name, a.emp_max_salary,
(SELECT MAX(salary) max_salary FROM salaries), 
(SELECT MAX(salary) max_salary FROM salaries) - a.emp_max_salary salary_diff
FROM employees as e
JOIN (SELECT s.emp_no, MAX(salary) AS emp_max_salary
				   FROM salaries s
				   GROUP BY s.emp_no
				   ORDER BY s.emp_no) a
ON e.emp_no = a.emp_no
WHERE e.emp_no IN (SELECT emp_no FROM dept_emp WHERE dept_no IN ('d002', 'd003'))
ORDER BY emp_no;

-- Exercise 7.1: Retrieve the salary that occurred the most

-- Returns a list of the count of salaries
-- Solution
SELECT a.salary 
FROM (
	SELECT salary, COUNT(*)
	FROM salaries
	GROUP BY salary
	ORDER BY COUNT(*) DESC, salary DESC
	LIMIT 1) a;

-- Exercise 7.2: Find the average salary excluding the highest and
-- the lowest salaries
-- Solution
SELECT ROUND(AVG(salary), 2) as avg_salary
FROM salaries
WHERE salary NOT IN (
	(SELECT MIN(salary) FROM salaries),
	(SELECT MAX(salary) FROM salaries));

-- Exercise 7.3: Retrieve a list of customers id, name that has
-- bought the most from the store

-- Returns a list of customer counts
SELECT sales.customer_id, COUNT(*) AS cust_count
FROM sales
GROUP BY sales.customer_id
ORDER BY cust_count DESC;
	 
-- Solution
SELECT c.customer_id, c.customer_name, a.cust_count
FROM customers c,
  	(SELECT customer_id, COUNT(*) AS cust_count
  	 FROM sales
     GROUP BY customer_id
	 ORDER BY cust_count DESC) AS a
  WHERE c.customer_id = a.customer_id
ORDER BY a.cust_count DESC;

-- Exercise 7.4: Retrieve a list of the customer name and segment
-- of those customers that bought the most from the store and
-- had the highest total sales

-- Returns a list of customer counts and total sales
SELECT customer_id, COUNT(*) AS cust_count, SUM(sales) as total_sales
FROM sales
GROUP BY customer_id
ORDER BY total_sales DESC, cust_count DESC;

-- Solution
SELECT c.customer_id, c.customer_name, c.segment, a.cust_count, a.total_sales
FROM customers c,
  	(SELECT customer_id, COUNT(*) AS cust_count, SUM(sales) total_sales
  	 FROM sales
     GROUP BY customer_id
	 ORDER BY total_sales DESC, cust_count DESC) AS a
  WHERE c.customer_id = a.customer_id
ORDER BY a.total_sales DESC, a.cust_count DESC;