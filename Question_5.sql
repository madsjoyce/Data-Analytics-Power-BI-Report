-- 5. Which product category generated the most profit for the "Wiltshire, UK" region in 2021?

SELECT 
    category,
    full_region AS region,
    SUM(sale_price * product_quantity) AS total_revenue,
    ROUND(SUM(cost_price * product_quantity)::numeric, 2) AS total_cost,
    ROUND(SUM((sale_price * product_quantity) - (cost_price * product_quantity))::numeric, 2) AS total_profit
FROM 
    forquerying2
WHERE 
    EXTRACT(YEAR FROM dates::timestamp) = 2021 AND full_region = 'Wiltshire, UK'
GROUP BY 
    category, 
    full_region
ORDER BY 
    total_profit DESC;
