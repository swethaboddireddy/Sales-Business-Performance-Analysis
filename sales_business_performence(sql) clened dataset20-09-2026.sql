create database businesssales;

use  businesssales;

desc sales_performance;

select * from sales_performance;

alter table sales_performance drop column ï»¿row_id;

alter table sales_performance modify column order_id varchar(20);

alter table sales_performance modify column customer_id varchar(20);

update sales_performance set ship_mode = "Unknown" where trim(ship_mode) = '';
update sales_performance set ship_mode = upper(ship_mode);
alter table sales_performance modify column ship_mode varchar(20);

set sql_safe_updates = 0;

update sales_performance set customer_name = "michael jackson" where trim(customer_name) = '';
alter table sales_performance modify column  customer_name varchar(20);
update sales_performance set customer_name = upper(customer_name);

update sales_performance set segment = "unknown" where trim(segment) = '';
alter table sales_performance modify column  segment varchar(15);
update sales_performance set segment = upper(segment);

update sales_performance set country = "russia" where trim(country) = '';
alter table sales_performance modify column  country varchar(20);
update sales_performance set country = upper(country);

update sales_performance set city = "los angeles" where trim(city) = '';
alter table sales_performance modify column  city varchar(20);
update sales_performance set country = upper(city);

update sales_performance set state = "utthar pradesh" where trim(state) = '';
alter table sales_performance modify column  state varchar(20);
update sales_performance set state = upper(state);

update sales_performance set postal_code = 505001 where trim(postal_code) = '';
alter table sales_performance modify column  postal_code int;
update sales_performance set postal_code = 506002 where trim(postal_code) = "N/A";

update sales_performance set market = "united states of america" where trim(market) = '';
alter table sales_performance modify column  market varchar(25);
update sales_performance set market = upper(market);

update sales_performance set region = "north" where trim(region) = '';
alter table sales_performance modify column  region varchar(10);
update sales_performance set region = upper(region);

select * from sales_performance;

alter table sales_performance modify column  product_id varchar(20);

update sales_performance set category = "electronics" where trim(category) = '';
alter table sales_performance modify column  category varchar(25);
update sales_performance set category = upper(category);

update sales_performance set sub_category = "unknown" where trim(sub_category) = '';
alter table sales_performance modify column  sub_category varchar(30);
update sales_performance set sub_category = upper(category);


alter table sales_performance modify column  product_name varchar(30);
update sales_performance set product_name = upper(product_name);

alter table sales_performance modify column  quantity int;

select avg(profit) from sales_performance;
update sales_performance set profit = 5064.814443500009 where trim(profit) = '';
alter table sales_performance modify column  profit decimal(15,2);

select avg(shipping_cost) from sales_performance;
update sales_performance set shipping_cost = 123.15916199999916 where trim(shipping_cost) = '';
alter table sales_performance modify column shipping_cost decimal(12,2);

select avg(expense) from sales_performance;
update sales_performance set expense = 7842.3381475000215 where trim(expense) = '';
alter table sales_performance modify column expense decimal(12,2);

select * from sales_performance;

select avg(revenue) from sales_performance;
update sales_performance set revenue = 12991.858647999981 where trim(revenue) = '';
alter table sales_performance modify column revenue decimal(15,2);

alter table sales_performance modify column profit_margin decimal(10,2);

update sales_performance set order_priority = "unknown" where trim(order_priority) = '';
alter table sales_performance modify column order_priority  varchar(10);
update sales_performance set order_priority = upper(order_priority);

update sales_performance set payment_method  = "neft" where trim(payment_method) = '';
alter table sales_performance modify column payment_method  varchar(15);
update sales_performance set payment_method = upper(payment_method);

update sales_performance set return_status  = "N/A" where trim(return_status) = '';
update sales_performance set return_status = upper(return_status);
update sales_performance set return_status  = "YES" where trim(return_status) = 'Y';
update sales_performance set return_status  = "NO" where trim(return_status) = 'N';
alter table sales_performance modify column return_status  varchar(10);

