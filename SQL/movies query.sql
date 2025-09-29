select * from Movies;

--1. Top 10 Movies by ROI (Return on Investment)
SELECT 
    Title,
    BudgetUSD,
    Global_BoxOfficeUSD,
    ROUND((Global_BoxOfficeUSD - BudgetUSD) / NULLIF(BudgetUSD, 0), 2) AS ROI
FROM movies
WHERE BudgetUSD > 0 AND Global_BoxOfficeUSD IS NOT NULL
ORDER BY ROI DESC
LIMIT 10;

--2. Genre-Wise Average IMDb Rating and Revenue
SELECT 
    Genre,
    ROUND(AVG(IMDbRating), 2) AS AvgRating,
    ROUND(AVG(Global_BoxOfficeUSD), 0) AS AvgRevenue
FROM movies
WHERE IMDbRating IS NOT NULL AND Global_BoxOfficeUSD IS NOT NULL
GROUP BY Genre
ORDER BY AvgRevenue DESC;

--3. Top 5 Directors with Highest Average Revenue (Min 5 Movies)
SELECT 
    Director,
    COUNT(*) AS NumMovies,
    ROUND(AVG(Global_BoxOfficeUSD), 0) AS AvgRevenue
FROM movies
WHERE Global_BoxOfficeUSD IS NOT NULL
GROUP BY Director
HAVING COUNT(*) >= 5
ORDER BY AvgRevenue DESC
LIMIT 10;

--4. Movie Release Trend by Year and Genre (Pivot Friendly Format)
SELECT 
    ReleaseYear,
    Genre,
    COUNT(*) AS NumMovies
FROM movies
WHERE ReleaseYear IS NOT NULL
GROUP BY ReleaseYear, Genre 
ORDER BY ReleaseYear, Genre;

--5. Correlation-Like Analysis: IMDb Rating vs Revenue Buckets
SELECT 
    CASE 
        WHEN Global_BoxOfficeUSD < 10000000 THEN 'Low (<$10M)'
        WHEN Global_BoxOfficeUSD BETWEEN 10000000 AND 50000000 THEN 'Mid ($10M–$50M)'
        WHEN Global_BoxOfficeUSD BETWEEN 50000000 AND 200000000 THEN 'High ($50M–$200M)'
        ELSE 'Blockbuster (>$200M)'
    END AS RevenueCategory,
    ROUND(AVG(IMDbRating), 2) AS AvgIMDbRating,
    COUNT(*) AS MovieCount
FROM movies
WHERE IMDbRating IS NOT NULL AND Global_BoxOfficeUSD IS NOT NULL
GROUP BY RevenueCategory
ORDER BY MovieCount DESC;

--6. Top 5 Most Frequent Lead Actors (with Revenue and Rating)
SELECT 
    LeadActor,
    COUNT(*) AS NumMovies,
    ROUND(AVG(Global_BoxOfficeUSD), 0) AS AvgRevenue,
    ROUND(AVG(IMDbRating), 2) AS AvgIMDbRating
FROM movies
WHERE LeadActor IS NOT NULL
GROUP BY LeadActor
ORDER BY NumMovies DESC
LIMIT 5;

--7. Identify Movies That Were Critically Acclaimed but Commercially Weak
SELECT 
    Title,
    IMDbRating,
    RottenTomatoesScore,
    Global_BoxOfficeUSD,
    BudgetUSD
FROM movies
WHERE IMDbRating >= 8.0 
  AND RottenTomatoesScore >= 85
  AND (Global_BoxOfficeUSD - BudgetUSD)<0
ORDER BY IMDbRating DESC;

--8. Decade-wise Genre Popularity (Movie Count per Genre per Decade)
SELECT 
    (ReleaseYear / 10) * 10 AS Decade,
    Genre,
    COUNT(*) AS MovieCount
FROM movies
WHERE ReleaseYear IS NOT NULL
GROUP BY Decade, Genre
ORDER BY Decade, MovieCount DESC;

--9. Most Profitable Movie Per Year
SELECT Title, ReleaseYear, MaxProfit
FROM (
    SELECT 
        Title,
        ReleaseYear,
        (Global_BoxOfficeUSD - BudgetUSD) AS Profit,
        RANK() OVER (PARTITION BY ReleaseYear ORDER BY (Global_BoxOfficeUSD - BudgetUSD) DESC) AS rank,
        (Global_BoxOfficeUSD - BudgetUSD) AS MaxProfit
    FROM movies
    WHERE BudgetUSD > 0 AND Global_BoxOfficeUSD IS NOT NULL
) AS yearly_ranked
WHERE rank = 1
ORDER BY ReleaseYear;

--10. Director-Actor Combo That Appeared Together Most Often
SELECT 
    Director,
    LeadActor,
    COUNT(*) AS NumCollaborations,
    ROUND(AVG(Global_BoxOfficeUSD), 0) AS AvgRevenue
FROM movies
WHERE Director IS NOT NULL AND LeadActor IS NOT NULL
GROUP BY Director, LeadActor
ORDER BY NumCollaborations DESC
LIMIT 5;

