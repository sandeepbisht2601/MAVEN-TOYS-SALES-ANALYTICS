                           
                           -- chapter 1. overall business performance --

-- 1.	What is the total revenue, total profit, and overall profit margin for the entire business?

SELECT 
	  ROUND(SUM(s.units * p.product_price),2)                                  AS  Total_Revenue,
      ROUND(SUM(s.units * p.product_cost),2)                                   AS  Total_Cost,
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Total_Profit,
      CONCAT(
      ROUND(
			SUM(s.units * (p.product_price - p.product_cost))
            /SUM(s.units * p.product_price) * 100 , 2
            ),'%')                                                             AS Profit_margin_pct
FROM sales s 
JOIN products p ON s.product_id = p.product_id ;


-- 2.	How many transactions and units were sold in total? What is the average order value?

SELECT 
	  COUNT(s.sale_id)                                   AS Total_transactions,
      SUM(s.units)									     AS Total_units_sold,
      ROUND(AVG(s.units * p.product_price),2)			 AS Avg_order_value
FROM sales s 
JOIN products p ON s.product_id = p.product_id ;




-- 3.	What is the total revenue and profit split by year?

SELECT 
	  YEAR(s.sale_date)                                                        AS  Yr,
      COUNT(s.sale_id)														   AS  Transactions,
	  ROUND(SUM(s.units * p.product_price),2)                                  AS  Revenue,      
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Profit,
      CONCAT(
      ROUND(
			SUM(s.units * (p.product_price - p.product_cost))
            /SUM(s.units * p.product_price) * 100 , 2
            ) ,'%')                                                                 AS Profit_margin_pct
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY Yr
ORDER BY Yr ;





-- 4.	What is the revenue and profit for each month? (Monthly trend)

SELECT 
	DATE_FORMAT(s.sale_date,'%M %Y')                                           AS  Month_year,
      COUNT(s.sale_id)														   AS  Transactions,
	  ROUND(SUM(s.units * p.product_price),2)                                  AS  Revenue,      
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Profit
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY YEAR(s.sale_date), MONTH(s.sale_date), DATE_FORMAT(s.sale_date, '%M %Y')
ORDER BY YEAR(s.sale_date), MONTH(s.sale_date);


-- 5.	Which quarter generates the most revenue and profit?

SELECT 
	  YEAR(s.sale_date)														   AS  Yr,
      QUARTER(s.sale_date)													   AS  Quart,
      COUNT(s.sale_id)														   AS  Transactions,
	  ROUND(SUM(s.units * p.product_price),2)                                  AS  Revenue,      
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Profit
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY Yr, Quart 
ORDER BY Yr, Quart 
;


-- 6.	Which day of the week generates the most revenue?

SELECT 
	  DAYNAME(s.sale_date)                                   AS  Day_name,
      COUNT(s.sale_id)							             AS  Transactions,
	  ROUND(SUM(s.units * p.product_price),2)                AS  Revenue
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY Day_name
ORDER BY Revenue desc
;

                           -- chapter 2. Product and category analysis -- 
                           
-- 7 Which product category generates the most profit? What is the margin for each?

SELECT 
	  p.Product_Category,
	  ROUND(SUM(s.units * p.product_price),2)                                  AS  Total_Revenue,
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Total_Profit,
      CONCAT(
      ROUND(
			SUM(s.units * (p.product_price - p.product_cost))
            /SUM(s.units * p.product_price) * 100 , 2
            ),'%' )                                                                 AS Profit_margin_pct
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY p.Product_Category
ORDER BY Total_profit desc;

-- 8 What are the top 10 best-selling products by total revenue?

SELECT 
	  p.product_name,
      p.product_category,
      p.product_price,
      SUM(s.units)                                                             AS  Total_units,
      ROUND(SUM(s.units * p.product_price),2)                                  AS  Total_Revenue,
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)               AS  Total_Profit
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.product_price
ORDER BY Total_revenue desc
limit 10;

-- 9 Which products have the highest profit margin percentage?

SELECT 
	  p.product_name,
      p.product_category,
      p.product_cost,
      p.product_price,
      ROUND((p.product_price - p.product_cost),2)                                           AS  Profit_per_unit,
	  ROUND((p.product_price - p.product_cost)/ p.product_price * 100 ,2)                     AS  Margin_pct
