SELECT TOP 5 * FROM Product_data;


           ------ QUESTION 1: ------
--- TOP 2 HIGH DEMAND PRODUCTS IN EACH CATEGORY ---

WITH ProductDemand AS (
 SELECT 
   Category, 
   ProductName,
   Stock,
   Reviews,
   CAST (Reviews AS FLOAT) / NULLIF(Stock,0) AS Demand,
   ROW_NUMBER() OVER (
    PARTITION BY Category
    ORDER BY CAST(Reviews AS FLOAT) / NULLIF(Stock,0) DESC
   ) AS rn
FROM Product_data
WHERE Stock < 100
)
SELECT 
 Category,
 ProductName, 
 Stock,
 Reviews,
 ROUND(Demand,2) AS Demand
FROM ProductDemand
WHERE rn <=2;



      ----- QUESTION 2 -----
--- DISCOUNT IMPACT ON ENGAGEMENT ---

SELECT
  CASE
   WHEN Discount BETWEEN 0 AND 10 THEN '0-10%'
   WHEN Discount BETWEEN 11 AND 20 THEN '11-20%'
   WHEN Discount BETWEEN 21 AND 30 THEN '21-30%'
   WHEN Discount BETWEEN 31 AND 40 THEN '31-40%'
   ELSE '40%+'
  END AS Discount_Range,

  AVG(Reviews) AS Avg_Reviews,
  AVG(Rating) AS Avg_Rating
FROM Product_data
GROUP BY 
  CASE
   WHEN Discount BETWEEN 0 AND 10 THEN '0-10%'
   WHEN Discount BETWEEN 11 AND 20 THEN '11-20%'
   WHEN Discount BETWEEN 21 AND 30 THEN '21-30%'
   WHEN Discount BETWEEN 31 AND 40 THEN '31-40%'
   ELSE '40%+'
  END
HAVING AVG(Reviews) > 300
ORDER BY Avg_Reviews DESC;



      ----- QUESTION 3: -----
--- BRAND REVENUE CONTRIBUTION ---

WITH BrandRevenue AS (
    SELECT 
       Brand, 
       SUM(
          Price * (1- Discount / 100.0) * Reviews
       ) AS Revenue
    from Product_data
    GROUP BY Brand
),
TotalRevenue AS (
    SELECT 
        SUM(Revenue) AS Total_Revenue
    FROM BrandRevenue 
)
SELECT
    br.Brand, 
    ROUND(br.Revenue,2) AS Revenue, 
    ROUND(
       (br.Revenue / tr.Total_Revenue) * 100, 
       2
    ) AS Revenue_Percentage
FROM BrandRevenue br
CROSS JOIN TotalRevenue tr
WHERE 
  (br.Revenue / tr.Total_Revenue) * 100 > 10
ORDER BY Revenue_Percentage DESC;





