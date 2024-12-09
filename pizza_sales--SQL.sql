create database pizzasales;
drop database pizzasales;
create database pizza;
use pizza;
select * from pizzas;
select * from pizza_types;
create table orders(
order_id int primary key,
order_date date not null,
order_time time not null);
select * from order_details;


#total no of orders placed --21350
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;



#Calculate the total revenue generated from pizza sales.--81786.05
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
    
   
   
   #Identify the highest-priced pizza.--35.95
SELECT #1st method
    MAX(price)
FROM
    pizzas;
    
    SELECT 
    pt.name, ps.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
ORDER BY ps.price DESC
LIMIT 1; #2nd method



#Identify the most common pizza size ordered.--L-size 18526
SELECT 
    ps.size, COUNT(od.order_details_id) AS total_count
FROM
    pizzas AS ps
        JOIN
    order_details AS od ON ps.pizza_id = od.pizza_id
GROUP BY ps.size
ORDER BY total_count DESC;


#List the top 5 most ordered pizza types along with their quantities.--
SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = ps.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;



#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON ps.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY quantity DESC;


#Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;


#Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;



#Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity)) AS average_pizzas_ordered_per_day
FROM
    (SELECT 
        os.order_date AS date, SUM(od.quantity) AS quantity
    FROM
        order_details AS od
    JOIN orders AS os ON os.order_id = od.order_id
    GROUP BY date) AS order_quantity;
    
    
    
    #Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * ps.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON ps.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


#Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category, round(SUM(od.quantity * ps.price)/(SELECT 
    SUM(order_details.quantity * pizzas.price)
             as total_sales
FROM
    order_details 
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id)*100,2) as revenue_percent
FROM
    pizza_types AS pt
        JOIN
    pizzas AS ps ON pt.pizza_type_id = ps.pizza_type_id
        JOIN
    order_details AS od ON ps.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY revenue_percent DESC;



#Analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over(order by order_date) as cumlative_rev from(select orders.order_date,sum(od.quantity*ps.price) as revenue from order_details as od join pizzas as ps on od.pizza_id = ps.pizza_id
join orders on orders.order_id = od.order_id group by orders.order_date order by revenue desc) as cum_sales;




#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name,revenue from
(select category,name,revenue,rank() over(partition by category order by revenue desc) as rnk from
(select pt.category,pt.name,sum(od.quantity*ps.price) as revenue from pizza_types as pt join pizzas as ps 
on pt.pizza_type_id = ps.pizza_type_id join order_details as od on od.pizza_id = ps.pizza_id 
group by pt.category,pt.name) as a) as b
where rnk<=3;