FROM products p 
ORDER BY Margin_pct desc
limit 10
;

      

-- 10 Which products are the lowest performers by total revenue?

SELECT 
	  p.product_name,
      p.product_category,
      SUM(s.units)                                                        As Total_units,
      ROUND(SUM(s.units * p.product_price),2)                             AS Total_revenue
FROM sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_category
ORDER BY Total_revenue asc
limit 5;

-- 11 What is the revenue contribution % of each category vs the total?

WITH rev_contri AS (
					SELECT 
						  p.product_category,
                          ROUND(SUM(s.units * p.product_price),2)              AS Revenue
					FROM sales s 
                    JOIN products p ON s.product_id = p.product_id 
                    GROUP BY p.product_category
),
Total_rev AS (
				SELECT 
					  ROUND(SUM(Revenue),2)                                    AS Grand_revenue
                from rev_contri
)
SELECT 
	  rc.product_category,
      rc.revenue,
      tr.grand_revenue,
      ROUND((rc.revenue/tr.grand_revenue) * 100 , 1)                           AS  Revenue_share_pct 
FROM rev_contri rc 
CROSS JOIN total_rev tr 
ORDER BY rc.product_category
;
      

-- 12  What are the top 3 products by revenue within each category?

WITH Category_rev AS (
					  SELECT p.product_category,
							 p.product_name,
                             ROUND(SUM(s.units * p.product_price),2)                     AS Revenue
                      FROM sales s 
                      JOIN products p ON s.product_id = p.product_id
                      GROUP BY p.product_id,p.product_category,p.product_price
),
rank_products AS (
					SELECT *,
						   RANK() OVER(PARTITION BY product_category ORDER BY Revenue desc) AS Rankk
					FROM category_rev
)
SELECT 
		Product_category,
        Product_name,
        Revenue,
        Rankk
FROM rank_products
WHERE rankk <=3
ORDER BY Product_category,Rankk
;
                             
                                     -- Chapter 3  Store & Location Performance (Q13–Q18)-- 
                                     
-- 13 Which are the top 10 stores by total revenue?


SELECT 
	  st.store_name,
      ROUND(SUM(s.units * p.product_price),2)                       AS Revenue
FROM sales s 
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id 
GROUP BY st.store_id, st.store_name
ORDER BY Revenue Desc
LIMIT 10;

-- 14 How does revenue and profit compare across store location types?

SELECT 	
	  st.store_location,
      COUNT(DISTINCT st.store_id)                                        AS Stores,
      ROUND(SUM(s.units * p.product_price),2)                            AS Revenue,
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)         AS Profit,
      ROUND(AVG(s.units * p.product_price),2)                            AS Avg_per_order
FROM sales s 
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id 
GROUP BY  st.store_location
order by  Revenue desc
;

-- 15 Which cities generate the most revenue? (Top 10 cities)

SELECT 
	  st.store_city,
      COUNT(DISTINCT st.store_id)                             AS Stores,
      ROUND(SUM(s.units * p.product_price),2)                 AS Revenue,
      ROUND(SUM(s.units * p.product_price)
			/ COUNT(DISTINCT st.store_id),2)                  AS Rev_per_store
FROM sales s 
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id 
GROUP BY st.store_city
ORDER BY revenue desc
LIMIT 10
;


-- 16 Does product category profitability differ by store location type?

SELECT 	
	  st.Store_location,
      p.Product_category,
      SUM(s.units)                                                       AS Units_sold,
      ROUND(SUM(s.units * p.product_price),2)                            AS Revenue,
      ROUND(SUM(s.units * (p.product_price - p.product_cost)),2)         AS Profit
FROM sales s 
JOIN stores st ON s.store_id = st.store_id
JOIN products p ON s.product_id = p.product_id
GROUP BY st.store_location, p.product_category
ORDER BY st.store_location , profit desc
;

-- 17 Rank all stores by revenue using RANK() — show each store's position.

WITH Store_revenue AS(
				      SELECT st.Store_name,
							 st.Store_city,
                             st.Store_location,
                             ROUND(SUM(s.units * p.product_price),2)                               AS Revenue
					  FROM sales s 
					  JOIN stores st ON s.store_id = st.store_id
					  JOIN products p ON s.product_id = p.product_id
                      GROUP BY s.store_id
)
SELECT 
	   RANK() OVER(ORDER BY sr.revenue desc)                        AS Rankk,
       Store_name,
       Store_city,
       Store_location,
       Revenue
