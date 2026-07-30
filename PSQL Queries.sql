-- Walmart Project Queries

SELECT * FROM walmart;

-- DROP TABLE walmart;

-- DROP TABLE walmart;

-- 
SELECT COUNT(*) FROM walmart;

SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q1: Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Q2: Identify the highest-rated category in each branch, displaying the branch, category AVG RATING. 

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1


-- Q3: Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1

-- Q4: Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.



SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Q5: Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2


-- Q6: Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1


-- Q7: Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1


-- Q8: Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- 
-- Q9: Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

-- Q10: Which Product Category Generates the Highest Revenue?
SELECT
    category,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC;

-- Q11: Which Branch Generates the Highest Revenue?
SELECT
    branch,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue
FROM walmart
GROUP BY branch
ORDER BY revenue DESC;

-- Q12: Which City Generates the Highest Revenue?
SELECT
    city,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue
FROM walmart
GROUP BY city
ORDER BY revenue DESC;

-- Q13: Which Branch Has the Highest Average Customer Rating?
SELECT
    branch,
    ROUND(AVG(rating)::numeric, 2) AS avg_rating
FROM walmart
GROUP BY branch
ORDER BY avg_rating DESC;

-- Q14: Which Category Sold the Maximum Number of Items?
SELECT
    category,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY category
ORDER BY total_quantity DESC;

-- Q15: What is the Average Order Value (AOV) for Each Branch?
SELECT
    branch,
    ROUND(
        (SUM(unit_price * quantity) / COUNT(invoice_id))::numeric,
        2
    ) AS avg_order_value
FROM walmart
GROUP BY branch
ORDER BY avg_order_value DESC;

-- Q16: Which Hour Receives the Maximum Number of Orders?
SELECT
    EXTRACT(HOUR FROM time) AS sales_hour,
    COUNT(*) AS total_orders
FROM walmart
GROUP BY sales_hour
ORDER BY total_orders DESC;

-- Q17: Which Hour Generates the Highest Revenue?
SELECT
    EXTRACT(HOUR FROM time) AS sales_hour,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue
FROM walmart
GROUP BY sales_hour
ORDER BY revenue DESC;

-- Q18: How Does Revenue Change Every Month?
SELECT
    TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Month') AS month_name,
    EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YYYY')) AS month_no,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue
FROM walmart
GROUP BY month_no, month_name
ORDER BY month_no;

-- Q19: Which Month Generated the Highest Revenue?
SELECT
    TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Month') AS month_name,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue
FROM walmart
GROUP BY month_name
ORDER BY revenue DESC
LIMIT 1;

-- Q20: Which Payment Method Generates the Highest Revenue?
SELECT
    payment_method,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS total_revenue
FROM walmart
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Q21: What Percentage of Total Revenue Comes from Each Category?
SELECT
    category,
    ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(unit_price * quantity) * 100.0 /
            (SELECT SUM(unit_price * quantity) FROM walmart)
        )::numeric,
        2
    ) AS revenue_percentage
FROM walmart
GROUP BY category
ORDER BY revenue_percentage DESC;

-- Q22: Find the Top 3 Revenue-Generating Categories in Every Branch.
WITH revenue_cte AS
(
    SELECT
        branch,
        category,
        ROUND(SUM(unit_price * quantity)::numeric, 2) AS revenue,
        RANK() OVER
        (
            PARTITION BY branch
            ORDER BY SUM(unit_price * quantity) DESC
        ) AS ranking
    FROM walmart
    GROUP BY branch, category
)

SELECT
    branch,
    category,
    revenue
FROM revenue_cte
WHERE ranking <= 3
ORDER BY branch, revenue DESC;

-- Q23: Which Branches Generate Above-Average Revenue?
WITH branch_revenue AS
(
    SELECT
        branch,
        SUM(unit_price * quantity) AS revenue
    FROM walmart
    GROUP BY branch
)

SELECT
    branch,
    ROUND(revenue::numeric, 2) AS revenue
