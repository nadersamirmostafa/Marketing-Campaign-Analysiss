-- products_table

CREATE VIEW vw_products_Clean
AS
SELECT *
FROM products;


-------------------------------------------
-- Customer_Geography_table

WITH CTE_Customer_Geography AS
(
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Email,
        c.Gender,
        c.Age,
        g.Country,
        g.City
     
    FROM customers c
    LEFT JOIN geography g
        ON c.GeographyID = g.GeographyID
)

SELECT *
FROM CTE_Customer_Geography;


-------------------------------------------
-- Customer_Reviews_table

WITH CTE_Reviews_Clean AS
(
    SELECT
        ReviewID,
        CustomerID,
        ProductID,
        ReviewDate,
        Rating,
        LOWER(
            REPLACE(
                REPLACE(
                    LTRIM(RTRIM(ReviewText)),
                '  ',' '),
            '  ',' ')
        ) AS ReviewText_Clean

    FROM customer_reviews
)

SELECT *
FROM CTE_Reviews_Clean;


-------------------------------------------
-- Engagement_data_table

WITH CTE_Engagement_Clean AS (
    SELECT 
        EngagementID,
        ContentID,
        UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
        LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
        RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
        FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate,
        CampaignID,
        ProductID,
        Likes  
    FROM engagement_data
)
SELECT *
FROM CTE_Engagement_Clean
WHERE ContentType != 'Newsletter';



-------------------------------------------
-- Customer_Journey_table


WITH CTE_Customer_Journey_Clean AS
(
    SELECT
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        UPPER(Stage) AS Stage,
        Action,
        -- Replace NULL duration with 0
        COALESCE(Duration, 0) AS Duration
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY CustomerID, ProductID, VisitDate,  UPPER(Stage), Action
                   ORDER BY JourneyID
               ) AS rn
        FROM customer_journey   
    ) t
    WHERE rn = 1   -- remove duplicates
)

SELECT *
FROM CTE_Customer_Journey_Clean;

----------------------------------------------------------


