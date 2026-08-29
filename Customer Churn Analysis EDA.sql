                     -- Customer Churn Analysis EDA--


-- 1. Which age group and contract comination has the highest churn rate?

WITH analysis AS (
    SELECT
        CASE
            WHEN Age BETWEEN 18 AND 24 THEN '18-24'
            WHEN Age BETWEEN 25 AND 34 THEN '25-34'
            WHEN Age BETWEEN 35 AND 44 THEN '35-44'
            WHEN Age BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS Age_Group,
        Contract_Type,
        COUNT(*) AS Total_Customers,
        SUM(Churn = 'Yes') AS Churned_Customers
    FROM Customer_Churn_analysis
    GROUP BY Age_Group, Contract_Type
)
SELECT *,
       ROUND(Churned_Customers * 100.0 / Total_Customers, 2) AS Churn_Rate,
       RANK() OVER (
           ORDER BY Churned_Customers * 100.0 / Total_Customers DESC
       ) AS Churn_Rank
FROM analysis;


-- 2. Which contract type creates the highest revenue risk because of customer churn?

SELECT
	Contract_Type,
	COUNT(*) AS Churned_Customers,
	ROUND(SUM(Total_Charges),2) AS Revenue_At_Risk
FROM customer_churn_analysis
WHERE Churn = 'Yes'
GROUP BY Contract_Type
ORDER BY Revenue_At_Risk DESC;


-- 3. Which month experienced the highest churn rate?

WITH monthly_analysis AS(
    SELECT
		DATE_FORMAT(Date,'%Y-%m')AS Month,
        COUNT(*) AS Total_Customers,
        SUM(Churn='Yes') AS Churned_Customers
	FROM customer_churn_analysis
    GROUP BY DATE_FORMAT(Date,'%Y-%m')
)
SELECT
   Month,Total_Customers,Churned_Customers,
   ROUND(
      Churned_Customers * 100.0/ Total_Customers,2
   )AS Churn_Rate
FROM monthly_analysis
ORDER BY Churn_Rate  DESC
LIMIT 1;


-- 4. Does low satisfaction combined with frequent support calls create a high-risk customer segment?

SELECT 
	Support_Calls,
    Satisfaction_Score,
    COUNT(*) AS Total_Customers,
    ROUND(
      SUM(Churn = 'Yes') * 100.0/ COUNT(*),2
	)AS Churn_Rate
FROM customer_churn_analysis
GROUP BY Support_Calls,Satisfaction_Score
HAVING COUNT(*)>=30
ORDER BY Churn_Rate DESC
LIMIT 10;


-- 5. Which tenure period has highest churn risk?

WITH tenure_analysis AS (
    SELECT
        CASE
            WHEN Tenure_Months <= 12 THEN '0-12 Months'
            WHEN Tenure_Months <= 24 THEN '13-24 Months'
            WHEN Tenure_Months <= 36 THEN '25-36 Months'
            ELSE '37+ Months'
        END AS Tenure_Group,
        COUNT(*) AS Total_Customers,
        SUM(Churn = 'Yes') AS Churned_Customers
    FROM customer_churn_analysis
    GROUP BY Tenure_Group
)
SELECT
    Tenure_Group,
    Total_Customers,
    Churned_Customers,
    ROUND(
        Churned_Customers * 100.0 / Total_Customers, 2
    ) AS Churn_Rate,
    RANK() OVER (
        ORDER BY Churned_Customers * 100.0 / Total_Customers DESC
    ) AS Churn_Rank
FROM tenure_analysis
ORDER BY Churn_Rank;


-- 6. Which customer group should the company prioritize for immediate retention?

SELECT
	COUNT(*) AS High_Risk_CUstomers,
    ROUND(SUM(Total_Charges),2) AS Revenue_At_Risk
FROM customer_churn_analysis
WHERE Churn -'Yes'
	AND Satisfaction_Score <=2
    AND Support_Calls >=5;
    
    
-- 7. Which internet-service and contract comination has the highest churn?

SELECT
    Internet_Service,
    Contract_Type,
    COUNT(*) AS Total_Customers,
    SUM(Churn = 'Yes') AS Churned_Customers,
    ROUND(
        SUM(Churn = 'Yes') * 100.0 / COUNT(*), 2
    ) AS Churn_Rate
FROM customer_churn_analysis
GROUP BY Internet_Service, Contract_Type
ORDER BY Churn_Rate DESC
LIMIT 1;


-- 8. Which gender has higher churn within each conract type?

SELECT
    Contract_Type,
    Gender,
    COUNT(*) AS Total_Customers,
    SUM(Churn = 'Yes') AS Churned_Customers,
    ROUND(
        SUM(Churn = 'Yes') * 100.0 / COUNT(*), 2
    ) AS Churn_Rate
FROM customer_churn_analysis
GROUP BY Contract_Type, Gender
ORDER BY Contract_Type, Churn_Rate DESC;


-- 9. Are churned customers paying higher monthly charges than retained customers?

SELECT
    Churn,
    COUNT(*) AS Customers,
    ROUND(AVG(Monthly_Charges), 2) AS Avg_Monthly_Charges,
    ROUND(AVG(Total_Charges), 2) AS Avg_Total_Charges
FROM customer_churn_analysis
GROUP BY Churn;


-- 10. Which customer segment comines high churn with high monthly charges?

WITH segment_analysis AS (
    SELECT
        Contract_Type,
        COUNT(*) AS Total_Customers,
        SUM(Churn = 'Yes') AS Churned_Customers,
        ROUND(AVG(Monthly_Charges), 2) AS Avg_Monthly_Charges,
        ROUND(
            SUM(Churn = 'Yes') * 100.0 / COUNT(*), 2
        ) AS Churn_Rate
    FROM customer_curn_analysis
    GROUP BY Contract_Type
)
SELECT
    Contract_Type,
    Total_Customers,
    Churned_Customers,
    Avg_Monthly_Charges,
    Churn_Rate,
    RANK() OVER (
        ORDER BY Churn_Rate DESC, Avg_Monthly_Charges DESC
    ) AS Risk_Rank
FROM segment_analysis
ORDER BY Risk_Rank;



    
    
    
    
    
	
    

