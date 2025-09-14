-- SQL Retail Sales Analysis - P1

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
			(
				transactions_id	INT PRIMARY KEY, 
				sale_date DATE,
				sale_time TIME, 	
				customer_id	INT,
				gender	VARCHAR(15),
				age	INT, 
				category VARCHAR(15), 
				quantiy	INT,
				price_per_unit	FLOAT,
				cogs	FLOAT,
				total_sale FLOAT
			)
SELECT * FROM retail_sales
LIMIT 10

SELECT COUNT(*)
FROM retail_sales

-- DATA CLEANING
-- finding NULL values

SELECT * FROM retail_sales
WHERE 
	transactions_id	IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id	IS NULL OR
	gender	IS NULL OR
	age	IS NULL OR
	category IS NULL OR
	quantiy	IS NULL OR
	price_per_unit	IS NULL OR
	cogs	IS NULL OR
	total_sale IS NULL 

-- Deleting NULL VALUES
DELETE FROM retail_sales
WHERE 
	transactions_id	IS NULL OR
	sale_date IS NULL OR
	sale_time IS NULL OR
	customer_id	IS NULL OR
	gender	IS NULL OR
	age	IS NULL OR
	category IS NULL OR
	quantiy	IS NULL OR
	price_per_unit	IS NULL OR
	cogs	IS NULL OR
	total_sale IS NULL 

-- DATA EXPLORATION
-- checking all the values
SELECT * FROM retail_sales

-- how many sales we have?
SELECT COUNT (*) as total_sale FROM retail_sales

-- how many unique customers we have?
SELECT COUNT (DISTINCT customer_id) FROM retail_sales

-- how many unique categories we have? 
SELECT COUNT (DISTINCT category) as u_cat FROM retail_sales

-- Name of the distinct categories 
SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- Q1) Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05'

-- Q2) Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:

-- part A:
SELECT category, SUM(quantiy) FROM retail_sales
WHERE category = 'Clothing' GROUP BY 1
--  part B:
SELECT * FROM retail_sales
WHERE category = 'Clothing' AND quantiy >=4 
	  AND 
	  TO_CHAR(sale_date,'YYYY-MM') = '2022-11'

-- Q3) Write a SQL query to calculate the total sales (total_sale) for each category.:
-- part A
SELECT category, SUM(total_sale) AS net_sale, SUM(quantiy) AS net_quantity FROM retail_sales
GROUP BY category
-- part B -> finding average sales
SELECT category, SUM(total_sale) AS net_sale, SUM(quantiy) AS net_quantity,
		ROUND(SUM(total_sale)::NUMERIC / NULLIF(SUM(quantiy), 0), 2) AS avg_order_size
FROM retail_sales
GROUP BY category

-- Q4) Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
select 
round(avg(age),2) as avg_age 
from retail_sales
where category = 'Beauty'

-- Q5) Write a SQL query to find all transactions where the total_sale is greater than 1000.:
select * from retail_sales
where total_sale > 1000

select * from retail_sales
limit 5
      
-- Q6) Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
-- type A
select category, gender, count(*) as total_trans from retail_sales
group by gender, category
order by 1

-- Q7) Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
(INTERVIEW QUESTION)
-- part A
select * from 
(
select 
	extract (year from sale_date) as year,
	extract (month from sale_date) as month,
	round(avg(total_sale)::numeric,2) as avg_sale,
	rank() over(partition by extract (year from sale_date) order by round(avg(total_sale)::numeric,2) desc) as rank
from retail_sales
group by 1, 2 
) as t1
where rank = 1
-- part B 
select year, month, avg_sale
from 
(
select 
	extract (year from sale_date) as year,
	extract (month from sale_date) as month,
	round(avg(total_sale)::numeric,2) as avg_sale,
	rank() over(partition by extract (year from sale_date) order by round(avg(total_sale)::numeric,2) desc) as rank
from retail_sales
group by 1, 2 
) as t1
where rank = 1

-- Q8) Write a SQL query to find the top 5 customers based on the highest total sales 
select customer_id, sum(total_sale) as tot_sales
from retail_sales
group by customer_id
order by 2 desc
limit 5

-- Q9) Write a SQL query to find the number of unique customers who purchased items from each category.:
select category , count(distinct(customer_id)) as unq_cust
from retail_sales
group by 1

-- Q10) Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):

-- we will be creating a CTE (COMMON TABLE EXPRESSIOINS)
with hourly_sale
as
(
select *,
	case
		when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end as shift
from retail_sales
) 
select shift, count(*) as tot_ord  from hourly_sale
group by 1

-- End of Project




