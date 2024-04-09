select * from credit_card_transcations;
desc credit_card_transcations;
-- solve below questions
-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 
select * from credit_card_transcations;
with cte as (
select city, sum(amount) total_city from credit_card_transcations
group by city
order by total_city desc)
select city, total_city, round(total_city/(select sum(total_city) from cte)*100,2) percentage from cte
group by city, total_city
limit 5;

-- 2- write a query to print highest spend month for each year and amount spent in that month for each card type

with cte as (
select year(transaction_date) yr, month(transaction_date) mn, card_type, sum(amount) total
from credit_card_transcations
group by card_type, yr, mn),
cte2 as (
select *,
dense_rank() over(partition by card_type order by total desc) drnk
from cte)
select * from cte2
where drnk = 1;

select year(transaction_date) yr, month(transaction_date) mn, sum(amount) total,
dense_rank() over(partition by year(transaction_date) order by sum(amount) desc)  drnk
from credit_card_transcations
group by year(transaction_date), month(transaction_date);

-- 3- write a query to print the transaction details(all columns from the table) for each card type when
	-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as (
select *, sum(amount) over(partition by card_type order by transaction_id) cummulative from credit_card_transcations),
cte2 as (
select *,
dense_rank() over(partition by card_type order by cummulative desc) drnk
from cte)
select * from cte2
where drnk = 1;
-- Another example
select *, sum(amount) cummulative from credit_card_transcations
group by card_type
having sum(amount) > 1000000;

-- 4- write a query to find city which had lowest percentage spend for gold card type

with cte as (
select city, card_type, sum(amount) sum_gold from credit_card_transcations
where card_type = 'Gold'
group by city, card_type),
cte2 as (
select city, sum(amount) sum_all from credit_card_transcations
group by city)
select cte.city, concat(round(sum_gold/sum_all*100,2),"%") Percentage from cte
join cte2 on cte.city = cte2.city
order by Percentage;

-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte as (
select city, exp_type, sum(amount) total_amount from credit_card_transcations
group by city, exp_type),
cte2 as (
select *,
dense_rank() over(partition by city order by total_amount desc) rn_desc,
dense_rank() over(partition by city order by total_amount) rn_asc
from cte)
select city, max(case when rn_desc = 1 then exp_type end) Highest_expense_type,
min(case when rn_asc = 1 then exp_type end) Lowest_expense_type from cte2
group by city;

-- 6- write a query to find percentage contribution of spends by females for each expense type
with cte as (
select exp_type, sum(amount) sum_type from credit_card_transcations 
where gender = 'F' 
group by exp_type),
cte2 as (
select exp_type, sum(amount) sum_total from credit_card_transcations
group by exp_type)
select cte.exp_type, concat(round(cte.sum_type/cte2.sum_total*100.0,2),"%") percentage from cte 
join cte2 on cte.exp_type = cte2.exp_type;
-- 7- which card and expense type combination saw highest month over month growth in Jan-2014

with cte as (
select card_type, exp_type, year(transaction_date) yr, month(transaction_date) mn, sum(amount) total
from credit_card_transcations
group by card_type, exp_type, yr, mn),
cte2 as (
select *,
lag(total) over(partition by card_type,exp_type order by yr,mn) previous_month
from cte)
select *, (total - previous_month) month_growth
from cte2
where previous_month is not null and yr = '2014' and mn = 1
order by month_growth desc
limit 1;
-- 8- during weekends which city has highest total spend to total no of transcations ratio 

select city, sum(amount)/count(transaction_id) ratio
from credit_card_transcations
where dayname(transaction_date) in ('Saturday','Sunday')
group by city
order by ratio desc
limit 1;
-- 9- which city took least number of days to reach its 500th transaction after the first transaction in that city.

with cte as (
select *,
row_number() over(partition by city order by transaction_date) rn
from credit_card_transcations),
cte2 as (
select *,
lag(transaction_date) over(order by city) lg
from cte
where rn =1 or rn = 500)

select city, timestampdiff(day, (case when rn = 500 then lg end), (case when rn = 500 then transaction_date end)) days from cte2
where timestampdiff(day, (case when rn = 500 then lg end), (case when rn = 500 then transaction_date end)) is not null
order by days
limit 1;