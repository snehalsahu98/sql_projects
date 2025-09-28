-- EDA

select * from customers;
select * from restaurants;
select * from orders;
select * from riders;
select * from deliveries;

-- Import dataset
-- FYI : Follow a Hierarchy while importing tables as we are using PK & FK constraints

-- checking for Null Values
select * from customers
where 
customer_name is null or 
reg_date is null

-- Handling NULL Values: 
-- insert and deleting a record from a table
insert into customers(customer_id)
values (38),(65),(93);

delete from customers 
where
customer_name is null or 
reg_date is null
-- FYI: if inserting values to orders PK & FK can't be null 



-- ----------------------------------------------
-- Analysis & Reports
-- ----------------------------------------------

-- Q1) Most favored dishes of a Customer
-- Write a query to find the top 5 most frequently ordered dishes by customer called 'Arjun Mehta' in the last 1 year.

-- logic:
-- join cx & orders
-- 2 filters: last 1 year, 'Arjun Mehta'
-- group by cx id, dishes, cnt

select customer_name, dishes, total_orders from -- table name
(
select c.customer_id, c.customer_name, o.order_item as dishes, count (*) as total_orders, dense_rank() over ( order by count(*) desc) as rank
from orders as o join customers as c on c.customer_id = o.customer_id
WHERE 
order_date >= '2023-06-01' AND order_date <  '2024-06-01'
and customer_name = 'Arjun Mehta'
group by 1,2,3 order by 1, 4 desc
) as t1 
where rank <=5
-- using "SUB QUERY" here 
select * from orders;



-- Q2) Popular Time Slots
-- Identify the time slots during which the most orders are placed. Based on two hour intervals.

-- Approach 01
select 
case
	when extract (hour from order_time) between 0 and 1 then '00:00 - 02:00'
	when extract (hour from order_time) between 2 and 3 then '02:00 - 04:00'
	when extract (hour from order_time) between 4 and 5 then '04:00 - 06:00'
	when extract (hour from order_time) between 6 and 7 then '06:00 - 08:00'
	when extract (hour from order_time) between 8 and 9 then '08:00 - 10:00'
	when extract (hour from order_time) between 10 and 11 then '10:00 - 12:00'
	when extract (hour from order_time) between 12 and 13 then '12:00 - 14:00'
	when extract (hour from order_time) between 14 and 15 then '14:00 - 16:00'
	when extract (hour from order_time) between 16 and 17 then '16:00 - 18:00'
	when extract (hour from order_time) between 18 and 19 then '18:00 - 20:00'
	when extract (hour from order_time) between 20 and 21 then '20:00 - 22:00'
	when extract (hour from order_time) between 22 and 23 then '22:00 - 00:00'
end as time_slot, 
count (order_id) as order_count
from orders
group by time_slot
order by order_count desc; 

-- Approach 02
select 
	floor (extract(hour from order_time)/2)*2 as start_time,
	floor (extract (hour from order_time)/2)*2 + 2 as end_time, 
	count(*) as total_orders
from orders
group by 1, 2
order by 1


-- Q3) Order Value Analysis
--Find the average order value per customer who has placed more than 750 orders. Return: customer_name and AOV (average order value)

select * from (
select c.customer_name, avg(o.total_amount) as aov, count(o.*) as total_orders
from orders as o join customers as c on o.customer_id = c.customer_id
group by 1
)
where total_orders > 750 
order by 3 desc

-- Q4) High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name and customer_id

select c.customer_name, sum(o.total_amount) as total_rev
from orders as o join customers as c on c.customer_id = o.customer_id
group by 1
HAVING sum(o.total_amount) > 100000
order by 2 desc


-- Q5) Orders w/o Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restaurant name, city and number of not delivered orders

-- Approach 01: JOIN
select r.restaurant_name, r.city, count(*) 
from orders as o left join restaurants as r on r.restaurant_id = o.restaurant_id
left join deliveries as d on d.order_id = o.order_id
where d.delivery_id is null
group by 1, 2
order by 3 desc