FROM store_revenue sr
ORDER BY Rankk 
limit 5
;
                      

-- 18 Which stores are performing above vs below the average store revenue?

WITH Store_revenue AS(
				      SELECT st.Store_name,
							 st.Store_city,
                             st.Store_location,
                             ROUND(SUM(s.units * p.product_price),2)                               AS Revenue
					  FROM sales s 
					  JOIN stores st ON s.store_id = st.store_id
					  JOIN products p ON s.product_id = p.product_id
                      GROUP BY s.store_id,st.store_name,st.store_city,st.store_location
),
Avg_revenue AS (				
            
				SELECT 
						ROUND(AVG(revenue),2)                                                        AS Average_revenue
				FROM Store_revenue sr
)
SELECT 
	  sr.Store_name,
      sr.Store_city,
      sr.Store_location,
      sr.Revenue,
      ar.Average_revenue,
      CASE 	WHEN sr.revenue > ar.average_revenue 
            THEN 'Above_average'
            ELSE 'Below_average'
	  END                                                       AS Performace
FROM store_revenue sr 
CROSS JOIN Avg_revenue ar
ORDER BY revenue desc;
	  
                               --  Chapter 4 — Inventory Health Analysis -- 


-- 19 How much total capital is tied up in inventory across all stores?

SELECT 
	   SUM(i.stock_on_hand)                               AS Total_units_in_stock,
       ROUND(SUM(i.stock_on_hand * product_cost),2)       AS Value_at_cost,
       ROUND(SUM(i.stock_on_hand * product_price),2)      AS Value_at_Retail,
       COUNT(CASE WHEN i.stock_on_hand = 0 THEN 1 END)    AS Stockout_count
FROM inventory i 
JOIN products p ON i.Product_ID = p.Product_ID
;
       
-- 20 Which store-product combinations are currently out of stock?

SELECT 
	  st.Store_name,
      st.store_city,
      p.product_name,
      p.product_category,
      i.stock_on_hand
FROM inventory i 
JOIN products p ON i.product_id = p.product_id
JOIN stores st ON i.store_id = st.store_id
where i.Stock_On_Hand = 0
;

-- 21 Estimate daily revenue being lost due to stockouts.

WITH Avg_daily AS (
				   SELECT store_id,
						  product_id,
                          ROUND(SUM(units)/COUNT(DISTINCT sale_date),2)     AS     Avg_units_day
				   FROM sales 
                   GROUP BY store_id,product_id
)
SELECT st.store_name,
       p.product_name,
       p.product_price,
       ROUND(ad.Avg_units_day,2)                                             AS    Avg_units_day,
       ROUND((ad.Avg_units_day * p.product_price),2)                      AS    Est_Daily_revenue_lost
FROM inventory i 
JOIN Avg_daily ad ON i.store_id = ad.store_id 
				AND i.product_id = ad.product_id
JOIN stores st ON i.store_id = st.store_id 
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_on_hand = 0 
ORDER BY Est_daily_revenue_lost desc
LIMIT 10
;

-- 22 How many days of stock remain for each product at each store?

WITH Avg_daily AS (
				   SELECT store_id,
						  product_id,
                          ROUND(SUM(units)/COUNT(DISTINCT sale_date),2)     AS     Avg_units_day
				   FROM sales 
                   GROUP BY store_id,product_id
)
SELECT st.store_name,
       p.product_name,
       p.product_price,
       ROUND(ad.Avg_units_day,2)                                             AS    Avg_units_day,
       i.Stock_On_Hand,
       ROUND(i.stock_on_hand/NULLIF(ad.avg_units_day,0),0)                   AS    Days_of_stock
FROM inventory i 
JOIN Avg_daily ad ON i.store_id = ad.store_id 
				AND i.product_id = ad.product_id
JOIN stores st ON i.store_id = st.store_id 
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_on_hand > 0 
ORDER BY Days_of_stock desc
LIMIT 15;

-- 23 Which stores have the highest inventory value locked up at cost?

