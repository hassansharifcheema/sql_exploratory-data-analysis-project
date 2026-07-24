# SQL Data Analytics Project — Customer & Sales Insights

A T-SQL (SQL Server) analytics project built on a "gold layer" retail data warehouse (`gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`). The project moves from exploratory data analysis through to two production-style reporting views, applying advanced analytical SQL techniques (window functions, CTEs, segmentation logic) to answer core business questions around customer behavior, product performance, and sales trends.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Data Model](#data-model)
- [Repository Structure](#repository-structure)
- [Analytical Modules](#analytical-modules)
- [Key Business Questions Answered](#key-business-questions-answered)
- [Deliverables (Reporting Views)](#deliverables-reporting-views)
- [Technologies Used](#technologies-used)
- [How to Use This Repository](#how-to-use-this-repository)
- [Skills Demonstrated](#skills-demonstrated)
- [Known Limitations & Suggested Improvements](#known-limitations--suggested-improvements)
- [Author](#author)

---

## Project Overview

**Objective:** Transform granular sales transaction data into decision-ready insights on customer value, product performance, and sales trends, culminating in two reusable SQL views suitable for BI tool consumption (e.g., Power BI, Tableau).

**Approach:** The project follows a standard analytics-engineering progression:

1. Explore the schema and dimensions (EDA)
2. Quantify business scale (magnitude analysis)
3. Identify top/bottom performers (ranking analysis)
4. Evaluate performance against historical and average benchmarks (performance analysis)
5. Assess each category's contribution to total sales (part-to-whole analysis)
6. Segment customers and products into behavioral/value tiers (segmentation)
7. Consolidate findings into two final reporting views: `gold.customer_report` (and, if added, a corresponding product report)

---

## Data Model

The project assumes a **star schema** ("gold layer") with the following tables:

| Table | Type | Description |
|---|---|---|
| `gold.fact_sales` | Fact | Transaction-level sales records (order number, order date, product key, customer key, sales amount, quantity, price) |
| `gold.dim_customers` | Dimension | Customer attributes (customer key, customer number, first/last name, birthdate, gender, country) |
| `gold.dim_products` | Dimension | Product attributes (product key, product name, category, subcategory, cost) |

> **Note:** This README documents the schema as referenced in the SQL scripts. If a database setup script (DDL) or sample dataset is included in the repository, link it here so the project is fully reproducible by anyone who clones it.

---

## Repository Structure

```
sql-data-analytics-project/
│
├── scripts/
│   ├── exploratory_data_analysis.sql       # Database, dimension, date, and measure exploration
│   ├── performance_analysis.sql            # Year-over-year and average-benchmark performance analysis
│   ├── part_to_whole_analysis.sql          # Category contribution to total sales
│   ├── customer_segmentation.sql           # Product cost segmentation & customer value segmentation
│   └── customer_report.sql                 # Final consolidated customer-level reporting view
│
├── README.md
└── LICENSE
```

> Adjust the folder names above to match your actual repository layout before publishing — see [Known Limitations](#known-limitations--suggested-improvements).

---

## Analytical Modules

### 1. Exploratory Data Analysis (`exploratory_data_analysis.sql`)
Establishes baseline familiarity with the dataset:
- Table and column inventory via `INFORMATION_SCHEMA`
- Dimension exploration (distinct countries, product categories/subcategories)
- Date range exploration (order date range, customer age range)
- Core measures (total sales, items sold, average price, order count)
- A unified business metrics summary using `UNION ALL`
- **Magnitude analysis** — customers by country/gender, products by category, revenue by category and by customer, sales quantity by country
- **Ranking analysis** — top 5 and bottom 5 products by revenue (via `TOP` and `ROW_NUMBER()`), top 10 customers by revenue

### 2. Performance Analysis (`performance_analysis.sql`)
Evaluates yearly product sales against two benchmarks using window functions:
- **Average benchmark:** compares each year's sales to the product's all-time average (`AVG() OVER (PARTITION BY product_name)`), flagging results as *Above Average* / *Below Average*
- **Year-over-year benchmark:** uses `LAG()` to compare each year's sales to the prior year, flagging *Increase* / *Decrease* / *No Change*

### 3. Part-to-Whole Analysis (`part_to_whole_analysis.sql`)
Quantifies each product category's contribution to total revenue using `SUM() OVER()` as a window aggregate, expressed as a percentage of overall sales.

### 4. Segmentation (`customer_segmentation.sql`)
Two independent segmentation exercises:
- **Product segmentation:** buckets products into cost ranges (`Below 100`, `100–500`, `500–1000`, `Above 1000`) and counts products per range
- **Customer segmentation:** classifies customers into `VIP`, `Regular`, or `New` based on lifespan (months between first and last order) and total spend

### 5. Customer Report View (`customer_report.sql`)
Consolidates all customer-level logic into a single reusable view, `gold.customer_report`, combining:
- Demographics (name, age, age group)
- Behavioral segment (VIP / Regular / New)
- Core metrics (total orders, total sales, total quantity, total products, lifespan)
- KPIs (recency in months, average order value, average monthly spend)

---

## Key Business Questions Answered

- What is the overall scale of the business (total sales, orders, customers, products)?
- Which countries and customer segments generate the most revenue and volume?
- Which products and customers are the top and bottom revenue contributors?
- Is a given product's yearly performance above or below its historical average, and is it trending up or down year-over-year?
- Which product category contributes the largest share of total revenue?
- How should customers and products be segmented for targeted business action (e.g., retention campaigns, pricing strategy)?
- What is each customer's lifetime value, order frequency, and recency?

---

## Deliverables (Reporting Views)

| View | Grain | Primary Use Case |
|---|---|---|
| `gold.customer_report` | One row per customer | Customer segmentation, CRM/retention analysis, lifetime value tracking |

---

## Technologies Used

- **SQL Server (T-SQL)** — all scripts use SQL Server syntax (`GETDATE()`, `DATEDIFF()`, `TOP N`, bracketed identifiers)
- **Core techniques:** Common Table Expressions (CTEs), window functions (`ROW_NUMBER()`, `LAG()`, `SUM() OVER()`, `AVG() OVER()`), `CASE WHEN` segmentation logic, aggregate functions, view creation

---

## How to Use This Repository

1. Ensure you have access to a SQL Server instance (or Azure SQL Database) with a `gold` schema containing `dim_customers`, `dim_products`, and `fact_sales`.
2. Run `exploratory_data_analysis.sql` first to validate the schema and get familiar with the data.
3. Run the analysis scripts in the order listed under [Analytical Modules](#analytical-modules) to reproduce each stage of the analysis.
4. Execute `customer_report.sql` to create the `gold.customer_report` view.
5. Connect a BI tool (Power BI, Tableau, Metabase) directly to the view for dashboarding, or query it directly for ad hoc analysis.

---

## Skills Demonstrated

- Data exploration and schema discovery on an unfamiliar database
- Multi-table joins across a star schema
- Window function analytics (ranking, running/partitioned aggregates, period-over-period comparison)
- Business segmentation logic translated into SQL (`CASE WHEN`)
- KPI design (recency, average order value, average monthly spend)
- View design for downstream BI consumption

---

## Known Limitations & Suggested Improvements

In the interest of maintaining industry-standard quality, the following should be addressed before treating this as a portfolio-ready public repository:

| Issue | Location | Recommendation |
|---|---|---|
| Typo in age-group label (`'inder 20'`) | `customer_report.sql` | Correct to `'Under 20'` |
| Inconsistent casing/spacing in filenames (spaces, mixed case) | Repo root | Standardize to `lower_snake_case.sql` for all files (already done for most; align the remaining two) |
| Alias typo `avg_ordeer_value` | `customer_report.sql` | Correct to `avg_order_value` |
| No DDL/setup script or sample dataset included | Repository | Add a `datasets/` folder with a schema-creation script (or a link to the source dataset) so the project is independently reproducible |
| No inline data dictionary for view output columns | `customer_report.sql` | Add a header comment block documenting each output column, consistent with the file's own top-of-file documentation style |
| Missing product-level equivalent to `customer_report` | Repository | Consider adding a `gold.product_report` view (revenue segment, sales trend, recency) to mirror the customer report and round out the portfolio |
| No version control artifacts (`.gitignore`, `LICENSE`) confirmed | Repository | Add both before publishing publicly |

Addressing these before publishing will materially strengthen the repository's credibility to a technical reviewer or hiring manager evaluating it as portfolio evidence.

---

## Author

**Hassan** — BBA Finance student, University of Gujrat. Building a finance-domain SQL portfolio as part of a broader path toward freelance data analysis and FinTech/AI-in-Finance roles.

- LinkedIn: *[add link]*
- Portfolio: *[add link]*
- Email: *[add contact]*