-- Approach 02: SUB QUERY
select *
from orders as o left join restaurants as r on r.restaurant_id = o.restaurant_id
where o.order_id not in (select order_id from deliveries)


-------------------------------------------------------------------------------------
-- Q6) Restaurant Revenue Ranking
-- Rank restaurant by their total revenue from the last year, include their name, total revenue and rank within their city

-- Approach 01: City wise Ranking
select r.city, r.restaurant_name, sum(o.total_amount) as revenue, 
	   rank() over(partition by r.city order by sum(o.total_amount) desc ) as rank
from orders as o join restaurants as r on r.restaurant_id = o.restaurant_id
group by 1, 2 order by 1, 3 desc


-- Approach 02: Global Ranking
select r.city, r.restaurant_name, sum(o.total_amount) as revenue, 
	   rank() over(order by sum(o.total_amount) desc ) as rank
from orders as o join restaurants as r on r.restaurant_id = o.restaurant_id
group by 1, 2 order by 1, 3 desc

-- Approach 03: SUB Query
with ranking_table as
(
select r.city, r.restaurant_name, sum(o.total_amount) as revenue, 
	   rank() over(partition by r.city order by sum(o.total_amount) desc ) as rank
from orders as o join restaurants as r on r.restaurant_id = o.restaurant_id
-- where o.order_date >= current_date - interval '1 year'
group by 1, 2 order by 1, 3 desc
)
select * from ranking_table 
where rank = 1

-- FYI: used rank function here, need to do partition
-- code snippet for rank function = rank() over()


-------------------------------------------------------------------------------------
-- Q7) Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.
-- Part A
select r.city, o.order_item as dish, count(order_id) as total_orders,
	   rank() over(partition by r.city order by count(order_id) desc) as rank
from orders as o join restaurants as r on r.restaurant_id = o.restaurant_id
group by 1, 2

-- Part B
select * from 
(
select r.city, o.order_item as dish, count(order_id) as total_orders,
	   rank() over(partition by r.city order by count(order_id) desc) as rank
from orders as o join restaurants as r on r.restaurant_id = o.restaurant_id
group by 1, 2
) as t1
where rank = 1
-- FYI: we need to go outside the query to create filter based on rank


-------------------------------------------------------------------------------------
-- Q8) Customer Churn:
-- Find customers who haven't placed an order in 2024 but did in 2023. 

-- logic
-- t1: cx who have done orders in 2023
-- t2: cx who have notdone orders in 2024 -- t3: compare 1 & 2 using a sub query

select distinct customer_id from orders 
where 
	extract (year from order_date) = 2023 and
	customer_id not in 
	(
	select distinct customer_id from orders 
	where extract(year from order_date) = 2024
	)

-------------------------------------------------------------------------------------
-- Q9) Cancellation Rate Comparison: 
-- Calculate and compare the order cancellaton rate for eeach restaurant between the current date and the previous year
-- Part A - for 2023
with cancel_ratio_23 as -- CTE 1
(
select 
	o.restaurant_id, count(o.order_id) as total_orders, 
	count(case when d.delivery_id is null then 1 end) as not_delivered
from orders as o left join deliveries as d on o.order_id = d.order_id
where extract(year from order_date) = 2023
group by 1
),
last_year_data as -- CTE 2 - depends on CTE 1
(
select *, round(not_delivered::numeric/total_orders::numeric * 100,2) as cancelation_ratio
from cancel_ratio_23
),
-- Part B - for 2024
cancel_ratio_24 as -- CTE 3
(
select 
	o.restaurant_id, count(o.order_id) as total_orders, 
	count(case when d.delivery_id is null then 1 end) as not_delivered
from orders as o left join deliveries as d on o.order_id = d.order_id
where extract(year from order_date) = 2024
group by 1
),
current_year_data as  --CTE 4  - depends on CTE 3
(
select *, round(not_delivered::numeric/total_orders::numeric * 100,2) as cancelation_ratio
from cancel_ratio_24
)