FROM branch_revenue
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM branch_revenue
)
ORDER BY revenue DESC;

-- Q24: Which Categories Have an Above-Average Customer Rating?
WITH category_rating AS
(
    SELECT
        category,
        ROUND(AVG(rating)::numeric, 2) AS avg_rating
    FROM walmart
    GROUP BY category
)

SELECT
    category,
    avg_rating
FROM category_rating
WHERE avg_rating >
(
    SELECT AVG(avg_rating)
    FROM category_rating
)
ORDER BY avg_rating DESC;

-- Q25: Which Categories Generate High Revenue but Receive Low Customer Ratings?
WITH category_summary AS
(
    SELECT
        category,
        SUM(unit_price * quantity) AS revenue,
        ROUND(AVG(rating)::numeric, 2) AS avg_rating
    FROM walmart
    GROUP BY category
)

SELECT
    category,
    ROUND(revenue::numeric, 2) AS revenue,
    avg_rating
FROM category_summary
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM category_summary
)
AND avg_rating <
(
    SELECT AVG(avg_rating)
    FROM category_summary
)
ORDER BY revenue DESC;

-- Q26: Find the Month-over-Month Revenue Growth.
WITH monthly_revenue AS
(
    SELECT
        EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YYYY')) AS month_no,
        TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Month') AS month_name,
        SUM(unit_price * quantity) AS revenue
    FROM walmart
    GROUP BY month_no, month_name
)

SELECT
    month_name,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER(ORDER BY month_no)::numeric,
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            (
                revenue -
                LAG(revenue) OVER(ORDER BY month_no)
            )
            /
            LAG(revenue) OVER(ORDER BY month_no)
            * 100
        )::numeric,
        2
    ) AS growth_percentage
FROM monthly_revenue;

-- Q27: Find the Running (Cumulative) Revenue by Month.
WITH monthly_revenue AS
(
    SELECT
        EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YYYY')) AS month_no,
        TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Month') AS month_name,
        SUM(unit_price * quantity) AS revenue
    FROM walmart
    GROUP BY month_no, month_name
)

SELECT
    month_name,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND
    (
        SUM(revenue)
        OVER
        (
            ORDER BY month_no
        )::numeric,
        2
    ) AS running_revenue
FROM monthly_revenue;

-- Q28: Find the Top 5 Highest Value Transactions.
SELECT
    invoice_id,
    branch,
    category,
    ROUND((unit_price * quantity)::numeric, 2) AS transaction_value
FROM walmart
ORDER BY transaction_value DESC
LIMIT 5;

-- Q29: Find the Most Profitable Category in Every Branch.
WITH category_profit AS
(
    SELECT
        branch,
        category,
        ROUND(SUM(unit_price * quantity * profit_margin)::numeric, 2) AS total_profit,
        RANK() OVER
        (
            PARTITION BY branch
            ORDER BY SUM(unit_price * quantity * profit_margin) DESC
        ) AS ranking
    FROM walmart
    GROUP BY branch, category
)

SELECT
    branch,
    category,
    total_profit
FROM category_profit
WHERE ranking = 1
ORDER BY branch;

-- Q30: Find the Best Performing Month for Every Branch.
WITH monthly_revenue AS
(
    SELECT
        branch,
        EXTRACT(MONTH FROM TO_DATE(date, 'DD/MM/YYYY')) AS month_no,
        TO_CHAR(TO_DATE(date, 'DD/MM/YYYY'), 'Month') AS month_name,
        SUM(unit_price * quantity) AS revenue,
        RANK() OVER
        (
            PARTITION BY branch
            ORDER BY SUM(unit_price * quantity) DESC
        ) AS ranking
    FROM walmart
    GROUP BY
        branch,
        month_no,
        month_name
)

SELECT
    branch,
    month_name,
    ROUND(revenue::numeric, 2) AS revenue
FROM monthly_revenue
WHERE ranking = 1
ORDER BY branch;




