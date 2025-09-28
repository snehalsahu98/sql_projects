-- Zomato Data Analysis using SQL

-- CREATING TABLES FOR DATABASE
create table customers
(
customer_id int primary key,
customer_name varchar(55),
reg_date date
);


create table restaurants
(
restaurant_id int primary key,
restaurant_name	varchar(55), 
city varchar (15), 
opening_hours varchar(55)
);


create table orders
(
order_id int primary key,
customer_id	int, -- fk customers
restaurant_id int, -- fk restaurants
order_item varchar(55),
order_date	date,
order_time	time,
order_status varchar(55),
total_amount float
);

-- adding FK CONSTRAINT
alter table orders
add constraint fk_customers
foreign key (customer_id)
references customers(customer_id);

alter table orders
add constraint fk_restaurants
foreign key (restaurant_id)
references restaurants(restaurant_id);

create table riders
(
rider_id	int primary key, 
rider_name	varchar(55),
sign_up date
);

-- adding FK CONSTRAINT while creating table
drop table if exists deliveries;
create table deliveries
(
delivery_id	int primary key,
order_id	int, -- fk orders
delivery_status varchar(35),	
delivery_time	time,
rider_id int, -- fk riders
constraint fk_orders foreign key (order_id) references orders(order_id),
constraint fk_riders foreign key (rider_id) references riders(rider_id)
);


-- DROP TABLE ORDERING
drop table if exists orders; 
drop table if exists customers; 
drop table if exists restaurants; 
drop table if exists deliveries; 
drop table if exists riders; 

-- End of Schemas
---------------------------------------------------------------------------------------------------------------

