select cd.restaurant_id as rest_id, cd.cancelation_ratio as cc_ratio, ld.cancelation_ratio as lc_ratio
from current_year_data as cd join last_year_data as ld on cd.restaurant_id = ld.restaurant_id
-- FYI: using CTE


-------------------------------------------------------------------------------------
-- Q 10) Rider Average Delivery Time: 
-- Determine each rider's average delivery time.
-- solve with EPOCH statement & use CASE statement
with rider_avg as 
(
select o.order_id, o.order_time, d.delivery_time, d.rider_id, 
	d.delivery_time - o.order_time as time_difference,
	extract(epoch from (d.delivery_time - o.order_time + case when d.delivery_time < o.order_time 
	then interval '1 day' else interval '0 day' end))/60 as sec -- div by 60 to convert to min, 
	-- EPOCH works only in secs
from orders as o join deliveries as d on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
) 
select rider_id, round(avg(sec), 2) as avg_time from rider_avg
group by 1 order by 1


-------------------------------------------------------------------------------------
-- Q 11) Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.

-- logic = first find out month | monthly basis growth can be plotted
with growth_ratio as 
(
select o.restaurant_id, to_char(o.order_date, 'mm-yy') as month, count(o.order_id) as cr_month_orders,
	lag(count(o.order_id), 1) over(partition by o.restaurant_id order by to_char(o.order_date, 'mm-yy')  ) as prev_month_orders
	-- windows function lag() - used to find the monthly growth ratio
	-- order by month = to_char(o.order_date, 'mm-yy')
from orders as o join deliveries as d on o.order_id = d.order_id 
where d.delivery_status = 'Delivered'
group by 1, 2 order by 1, 2
)
select restaurant_id, month, prev_month_orders, cr_month_orders, 
	round((cr_month_orders::numeric - prev_month_orders::numeric)/prev_month_orders::numeric * 100, 2)
	as growth_ratio
from growth_ratio
-------------------------------------------------------------------------------------
-- Q 12) Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). If a customer's total spending exceeds the AOV, label them as 'Gold'; otherwise, label them as 'Silver'. 
-- Write an SQL query to determine each segment's total number of orders and total revenue.

-- logic: cx total spend, aov, 
-- segments: gold, silver | each category & total orders & total rev

-- Approach 01
select customer_id, round(avg(total_amount)::numeric,2) as total_spent,
	case when avg(total_amount) > (select avg(total_amount) from orders) 
	then 'Gold' else 'Silver' end as cx_cat
	-- subquery = select avg(total_amount) from orders
from orders 
group by 1 order by 1
-- aov = 322.82

-- Approach 02: 
select cx_cat, sum(total_orders) as total_orders, sum(total_spent) as total_revenue from 
(
select customer_id, sum(total_amount) as total_spent, count(order_id) as total_orders, 
	case when avg(total_amount) > (select avg(total_amount) from orders) 
	then 'Gold' else 'Silver' end as cx_cat
	-- subquery = select avg(total_amount) from orders
from orders 
group by 1 order by 1
) as t1 
group by 1


-------------------------------------------------------------------------------------
-- Q 13) Rider's Monthly Total Earnings: 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

select d.rider_id, to_char(o.order_date, 'mm-yy') as month, sum(total_amount) as rev,
	round(sum(total_amount::numeric)* 0.08,2) as riders_earning
from orders as o join deliveries as d on o.order_id = d.order_id
group by 1, 2 order by 1, 2 


-------------------------------------------------------------------------------------
-- Q 14) : Rider Rating Analysis:
-- Find the number of 5 star, 4 star and 3 star ratings each rider has. Riders receive this rating based on delivery time. If orders are delivered less than 15 mins of order received time the rider get 5 star rating, if they deliver 15 and 20 mins they get 4 star rating, if they deliver after 20 mins they get 3 star rating. 

