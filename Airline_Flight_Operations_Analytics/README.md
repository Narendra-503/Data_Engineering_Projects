# ✈️ Airline Flight Operations Analytics

An end-to-end Data Engineering project built using **Databricks, Lakeflow Spark Declarative Pipelines, SQL, Delta Lake, and Power BI**. This project transforms raw airline flight data into clean, structured, business-ready datasets using Medallion Architecture and provides interactive dashboards for analyzing airline performance, flight operations, routes, delays, and data quality.


## 📌 1. Project Overview

This project implements a complete data engineering workflow using the Medallion Architecture (Bronze → Silver → Gold).

The pipeline ingests raw airline flight data, performs data cleaning and validation, creates analytical Gold tables, and connects the processed data to Power BI for business intelligence and visualization.

### 🎯 Project Objectives

- Build an end-to-end data engineering pipeline.
- Ingest raw CSV data into Databricks.
- Implement Bronze, Silver, and Gold layers.
- Perform data cleaning and duplicate removal.
- Handle missing values and invalid records.
- Implement data quality checks and reconciliation.
- Generate business-ready analytical tables using SQL.
- Develop interactive Power BI dashboards.
- Maintain project documentation and version control using GitHub.

---

## 🛠️ 2. Technology Stack

| Technology                           | Purpose                           |
| ------------------------------------ | --------------------------------- |
| Databricks Free Edition              | Data engineering platform         |
| Lakeflow Spark Declarative Pipelines | Data pipeline development         |
| Apache Spark                         | Distributed data processing       |
| SQL                                  | Data transformation and analysis  |
| Delta Lake                           | Reliable data storage             |
| Unity Catalog                        | Data and volume management        |
| Auto Loader / read_files             | Data ingestion                    |
| Power BI Desktop                     | Interactive dashboards            |
| Git & GitHub                         | Version control and documentation |

---

## 📂 3. Project Structure

```text
Airline_Flight_Operations_Analytics/
│
├── Assests/
│   ├── Dashboard/
│   │   ├── Airline-wise performance.png
│   │   ├── data quality.png
│   │   └── routes,delays.png
│   │
│   ├── Pipeline_Graph/
│   │   └── Pipeline.png
│   │
│   └── architecture/
│       ├── End-to-End Data Flow Infographic.png
│       └── Silver Layer_ Four Cleaning.png
│
├── Data/
│   └── airline_flights_raw.csv
│
├── Docs/
│   └── Airline_Flight_Operations_Data_Engineering_Project.pdf
│
├── ETL_Pipeline/
│   ├── Bronze_Transformation.sql
│   ├── Silver_Transformation.sql
│   └── Gold_Transformation.sql
│
└── README.md
```

---

## 🏗️ 4. Project Architecture

The project follows the Medallion Architecture, which organizes data into three layers.

| Layer  | Description                                                     |
| ------ | --------------------------------------------------------------- |
| Bronze | Ingests raw CSV records into a streaming table                  |
| Silver | Cleans, standardizes, validates, and separates rejected records |
| Gold   | Creates business-level analytical summary tables                |

### End-to-End Data Flow

<img width="1672" height="941" alt="End-to-End Data Flow Infographic" src="https://github.com/user-attachments/assets/5768b8e9-22d7-4cda-8a04-d7d7e06a33c5" />


### Silver Layer Data Cleaning

<img width="1672" height="941" alt="Silver Layer_ Four Cleaning" src="https://github.com/user-attachments/assets/3529eded-891c-4d14-bec4-6ce9de2dee58" />



---

## 🔄 5. ETL Pipeline Implementation
<img width="1053" height="628" alt="pipeline" src="https://github.com/user-attachments/assets/dfa6d9c2-6e12-4597-a099-0a63ed9f035c" />

### Bronze Layer – Data Ingestion

- Ingests raw CSV files from Unity Catalog Volumes.
- Uses Databricks `read_files()` with streaming ingestion.
- Captures source filename and ingestion timestamp.
- Stores raw records in `bronze_airline_flights`.

### Silver Layer – Data Cleaning

The Silver layer performs the following transformations:

1. Duplicate removal using `SELECT DISTINCT`.
2. Text standardization using `TRIM()` and `INITCAP()`.
3. Missing value handling using `COALESCE()`.
4. Delay calculation using `TIMESTAMPDIFF()`.
5. Ticket revenue calculation for missing values.
6. Delay categorization into On Time, Minor Delay, and Major Delay.
7. Data validation using expectations and rejection rules.

