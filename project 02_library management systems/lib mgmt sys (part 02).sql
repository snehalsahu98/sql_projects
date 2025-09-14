-- Project Task
-- CRUD (Create, Read, Update, Delete) Operations | PART 01

-- Task 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
select * from books
limit 5

insert into books (isbn, book_title, category, rental_price, status,  author, publisher )
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
select * from books

-- Task 2: Update an Existing Member's Address

update members
set member_address ='125 Main St'
where member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select * from issued_status

delete from issued_status
where issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status

select issued_emp_id, issued_book_name from issued_status
where issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select * from 
(
select issued_emp_id, count(issued_book_name) as no_of_book_issued from issued_status
group by 1
order by 2 desc
) 
where no_of_book_issued > 1


-- CTAS (Create Table as Select) | PART 02
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

create table book_cnts as
select b.isbn, b.book_title, count(ist.issued_id) as no_issued
from books as b join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1, 2

select * from book_cnts
order by 3 desc

-- Part 03: Data Analysis & Finding
-- Task 7. Retrieve All Books in a Specific Category:
select * from books
where category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

select b.category, sum(b.rental_price), count(*)
from books as b join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1
order by 2

-- Task 9: List Members Who Registered in the Last 180 Days:
insert into members(member_id, member_name, member_address, reg_date)
values 
('C123','sam','145 main st','2025-07-01'),
('C134','john','133 main st','2025-06-01');
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e2.emp_name as manager,
	e2.emp_id as manager_id,
	e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.* 
FROM 
employees as e1 JOIN branch as b ON e1.branch_id = b.branch_id    
JOIN employees as e2 ON e2.emp_id = b.manager_id

-- part B
select e2.emp_name as manager, b.manager_id, e1.*
FROM employees as e1 JOIN branch as b ON e1.branch_id = b.branch_id    
JOIN employees as e2 ON e2.emp_id = b.manager_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7 usd:
create table ex_books as
select * from books 
where rental_price >= 7

select * from ex_books
select * from books

-- Task 12: Retrieve the List of Books Not Yet Returned
select distinct ist.issued_book_name, count(ist.issued_id)
from issued_status as ist left join return_status as rs 
on ist.issued_id = rs.issued_id
where rs.issued_id is null
group by ist.issued_book_name











