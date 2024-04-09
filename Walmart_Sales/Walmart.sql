CREATE DATABASE IF NOT EXISTS walmartsales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id varchar(30) NOT NUll PRIMARY KEY,
    branch varchar(5) NOT NULL,
    city varchar(30) NOT NULL,
    customer_type varchar(30) NOT NULL,
    gender varchar(10) NOT NULL,
    product_line varchar(30) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method varchar(20) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11, 9) NOT NULL,
    income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

select * from sales;

-- ----------------------------------------------------Feature Engineering------------------------------------------------------------------------
-- ------time_of_day
select 
	time,
    (case 
    when `time` between "00:00:00" and "12:00:00" then "Morning"
    when `time` between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening"
    end
    ) as time_of_day
from sales;

alter table sales add column time_of_day varchar(20);

#to update the data in the sales table 
update sales
set time_of_day = (
	case 
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		else "Evening"
    end
);


-- ------day_name
select 
	date,
    dayname(date) as day_name
from sales;

alter table sales add column day_name varchar(15);
update sales
set day_name = dayname(date);

-- ------month_name
select
	date,
    monthname(date) as month_name
from sales;

alter table sales add column month_name varchar(15);
update sales
set month_name = monthname(date);






-- ----------------------------------------------------  Generic  -----------------------------------------------------------------------------
-- ------- How many unique cities does data have?
select distinct city from sales;

-- ------- In which city each branch is?
select distinct branch from sales;




-- ---------------------------------------------------------------- Product -------------------------------------------------------------------
-- ------- How many unique product lines does the data have?
select distinct product_line from sales;

-- ------- What is the most common payment method?
select payment_method, count(payment_method) from sales group by payment_method;

-- ------- What is the most selling product_line?
select product_line, count(product_line) as sale_count from sales group by product_line order by sale_count desc;

-- ------- What is the total revenue by month?
select sum(total) as total_revenue, month_name from sales group by month_name order by total_revenue desc;

-- ------- What month has largest cogs(cost of goods sold)?
select sum(cogs) as cogs, month_name from sales group by month_name order by cogs desc;

-- ------- What product_line has largest revenue?
select product_line, sum(total) as total_revenue from sales group by product_line order by total_revenue desc;

-- ------- What is the city with largest revenue?
select city, sum(total) as total_revenue from sales group by city;	

-- ------- What product line had the largest vat?
select product_line, avg(vat) as avg_tax from sales group by product_line order by avg_tax desc;

-- ------- Fetch each product line and add a column to each product line showing 'Good' or 'Bad'. Good means it is greated the average sales
alter table sales Drop column GB;
-- ------- What branch sold more products than average sold?
select branch, sum(quantity) as quantity from sales group by branch having quantity > (select avg(quantity) from sales);

-- ------- What is the most common product line by gender?
select product_line, gender,count(gender) as cnt from sales group by gender, product_line order by cnt desc;

-- ------- What is the average rating of each product line?
select product_line, avg(rating) as rate from sales group by product_line;





-- ---------------------------------------------------------------- Sales -------------------------------------------------------------------
-- ------- Number of sales made in each time of the day per weekday
select time_of_day,count(*) as total_sales from sales where day_name in ("Sunday","Saturday") group by time_of_day,day_name order by total_sales desc;

-- ------- Which of the customer types bring most revenue?
select customer_type,sum(total) as total_revenue from sales group by customer_type;

-- ------- Which city has largest VAT?
select city,avg(vat) as vat from sales group by city order by vat desc;

-- ------- Which customer type pays the most in vat?
select customer_type, avg(vat) as vat from sales group by customer_type order by vat desc;

select customer_type,count(customer_type) as cut from sales group by customer_type;

select * from sales;