SELECT 
	  st.Store_name,
      st.Store_city,
      SUM(i.stock_on_hand)                                       AS Total_units,
      ROUND(SUM(i.stock_on_hand * p.product_cost),2)             AS Inventory_at_cost
FROM inventory i 
JOIN stores st ON i.store_id = st.store_id
JOIN products p ON i.product_id = p.product_id
GROUP BY st.Store_Name,st.Store_City
ORDER BY Inventory_at_cost desc
LIMIT 10;

                     -- Chapter 5 — Trends, Patterns & Summary Insights -- 
                     
                     
-- 24 Calculate month-over-month revenue growth using LAG().

WITH Monthly AS(
			    SELECT DATE_FORMAT(s.sale_date,'%M %Y')                         AS Month_Year,
                YEAR(s.sale_date) 												AS yr,
                MONTH(s.sale_date) 												AS mn,
					   ROUND(SUM(s.units * p.product_price),2)                  AS Revenue
				FROM sales s 
                JOIN products p ON s.product_id = p.product_id
                GROUP BY  YEAR(s.sale_date), MONTH(s.sale_date), DATE_FORMAT(s.sale_date,'%M %Y')
               
)
SELECT 
	  Month_Year,
      Revenue,
      LAG(Revenue) OVER(ORDER BY yr,mn) 									AS Previous_month_revenue,
      ROUND(Revenue - LAG(Revenue) OVER(ORDER BY yr,mn),2) 			    AS Difference,
      ROUND((Revenue - LAG(Revenue) OVER(ORDER BY yr,mn))
			/ Revenue *100 , 2)											        AS Mom_pct
FROM Monthly
ORDER BY yr, mn
;
                
-- 25 What is the running (cumulative) total revenue month by month?

WITH Monthly  AS (
				  SELECT 
						DATE_FORMAT(s.sale_date,'%Y-%m')             AS Ym,
                        ROUND(SUM(s.units * p.product_price),2)      AS Revenue
				  FROM sales s 
                  JOIN products p ON s.product_id = p.product_id
                  GROUP BY Ym
)
SELECT 
		Ym,
        Revenue,
        ROUND(SUM(Revenue) OVER(ORDER BY Ym) ,2)                       AS Cummulative_Revenue
FROM Monthly
ORDER BY Ym
;

-- 26 What is the 3-month rolling average revenue? (Smoothed trend)

WITH Monthly  AS (
				  SELECT 
						DATE_FORMAT(s.sale_date,'%Y-%m')             AS Ym,
                        ROUND(SUM(s.units * p.product_price),2)      AS Revenue
				  FROM sales s 
                  JOIN products p ON s.product_id = p.product_id
                  GROUP BY Ym
)
SELECT 
		Ym,
        Revenue,
        ROUND(AVG(Revenue) OVER(ORDER BY Ym
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0)                       AS Rolling_3m_avg
FROM Monthly
ORDER BY Ym
;

-- 27 Which products showed consistent growth month over month for at least 3 consecutive months? -- 

WITH Monthly_prod AS (
				SELECT 
					  p.product_name,
                      DATE_FORMAT(s.sale_date,'%Y-%m')                       AS Ym,
                      SUM(s.units)                                           AS Units_sold
				FROM sales s 
                JOIN products p ON s.product_id = p.product_id 
                GROUP BY p.product_name,Ym
),
Growth AS (
			SELECT 
				  product_name,Ym,Units_sold,
                  CASE
					  WHEN Units_sold > LAG(Units_sold) OVER(PARTITION BY product_name ORDER BY Ym)
                      THEN 1
                      ELSE 0
                      END                                                     AS is_growth
			FROM Monthly_prod
),
streak AS (
			SELECT 
					product_name,Ym,is_growth,
                    SUM(CASE WHEN is_growth = 0 THEN 1 ELSE 0 END) OVER(PARTITION BY product_name ORDER BY Ym) AS Streak_group
			From Growth 
),
Streak_count AS (
				 SELECT 
						product_name,streak_group,
                        SUM(is_growth)                                         AS consecutive_growth_months
				 FROM 
						streak
				 GROUP BY product_name,streak_group
)
SELECT 
		DISTINCT Product_name 
FROM streak_count
WHERE consecutive_growth_months >= 3
ORDER BY product_name ASC
;
 
      
      
      
      
      
      
       







