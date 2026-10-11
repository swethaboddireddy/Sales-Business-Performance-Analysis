use  businesssales;

desc sales_performance;

select * from sales_performance;


/* ==========================================================================
       1 - DATA QUALITY CHECKS
   ========================================================================== */

-- 1 Row count, date range, unparsed dates

SELECT COUNT(*)AS total_rows,
       MIN(order_date)AS first_order,
       MAX(order_date)AS last_order,
       SUM(order_date IS NULL)AS bad_order_dates,
       SUM(ship_date  IS NULL)AS bad_ship_dates
FROM sales_performance;

-- 2 order_id is NOT unique in this file (use row_id as the true key)
SELECT COUNT(*)AS total_rows,
       COUNT(DISTINCT order_id)AS unique_order_ids,
       COUNT(*) - COUNT(DISTINCT order_id) AS repeated_order_ids
FROM sales_performance;

-- 3 Unknown / blank values per column

SELECT SUM(ship_mode      = 'Unknown') AS ship_mode_unknown,
       SUM(segment        = 'Unknown') AS segment_unknown,
       SUM(order_priority = 'Unknown') AS priority_unknown,
       SUM(payment_method = 'Unknown') AS payment_unknown,
       SUM(sales_channel  = 'Unknown') AS channel_unknown,
       SUM(sub_category   = 'Unknown') AS sub_category_unknown,
       SUM(return_status  = 'Unknown') AS return_unknown,
       SUM(coupon_used    = 'Unknown') AS coupon_unknown
FROM sales_performance;

-- 4 Rows where ship_date is before order_date (date columns are unreliable here)

SELECT COUNT(*) AS ship_before_order
FROM sales_performance
WHERE ship_date < order_date;

-- 5 Check the label fixes worked (each should now list clean values only)

SELECT DISTINCT country FROM sales_performance ORDER BY country;
SELECT DISTINCT state   FROM sales_performance ORDER BY state;
SELECT DISTINCT market  FROM sales_performance ORDER BY market;


/* ==========================================================================
         2 - HEADLINE KPIs
   ========================================================================== */

-- 1 Overall business KPIs

SELECT COUNT(*)AS total_orders,
       COUNT(DISTINCT customer_id)AS unique_customers,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2)AS profit_margin_pct,
       ROUND(AVG(sales), 2)AS avg_order_value,
       SUM(quantity)AS units_sold,
       ROUND(AVG(discount) * 100, 2)AS avg_discount_pct,
       ROUND(AVG(customer_rating), 2)AS avg_rating,
       ROUND(AVG(delivery_days), 2)AS avg_delivery_days
FROM sales_performance;

-- 2 Loss-making orders: how many and how much

SELECT COUNT(*)AS loss_orders,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM sales_performance) * 100, 2) AS pct_of_orders,
       SUM(profit)AS total_loss
FROM sales_performance
WHERE profit < 0;


/* ==========================================================================
        3 - TIME TRENDS
      ========================================================================== */

-- 1 Yearly sales, profit and margin

SELECT YEAR(order_date)AS yr,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
GROUP BY YEAR(order_date)
ORDER BY yr;

-- 2 Year-over-year growth in sales and profit

WITH yearly AS (
    SELECT YEAR(order_date) AS yr,
           SUM(sales)AS total_sales,
           SUM(profit)AS total_profit
    FROM sales_performance
    GROUP BY YEAR(order_date)
)
SELECT yr,
       total_sales,
       ROUND((total_sales - LAG(total_sales) OVER (ORDER BY yr))
             / LAG(total_sales) OVER (ORDER BY yr) * 100, 2)   AS sales_yoy_pct,
       total_profit,
       ROUND((total_profit - LAG(total_profit) OVER (ORDER BY yr))
             / LAG(total_profit) OVER (ORDER BY yr) * 100, 2)  AS profit_yoy_pct
FROM yearly
ORDER BY yr;

-- 3 Monthly sales trend

SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month_key,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit
FROM sales_performance
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year_month_key;

-- 4 Running (cumulative) sales by month

WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS year_month_key,
           SUM(sales)AS month_sales
    FROM sales_performance
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT year_month_key,
       month_sales,
       SUM(month_sales) OVER (ORDER BY year_month_key) AS cumulative_sales
FROM monthly
ORDER BY year_month_key;

-- 5 Seasonality: which calendar month sells most (all years combined)

SELECT MONTH(order_date)AS month_no,
       MONTHNAME(order_date)AS month_name,
       SUM(sales)AS total_sales,
       ROUND(AVG(sales), 2)AS avg_order_value
FROM sales_performance
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY month_no;


/* ==========================================================================
        4 - PRODUCT PERFORMANCE
   ========================================================================== */

-- 1 Category performance

SELECT category,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct,
       ROUND(SUM(sales) / (SELECT SUM(sales) FROM sales_performance) * 100, 2) AS sales_share_pct
FROM sales_performance
GROUP BY category
ORDER BY total_sales DESC;

-- 2 Sub-category performance (excluding 'Unknown')

SELECT sub_category,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
WHERE sub_category <> 'Unknown'
GROUP BY sub_category
ORDER BY total_profit DESC;

