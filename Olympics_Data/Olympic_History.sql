-- There are 2 datasets 
-- 1- athletes : it has information about all the players participated in olympics
-- 2- athlete_events : it has information about all the events happened over the year.(athlete id refers to the id column in athlete table)
select * from athlete_events;
select * from athletes;
drop table athlete_events;

-- 1 which team has won the maximum gold medals over the years.

with cte as (
select team, count(distinct event) cnt,
row_number() over(partition by year order by count(a.team) desc) rn
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where medal = 'Gold'
group by team
order by cnt desc)

select * from cte 
where rn = 1
limit 1;


-- 2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
	-- team,total_silver_medals, year_of_max_silver
    
with cte as (
select a.team, count(distinct event) silver_medals , ae.year,
rank() over(partition by team order by count(distinct event) desc) rn
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where lower(medal) = 'silver'
group by a.team,ae.year)

select team, sum(silver_medals) total_silver_medals, max(case when rn = 1 then year end) year_of_max_silver
from cte group by team;

-- 3 which player has won maximum gold medals  amongst the players 
	-- which have won only gold medal (never won silver or bronze) over the years

with cte as (
select * from athlete_events ae
join athletes a on ae.athlete_id = a.id)

select name, count(1) gold_medals from cte 
where name not in (select distinct name from cte
					where medal in ('silver','bronze'))
and medal = 'Gold'
group by name
order by gold_medals desc
limit 1;

-- 4 in each year which player has won maximum gold medal . Write a query to print year,player name 
	-- and no of golds won in that year . In case of a tie print comma separated player names.

with cte as (
select year, name, count(1) no_of_golds,
dense_rank() over(partition by year order by count(name) desc) drnk
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where medal = 'Gold'
group by year, name
order by year)
select year, no_of_golds, group_concat(name) names from cte
where drnk = 1
group by year;

-- 5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
	-- print 3 columns medal,year,sport

with cte as (
select *,
first_value(event) over(partition by medal order by year) fv,
row_number() over(partition by medal) rn
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where team = 'India' and medal <> 'NA'
order by medal, year)

select medal, year, event from cte
where rn = 1;

select distinct * from (
select medal,year,event,rank() over(partition by medal order by year) rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where team='India' and medal != 'NA'
) A
where rn=1;

-- 6 find players who won gold medal in summer and winter olympics both.

select name from athlete_events ae
join athletes a on ae.athlete_id = a.id
where medal = 'Gold'
group by name
having count(distinct season) = 2;


-- 7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select name, year from athlete_events ae
join athletes a on ae.athlete_id = a.id
where medal <> 'NA'
group by name, year 
having count(distinct medal) = 3;

-- 8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
	-- Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte as (
select name, year, event
from athlete_events ae
join athletes a on ae.athlete_id = a.id
where medal = 'Gold' and year >= 2000 and medal <> 'NA' and season = 'Summer'
group by name, year, event)

select * from (select *, lag(year) over(partition by name,event order by year) prev_year,
lead(year) over(partition by name,event order by year) next_year
from cte) x
where year = prev_year + 4 and year = next_year - 4;
