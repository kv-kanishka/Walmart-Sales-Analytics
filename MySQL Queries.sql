-- Walmart Project Queries - MySQL

SELECT * FROM walmart;

-- DROP TABLE walmart;

-- DROP TABLE walmart;

-- Count total records
SELECT COUNT(*) FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity) FROM walmart;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rank = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE rank = 1;

-- Q4: Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

-- Q10: Which Product Category Generates the Highest Revenue?
SELECT
    category,
    ROUND(SUM(unit_price * quantity),2) AS total_revenue
FROM walmart
GROUP BY category
ORDER BY total_revenue DESC;

-- Q11: Which Branch Generates the Highest Revenue?
SELECT
    branch,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY branch
ORDER BY revenue DESC;

-- Q12: Which City Generates the Highest Revenue?
SELECT
    city,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY city
ORDER BY revenue DESC;

-- Q13: Find Top 5 Revenue Generating Branches. 
SELECT
    branch,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY branch
ORDER BY revenue DESC
LIMIT 5;

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
    ROUND(SUM(unit_price * quantity)/COUNT(invoice_id),2) AS avg_order_value
FROM walmart
GROUP BY branch
ORDER BY avg_order_value DESC;

-- Q16: Which Hour Receives the Maximum Number of Orders?
SELECT
    HOUR(TIME(time)) AS sales_hour,
    COUNT(*) AS total_orders
FROM walmart
GROUP BY sales_hour
ORDER BY total_orders DESC;

-- Q17: Which Hour Generates the Highest Revenue?
SELECT
    HOUR(TIME(time)) AS sales_hour,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY sales_hour
ORDER BY revenue DESC;

-- Q18: How does revenue change every month?
SELECT
    MONTHNAME(STR_TO_DATE(date,'%d/%m/%Y')) AS month_name,
    MONTH(STR_TO_DATE(date,'%d/%m/%Y')) AS month_no,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY month_no, month_name
ORDER BY month_no;

-- Q19: Which Month Generated the Highest Revenue?
SELECT
    MONTHNAME(STR_TO_DATE(date,'%d/%m/%Y')) AS month_name,
    ROUND(SUM(unit_price * quantity),2) AS revenue
FROM walmart
GROUP BY month_name
ORDER BY revenue DESC
LIMIT 1;

-- Q20: Which Payment Method Generates the Highest Revenue?
SELECT
    payment_method,
    ROUND(SUM(unit_price * quantity),2) AS total_revenue
FROM walmart
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Q21: Which Payment Method Generates the Highest Revenue?
SELECT
    category,
    ROUND(SUM(unit_price * quantity),2) AS revenue,
    ROUND(
        SUM(unit_price * quantity) * 100 /
        (SELECT SUM(unit_price * quantity) FROM walmart),
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
ROUND(SUM(unit_price*quantity),2) AS revenue,
RANK() OVER(
PARTITION BY branch
ORDER BY SUM(unit_price*quantity) DESC
) AS ranking
FROM walmart
GROUP BY branch,category
)
SELECT
branch,
category,
revenue
FROM revenue_cte
WHERE ranking<=3
ORDER BY branch,revenue DESC;

-- Q23: Which Branches Generate Above-Average Revenue?
WITH branch_revenue AS (
    SELECT
        branch,
        SUM(unit_price * quantity) AS revenue
    FROM walmart
    GROUP BY branch
)
SELECT
    branch,
    revenue
FROM branch_revenue
WHERE revenue > (
    SELECT AVG(revenue)
    FROM branch_revenue
)
ORDER BY revenue DESC;

-- Q24: Which Branches Generate Above-Average Revenue?












