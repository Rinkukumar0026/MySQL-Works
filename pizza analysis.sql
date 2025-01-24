CREATE DATABASE pizzaplace;
use pizzaplace;
CREATE TABLE orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

select * from orders;
use pizzaplace;
create table order_details(
order_detail_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_detail_id));

select * from order_details;

select order_time,
(case when `order_time` between "08:00:00" and "12:00:00" then "Morning"
when `order_time` between "12:01:00" and "16:00:00" then "Afternoon"
when `order_time` between "16:01:00" and "19:00:00" then "Evening"
else "Night"
end) as Time_of_day
from orders;

alter  table orders add column time_of_day varchar(20);

update orders set time_of_day = (case when `order_time` between "00:00:00" and "12:00:00" then "Morning"
when `order_time` between "12:01:00" and "16:00:00" then "Afternoon"
when `order_time` between "16:01:00" and "19:00:00" then "Evening"
else "Night"
end);

select * from orders;

alter table orders add column month_name varchar(20) not null;
update orders set month_name = (monthname(orders.order_date));

select * from orders;

-- -- what is the total number of order placed
select count(order_id) as Total_orders from orders;

-- Calculate the total revenue from pizza sales

select round(sum(order_details.quantity * pizzas.price),2) as Total_sales
from order_details join pizzas on pizzas.pizza_id = order_details.pizza_id;

-- The highest priced pizza

select pizza_types.name,pizzas.price from pizzas join pizza_types on
pizzas.pizza_type_id = pizza_types.pizza_type_id
order by price desc
limit 1;

--  The most common pizza size ordered

select pizzas.size, sum(order_details.quantity) as Total_quantity_ordered
from pizzas join order_details on
pizzas.pizza_id = order_details.pizza_id
group by pizzas.size 
order by Total_quantity_ordered desc;

-- The top 5 most ordered pizza types along their quantities.

select pizza_types.name, sum(order_details.quantity) as Total_quantity
from 
pizzas join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by Total_quantity Desc
limit 5;

-- The quantity of each pizza categories ordered.

select pizza_types.category, sum(order_details.quantity) as Total_quantity
from
pizzas join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by Total_quantity desc;

-- The distribution of orders by hours of the day.

select orders.time_of_day, count(orders.order_id) as order_count
from orders
group by orders.time_of_day
order by order_count desc;


-- The category-wise distribution of pizzas.

select category, count(pizza_type_id) from pizza_types
group by category;

-- The average number of pizzas ordered per day.

select day(order_date) as order_day, avg(Tot_quantity) as avg_order
from
(select orders.order_date, sum(order_details.quantity) as Tot_quantity
from orders join order_details on orders.order_id = order_details.order_id
group by order_date) as a
group by order_day;

-- Top 3 most ordered pizza type base on revenue.

select pizza_types.name, sum(pizzas.price * order_details.quantity) as Total_rev
from pizzas join order_details on
pizzas.pizza_id = order_details.pizza_id
join pizza_types on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by Total_rev desc
limit 3;


-- The percentage contribution of each pizza type to revenue.	

select category, round((Tot_rev/ (select round(sum(order_details.quantity * pizzas.price),2) as Total_sales
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id) )*100,2) as percentage_contri 
from(
select pizza_types.category, sum(pizzas.price * order_details.quantity) as Tot_rev
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category) as a;


-- The cumulative revenue generated over time

select order_date, sum(Tot_rev) over (order by order_date) as Cum_ren from
(select orders.order_date, sum(pizzas.price * order_details.quantity) as Tot_rev
from order_details join pizzas on
order_details.pizza_id = pizzas.pizza_id
join orders on 
orders.order_id = order_details.order_id
group by orders.order_date) as a;

-- The top 3 most ordered pizza type based on revenue for each pizza category.

select*from(
select category, name, Tot_rev, rank() over (partition by category order by Tot_rev desc) as ranking
from(
select pizza_types.category, pizza_types.name, sum(pizzas.price * order_details.quantity) as Tot_rev
from pizza_types join pizzas on pizza_types.pizza_type_id =  pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name
order by Tot_rev) as a) as b
where Ranking<=3;













