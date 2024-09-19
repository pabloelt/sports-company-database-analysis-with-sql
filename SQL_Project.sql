# SPRINT WEEK 1 - TASK 1
---------------------------------------------

-- Import database from dump: project_database.sql

-- Activate the database as the default one
use project_database;

-- Review the dataset content in the main four tables
select * from channels;
select * from products;
select * from stores;
select * from sales;

-- ¿Is it the granularity of the dataset right?
select count(*) as COUNT from sales
group by id_store, id_prod, id_channel, date_time
having COUNT > 1;

-- It seems that some of the records are duplicated, let's investigate that
select id_store, id_prod, id_channel, date_time, count(*) as COUNT from sales
group by id_store, id_prod, id_channel, date_time
having COUNT > 1
order by id_store, id_prod, id_channel, date_time;

-- Some particular cases
select * from sales
where id_store = 1115
	and id_prod = 127110
    and id_channel = 5
    and date_time = '22/12/2016';

-- We need to create a new table sales_agr with the right granularity, and also:
	-- Change the date_time type 
	-- Create a new field called turnover as the multiplication of amount times offer_price
create table sales_agr as
select str_to_date(date_time, '%d/%m/%Y') as date_time,
	   id_prod, id_store, id_channel,
       sum(amount) as amount,
       avg(official_price) as official_price,
       avg(offer_price) as offer_price,
       round(sum(amount) * avg(offer_price),2) as turnover
from sales
group by 1, 2, 3, 4;
       
-- Review the new sales_agr table
select * from sales_agr limit 10;

-- Review the records in sales_agr
select count(*) from sales_agr;
select count(*) from sales;



# SPRINT WEEK 1 - TASK 2
---------------------------------------------

-- Create an ER diagram to see how the new table is linked

-- The new sales_agr table is not connected with the rest of the tables. We need
	--  to include a new key field called id_sale
	--  id_prod as a FK with the corresponding table
	--  id_store as a FK with the corresponding table
	--  id_channel as a FK with the corresponding table
alter table sales_agr add id_sale int auto_increment primary key,
					  add foreign key(id_prod) references products (id_prod) on delete cascade,
                      add foreign key(id_store) references stores (id_store) on delete cascade,
                      add foreign key(id_channel) references channels (id_channel) on delete cascade;
 
 -- Check the new ER diagram
 
-- Create a view over sales_agr that includes the order id
create view v_sales_agr_order as 
with master_orders as (
	select date_time, id_store, id_channel, row_number() over() as id_order
    from sales_agr
    group by date_time, id_store, id_channel)
select id_sale, id_order, s.date_time, s.id_prod, s.id_store, s.id_channel, amount, official_price, offer_price, turnover 
from sales_agr as s
	left join master_orders as m
    on (s.date_time = m.date_time) and (s.id_store = m.id_store) and (s.id_channel = m.id_channel);
    
select * from v_sales_agr_order;


     
# SPRINT WEEK 2 - TASK 1
---------------------------------------------

-- How many orders do we have in the historical data?
select max(id_order) from v_sales_agr_order;

-- From which day do we have data?
select min(date_time) as first_day, max(date_time) as last_day from sales_agr;

-- How many different products do we have in our catalog?
select count(distinct id_prod) as num_prod from products;

-- How many different stores do we distribute to?
select count(distinct id_store) as num_store from stores;

-- Through which channels can orders be placed with us?
select distinct channel from channels;



# SPRINT WEEK 2 - TASK 2
---------------------------------------------

-- What are the top 3 channels with the highest turnover?
select channel, round(sum(turnover),2) as turnover_channel
from sales_agr as s
	left join channels as c
    on s.id_channel = c.id_channel
group  by s.id_channel
order by turnover_channel desc
limit 3;

-- What is the monthly turnover trend per channel over the last 12 full months?
select channel, month(date_time) as month, round(sum(turnover),2) as turnover_channel
from sales_agr as s
	left join channels as c
    on s.id_channel = c.id_channel
where date_time between '2017-07-01' and '2018-06-30'
group by s.id_channel, month
order by s.id_channel, month;

-- What are the top 50 clients (stores with highest turnover)?
select store_name, round(sum(turnover),2) as turnover_store
from sales_agr as s
	left join stores as st
    on s.id_store = st.id_store
group by s.id_store
order by turnover_store desc
limit 50;

-- Turnover trend by country per term since 2017.	
select country, year(date_time) as year, quarter(date_time) as quarter, round(sum(turnover),2) as turnover_quarter
from sales_agr as s
	left join stores as st
	on s.id_store = st.id_store
