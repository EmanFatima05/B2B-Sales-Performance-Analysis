# B2B Sales Analytics Project 

##  Project Overview

This project is an end‑to‑end **data analytics case study** focused on understanding **sales performance, discount behavior, and business stability** using a modern analytics stack.

The workflow follows a real‑world analytics pipeline:
**Data generation → Data cleaning → Exploratory analysis → Business intelligence reporting**.

The final outcome is an **interactive Power BI report** designed for business stakeholders.

---

##  Data Collection

### 🔹 Synthetic Data Generation (Python)

* A **Python script** was used to generate a **dirty transactional dataset**.
* The dataset simulates a real e‑commerce environment with:

  * **800,000+ rows** of sales transactions
  * Intentional data quality issues such as:

    * Missing values
    * Inconsistent formats
    * Duplicate records
    * Noisy categorical fields

### 🔹 Core Tables Created

* **Sales** (transaction‑level data)
* **Customers**
* **Products**
* **Stores**

The data was generated to closely resemble **production‑scale business data**.

---

##  Data Cleaning & Preprocessing

### 🔹 Tools Used

* **Python (Jupyter Notebook – .ipynb)**
* Libraries:

  * pandas
  * numpy

### 🔹 Cleaning Activities Performed

* Handling missing and null values
* Removing duplicate records
* Standardizing column formats
* Validating numerical ranges (price, quantity, discount)
* Ensuring referential integrity between tables
* Creating derived fields required for analysis

 The complete data cleaning logic is documented in the **attached Jupyter Notebook (.ipynb)**.

---

##  Exploratory Data Analysis (EDA)

### 🔹 Tool Used

* **SQL (SQL Server)**

### 🔹 EDA Objectives

* Understand sales distribution and trends
* Identify high‑discount and low‑margin areas
* Validate data consistency post‑cleaning
* Analyze customer, product, and regional behavior

### 🔹 Key SQL Analyses

* Revenue and profit trends
* Discount contribution analysis
* Category and region‑level aggregation
* Outlier detection in sales and discounts

EDA results were used to **shape KPIs and visuals** in the Power BI report.

---

##  Power BI Reporting

### 🔹 Data Model

* **Star Schema** with Sales as the fact table
* Dimension tables:

  * Customers
  * Products
  * Stores
  * Calendar (marked as Date Table)
    
<img width="1257" height="745" alt="image" src="https://github.com/user-attachments/assets/991f7ee2-2414-4944-b5d3-a24e3128465c" />

### 🔹 Report Pages

* Overview
* Discount Analysis
* Product Performance
* Regional Insights

### 🔹 Features Implemented

* DAX‑based KPIs
* Time‑series analysis
* Discount impact evaluation
* Interactive slicers and drill‑downs

The report enables **data‑driven decision making**for management.

<img width="1322" height="745" alt="image" src="https://github.com/user-attachments/assets/dfa32e1a-49bc-4704-ac36-94317c9486a3" />

---

<img width="1327" height="743" alt="image" src="https://github.com/user-attachments/assets/5bd44b04-84c2-41db-a4e3-b21b8983e905" />

---

<img width="1325" height="740" alt="image" src="https://github.com/user-attachments/assets/50951764-d60d-4214-a746-a24b515f770b" />

---

<img width="1323" height="737" alt="image" src="https://github.com/user-attachments/assets/570f35c9-b372-4625-83b7-76f0a484e536" />

---

<img width="1320" height="742" alt="image" src="https://github.com/user-attachments/assets/2c658a1d-f4f5-4097-a721-0b5951386f8c" />

---

##  Business Questions Addressed

1. **Are discounts effectively increasing sales volume, or are they eroding profit?**
2. **Which products contribute most to discount leakage (80/20 analysis)?**
3. **How does discount behavior vary across regions and customer segments?**
4. **Is the business maintaining healthy margins after applying discounts?**

Each question is answered through a combination of **KPIs, trend analysis, and visual storytelling**.

---

##  Recommendations

###  Business Status

Based on the analysis:

* Revenue and profit trends show **consistent growth**
* Discounting is controlled and mostly effective
* No major structural risks were identified

###  Strategic Recommendation

**The business is stable and well‑positioned for expansion.**

Suggested next steps:

* Gradual expansion into new regions
* Optimizing discounts for high‑impact products
* Strengthening pricing strategies for low‑margin categories
* Leveraging data‑driven promotions instead of blanket discounting

---

##  Conclusion

This project demonstrates a **full analytics lifecycle**, from raw data creation to executive‑ready insights, showcasing strong skills in:

* Python data processing
* SQL analytics
* Power BI modeling and visualization
* Business storytelling

---

 **Artifacts Included**

* Python data generation script
* Data cleaning Jupyter Notebook (.ipynb)
* SQL EDA scripts
* Power BI (.pbix) report

---

✨ *This project is suitable for portfolio, interviews, and real‑world analytics demonstrations.*

