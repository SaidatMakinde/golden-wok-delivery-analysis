# Golden Wok Delivery Operations Analysis

## Overview

I analysed **5,000 delivery orders** using **SQL Server and Power BI** to understand delivery delays, traffic, weather, profit, and customer ratings. I ran 12 SQL queries and checked the results against a four-page Power BI dashboard.

## Business Problem

Golden Wok needs to understand which deliveries arrive late, whether longer journeys remain profitable, and how delivery conditions relate to customer experience.

## Objectives

- Compare delivery performance across kitchens, zones, weather, and rush hour.
- Examine delivery costs, profit per order, and customer ratings.
- Identify data issues and recommend practical next steps.

## Dataset

**Source:** ONYX Data Challenge — September 2026, Golden Wok Food Delivery.  
**Period:** January 2023–December 2024.  
**Currency:** Nigerian naira (NGN / ₦).

The five CSV files are included in this repository. Each order record represents one delivery.

| File | Records |
|---|---:|
| [fact_orders.csv](fact_orders.csv) | 5,000 |
| [dim_kitchen.csv](dim_kitchen.csv) | 4 |
| [dim_delivery_zone.csv](dim_delivery_zone.csv) | 20 |
| [dim_rider.csv](dim_rider.csv) | 60 |
| [dim_time_slot.csv](dim_time_slot.csv) | 48 |

## Tools & Technologies

**SQL Server, SSMS, Power Query, Power BI, and DAX.**

## Data Preparation

- Checked data types, missing values, and duplicate IDs.
- Connected orders to the four supporting tables using matching IDs.
- Created distance bands and flagged unusual temperatures and zero delivery times.
- Kept the original records and checked SQL results against Power BI.

## Analysis

The [SQL file](golden_wok_analysis.sql) contains 12 questions covering delivery rates, kitchens, zones, rush hour, traffic, weather, distance, route profitability, and customer ratings. I used joins, aggregate functions, `CASE`, CTEs, and `RANK()`.

**View the dashboard pages:**

- [Overview](Overview.PNG)
- [Delivery & Traffic](delivery_traffic.PNG)
- [Profit & Customer Experience](profit_customer_experience.PNG)
- [Data Checks & Recommendations](data_checks.PNG)

[Download the Power BI report](Golden_Wok_Analysis.pbix)

## Key Findings

| Measure | Result |
|---|---:|
| Total orders | 5,000 |
| On-time delivery rate | 50.06% |
| Late-delivery rate | 49.94% |
| Total recorded profit | ₦2,488,509.04 |
| Recorded profit per order | ₦497.70 |
| Average recorded delivery time | 500.05 minutes |
| Average customer rating | 3.00 / 5 |

- **Kitchen performance:** Lekki Phase 1 had the highest late-delivery rate at **51.27%**; Yaba Central had the lowest at **48.15%**.
- **Rush hour:** The late rate was **49.53%** during rush hour and **50.49%** outside rush hour. Rush-hour orders were not more frequently late in this data.
- **Weather:** Heavy Rain had the longest average delivery time, while Light Rain had the highest late rate at **52.86%**.
- **Distance and profit:** All **3,871 orders over 8 km** showed positive recorded profit, averaging **₦498.45 per order**. Profit did not consistently decrease with distance.
- **Customer experience:** On-time orders averaged **3.025/5**, compared with **2.983/5** for late orders—a small difference.
- **Food temperature:** **4,516 readings (90.32%)** exceeded 100°C and needed checking, preventing a reliable conclusion about cold food.

## Business Recommendations

- Check temperature readings, delivery times, kitchen details, and rush-hour labels before making operational changes.
- Confirm which costs are included in recorded profit before changing prices or delivery coverage.
- Once the data is checked, investigate routes with high late rates and monitor delivery performance after testing improvements.

## Limitations

- Delivery times range from **0 to 1,000 minutes**, and most temperature readings are unrealistic.
- Some kitchen and time details do not agree. The profit calculation is not fully explained.
- The comparisons show patterns, not proof of what caused delays or lower ratings. The findings do not justify stopping long-distance deliveries on their own.

## Project Structure

Keep these files together at the repository's main level so the links work:

```text
golden-wok-delivery-analysis/
    README.md
    golden_wok_analysis.sql
    Golden_Wok_Analysis.pbix
    Overview.PNG
    delivery_traffic.PNG
    profit_customer_experience.PNG
    data_checks.PNG
    fact_orders.csv
    dim_kitchen.csv
    dim_delivery_zone.csv
    dim_rider.csv
    dim_time_slot.csv
```

## How to Reproduce the Analysis

1. Download the project files and create a `GoldenWok` database in SQL Server.
2. Import the five CSVs using **Tasks → Import Flat File**, keeping their table names. Keep IDs as text and measures as numeric fields. Question 5 uses rush hour as **1 = Yes, 0 = No**.
3. Open `golden_wok_analysis.sql`, select the database, and run each complete query. All 12 queries were run and checked during this project.
4. Open `Golden_Wok_Analysis.pbix` in Power BI Desktop. Update the CSV source paths if refreshing, and clear filters to compare overall results with SQL.

## Key Skills Demonstrated

SQL joins, CTEs, conditional calculations, ranking, Power Query, data modelling, DAX, dashboard design, data validation, and communicating findings.

**Author:** Saidat Omotayo Makinde