select rider_id, stars, count(stars) as tot_stars
from (
select rider_id, d_time, 
	case 
	when d_time < 25 then '5 star'
	when d_time between 25 and 40 then '4 star'
	-- 15 and 20 are included here
	else '3 star'
	end as stars
from 
(
select o.order_id, o.order_time, d.delivery_time, d.rider_id,
	extract(epoch from (d.delivery_time - o.order_time + case when d.delivery_time < o.order_time 
	then interval '1 day' else interval '0 day' end))/60 as d_time
from orders as o join deliveries as d on o.order_id = d.order_id
where delivery_status = 'Delivered'
) as t1
) as t2
group by 1, 2 order by 1, 2 desc
-- FYI: using NESTED SUB QUERY



-------------------------------------------------------------------------------------
-- Q 15) Order Frequency by Day: 
-- Analyze order frequency per day of the week and indentify the peak day for each restaurant. 

select restaurant_name, day, total_orders from 
(
select r.restaurant_name, to_char(o.order_date, 'Day') as day, count(o.order_id) as total_orders,
	rank() over (partition by r.restaurant_name order by count(o.order_id) desc) as rank
from orders as o join restaurants as r on o.restaurant_id = r.restaurant_id
group by 1, 2 order by 1, 3 desc
) as t1
where rank = 1


-------------------------------------------------------------------------------------
-- Q 16) Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders. 

select o.customer_id, c.customer_name, sum(o.total_amount) as CLV 
from orders as o join customers as c on o.customer_id = c.customer_id
group by 1, 2 order by 1, 2


-------------------------------------------------------------------------------------
-- Q 17) Monthly Sales Trends:
-- Identify sales trends by comparing each month's total sales to the previous month. 
select *,round((total_sale::numeric - prev_mon_sale::numeric)/prev_mon_sale::numeric*100,2) as growth_ratio
from (
select year, month, total_sale, lag(total_sale, 1) over ( order by year, month) as prev_mon_sale
from 
(
select extract(year from order_date) as year, extract(month from order_date) as month,
	sum(total_amount) as total_sale
from orders
group by 1, 2
) as t1
) as t2
-------------------------------------------------------------------------------------
-- Q 18) Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages. 


with delivery_table as  -- CTE 1
(
select d.rider_id, extract(epoch from (d.delivery_time - o.order_time +
	case when d.delivery_time < o.order_time then interval '1 day' else interval '0 day' end))/60 as d_time
from orders as o join deliveries as d on o.order_id = d.order_id
where d.delivery_status = 'Delivered'
),
riders_time as -- CTE 2
(
select rider_id, round(avg(d_time::numeric),2) as avg_time from delivery_table
group by 1 
)
select * from -- SUB QUERY
(
select *, rank () over(order by avg_time) as rank
from riders_time order by 1
) where rank = 1 or rank = 15 order by 3



-------------------------------------------------------------------------------------
-- Q 19) Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes

select * from (
select seasons, order_item, sum(total_order) as tot_order, 
rank () over(partition by order_item order by sum(total_order) desc) as rank
from (
select  
	case 
	when month between 1 and 3 then 'Winter'
	when month between 4 and 6 then 'Spring'
	when month between 7 and 9 then 'Summer'
	when month between 10 and 12 then 'Autumn'
	end as seasons,
	month, order_item, total_order
from (
select order_item, extract(month from order_date) as month, count(order_item) as total_order
from orders
group by 1, 2 
) as t1
) as t2
group by 1, 2 order by 2, 3 desc
) where rank = 1

-------------------------------------------------------------------------------------
-- Q 20) Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the toal number of delivered orders since its joining

-- Q 20) Rank each city based on the toal revenue for last year 2023

select r.city, sum(total_amount) as total_revenue, 
	rank() over(order by sum(total_amount) desc) as city_rank
from orders as o join restaurants as r on o.restaurant_id = r.restaurant_id 
group by 1






-------------------------------------------------------------------------------------
                                  -- END OF CODE --
-------------------------------------------------------------------------------------




 