-- 3 Top 10 products by sales

SELECT product_name,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       SUM(quantity)AS units_sold
FROM sales_performance
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- 4 Bottom 10 products by profit

SELECT product_name,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
GROUP BY product_name
ORDER BY total_profit ASC
LIMIT 10;

-- 5 Top 3 products by profit inside each category

WITH product_profit AS (
    SELECT category, product_name, SUM(profit) AS total_profit
    FROM sales_performance
    GROUP BY category, product_name
),
ranked AS (
    SELECT category, product_name, total_profit,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY total_profit DESC) AS rnk
    FROM product_profit
)
SELECT category, rnk, product_name, total_profit
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- 6 Pareto: how much of sales comes from the top products

WITH product_sales AS (
    SELECT product_name, SUM(sales) AS total_sales
    FROM sales_performance
    GROUP BY product_name
)
SELECT product_name,
       total_sales,
       ROUND(total_sales / SUM(total_sales) OVER () * 100, 2)                          AS sales_pct,
       ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) / SUM(total_sales) OVER () * 100, 2) AS cumulative_pct
FROM product_sales
ORDER BY total_sales DESC;


/* ==========================================================================
         5 - GEOGRAPHY
     ========================================================================== */

-- 1 Region performance

SELECT region,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
GROUP BY region
ORDER BY total_sales DESC;

-- 2 Country performance

SELECT country,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
GROUP BY country
ORDER BY total_sales DESC;

-- 3 Top 5 states by sales

SELECT state,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit
FROM sales_performance
GROUP BY state
ORDER BY total_sales DESC
LIMIT 5;

-- 4 Best category in every region (by profit)

WITH region_cat AS (
    SELECT region, category, SUM(profit) AS total_profit
    FROM sales_performance
    GROUP BY region, category
),
ranked AS (
    SELECT region, category, total_profit,
           RANK() OVER (PARTITION BY region ORDER BY total_profit DESC) AS rnk
    FROM region_cat
)
SELECT region, category, total_profit
FROM ranked
WHERE rnk = 1
ORDER BY region;


/* ==========================================================================
       6 - CUSTOMERS
      ========================================================================== */

-- 1 Customer segment performance

SELECT segment,
       COUNT(DISTINCT customer_id)AS customers,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(AVG(sales), 2)AS avg_order_value
FROM sales_performance
WHERE segment <> 'Unknown'
GROUP BY segment
ORDER BY total_sales DESC;

-- 2 Top 10 customers by sales

SELECT customer_id,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit
FROM sales_performance
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- 3 One-time vs repeat customers

SELECT customer_type,
       COUNT(*)AS customers,
       SUM(customer_sales) AS total_sales,
       ROUND(SUM(customer_sales) / SUM(SUM(customer_sales)) OVER () * 100, 2) AS sales_share_pct
FROM (
    SELECT customer_id,
           SUM(sales) AS customer_sales,
           CASE WHEN COUNT(*) = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type
    FROM sales_performance
    GROUP BY customer_id
) AS c
GROUP BY customer_type;

-- 4 Customer value tiers (spend buckets)

SELECT CASE
           WHEN customer_sales >= 50000 THEN '1. High (50K+)'
           WHEN customer_sales >= 20000 THEN '2. Medium (20K-50K)'
           ELSE '3. Low (<20K)'
       END AS spend_tier,
       COUNT(*)AS customers,
       SUM(customer_sales) AS total_sales
FROM (
    SELECT customer_id, SUM(sales) AS customer_sales
    FROM sales_performance
    GROUP BY customer_id
) AS c
GROUP BY spend_tier
ORDER BY spend_tier;


/* ==========================================================================
       7 - SALES CHANNEL, PAYMENT, SHIPPING
   ========================================================================== */

-- 1 Sales channel performance

SELECT sales_channel,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
WHERE sales_channel <> 'Unknown'
GROUP BY sales_channel
ORDER BY total_sales DESC;

-- 2 Payment method usage

SELECT payment_method,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM sales_performance) * 100, 2) AS order_share_pct
FROM sales_performance
WHERE payment_method <> 'Unknown'
GROUP BY payment_method
ORDER BY orders DESC;

-- 3 Shipping mode: cost, speed and rating

SELECT ship_mode,
       COUNT(*)AS orders,
       ROUND(AVG(shipping_cost), 2)AS avg_shipping_cost,
       ROUND(AVG(delivery_days), 2)AS avg_delivery_days,
       ROUND(AVG(customer_rating), 2)AS avg_rating
FROM sales_performance
WHERE ship_mode <> 'Unknown'
GROUP BY ship_mode
ORDER BY avg_delivery_days;

-- 4 Order priority performance

SELECT order_priority,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       ROUND(AVG(delivery_days), 2)AS avg_delivery_days
FROM sales_performance
WHERE order_priority <> 'Unknown'
GROUP BY order_priority
ORDER BY orders DESC;


/* ==========================================================================
       8 - DISCOUNTS AND COUPONS
   ========================================================================== */

-- 1 Impact of discount level on sales and profit

