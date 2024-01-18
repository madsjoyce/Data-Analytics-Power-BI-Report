--- Which month in 2022 has had the highest revenue?

SELECT 
    month_name, 
    ROUND(SUM(sale_price * product_quantity)::numeric, 2) AS revenue_total
FROM 
    forquerying2
WHERE 
    EXTRACT(YEAR FROM dates::timestamp) = 2022
GROUP BY 
    month_name
ORDER BY 
    revenue_total DESC
LIMIT 1;