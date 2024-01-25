--- How many staff are there in all of the UK stores?

SELECT 
    country,
    SUM(staff_numbers) AS total_staff
FROM 
    dim_store
WHERE 
    country = 'UK'
GROUP BY 
    country;