SELECT ROUND(discount * 100)AS discount_pct,
       COUNT(*)AS orders,
       SUM(sales)AS total_sales,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2)  AS margin_pct,
       ROUND(AVG(quantity), 2)AS avg_quantity
FROM sales_performance
GROUP BY ROUND(discount * 100)
ORDER BY discount_pct;

-- 2 Discount level vs loss-making orders

SELECT ROUND(discount * 100)AS discount_pct,
       COUNT(*)AS orders,
       SUM(profit < 0)AS loss_orders,
       ROUND(SUM(profit < 0) / COUNT(*) * 100, 2)AS loss_order_pct
FROM sales_performance
GROUP BY ROUND(discount * 100)
ORDER BY discount_pct;

-- 3 Coupon vs no coupon

SELECT coupon_used,
       COUNT(*)AS orders,
       ROUND(AVG(sales), 2)AS avg_order_value,
       SUM(profit)AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM sales_performance
GROUP BY coupon_used
ORDER BY orders DESC;


/* ==========================================================================
       9 - RETURNS
   ========================================================================== */

-- 1 Overall return rate (known statuses only)

SELECT ROUND(SUM(return_status = 'Yes') / COUNT(*) * 100, 2) AS return_rate_pct,
       SUM(return_status = 'Yes')                            AS returned_orders,
       SUM(CASE WHEN return_status = 'Yes' THEN sales END)   AS returned_sales
FROM sales_performance
WHERE return_status <> 'Unknown';

-- 2 Return rate by category

SELECT category,
       COUNT(*)AS orders,
       SUM(return_status = 'Yes')AS returned_orders,
       ROUND(SUM(return_status = 'Yes') / COUNT(*) * 100, 2) AS return_rate_pct
FROM sales_performance
WHERE return_status <> 'Unknown'
GROUP BY category
ORDER BY return_rate_pct DESC;

-- 3 Return rate by shipping mode and delivery speed

SELECT ship_mode,
       ROUND(AVG(delivery_days), 2)AS avg_delivery_days,
       ROUND(SUM(return_status = 'Yes') / COUNT(*) * 100, 2) AS return_rate_pct
FROM sales_performance
WHERE return_status <> 'Unknown' AND ship_mode <> 'Unknown'
GROUP BY ship_mode
ORDER BY return_rate_pct DESC;


/* ==========================================================================
          10 - DELIVERY AND CUSTOMER SATISFACTION
      ========================================================================== */

-- 1 Does faster delivery mean better ratings?

SELECT CASE
           WHEN delivery_days <= 3 THEN '1. Fast (1-3 days)'
           WHEN delivery_days <= 6 THEN '2. Normal (4-6 days)'
           ELSE '3. Slow (7+ days)'
       END AS delivery_speed,
       COUNT(*)AS orders,
       ROUND(AVG(customer_rating), 2)AS avg_rating,
       ROUND(SUM(return_status = 'Yes') / SUM(return_status <> 'Unknown') * 100, 2) AS return_rate_pct
FROM sales_performance
GROUP BY delivery_speed
ORDER BY delivery_speed;

-- 2 Rating distribution

SELECT customer_rating,
       COUNT(*)AS orders,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM sales_performance) * 100, 2)AS pct_of_orders
FROM sales_performance
GROUP BY customer_rating
ORDER BY customer_rating;

-- 3 Average rating by category

SELECT category,
       ROUND(AVG(customer_rating), 2) AS avg_rating,
       ROUND(AVG(delivery_days), 2)AS avg_delivery_days
FROM sales_performance
GROUP BY category
ORDER BY avg_rating DESC;


/* ==========================================================================
     11 - LOSS ANALYSIS AND DEEP DIVES
   ========================================================================== */

-- 1 Where do loss-making orders come from? (category x region)

SELECT category,
       region,
       COUNT(*)AS loss_orders,
       SUM(profit)AS total_loss
FROM sales_performance
WHERE profit < 0
GROUP BY category, region
ORDER BY total_loss ASC
LIMIT 10;

-- 2 Sales share of each category within each region (window function)

SELECT region,
       category,
       SUM(sales) AS total_sales,
       ROUND(SUM(sales) / SUM(SUM(sales)) OVER (PARTITION BY region) * 100, 2) AS share_in_region_pct
FROM sales_performance
GROUP BY region, category
ORDER BY region, total_sales DESC;

-- 3 Year-wise sales by category (pivot style)

SELECT category,
       SUM(CASE WHEN YEAR(order_date) = 2022 THEN sales END) AS sales_2022,
       SUM(CASE WHEN YEAR(order_date) = 2023 THEN sales END) AS sales_2023,
       SUM(CASE WHEN YEAR(order_date) = 2024 THEN sales END) AS sales_2024,
       SUM(CASE WHEN YEAR(order_date) = 2025 THEN sales END) AS sales_2025
FROM sales_performance
GROUP BY category
ORDER BY category;

-- 4 Orders with high sales but negative profit (top 20 worst)

SELECT  order_id, product_name, category, region,
       sales, discount, profit
FROM sales_performance
WHERE profit < 0
ORDER BY profit ASC
LIMIT 20;