select avg(customer_rating) from sales_performance;
update sales_performance set customer_rating  = 3 where trim(customer_rating) = '';
alter table sales_performance modify column customer_rating int;

update sales_performance set coupon_used  = "N/A" where trim(coupon_used) = '';
update sales_performance set coupon_used = upper(coupon_used);
update sales_performance set coupon_used  = "YES" where trim(coupon_used) = 'Y';
update sales_performance set coupon_used  = "NO" where trim(coupon_used) = 'N';
alter table sales_performance modify column coupon_used  varchar(10);

select avg(delivery_days) from sales_performance;
update sales_performance set delivery_days  = 3 where trim(delivery_days) = '';
alter table sales_performance modify column delivery_days int;

update sales_performance set sales_channel = "unknown" where trim(sales_channel) = '';
alter table sales_performance modify column sales_channel  varchar(15);
update sales_performance set sales_channel = upper(sales_channel);

alter table sales_performance drop column notes;

UPDATE sales_performance set sales = REPLACE(REPLACE(sales, '$', ''), ',', '');
select sales from sales_performance limit 30;
alter table sales_performance modify column sales decimal(15,2);

select * from sales_performance;

update sales_performance
set discount =
    cast(
        replace(trim(discount),
'%', '')
       as decimal(5,2)
   ) / 100
where discount like '%\%%';
alter table sales_performance modify column discount decimal(5,2);

select order_date,ship_date from Sales_performance limit 30;

update sales_performance set order_date = nullif(trim(order_date), ''),ship_date = nullif(trim(ship_date), '');

select distinct order_date from sales_performance where order_date is not null limit 100;

select * from sales_performance;

SELECT 
    order_date,
    CASE
        WHEN TRIM(order_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(order_date), '%m/%d/%Y')

        WHEN TRIM(order_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(order_date), '%d-%m-%Y')

        WHEN TRIM(order_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(order_date), '%Y-%m-%d')

        ELSE NULL
    END AS converted_date
FROM sales_performance
LIMIT 100;


UPDATE sales_performance
SET order_date =
CASE
    WHEN order_date IS NULL OR TRIM(order_date) = ''
        THEN NULL

    WHEN TRIM(order_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%m/%d/%Y'),
            '%Y-%m-%d'
        )

    WHEN TRIM(order_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%d-%m-%Y'),
            '%Y-%m-%d'
        )

    WHEN TRIM(order_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(order_date), '%Y-%m-%d'),
            '%Y-%m-%d'
        )

    ELSE NULL
END;


SELECT 
   ship_date,
    CASE
        WHEN TRIM(ship_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%m/%d/%Y')

        WHEN TRIM(ship_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%d-%m-%Y')

        WHEN TRIM(ship_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
            THEN STR_TO_DATE(TRIM(ship_date), '%Y-%m-%d')

        ELSE NULL
    END AS converted_date
FROM sales_performance
LIMIT 100;


UPDATE sales_performance
SET ship_date =
CASE
    WHEN ship_date IS NULL OR TRIM(ship_date) = ''
        THEN NULL

    WHEN TRIM(ship_date) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(ship_date), '%m/%d/%Y'),
            '%Y-%m-%d'
        )

    WHEN TRIM(ship_date) REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(ship_date), '%d-%m-%Y'),
            '%Y-%m-%d'
        )

    WHEN TRIM(ship_date) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN DATE_FORMAT(
            STR_TO_DATE(TRIM(ship_date), '%Y-%m-%d'),
            '%Y-%m-%d'
        )

    ELSE NULL
END;


select * from sales_performance;

alter table sales_performance modify order_date date,
modify ship_date date;

SELECT COUNT(*) AS both_null
FROM sales_performance
WHERE order_date IS NULL
  AND ship_date IS NULL;
  
update sales_performance
set order_date = '2025-01-01',
    ship_date = '2025-01-01'
where order_date is NULL
 and ship_date is NULL;    
 
 