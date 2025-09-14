-- WELCOME TO ADVANCE SQL FOR LIBRARY MANAGEMENT SYSTEMS

-- CALL FUNCTION FOR ALL TABLES
select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1


------------------------------------------------------------------------------------------------------------
-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

-- SQL STORE PROCEDURES
create or replace procedure add_return_records(p_return_id varchar(20), p_issued_id varchar(20), p_book_quality varchar(15))
language plpgsql
as $$
declare
	v_isbn VARCHAR(20);
	v_book_name varchar(75);
begin
	-- all your logic & code
	-- CODE 01 | task 01
	insert into return_status (return_id, issued_id, return_date, book_quality)
	values(p_return_id, p_issued_id, current_date, p_book_quality );
	-- CODE 02| task 02
	select issued_book_isbn, issued_book_name
	into v_isbn, v_book_name
	from issued_status
	where issued_id = p_issued_id;
	
	-- CODE 03 | task 03
	update books
	set status = 'yes'
	where isbn = v_isbn;
	-- CODE 04 |  task 04 | print statement
	raise notice 'Thank you for returning the book: %', v_book_name;

end;
$$


-- Testing FUNCTION

-- issued_id = IS135
-- isbn = 978-0-307-58837-1

-- PART A | Checking if everything is OK
-- seeing if book status is yes or no
select * from books 
where isbn = '978-0-307-58837-1'
-- check if book is returned 
select * from return_status
where issued_id = 'IS135'
-- deleting values
delete from return_status
where issued_id = 'IS135'

-- PART B | Calling the actual SP function
call add_return_records('RS138', 'IS135', 'Good');


-------------------------------------------------------------------------------------------------------------
-- Task 15: Branch Performance Report | Creating a CTAS (Create Table AS)
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

create table branch_reports as
select b.branch_id, count (ist.issued_id) as issue, count (rs.return_id) as return, sum(bk.rental_price)
from issued_status as ist join employees as e on e.emp_id = ist.issued_emp_id
join branch as b on e.branch_id = b.branch_id
left join return_status as rs on rs.issued_id = ist.issued_id
join books as bk on ist.issued_book_isbn = bk.isbn
group by 1 order by 1;

select * from branch_reports


--------------------------------------------------------------------------------------------------------------
-- Task 16: CTAS: Create a Table of Active Members (using SUB QUERY)
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.


CREATE TABLE active_members AS
SELECT * FROM members 
WHERE member_id IN 
-- SUB QUERY
(
SELECT DISTINCT issued_member_id FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL '16 month'
);

SELECT * FROM active_members;


--------------------------------------------------------------------------------------------------------------
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select e.emp_name, b.*, count(ist.issued_id) as no_books
from issued_status as ist join employees as e on e.emp_id = ist.issued_emp_id
join branch as b on e.branch_id = b.branch_id
group by 1, 2 order by no_books desc


--------------------------------------------------------------------------------------------------------------
-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.









--------------------------------------------------------------------------------------------------------------
-- Task 19: Stored Procedure 
/* Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/

create or replace procedure issue_book (p_issued_id varchar(20), p_issued_member_id varchar(20), p_issued_book_isbn varchar(50), p_issued_emp_id varchar(20))
language plpgsql
as $$

declare 
	-- all the variables 
	v_status varchar(10);
	
begin
	-- all the code
	select status into v_status
	from books
	where isbn = p_issued_book_isbn;

	if v_status = 'yes' then
		insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		values (p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);
		
		update books 
		set status = 'no'
		where isbn = p_issued_book_isbn;
		
		raise notice 'Book records added successfully for book isbn: %', p_issued_book_isbn; 
	else
		raise notice 'Sorry to inform you the book you have requested is unavailable. Book isbn = %', p_issued_book_isbn; 
	end if;
	
end;
$$

-- TESTING THE STORED PROCEDURE

-- isbn = 978-0-553-29698-2 | status = 'yes'
-- isbn = 978-0-375-41398-8 | status = 'no'

-- PART A | Checking if everything is OK
-- seeing if book status is yes or no
select * from books 
where isbn in ('978-0-553-29698-2', '978-0-375-41398-8')


-- PART B | Calling the actual SP function
call issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
call issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');


--------------------------------------------------------------------------------------------------------------






















