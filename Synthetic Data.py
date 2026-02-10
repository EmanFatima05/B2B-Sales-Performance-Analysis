import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime
import random

# -----------------------------
# SETUP
# -----------------------------
fake = Faker("en_US")
np.random.seed(42)
random.seed(42)

START_DATE = datetime(2022, 1, 1)
END_DATE = datetime(2025, 12, 31)

NUM_CUSTOMERS = 800
NUM_PRODUCTS = 120
NUM_ORDERS = 18000

TOP_PRODUCT_SHARE = 0.65
TOP_STORE_SHARE = 0.70

dates = pd.date_range(START_DATE, END_DATE)

# -----------------------------
# STORES (Unequal geography)
# -----------------------------
stores = [
    ("NYC Downtown", "New York", "NY", "Northeast"),
    ("Brooklyn Hub", "New York", "NY", "Northeast"),
    ("Los Angeles Central", "Los Angeles", "CA", "West"),
    ("San Jose Tech Park", "San Jose", "CA", "West"),
    ("Chicago Loop", "Chicago", "IL", "Midwest"),
    ("Houston Galleria", "Houston", "TX", "South"),
    ("Dallas Uptown", "Dallas", "TX", "South"),
    ("Austin Central", "Austin", "TX", "South"),
    ("Miami Beach", "Miami", "FL", "South"),
    ("Atlanta Midtown", "Atlanta", "GA", "South"),
    ("Seattle Downtown", "Seattle", "WA", "West"),
    ("Boston Harbor", "Boston", "MA", "Northeast"),
    ("Philadelphia Center", "Philadelphia", "PA", "Northeast"),
    ("Detroit Central", "Detroit", "MI", "Midwest"),
    ("Cleveland Market", "Cleveland", "OH", "Midwest"),
    ("Newark Plaza", "Newark", "NJ", "Northeast"),
    ("St. Louis Downtown", "St. Louis", "MO", "Midwest"),
    ("Kansas City Plaza", "Kansas City", "MO", "Midwest"),
    ("Phoenix Metro", "Phoenix", "AZ", "West"),
    ("Denver Central", "Denver", "CO", "Midwest"),
    ("Portland Pearl", "Portland", "OR", "West"),
    ("San Diego Plaza", "San Diego", "CA", "West"),
    ("Las Vegas Strip", "Las Vegas", "NV", "West"),
    ("Orlando Outlet", "Orlando", "FL", "South"),
    ("Minneapolis Hub", "Minneapolis", "MN", "Midwest")
]

stores_df = pd.DataFrame(stores, columns=["Store_Name", "City", "State", "Region"])
stores_df["Store_ID"] = ["S" + str(i).zfill(3) for i in range(1, len(stores_df)+1)]
stores_df["Store_Status"] = np.where(
    stores_df["City"].isin(["Detroit", "Cleveland", "Newark"]),
    "Inactive",
    "Active"
)
stores_df["Open_Date"] = pd.to_datetime(
    np.random.choice(pd.date_range("2010-01-01", "2020-01-01"), len(stores_df))
)

# Dominant cities
top_stores = stores_df.loc[
    stores_df["City"].isin(["New York", "Los Angeles", "San Jose", "Chicago", "Houston"]),
    "Store_ID"
].tolist()

# -----------------------------
# PRODUCTS (Strong Pareto)
# -----------------------------
base_products = [
    "Apple iPhone 14", "Apple iPhone 13", "Samsung Galaxy S23",
    "MacBook Pro 14", "MacBook Air M2", "Dell XPS 13",
    "HP Spectre x360", "Lenovo ThinkPad X1",
    "Sony WH-1000XM5", "Bose QC45",
    "PlayStation 5", "Xbox Series X",
    "Nintendo Switch", "Apple Watch Series 9",
    "Samsung Galaxy Watch 6"
]

while len(base_products) < NUM_PRODUCTS:
    base_products.append(fake.catch_phrase())

products_df = pd.DataFrame({
    "Product_ID": ["P" + str(i).zfill(4) for i in range(1, NUM_PRODUCTS + 1)],
    "Product_Name": base_products[:NUM_PRODUCTS],
    "Category": np.random.choice(
        ["Electronics", "electronics", "Elec", "Accessories"],
        NUM_PRODUCTS,
        p=[0.5, 0.2, 0.15, 0.15]
    ),
    "Standard_Cost": np.random.uniform(80, 1200, NUM_PRODUCTS),
    "List_Price": np.random.uniform(100, 1800, NUM_PRODUCTS),
    "Product_Status": np.random.choice(["Active", "Discontinued"], NUM_PRODUCTS, p=[0.85, 0.15])
})

