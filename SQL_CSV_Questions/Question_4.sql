-- 4. Create a view where the rows are the store types and the columns are the total sales, percentage of total sales, and the count of orders

CREATE VIEW question_4 AS
SELECT 
    store_type,
    ROUND(CAST(SUM(sale_price * product_quantity) AS numeric), 2) AS total_sales,
    ROUND(CAST(SUM(sale_price * product_quantity) / SUM(SUM(sale_price * product_quantity)) OVER () * 100 AS numeric), 2) AS sales_percentage,
    COUNT(order_date) AS orders
FROM 
    forview
GROUP BY 
    store_type;