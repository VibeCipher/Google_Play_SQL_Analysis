-- Q1. How many total apps are in the dataset?
SELECT COUNT(*) AS total_apps
FROM playstore;

-- Q2. How many unique categories exist?
SELECT COUNT(DISTINCT category) AS unique_categories
FROM playstore;

-- Q3. What are all the unique content ratings available?
SELECT DISTINCT content_rating
FROM playstore
ORDER BY content_rating;

-- Q4. How many free vs paid apps are there?
SELECT type,
       COUNT(*) AS app_count
FROM playstore
WHERE type IN ('Free', 'Paid')
GROUP BY type;

-- Q5. What is the overall average rating across all apps?
SELECT ROUND(AVG(rating), 2) AS avg_rating
FROM playstore
WHERE rating IS NOT NULL;


-- ============================================================
-- SECTION B : CATEGORY ANALYSIS
-- ============================================================

-- Q6. Which category has the most apps?
SELECT category,
       COUNT(*) AS total_apps
FROM playstore
GROUP BY category
ORDER BY total_apps DESC
LIMIT 10;

-- Q7. What is the average rating per category? (only categories with 10+ apps)
SELECT category,
       ROUND(AVG(rating), 2)  AS avg_rating,
       COUNT(*)               AS app_count
FROM playstore
WHERE rating IS NOT NULL
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC;

-- Q8. Which category has the highest number of total reviews?
SELECT category,
       SUM(reviews) AS total_reviews
FROM playstore
WHERE reviews IS NOT NULL
GROUP BY category
ORDER BY total_reviews DESC
LIMIT 10;

-- Q9. What percentage of apps in each category are free?
SELECT category,
       COUNT(*)                                              AS total_apps,
       SUM(CASE WHEN type = 'Free' THEN 1 ELSE 0 END)       AS free_apps,
       ROUND(
           100.0 * SUM(CASE WHEN type = 'Free' THEN 1 ELSE 0 END) / COUNT(*),
           1
       )                                                    AS free_pct
FROM playstore
GROUP BY category
ORDER BY free_pct ASC
LIMIT 10;


-- ============================================================
-- SECTION C : RATINGS DEEP DIVE
-- ============================================================

-- Q10. How are ratings distributed? (bucket analysis)
SELECT CASE
           WHEN rating < 2.0               THEN '⭐ Below 2'
           WHEN rating BETWEEN 2.0 AND 3.0 THEN '⭐⭐ 2–3'
           WHEN rating BETWEEN 3.0 AND 4.0 THEN '⭐⭐⭐ 3–4'
           WHEN rating BETWEEN 4.0 AND 4.5 THEN '⭐⭐⭐⭐ 4–4.5'
           WHEN rating > 4.5              THEN '⭐⭐⭐⭐⭐ 4.5+'
       END                   AS rating_bucket,
       COUNT(*)              AS app_count
FROM playstore
WHERE rating IS NOT NULL
GROUP BY rating_bucket
ORDER BY rating_bucket;

-- Q11. Top 10 highest-rated apps with more than 10,000 reviews (removes obscure apps)
SELECT app,
       category,
       rating,
       reviews
FROM playstore
WHERE rating IS NOT NULL
  AND reviews > 10000
ORDER BY rating DESC, reviews DESC
LIMIT 10;

-- Q12. Which categories have more than 30% of their apps rated below 3.5?
SELECT category,
       COUNT(*)                                                     AS total_apps,
       SUM(CASE WHEN rating < 3.5 THEN 1 ELSE 0 END)               AS low_rated,
       ROUND(
           100.0 * SUM(CASE WHEN rating < 3.5 THEN 1 ELSE 0 END) / COUNT(*),
           1
       )                                                           AS low_rated_pct
FROM playstore
WHERE rating IS NOT NULL
GROUP BY category
HAVING low_rated_pct > 30
ORDER BY low_rated_pct DESC;

-- Q13. What are the most common install milestones?
SELECT installs,
       COUNT(*) AS app_count
FROM playstore
GROUP BY installs
ORDER BY app_count DESC;

-- Q14. Top 10 most reviewed apps (proxy for popularity)
SELECT app,
       category,
       reviews,
       rating
