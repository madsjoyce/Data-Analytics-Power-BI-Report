--- 3. Which German store type had the highest revenue for 2022?

SELECT 
       store_type, 
       country,
        ROUND(SUM(sale_price * product_quantity)::numeric, 2) AS revenue_total
FROM 
       forquerying2
WHERE 
       EXTRACT(YEAR FROM dates::timestamp) = 2022 
       AND country = 'Germany'
GROUP BY 
       store_type, country
ORDER BY 
       revenue_total DESC;