# Cost inflation → loss makers
products_df.loc[products_df.sample(20).index, "Standard_Cost"] *= 1.5

top_products = products_df.sort_values(
    "List_Price", ascending=False
).head(int(NUM_PRODUCTS * 0.15))["Product_ID"].tolist()

# -----------------------------
# CUSTOMERS (Dirty CRM)
# -----------------------------
customers_df = pd.DataFrame({
    "Customer_ID": ["C" + str(i).zfill(5) for i in range(1, NUM_CUSTOMERS + 1)],
    "Full_Name": [fake.name() for _ in range(NUM_CUSTOMERS)],
    "Segment": np.random.choice(["Retail", "Corporate", "Wholesale"], NUM_CUSTOMERS, p=[0.65, 0.25, 0.10]),
    "City": [fake.city() for _ in range(NUM_CUSTOMERS)],
    "State": [fake.state_abbr() for _ in range(NUM_CUSTOMERS)],
    "Country": "USA",
    "Status": np.random.choice(["Active", "Inactive"], NUM_CUSTOMERS, p=[0.9, 0.1])
})

# Duplicate customers
dup = customers_df.sample(25)
dup["Customer_ID"] = dup["Customer_ID"] 
customers_df = pd.concat([customers_df, dup], ignore_index=True)

# -----------------------------
# SALES / TRANSACTIONS
# -----------------------------
sales = []

for i in range(NUM_ORDERS):
    order_date = random.choice(dates)

    # Growth then decline
    if order_date.year <= 2023:
        base_qty = np.random.poisson(4)
    else:
        base_qty = np.random.poisson(1)

    # Product skew
    if random.random() < TOP_PRODUCT_SHARE:
        product_id = random.choice(top_products)
        qty = max(1, base_qty + np.random.randint(1, 4))
    else:
        product_id = random.choice(products_df["Product_ID"])
        qty = max(1, base_qty - np.random.randint(0, 2))

    # Store skew
    if random.random() < TOP_STORE_SHARE:
        store_id = random.choice(top_stores)
    else:
        store_id = random.choice(stores_df["Store_ID"])

    unit_price = products_df.loc[
        products_df["Product_ID"] == product_id, "List_Price"
    ].values[0]

    cost = products_df.loc[
        products_df["Product_ID"] == product_id, "Standard_Cost"
    ].values[0]

    # Discount abuse on weak products
    if product_id not in top_products:
        discount = random.choice([0.2, 0.3, 0.4, None])
    else:
        discount = random.choice([0, 0.1, None])

    revenue = qty * unit_price * (1 - discount if discount else 1)
    profit = revenue - (qty * cost)

    # Heavy losses on weak stores/products
    if store_id not in top_stores or product_id not in top_products:
        if random.random() < 0.35:
            profit *= -1

    sales.append([
        f"O{i+1:06}",
        order_date,
        random.choice(customers_df["Customer_ID"]),
        product_id,
        store_id,
        qty,
        unit_price,
        discount,
        revenue,
        cost,
        profit,
        random.choice(["Completed", "Completed", "Cancelled", "Returned"])
    ])

sales_df = pd.DataFrame(sales, columns=[
    "Order_ID", "Order_Date", "Customer_ID", "Product_ID", "Store_ID",
    "Quantity", "Unit_Price", "Discount", "Revenue", "Cost", "Profit", "Order_Status"
])

# -----------------------------
# INTENTIONAL DIRT
# -----------------------------
sales_df.loc[sales_df.sample(60).index, "Customer_ID"] = None
sales_df.loc[sales_df.sample(50).index, "Order_Date"] = pd.NaT
sales_df = pd.concat([sales_df, sales_df.sample(150)], ignore_index=True)

inactive_ids = stores_df.loc[stores_df["Store_Status"] == "Inactive", "Store_ID"]
sales_df.loc[sales_df["Store_ID"].isin(inactive_ids), "Profit"] *= 0.6

# -----------------------------
# EXPORT
# -----------------------------
sales_df.to_csv("data/sales_transactions.csv", index=False)
customers_df.to_csv("data/customers.csv", index=False)
products_df.to_csv("data/products.csv", index=False)
stores_df.to_csv("data/stores.csv", index=False)

print("✅ Executive-grade, dirty, UNEQUAL business data generated.")
