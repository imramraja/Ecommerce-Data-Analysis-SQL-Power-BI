# 🛒 Ecommerce Data Analysis – Advanced SQL + Power BI

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/iamramraja/)
[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/imramraja)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

## 📌 Project Overview

This project delivers a comprehensive, end-to-end analytical solution for the **Brazilian E-Commerce Public Dataset by Olist**. It demonstrates the full workflow of a data analyst: from cleaning raw data and performing advanced SQL analysis to building interactive Power BI dashboards that drive business decisions.

With over **100,000 orders**, **3,000+ products**, and **3,000+ sellers**, this project simulates a real-world e-commerce ecosystem. The goal was to go beyond basic queries and build a performance monitoring layer that answers strategic business questions through advanced SQL techniques and presents the findings in an accessible, visual format.

## 🎯 Key Business Questions Answered

- What are the monthly revenue trends and seasonal patterns?
- Who are the top customers by lifetime value, and how can we segment them?
- Which products are frequently bought together (affinity analysis)?
- How does delivery delay impact customer review scores?
- Which sellers drive the most revenue, and are they also the highest-rated?
- What is the cancellation rate by product category?

## 🛠️ Technical Toolkit

| Area | Technologies Used |
|------|-------------------|
| **Database** | Microsoft SQL Server (T‑SQL) |
| **Data Modeling** | Star schema with fact tables (orders, items, payments) and dimension tables (customers, products, sellers, time) |
| **SQL Techniques** | Window functions (RANK, LAG, NTILE), CTEs, subqueries, self‑joins, dynamic date logic |
| **Reusable Objects** | Stored procedures, scalar functions, table‑valued functions, SQL views |
| **Visualization** | Power BI dashboards with DAX measures and interactive reports |


## 🧼 Data Cleaning Process

The `Data Cleaning` folder contains scripts that transform raw CSV exports into analysis-ready tables. Key steps include:
- Trimming whitespace and standardizing text (e.g., lowercasing categories)
- Converting string dates to `DATETIME2`
- Casting numeric fields to appropriate types (`DECIMAL`, `INT`)
- Handling missing values (setting empty strings to NULL)
- Removing duplicate geolocation rows
- Adding derived columns (`total_item_value`, `delivery_delay_days`)
- Creating indexes for query performance

All raw data is preserved; cleaned versions are stored with a `_clean` suffix.

## 🔍 20 Business Analysis Queries

The `Business Problems Analysis` folder contains **20 thoughtfully designed SQL queries**, each addressing a real business problem. They are organized by increasing complexity.

| # | Problem Focus | Key Technique | Business Insight Example |
|---|---------------|---------------|--------------------------|
| 1 | Monthly revenue trend | Aggregation, date functions | Revenue peaks in November – likely Black Friday effect |
| 2 | Top 10 products by revenue | `TOP`, joins | Top 5 products contribute 25% of total revenue |
| 3 | Customer order frequency | Subquery, `CASE` | 60% of customers are one‑time buyers |
| 4 | Avg delivery time by state | Date difference | Southeast delivers 3 days faster than North |
| 5 | Payment method popularity | Aggregation | Credit card used in 74% of orders |
| 6 | Seller performance ranking | Window functions (`RANK`) | Revenue and review score are not correlated |
| 7 | Category revenue % | Window functions (%) | “Health & beauty” drives 18% of revenue |
| 8 | Customer lifetime value (CLV) | Aggregation, `CASE` | Top 10% of customers generate 40% of revenue |
| 9 | Repeat purchase rate | Subquery, `HAVING` | Repeat rate is 12% – opportunity for loyalty |
| 10 | Cancellation rate by category | `CASE`, aggregation | “Furniture” has highest cancellation rate (8%) |
| 11 | 3‑month moving average | Window functions (`ROWS BETWEEN`) | Smooths volatility; shows consistent growth |
| 12 | First vs. repeat order value | `ROW_NUMBER` | Repeat orders are 35% higher in value |
| 13 | Product affinity analysis | Self‑join | “Bed” and “mattress” appear together in 200+ orders |
| 14 | Delivery delay vs. review score | Correlation analysis | Each extra delay day drops score by 0.2 points |
| 15 | RFM customer segmentation | `NTILE` | Identified 1,200 “Champions” for targeted campaigns |
| 16 | Geographic customer density | Aggregation, joins | São Paulo state has 45% of customers |
| 17 | Delivery delay root cause | Multi‑level `GROUP BY` | Sellers in remote states cause 60% of delays |
| 18 | **Stored procedure** monthly report | Procedure with multiple result sets | One call gives overview, top products, category breakdown |
| 19 | **Scalar function** customer tier | UDF | Reusable tier logic for dashboards |
| 20 | **Table‑valued function** product sales | TVF | Flexible product sales summary for any period |

