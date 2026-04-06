# Google_Play_SQL_Analysis
📌 Project Overview

This project uses **pure SQL** to analyse the Google Play Store dataset containing 10,000+ apps across 33 categories. While my [Python/EDA version](https://github.com/VibeCipher/Google_Play_Store_Analysis) explored the same dataset visually, this project demonstrates the ability to answer the same business questions using structured queries — the core skill every Data Analyst needs.

---

## ❓ Business Questions Answered

| # | Question | SQL Concept Used |
|---|----------|-----------------|
| 1 | Which categories dominate the Play Store? | GROUP BY, ORDER BY |
| 2 | Do paid apps have better ratings than free ones? | CASE WHEN, AVG |
| 3 | Which apps are the most popular by reviews? | ORDER BY, LIMIT |
| 4 | How are ratings distributed across the store? | Bucketing with CASE |
| 5 | Which categories have the most low-rated apps? | HAVING, Aggregation |
| 6 | Who are the top 3 apps in each category by reviews? | Window Functions, RANK() |
| 7 | Which categories beat the global average rating? | CTEs, CROSS JOIN |
| 8 | What is the rating gap within each category? | MIN/MAX, Aggregation |
| 9 | Which categories have the most 1B+ install apps? | Filtering, COUNT |
| 10 | Running total of apps across categories | SUM() OVER() |

---

## 🔍 Key Insights

- **Family & Game** categories dominate the store — together they account for nearly 30% of all apps
- **Paid apps** rate slightly higher on average (~4.1 vs ~4.0) but receive dramatically fewer reviews — suggesting a smaller but more engaged user base
- **Events & Education** categories have the highest average ratings, while **Dating** apps consistently score the lowest
- Over **80% of all apps are free** — the freemium model is the default on Android
- App ratings show a **ceiling effect** — most cluster between 4.0 and 4.5, making it hard to stand out purely on ratings
- A **power law distribution** governs installs — a handful of apps capture billions of downloads while the majority sit under 100K

---

## 🛠️ SQL Concepts Demonstrated

- `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- Conditional logic: `CASE WHEN`
- **Window Functions**: `RANK()`, `ROW_NUMBER()`, `SUM() OVER()`
- **CTEs** (Common Table Expressions): multi-step logic without subquery nesting
- Data type casting: `CAST(REPLACE(price, '$', '') AS DECIMAL)`

---

## 📁 Project Structure

```
📦 Google_Play_Store_SQL_Analysis
 ┣ 📄 Google_Play_SQL_analysis.sql   ← All 25 queries
 ┣ 📄 googleplaystore.csv                 ← Dataset
 ┗ 📄 README.md                           ← You are here
```

---

## 🚀 How to Run

1. Clone this repository
2. Import `googleplaystore.csv` into your MySQL/PostgreSQL database
3. Run the `CREATE TABLE` statement at the top of the `.sql` file
4. Load the CSV using your preferred method (see comments in the file)
5. Execute queries section by section

```sql
-- Example: Run this to get started
SELECT category, COUNT(*) AS total_apps
FROM playstore
GROUP BY category
ORDER BY total_apps DESC
LIMIT 10;
```
## 🔗 Related Projects

- 🐍 [Python EDA Version](https://github.com/VibeCipher/Google_Play_Store_Analysis) — Same dataset explored with Pandas, Matplotlib & Seaborn
- 📺 [YouTube Channel Analysis](https://github.com/VibeCipher/Youtube_Analysis)
- 🎵 [Spotify Analysis](https://github.com/VibeCipher/Spotify_Analysis)

---

## 👤 Author

**Soham Chatterjee**
- 🔗 [LinkedIn](https://www.linkedin.com/in/sohamchatterjee-data/)
- 💻 [GitHub](https://github.com/VibeCipher)
- 📊 [Portfolio](http://datascienceportfol.io/sohamchatterjee45)