where date_time between '2017-01-01' and '2018-06-30'
group by country, year, quarter
order by country, year, quarter;



# SPRINT WEEK 3 - TASK 1
---------------------------------------------

-- Find the top 20 products with higer margins for each line
with table_margin as(
	select *, round((price-cost)/cost*100, 2) as margin
    from products)
select *
from (select id_prod, line, product, margin, row_number() over(partition by line order by margin desc) as ranking
	  from table_margin) as subquery_ranking
where ranking <= 20;

-- Find those products (id_prod) with discounts that exceed the value that falls below the 90% of all discounts
with table_discount as(
	select *, (official_price_avg - offer_price_avg) / official_price_avg as discount
	from(select id_prod, avg(official_price) as official_price_avg, avg(offer_price) as offer_price_avg
		 from sales_agr
		 group by id_prod) as subquery_avg_price)
select *
from (select id_prod, round(discount*100, 2) as discount, round(cume_dist() over(order by discount), 5) as discount_dist
	 from table_discount) as subquery_dist
where discount_dist >= 0.9;



# SPRINT WEEK 3 - TASK 2
---------------------------------------------

-- How many products are we selling?
select count(distinct product) from products; #144 different products
select count(distinct id_prod) from products; #274 different products (color distinction)

-- Which products would we need to keep to maintain 90% of the current turnover?
with table_turnover_prod_cum_per as(
	select id_prod,
		   round(sum(turnover_prod) over(order by turnover_prod desc), 2) as turnover_prod_cum,
		   round(sum(turnover_prod) over(), 2) as turnover_prod_total,
		   round(sum(turnover_prod) over(order by turnover_prod desc)/sum(turnover_prod) over(), 4) as turnover_prod_cum_per
	from (select id_prod, sum(turnover) as turnover_prod
		  from sales_agr
	      group by id_prod
	      order by turnover_prod desc) as subquery_turnover_prod)
select id_prod, turnover_prod_cum, turnover_prod_cum_per
from table_turnover_prod_cum_per
where turnover_prod_cum_per <= 0.9;

-- And therefore, which specific products could we eliminate and still maintain 90% of the revenue?
with table_turnover_prod_cum_per as(
	select id_prod,
		   round(sum(turnover_prod) over(order by turnover_prod desc), 2) as turnover_prod_cum,
		   round(sum(turnover_prod) over(), 2) as turnover_prod_total,
		   round(sum(turnover_prod) over(order by turnover_prod desc)/sum(turnover_prod) over(), 4) as turnover_prod_cum_per
	from (select id_prod, sum(turnover) as turnover_prod
		  from sales_agr
	      group by id_prod
	      order by turnover_prod desc) as subquery_turnover_prod)
select id_prod, turnover_prod_cum, turnover_prod_cum_per
from table_turnover_prod_cum_per
where turnover_prod_cum_per > 0.9;



# SPRINT WEEK 3 - TASK 3
---------------------------------------------

-- What different product lines are we selling?
select distinct line from products;

-- What is the contribution (in percentage) of each line to the total turnover?
with table_turnover_line as(
	select line, round(sum(turnover), 2) as turnover_line
	from sales_agr as s
		left join products as p
		on s.id_prod = p.id_prod
	group by line
	order by turnover_line desc)
select line, turnover_line, round(turnover_line / sum(turnover_line) over(), 2) as turnover_line_per
from table_turnover_line;

-- Could we cut some of the product lines without affecting too much the overall turnover?
# Outdoor Protection line just represents 1% of the overall turnover
# Personal Accessories line is the top-seller one with a 33% of the overall turnover

-- Inside the top-seller product line, is there any particular product on trend?
with table_prod_quarter as(
	select line, product, quarter(date_time) as quarter, round(sum(turnover),2) as turnover_prod
	from sales_agr as s
		left join products as p
		on s.id_prod = p.id_prod
	where line = 'Personal Accessories' and date_time between '2018-01-01' and '2018-06-30'
	group by product, quarter
	order by product, quarter)
select product, trend
from (select line, product, quarter, turnover_prod,
			 round(turnover_prod / lag(turnover_prod) over(partition by product order by quarter), 4) as trend
	  from table_prod_quarter) as subquery_trend
where trend is not null
order by trend desc;



# SPRINT WEEK 4 - TASK 1
---------------------------------------------