## ⚙️ Advanced SQL Objects

The `Functions` and `Procedures` folders contain reusable database objects that demonstrate production-ready skills:

### Stored Procedure: `sp_GetMonthlySalesReport`
- **Purpose:** Accepts year/month and returns three result sets: overall KPIs, top 10 products, and category breakdown.
- **Value:** Automates recurring reporting for business users.

### Scalar Function: `fn_GetCustomerTier`
- **Purpose:** Returns ‘Bronze’, ‘Silver’, or ‘Gold’ based on total customer spend.
- **Value:** Encapsulates business logic for consistent use across reports.

### Table‑Valued Function: `tvf_GetProductSales`
- **Purpose:** Returns product sales summary for any date range.
- **Value:** Enables dynamic, parameterized analysis without rewriting queries.

## 📈 Power BI Dashboards

The `Power BI` folder contains interactive dashboards that bring the SQL insights to life. These files connect directly to the cleaned SQL views and tables.


### Dashboard Previews

Below are previews of the main dashboard pages from the `assets` folder:

| Page | Preview |
|------|---------|
| **Overview** – KPIs, payment distribution, review scores, and monthly order trends | ![Overview](assets/Dashboard_page-1.jpg) |
| **Orders Analysis** – Geographic distribution of orders and breakdown by product category | ![Orders Analysis](assets/Dashboard_page-2.jpg) |
| **Order Details** – Detailed view of orders with delivery status and region | ![Order Details](assets/Dashboard_page-3.jpg) |
| **Product Sales Details** – Drill-down into sales for a specific product category (Watches Gifts) | ![Product Sales](assets/Dashboard_page-4.jpg) |

## 💡 Key Insights & Business Impact

| Insight | Business Recommendation |
|---------|--------------------------|
| **40% of revenue comes from top 10% of customers** | Launch a VIP loyalty program to retain high‑value customers |
| **Repeat customers spend 35% more** | Introduce post‑purchase incentives to convert one‑time buyers |
| **Furniture category has 8% cancellation rate** | Investigate product descriptions, quality, or shipping issues |
| **Delivery delay strongly correlates with lower scores** | Set delivery SLAs for sellers in remote regions |
| **Credit card dominates (74%) with average 3 installments** | Partner with card issuers for exclusive offers |
| **RFM analysis identified 1,200 “Champions”** | Target them for early access to new products |

## 🙋‍♂️ About Me

I am a data analyst passionate about turning raw data into strategic business insights. This project reflects my ability to:

- **Architect robust data models** (star schema, indexing)
- **Write advanced, optimized SQL** (window functions, CTEs, stored procedures, views)
- **Build interactive Power BI dashboards** that tell a compelling story
- **Translate technical findings into actionable business recommendations**

I am actively seeking opportunities where I can apply these skills to drive data-informed decisions.

**Let's connect!**  
[LinkedIn](https://www.linkedin.com/in/iamramraja/) | [GitHub](https://github.com/imramraja)

