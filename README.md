# Data-Analytics-Power-BI-Report

# Table of Contents
<a name="Milestone-3"></a>
<a name="Milestone-4"></a>
<a name="Milestone-5"></a>
<a name="Milestone-6"></a>
<a name="Milestone-7"></a>
<a name="Milestone-8"></a>
<a name="Milestone-9"></a>
<a name="Milestone-10"></a>

1. [Milestone 1: Importing and Preparing Orders Table](#Milestone-1) 
2. [Milestone 2: Create the Data Model](#Milestone-2)
3. [Milestone 3: Set up the Report](#Milestone-3)
4. [Milestone 4: Build the Customer Detail Page](#Milestone-4)
5. [Milestone 5: Create an Executive Summary Page](#Milestone-5)
6. [Milestone 6: Create a Product Detail Page](#Milestone-6)
7. [Milestone 7: Create a sttores Map Page](#Milestone-7)
8. [Milestone 8: Cross Filtering and Navigation](#Milestone-8)
9. [Milestone 9: Create Metrics for Users outside the comany using SQL](#Milestone-9)
---
**Note:** As I am a Mac user, I first had to create a Windows VM for this project. These are the steps I followed in order to do this:
1. Access Azure
2. Create a Windows Virtual Machine with the size D2s_v3. This VM costs ~$85/month but the Azure free trial offers a free $200 credit to spend on any Azure service. So as long as I finished the project within the propose timeline, I would not incur any additional charges.
3. Connect my VM to my local machine. I did this by Utilising Microsoft Remote Desktop.

--- 
# <a name="Milestone-1"></a> Milestone 1: Data Import and Transformation 


Below are three different dataframes that I needed to import and transform as part of my project. Each section reveals the steps I took to do this.

## Orders Table
1. **Connect to Azure SQL Database:**
   - Utilising the provided Azure SQL Database credentials, I connected to the database and imported the `orders_powerbi` table into Power BI using the Import option.

2. **Data Privacy and Integrity:**
   - In Power Query Editor,I deleted the `Card Number` column to ensure data privacy.
   - I then split the `Order Date` and `Shipping Date` columns into date and time components.
   - Next, I filtered out rows with missing or null values in the `Order Date` column to maintain data integrity.
   - Lastly, I renamed columns according to Power BI conventions for clarity and consistency.

## Products Table
3. **Import Products.csv:**
   - I downloaded the `Products.csv` file and imported it into Power BI using the Get Data option.
   - I then used 'Remove Duplicates' on the `product_code` column to ensure uniqueness.

4. **Clean and Transform Weight Column:**
   - Using 'Columns from Example' in the Power Query Editor, I separated the `Weight` column to create a new column called `WeightValue` with just the weight value.
   - Using the same method, I then separated the Weight Units from the `Weight` column, and put it into a new column called `WeightUnit`.
   - Any blank entries in the `WeightUnit` column, I replaced  with "kg"
   - I then converted the `WeightValue` column to decimal; replace any errors with 1.
   - I then created a column called `WeightMultiplier` that contained split values from the `Weight` column that had expressions such as `2x200g`. This would allow me to correctly transform `Weight` values that had mathematical expressions. Any values in the new `WeightMultiplier` that were blank or null were replaced with 1, as they were already complete and did not need multiplication.
   - I then Created a new column called 'NewWeight' which contained the values of `WeightValue` multiplied by the `WeightMultiplier` column. This ensured that all mathematical expressions were correctly converted to the right value. I used the following DAX to create this column:
        - `[NewWeight = 'Products'[WeightMultiplier] * 'Products'[WeightValue]]`
   - I then needed to standardise the weight values, so I converted all Weight Values into Kilograms by creating a new calculated column called 'KG_Weight', which used the following DAX to convert all non-Kg values into Kg values:
        - `[KG_Weight = IF('Products'[WeightUnit] <> "kg", 'Products'[NewWeight] / 1000, 'Products'[NewWeight])]`

5. **Data Cleanup:**
   - Lastly, I renamed all columns according to Power BI conventions for consistency and clarity.

## Stores Table
6. **Connect to Azure Blob Storage:**
   - Using Power BI's Get Data option, I connected to Azure Blob Storage and imported the `Stores` table by utilising the provided Blob Storage credentials.

7. **Column Renaming:**
   - I renamed the columns in the dataset to align with Power BI conventions, ensuring clarity in the report.

## Customers Table
8. **Import Customers Folder:**
   - I downloaded and unziped the `Customers.zip` file.
   - Using the Get Data option, I imported the Customers folder into Power BI, combining and transforming the data.

9. **Data Manipulation:**
   - Createx a `FullName` column by combining `[First Name]` and `[Last Name]`.
   - Deleted unnecessary columns and renamed the remaining ones according to Power BI conventions.

## Summary
This milestone involved connecting to various data sources, importing tables into Power BI, and performing necessary data transformations to ensure data integrity, privacy, and clarity. The README provides detailed steps for each table, guiding you through the process of loading, cleaning, and structuring the data for effective reporting in Power BI.


---
# <a name="Milestone-2"></a> Milestone 2: Create the Data Model



## Continuous Date Table Creation

1. **Continuous Date Table:** Created a continuous date table covering the entire time period of the data from Orders['Order Date'] to Orders['Shipping Date'] using DAX formula:
`Dates = 
   ADDCOLUMNS (
    CALENDAR (
        MIN ( Orders[OrderDate] ),
        MAX ( Orders[ShippingDate] )
    ),` 

2. **Date Table Columns:** Added new Date columns using the following DAX formula:

![Alt text](<Images/Screenshot 2024-01-08 at 11.45.38.png>)

- I then Used the following DAX forumlas separately:

      - Start of Year: `Start_of_Year = STARTOFYEAR('Dates'[Date])   `
      - Start of Quarter: `Start_of_Quarter = STARTOFQUARTER(Dates[Date]) `
      - Start of Month: `Start_of_Month = STARTOFMONTH(Dates[Date]) `
      - Start of Week: `Start_of_Week = VAR WeekStartDate = [Date] - WEEKDAY([Date], 2) + 1
RETURN WeekStartDate `


## Star Schema and Relationships

3. **Star Schema:** Established a star schema by creating relationships between tables.
   
4. **Table Relationships:**
   - Orders[ProductCode] to Products[ProductCode]
   - Orders[StoreCode] to Stores[StoreCode]
   - Orders[UserID] to Customers[UserUUID]
   - Orders[OrderDate] to Date[Date]
   - Orders[ShippingDate] to Date[Date]

5. **Active Relationship:** Ensured the relationship between Orders[Order Date] and Date[date] is an active relationship with a one-to-many relationship.

## Measures Table Creation

6. **Measures Table:** Created a separate table for measures named "Measures_Table" in Power Query Editor to organise and manage measures effectively.

## Key Measures

7. **Key Measures:**
Created the following Key Meausres in the Measures_Table using the following DAX formulas:
   - **Total Orders**: Count of orders in the Orders table.
      -  `Total_Orders = COUNTROWS(VALUES('Orders'[UserID]))`
   - **Total Revenue**: Sum of (Product Quantity * Sale_Price) for each order.
      - `Total_Revenue = SUMX(Orders, Orders[ProductQty] * RELATED(Products[SalePrice])) `
   - **Total Profit**: Sum of (Product Quantity * (SalePrice - CostPrice)) for each order.
      - `Total_Profit = SUMX(Orders, (RELATED(Products[SalePrice]) - RELATED(Products[CostPrice])) * Orders[ProductQty]) ` 
   - **Total Customers**: Count of unique customers in the Orders table.
      - `TotalCustomers = DISTINCTCOUNT(Orders[UserID]) `
   - **Total Quantity**: Count of items sold in the Orders table.
      - `Total_Quantity = SUM(Orders[ProductQty]) `
   - **Profit YTD**: Total profit for the current year.
      - ` Profit_YTD = 
CALCULATE(
    SUMX(
        FILTER(
            ALL(Orders),
            YEAR(Orders[OrderDate]) = YEAR(TODAY())
        ),
        (RELATED(Products[SalePrice]) - RELATED(Products[CostPrice])) * Orders[ProductQty]
    )
)`
   - **Revenue YTD**: Total revenue for the current year.
     -  `Revenue_YTD = 
CALCULATE(
    SUMX(
        FILTER(
            ALL(Orders),
            YEAR(Orders[OrderDate]) = YEAR(TODAY())
        ),
        (RELATED(Products[SalePrice]) * Orders[ProductQty])
    )
) `

## Hierarchies

8. **Date Hierarchy:** Created a date hierarchy with levels: Start of Year, Start of Quarter, Start of Month, Start of Week, Date for drill-down in line charts.

9. **Geography Hierarchy:** Created a geography hierarchy with levels: World Region, Country, Country Region for data filtering.

10. **Country and Geography Columns:** Added calculated columns in the Stores table for a full country name and geography based on specified schemes.

## Data Categorisation

11. **Data Categories:** Ensured correct data categories for specific columns (World Region, Country, Country Region) for accurate mapping.
---
**Model View:** Please see the screenshot below for the up-to-date model view for this project.

![Screenshot of Current Model](<Images/Screenshot 2024-01-08 at 12.03.29.png>)
---

# <a name="Milestone-3"></a> Milestone 3: Set up the Report