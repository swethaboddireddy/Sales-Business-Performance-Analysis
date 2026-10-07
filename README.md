# Sales & Business Performance Analysis

End-to-end data analytics project: raw sales data collected and cleaned with **Excel** and **MySQL**, explored with **Python** (Jupyter Notebook), and turned into an interactive **Power BI** dashboard for business decision-making.

## Project Overview

This project analyzes **20,000 sales orders** across **32 fields** to understand sales and profit performance by product category, region, customer segment and sales channel, along with yearly and monthly trends, the effect of discounts on profit, and delivery and customer-rating patterns.

The workflow covers the full analytics cycle: collecting raw data, cleaning it, analyzing it, and presenting the results in an interactive dashboard.

## Business Questions

- Which product categories generate the most sales and profit?
- Which regions perform best, and which lag behind?
- How have sales and profit changed over time (monthly and yearly)?
- Which customer segments and sales channels contribute most to sales?
- How do discounts affect profit?
- Which products are the top performers by sales and by profit?
- How do delivery time and customer ratings look across orders?

## Dataset

| Item | Details |
|---|---|
| Records | 20,000 orders |
| Fields | 32 columns |
| Period | 2022 - 2025 |
| Source | Raw sales dataset, collected and cleaned by the author |

**Column groups**

- **Order:** `order_id`, `order_date`, `ship_date`, `ship_mode`, `order_priority`, `delivery_days`
- **Customer:** `customer_id`, `customer_name`, `segment`
- **Location:** `country`, `city`, `state`, `postal_code`, `market`, `region`
- **Product:** `product_id`, `category`, `sub_category`, `product_name`
- **Financials:** `sales`, `quantity`, `discount`, `profit`, `shipping_cost`, `expense`, `revenue`, `profit_margin`
- **Other:** `payment_method`, `return_status`, `customer_rating`, `coupon_used`, `sales_channel`

## Tools & Technologies

| Tool | Purpose |
|---|---|
| **Microsoft Excel** | Initial data cleaning and standardization |
| **MySQL** | Data cleaning, validation and querying |
| **Python** (Pandas, NumPy, Matplotlib, Seaborn) | Exploratory data analysis and visualization |
| **Jupyter Notebook** | Analysis environment |
| **Power BI** | Interactive dashboard and KPI reporting |

## Project Workflow

1. **Data Collection:** gathered the raw sales dataset (20,000 orders, 32 fields).
2. **Data Cleaning (Excel & MySQL):** handled missing values and inconsistent date formats, and standardized the data to produce an analysis-ready dataset.
3. **Exploratory Data Analysis (Python):** loaded the cleaned data in Jupyter, converted date columns to datetime, filled missing `return_status` and `coupon_used` values, and visualized sales, profit and trends.
4. **Dashboard (Power BI):** built an interactive dashboard to monitor sales, profit, and category and regional performance.
5. **Insights:** summarized findings to support business decisions.

## Exploratory Data Analysis

The notebook [`Sales_Performance_Project_Completed.ipynb`](Sales_Performance_Project_Completed.ipynb) includes:

- **Data checks:** `head`, `tail`, `info`, data types and missing-value checks
- **Data preparation:** date conversion and missing-value handling
- **Category analysis:** total sales, profit and quantity by category
- **Regional analysis:** sales and profit by region
- **Time trends:** monthly and yearly sales and profit
- **Segment & channel analysis:** sales share by customer segment and by sales channel
- **Relationships:** discount vs. profit, sales vs. profit, correlation heatmap and pairplot
- **Distributions:** customer ratings, delivery days, profit margin, sales by category (box plot) and profit by region (violin plot)
- **Top performers:** top 10 products by sales and by profit
- **Summary view:** a combined 2x2 dashboard of key charts

## Power BI Dashboard

The dashboard tracks key KPIs such as total sales, profit and profit margin, with slicers for category, region and time period.


## Repository Structure

```
├── data/
│   └── sales_business_performance_cleaned_Dataset.xlsx
├── notebooks/
│   └── Sales_Performance_Project_Completed.ipynb
├── powerbi/
│   └── Sales_Dashboard.pbix
├── images/
│   └── dashboard_overview.png
└── README.md
```

## How to Run

1. Clone the repository
   ```bash
   git clone https://github.com/<your-username>/<your-repo-name>.git
   cd <your-repo-name>
   ```
2. Install the required libraries
   ```bash
   pip install pandas numpy matplotlib seaborn openpyxl jupyter
   ```
3. Update the file path in the notebook's data-loading cell to point to the dataset in the `data/` folder
   ```python
   df = pd.read_excel("data/sales_business_performance_cleaned_Dataset.xlsx")
   ```
4. Launch Jupyter and run the notebook
   ```bash
   jupyter notebook
   ```
5. Open the `.pbix` file in **Power BI Desktop** to explore the dashboard.

## Author

**Swetha Boddireddy**
Data Analyst | Hyderabad, Telangana