FROM playstore
WHERE reviews IS NOT NULL
ORDER BY reviews DESC
LIMIT 10;

-- Q15. Which category dominates the 1B+ installs club?
SELECT category,
       COUNT(*) AS blockbuster_apps
FROM playstore
WHERE installs = '1,000,000,000+'
GROUP BY category
ORDER BY blockbuster_apps DESC;

-- Q16. Average rating — free vs paid apps
SELECT type,
       ROUND(AVG(rating), 2) AS avg_rating,
       COUNT(*)              AS total_apps
FROM playstore
WHERE type IN ('Free', 'Paid')
  AND rating IS NOT NULL
GROUP BY type;

-- Q17. Top 10 most expensive apps on the store
SELECT app,
       category,
       price,
       rating,
       reviews
FROM playstore
WHERE type = 'Paid'
  AND price NOT IN ('0', 'Free')
ORDER BY CAST(REPLACE(price, '$', '') AS DECIMAL(10,2)) DESC
LIMIT 10;

-- Q18. Do paid apps get reviewed less? Average reviews — free vs paid
SELECT type,
       ROUND(AVG(reviews), 0) AS avg_reviews
FROM playstore
WHERE type IN ('Free', 'Paid')
  AND reviews IS NOT NULL
GROUP BY type;

-- Q19. How many apps exist per content rating?
SELECT content_rating,
       COUNT(*)              AS app_count,
       ROUND(AVG(rating), 2) AS avg_rating
FROM playstore
WHERE rating IS NOT NULL
GROUP BY content_rating
ORDER BY app_count DESC;

-- Q20. Which content rating category performs best in ratings?
SELECT content_rating,
       ROUND(AVG(rating), 2) AS avg_rating,
       COUNT(*)              AS total_apps
FROM playstore
WHERE rating IS NOT NULL
GROUP BY content_rating
HAVING COUNT(*) > 50
ORDER BY avg_rating DESC;

-- Q21. Rank apps within each category by number of reviews (Window Function)
SELECT *
FROM (
    SELECT app,
           category,
           reviews,
           RANK() OVER (PARTITION BY category ORDER BY reviews DESC) AS rank_in_category
    FROM playstore
    WHERE reviews IS NOT NULL
) t
WHERE rank_in_category <= 3;

-- Q22. Running total of apps per category (ordered alphabetically)
SELECT category,
       COUNT(*)                                  AS apps_in_category,
       SUM(COUNT(*)) OVER (ORDER BY category)    AS running_total
FROM playstore
GROUP BY category
ORDER BY category;

-- Q23. CTE — Find categories where avg rating is above the overall average
WITH overall_avg AS (
    SELECT AVG(rating) AS global_avg
    FROM playstore
    WHERE rating IS NOT NULL
),
category_avg AS (
    SELECT category,
           ROUND(AVG(rating), 2) AS cat_avg,
           COUNT(*)              AS total_apps
    FROM playstore
    WHERE rating IS NOT NULL
    GROUP BY category
    HAVING COUNT(*) >= 10
)
SELECT c.category,
       c.cat_avg,
       ROUND(o.global_avg, 2) AS global_avg,
       ROUND(c.cat_avg - o.global_avg, 2) AS diff_from_global
FROM category_avg c
CROSS JOIN overall_avg o
WHERE c.cat_avg > o.global_avg
ORDER BY diff_from_global DESC;

-- Q24. CTE — Top app per category by reviews
WITH ranked_apps AS (
    SELECT app,
           category,
           reviews,
           rating,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY reviews DESC) AS rn
    FROM playstore
    WHERE reviews IS NOT NULL
)
SELECT app,
       category,
       reviews,
       rating
FROM ranked_apps
WHERE rn = 1
ORDER BY reviews DESC;

-- Q25. Which categories have the biggest gap between their best and worst rated apps?
SELECT category,
       ROUND(MAX(rating), 2)              AS highest_rating,
       ROUND(MIN(rating), 2)              AS lowest_rating,
       ROUND(MAX(rating) - MIN(rating), 2) AS rating_gap
FROM playstore
WHERE rating IS NOT NULL
GROUP BY category
HAVING COUNT(*) >= 10
ORDER BY rating_gap DESC
LIMIT 10;