-- Client segmentation: 
	-- Create a 4-segment matrix based on the number of orders and client (store) turnover
	-- Each axis will divide between those above and below the average
	-- Save the query as a view for easy access
create view v_segmentation_matrix as
with table_orders_turnover_store as(
	select id_store, count(distinct id_order) as num_orders, round(sum(turnover), 2) as turnover_store
	from v_sales_agr_order
	group by id_store),

	table_avg as(
		select round(avg(num_orders), 2) as avg_orders, round(avg(turnover_store), 2) as avg_turnover_store
		from table_orders_turnover_store)
select *,
	   case
			when num_orders <= avg_orders and turnover_store <= avg_turnover_store then 'O- T-'
            when num_orders <= avg_orders and turnover_store > avg_turnover_store then 'O- T+'
            when num_orders > avg_orders and turnover_store <= avg_turnover_store then 'O+ T-'
            when num_orders > avg_orders and turnover_store > avg_turnover_store then 'O+ T+'
            else 'ERROR'
		end as segmentation
from table_orders_turnover_store, table_avg;

-- Calculate how many customers we have in each segment of the matrix
select segmentation, count(*)
from v_segmentation_matrix
group by segmentation;

-- Growth potential:
	-- Segment the stores by their type, and calculate the 75th percentile (P75) of the revenue
	-- For each store that is below the 75th percentile (P75), calculate its growth potential
with table_store_type as(
	select s.id_store, type, round(sum(turnover), 0) as turnover_store_type
	from sales_agr as s
		left join stores as st
		on s.id_store = st.id_store
	group by s.id_store, type
	order by type, s.id_store),
    
     table_p75_values as(
	select type, turnover_store_type as turnover_p75
	from (select *, row_number() over(partition by type order by percentil) as ranking
	      from (select *, round(percent_rank() over(partition by type order by turnover_store_type)*100, 2)as percentil
			    from table_store_type) as subquery_percent
	      where percentil >= 75) as subquery_ranking
	where ranking = 1)

select id_store, t1.type, turnover_store_type, turnover_p75,
	   case
			when (turnover_store_type - turnover_p75) >= 0 then 0
            when (turnover_store_type - turnover_p75) < 0 then round(turnover_p75 - turnover_store_type, 0)
            else -999999999999
	   end as potential
from table_store_type as t1
	inner join table_p75_values as t2
    on t1.type = t2.type
order by potential desc;

-- Client reactivation:
	-- Identify customers who haven't made a purchase in over 3 months
with table_last_date_total as(
	select max(date_time) as last_date_total
	from sales_agr),
    
     table_last_date_store as(
	select id_store, max(date_time) as last_date_store
	from sales_agr
	group by id_store)
    
select *
from (select *, datediff(last_date_total,last_date_store) as days_no_purchase
	  from table_last_date_store, table_last_date_total) as subquery_days
where days_no_purchase > 90
order by days_no_purchase desc;



# SPRINT WEEK 5 - TASK 1
---------------------------------------------

-- Generate an item-item recommendation system
	-- That identifies products frequently bought together in the same order
	-- And recommends to each store based on their own purchase history
	-- NOTE: you will need to change an option to avoid a timeout error:
	-- Edit --> Preferences --> SQL Editor --> DBMS connection read timeout interval (in seconds)
    
-- Procedure:
-- Create a table with the master item-item recommendations
create table recommender
select v1.id_prod as precedent, v2.id_prod as consequent, count(v1.id_order) as frequency
from v_sales_agr_order as v1
	inner join v_sales_agr_order as v2
     on v1.id_order = v2.id_order #we cross-check order with order to identify the products that are purchased in the same order
        and v1.id_prod != v2.id_prod #we remove the records of each product with itself
        and v1.id_prod < v2.id_prod #we avoid the symmetrical matrix
group by v1.id_prod, v2.id_prod; #we check in how many orders they mach

select * from recommender
order by precedent, frequency desc;

-- Generate a query that produces recommendations for each specific store
-- It has to remove already purchased products from the recommendations for each store
with table_input_client as(
	select id_prod, id_store
	from sales_agr
	where id_store = '1201'),
    
     table_recommended_prod as(
	select consequent, sum(frequency) as frequency
	from table_input_client as t
		left join recommender as r
		on t.id_prod = r.precedent
	group by consequent
	order by frequency desc)
    
select consequent as recommended_prod, frequency
from table_recommended_prod as t1
	left join table_input_client as t2
    on t1.consequent = t2.id_prod
where id_prod is null
limit 10;