**Silver tables:**

- `silver_flights_clean`
- `silver_flights_rejected`

### Gold Layer – Business Transformations

The Gold layer creates five analytical tables:

| Gold Table                 | Purpose                                 |
| -------------------------- | --------------------------------------- |
| `gold_monthly_flights`     | Monthly flight and passenger trends     |
| `gold_airline_performance` | Airline-wise operational performance    |
| `gold_route_summary`       | Route-wise flight and revenue analysis  |
| `gold_delay_summary`       | Flight delay category analysis          |
| `gold_data_quality`        | Data quality metrics and reconciliation |

---

## 📊 6. Data Quality and Reconciliation

Data quality checks ensure that the processed records are reliable and consistent.

### Reconciliation Results

| Metric               | Records |
| -------------------- | ------: |
| Total Bronze Records |   1,365 |
| Unique Flight IDs    |   1,340 |
| Duplicate Records    |      25 |
| Clean Silver Records |   1,321 |
| Rejected Records     |      19 |
| Unaccounted Records  |       0 |

**Reconciliation Formula:**

`Bronze Records = Clean Records + Rejected Records + Duplicates Removed`

`1,365 = 1,321 + 19 + 25`

\<details> \<summary>Additional data quality checks\</summary>

- Missing airline values
- Missing delay minutes
- Missing delay reasons
- Missing ticket revenue
- Overbooked flight records
- Invalid passenger counts
- Negative average fare

\</details>

---

## 📈 7. Power BI Dashboards

The project includes three interactive dashboard pages developed using Power BI Desktop.

### Dashboard 1 – Airline-wise Flight Performance
<img width="1522" height="777" alt="Airline-wise performance" src="https://github.com/user-attachments/assets/110c1c29-a6c0-433a-b798-960ad06a6779" />



**Key KPIs:**

- Total Flights
- Total Passengers
- Total Revenue
- Delayed Flights
- Average Load Factor

**Visualizations:**

- Monthly Delayed Flights
- Monthly Flight Trends
- Total Flights by Airline

### Dashboard 2 – Airline Data Quality Analysis
<img width="1521" height="775" alt="data quality" src="https://github.com/user-attachments/assets/71ffb356-f373-49b7-ad71-9005aca1fa29" />



**Key KPIs:**

- Duplicate Records
- Rejected Records
- Total Bronze Records
- Clean Records
- Reconciliation Status

**Visualizations:**

- Records by Quality Category
- Missing Data Breakdown
- Missing Data Analysis

### Dashboard 3 – Airlines, Routes & Delays Analysis

<img width="1523" height="777" alt="routes,delays" src="https://github.com/user-attachments/assets/fb219755-ccd3-4289-a23f-74bca2627e84" />


**Key KPIs:**

- Average Delay
- Total Delayed Flights
- Total Airlines

**Visualizations:**

- Airline Performance Analysis
- Flight Distribution by Delay Category
- Top 10 Routes by Revenue
- Delay Category Distribution

---

## 💡 8. Key Project Outcomes

- Successfully ingested 1,365 raw flight records.
- Identified and removed 25 duplicate records.
- Processed 1,321 clean records.
- Identified 19 rejected records.
- Achieved zero unaccounted records in reconciliation.
- Created five Gold analytical tables.
- Developed three Power BI dashboard pages.

---

## 📁 9. Project Documentation

The complete project documentation is available in the `Docs` folder.

It includes:

- Project introduction and objectives
- Architecture and workflow
- Data ingestion and transformation
- Data quality implementation
- SQL transformations
- Dashboard explanation
- Project outcomes

---

## 🚀 10. Learning Outcomes

Through this project, I gained practical experience in:

- Building end-to-end data engineering pipelines.
- Working with Databricks and Apache Spark.
- Implementing Medallion Architecture.
- Developing SQL transformations.
- Handling missing values, duplicates, and invalid records.
- Implementing data quality and reconciliation checks.
- Creating business intelligence dashboards using Power BI.
- Managing project files using Git and GitHub.

---

## 👨‍💻Author

Narendra Reddy

GitHub: @Narendra-503

Project Repository:

Airline Flight Operations Analytics

⭐ If you find this project useful, consider giving the repository a star!

Thank you for exploring my Airline Flight Operations Analytics project!

