# Data-Analytics-Power-BI-Report
![BI 2](https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/0f5d8eec-f56b-4465-8959-623ac2d7b49e)

# Table of Contents

1. [Milestone 1: Importing and Preparing Orders Table](#milestone-1-importing-and-preparing-orders-table)
2. [Milestone 2: Creating the Data Model](#milestone-2-creating-the-data-model)
3. [Milestone 3: Setting up the Report](#milestone-3-setting-up-the-report)
4. [Milestone 4: Building the Customer Detail Page](#milestone-4-building-the-customer-detail-page)
5. [Milestone 5: Creating an Executive Summary Page](#milestone-5-creating-an-executive-summary-page)
6. [Milestone 6: Creating a Product Detail Page](#milestone-6-creating-a-product-detail-page)
7. [Milestone 7: Creating a Stores Map Page](#milestone-7-creating-a-stores-map-page)
8. [Milestone 8: Cross Filtering and Navigation](#milestone-8-cross-filtering-and-navigation)
9. [Milestone 9: Creating Metrics for Users Outside the Company Using SQL](#milestone-9-creating-metrics-for-users-outside-the-company-using-sql)

---
**Note:** As I am a Mac user, I first had to create a Windows VM for this project. These are the steps I followed in order to do this:
1. Access Azure
2. Create a Windows Virtual Machine with the size D2s_v3. This VM costs ~$85/month but the Azure free trial offers a free $200 credit to spend on any Azure service. So as long as I finished the project within the propose timeline, I would not incur any additional charges.
3. Connect my VM to my local machine. I did this by Utilising Microsoft Remote Desktop.

--- 
# Milestone 1: Importing and Preparing Orders Table


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
# Milestone 2: Creating the Data Model


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

- I then Used the following DAX forumlas separately to create the following DateTime measures:

      - Start of Year: `Start_of_Year = STARTOFYEAR('Dates'[Date])   `
      - Start of Quarter: `Start_of_Quarter = STARTOFQUARTER(Dates[Date]) `
      - Start of Month: `Start_of_Month = STARTOFMONTH(Dates[Date]) `
      - Start of Week: `Start_of_Week = VAR WeekStartDate = [Date] - WEEKDAY([Date], 2) + 1
         RETURN WeekStartDate`



## Star Schema and Relationships

3. **Star Schema:** Established a star schema by creating relationships between tables.
   -  <img width="909" alt="Screenshot 2024-01-16 at 14 57 30" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/670afa81-24d0-44b5-9a5e-09232e69d73d">
   
5. **Table Relationships:**
   - Orders[ProductCode] to Products[ProductCode]
   - Orders[StoreCode] to Stores[StoreCode]
   - Orders[UserID] to Customers[UserUUID]
   - Orders[OrderDate] to Date[Date]
   - Orders[ShippingDate] to Date[Date]

6. **Active Relationship:** Ensured the relationship between Orders[Order Date] and Date[date] is an active relationship with a one-to-many relationship.

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
      - ` Profit_YTD = TOTALYTD(Measures_Table[Total Profit], Dates[Date])`
   - **Revenue YTD**: Total revenue for the current year.
     -  `Revenue YTD = TOTALYTD(Measures_Table[Total Revenue], Dates[Date])`

## Hierarchies

8. **Date Hierarchy:** Created a date hierarchy with levels: Start of Year, Start of Quarter, Start of Month, Start of Week, Date for drill-down in line charts.
   - <img width="283" alt="Screenshot 2024-01-16 at 15 00 23" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/d0b48747-1d4d-4ac9-b231-5042b7b937a7">

9. **Geography Hierarchy:** Created a geography hierarchy with levels: World Region, Country, Country Region for data filtering.
   - <img width="277" alt="Screenshot 2024-01-16 at 15 00 00" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/4edf7436-eae2-49e7-9dbe-abe3dad93734">

10. **Country and Geography Columns:** Added calculated columns in the Stores table for a full country name and geography based on specified schemes.
    - Using the following DAX Formula: <img width="207" alt="Screenshot 2024-01-16 at 15 02 42" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/c88d2aa0-56c7-4a8f-ad9c-c143662d7a76">

## Data Categorisation

11. **Data Categories:** Ensured specific columns (World Region, Country, Country Region) were categorised correctly for accurate mapping.
---
**Model View:** Please see the screenshot below for the up-to-date model view for this project.

![Screenshot of Current Model](<Images/Screenshot 2024-01-08 at 12.03.29.png>)
---

# Milestone 3: Setting up the Report

1. **Creating report pages:** Created an Executive Summary page, Customer Detail page, Product Detail page and Stores Map page.
2. **Selecting a colour theme:** I selected a colour theme that I thought would look good as a finished report. 
3. **Adding Navigation sidebars:** added a rectangle shape covering a narrow strip on the left side of each page. This would be the sidebar that we will use to navigate between pages later in my report build.

---

# Milestone 4: Building the Customer Detail Page

## Creating Headline Card Visiuals 
1. Created two rectangles and arrange them in the top left corner of the page. These served as the backgrounds for the card visuals.

2. Added a card visual for the `[TotalCustomers]` measure I created earlier, renaming the field Unique Customers. I did this by selecting a card visual and dragging the `[TotalCustomers]` measure into the card visual. I then formatted the card according to my report colour scheme. 

3. Created a new measure in my `Measures` Table called `[RevenuePerCustomer]`. This was created by dividing `[Total Revenue]` by the `[Total Customers]` measures.

4. Added a card visual for the `[RevenueperCustomer]` measure, by following the same steps I used for `[TotalCustomers]`.

## Creating Summary Charts
5. Added a Donut Chart visual showing the total customers for each country, by using the `[Users[Country]` column to filter the `[Total Customers]` measure.

6. Added a Column Chart visual showing the number of customers who purchased each product category, using the `Products[Category]` column to filter the `[Total Customers]` measure. 

## Creating the Line Chart

7. Added a Line Chart visual to the top of the page, that showed `[Total Customers]` on the Y axis, and use the Date Hierarchy I created in Step 8 of Milestone 2 for the X axis. I have allowed users to drill down to the month level, but not to weeks or individual dates.
   - <img width="179" alt="Screenshot 2024-01-16 at 15 08 55" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/3f148d8c-7be0-4e37-894d-64097161e627">

8. Added a trend line, and a forecast for the next 10 periods with a 95% confidence interval.
   - <img width="180" alt="Screenshot 2024-01-16 at 15 12 57" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/43db306c-d6f3-41a9-9e27-0ee398a7105a"> <img width="180" alt="Screenshot 2024-01-16 at 15 09 36" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/0efd3673-489d-4702-aeed-04f2baa606b6">

## Creating Top Customer Table
9. Created a new table, which displays the top 20 customers, filtered by revenue. The table shows each customer's full name, revenue, and number of orders.
   - <img width="384" alt="Screenshot 2024-01-16 at 15 10 15" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/1311137d-6eb3-41e9-ab5f-c24fdd0cb311">
10. Added conditional formatting to the revenue column, to display data bars for the revenue values. 

## Creating Top Customer Cards
11. Created a set of three card visuals that provide insights into the top customer by revenue. They display the top customer's name, the number of orders made by the customer, and the total revenue generated by the customer.

## Adding a Date Sliccer
12. Added a date slicer to allow users to filter the page by year, using the between slicer style. I did this by selecting the date slicer visualisation, and only adding Year to the field in Build a visual.

---

# Milestone 5: Creating an Executive Summary Page

## Copying and Arranging Cards:

1. Copied a grouped card visual from the Customer Details page.
2. Pasted it onto the Executive Summary page.
3. Duplicated the card two more times.
4. Arranged the three cards to span about half of the width of the page.
5. Assigned them to `Total Revenue`, `Total Orders`, and `Total Profit` measures.

## Format Cards:

6. Used the Format > Callout Value pane:
   - Ensure there were no more than 2 decimal places for Revenue and Profit cards.
   - Set 1 decimal place for the Total Orders measure.

## Line Chart:

7. Copied the line graph from the Customer Detail page.
8. Set X-axis to `Date Hierarchy` with `Start of Year`, `Start of Quarter`, and `Start of Month levels`.
9. Set Y-axis to Total Revenue.
10. Positioned the line chart just below the cards.

## Donut Charts:

11. Added two donut charts:
   - `Total Revenue` breakdown by `Store[Country]`.
   - `Total Revenue` breakdown by `Store[Store Type]`.

## Bar Chart:

14. Copied the `Total Customers` by `Product Category` column chart.
15. In the on-object Build a visual pane, I changed the visual type to Clustered bar chart.
16. Changed the X-axis field from `Total Customers` to `Total Orders`.
17. Altered the colour for my theme in the Colours tab.
  
## KPIs for Quarterly Targets:

18. Used the following DAX to create the following measures:
   - Previous Quarter Profit.
      - `Previous Quarter Profit = 
    CALCULATE(
        [Total Profit],
        DATEADD('Dates'[Start_of_Quarter], -1, QUARTER)
    )`
   - Previous Quarter Revenue.
      - `Previous Quarter Revenue = 
      CALCULATE(
         [Total Revenue],  
          DATEADD('Dates'[Start_of_Quarter], -1, QUARTER)
      )`
   - Previous Quarter Orders.
      - `Previous Quarter Orders = 
      CALCULATE(
         [Total Orders],  
          DATEADD('Dates'[Start_of_Quarter], -1, QUARTER)
      )`
   - Targets (5% growth in each measure compared to the previous quarter).
      - `Target Profit = 
   [Previous Quarter Profit] * 1.05`
      - `Target Revenue = 
   [Previous Quarter Revenue] * 1.05`
      -`Target Orders = 
   [Previous Quarter Orders] * 1.05`

19. Added a new KPI for Total Revenue, Total Profit and Total Orders:
   - Value field: Total Revenue.
   - Trend Axis: Start of Quarter.
   - Target: Target Revenue.

20. In the Format pane:
   - Set Trend Axis to On.
   - Set Direction to High is Good.
   - Set Bad Colour to red.
   - Set Transparency to 15%.

21. Formatted the Callout Value to show only 1 decimal place.

22. Duplicated the card two more times.
23. Set appropriate values for the Profit and Orders cards.

---
# Milestone 6: Creating a Product Detail Page

## Gauges for Current-Quarter Performance

1. Added three gauges for Orders, Revenue, and Profit.
2. Defined DAX measures for metrics and quarterly targets:
      -  `10% Target Quarter Orders = 
   'Measures_Table'[Previous Quarter Orders] * 1.1`
      - Current Quarter Orders = 
      CALCULATE(
      TOTALQTD('Measures_Table'[Total Orders],'Dates'[Date])
      )`
4. Set maximum gauge values to quarterly targets.
5. Applied conditional formatting to callout values so that it remains red until the target is reached.
6. Arranged gauges evenly along the top of the report.

## Filter Placeholder Shapes

7. Added rectangle shapes for card visuals.
8. Used a color in keeping with the theme.

## Area Chart for Product Categories

9. Added an area chart for revenue over time.
10. Configured X-axis to `Dates[Start of Quarter]`.
11. Y-axis values to `Total Revenue`.
12. Legend to `Products[Category]`.

## Top 10 Products Table

13. Copied the top customer table from `Customer Detail` page.
14. Included fields: `Product Description`, `Total Revenue`, `Total Customers`, `Total Orders`, `Profit per Order`.

## Scatter Graph for Promotional Suggestions

15. Created a calculated column `[Profit per Item]` by using the following DAX formula: `Profit per Item = SUMX(Products,Products[SalePrice] - Products[CostPrice])`
16. Added a scatter chart with X-axis as `[Profit per Item]` and Y-axis as `[Total Quantity]`.
17. Set Legend to `Products[Category]`.

## Slicer Panel with Bookmarks

18. Downloaded custom icons collection.
19. Added a custom icon button to the navigation bar.
20. Created a rectangle shape for slicer panel.
21. Add two vertical list slicers:` Products[Category]` and `Stores[Country]`.
22. Configured slicers for neat formatting.
23. Grouped slicers with the slicer toolbar shape.
24. Added a Back button and positioned it sensibly.
25. Created bookmarks for open and closed states of the toolbar.
26. Assigned actions to buttons using bookmarks.

---

## Milestone 7: Creating a Stores Map Page

## Task 1: Adding a Map Visual
1. On the Stores Map page, I added a new map visual from the visualisations section.
2. Set the style in the Format pane to my satisfaction and ensured Show Labels is set to On.
3. Map Controls:
  - Auto-Zoom: On
  - Zoom buttons: Off
  - Lasso button: Off
4. Assigned Geography hierarchy to the Location field, and ProfitYTD to the Bubble size field.

## Task 2: Adding a Country Slicer
5. Added a slicer above the map.
6. Set the slicer field to `Stores[Country]`.
7. Formatted the slicer:
  - Slicer style as Tile.
  - Selection settings to Multi-select with Ctrl/Cmd.
  - Show "Select All" as an option in the slicer.

Finished Stores Map page:

-    <img width="1038" alt="Screenshot 2024-01-15 at 16 15 01" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/7ddf5fa2-5bdc-4192-86a6-7e63f360e098">


## Task 3: Create a Store Drillthrough Page
8. Created a new page named `Stores Drillthrough`.
9. Opened the format pane and expanded the Page information tab.
10. Set the Page type to Drillthrough.
11. Set Drill through when to Used as category.
12. Set Drill through from to country region.
13. Added the following visuals to the drillthrough page:
      - A table showing the top 5 products with columns: Description, Profit YTD, Total Orders, Total Revenue.
      - A column chart showing Total Orders by product category for the store.
      - Gauges for Profit YTD against a profit target of 20% year-on-year growth vs. the same period in the previous year, using the Target field, not the Maximum Value field.
      - A Card visual showing the currently selected store.

Finished Drillthrough page:
-    <img width="1040" alt="Screenshot 2024-01-15 at 16 16 00" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/b28c47c9-936c-419b-b4b2-387b669ea5f9">


## Task 4: Create a Store's Tooltip Page
14. Created a new page named Store's Tooltip.
15. Copied over the Profit Gauge visual from the drillthrough page.
16. Set the tooltip of the visual to the Store's Tooltip page.

Finished Tooltip page:
-    <img width="365" alt="Screenshot 2024-01-15 at 16 17 05" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/6b24791d-4792-4198-bda6-c8584932acfb">

Finished Tooltip on Map Page:
-    <img width="1639" alt="Screenshot 2024-01-15 at 16 19 38" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/41b97b6c-4f4e-41b8-883c-db24b1fa4219">

---

## Milestone 8: Cross Filtering and Navigation

## Task 1: Fix Cross Filtering
To do this, I clicked on the 'Edit Interactions' button for the visualisation I wanted to cross-filter. I then selected the filter icon and selected the correct type of cross filtering needed for the other visualisations.

For example, in this cross filtering for the Total Customers by Product Bar Chart on the Customer Details page, I selected the small <img width="44" alt="Screenshot 2024-01-16 at 11 51 10" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/27710209-f79e-494f-abc8-b15c2e6f2a40"> icon so that there would be no impact on the Customers Line Graph.


<img width="1209" alt="Screenshot 2024-01-16 at 11 54 00" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/4735621a-a027-40c9-8fbe-5afe723a3abe">

## Here's the cross-filtering I did for this report's pages:

### Executive Summary Page
1. Product Category bar chart and Top 10 Products table not filtering the card visuals or KPIs.

### Customer Detail Page
2. Top 20 Customers table not filtering any of the other visuals.
3. Total Customers by Product Category Bar Chart not affecting the Customers line graph.
4. Total Customers by Country Donut chart cross-filter Total Customers by Product Donut Chart.

### Product Detail Page

5. Orders vs. Profitability scatter graph not affecting any other visuals.
6. Top 10 Products table not affectinf any other visuals.

## Task 2: Finishing the Navigation Bar

For each page, there was a custom icon available in the custom icons collection:
7. Using the white version for the default button appearance.
8. setting the blue version for the button when hovered over with the mouse pointer.

### Executive Summary Page Sidebar

9. Added four new blank buttons.
10. In the Format > Button Style pane, set Apply settings to Default.
11. Set each button icon to the relevant white png in the Icon tab.
12. For each button, set Apply settings to On Hover, and selected the alternative colourway of the relevant button under the Icon tab.
13. Turned on the Action format option for each button.
14. Selected the type as Page navigation.
15. Selected the correct page under Destination.
For Example:
   - <img width="180" alt="Screenshot 2024-01-16 at 14 44 01" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/1325a5c6-3db1-4934-9c45-e81992b41933"> <img width="174" alt="Screenshot 2024-01-16 at 14 46 43" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/cb79f2da-744d-40eb-89f9-051d858ac2ae">


### Replicating Across Other Pages

16. Grouped the buttons together.
17. Copied the group across to the other pages.

Finished Navigation Bar:
-   <img width="1157" alt="Screenshot 2024-01-16 at 14 52 53" src="https://github.com/madsjoyce/Data-Analytics-Power-BI-Report/assets/150938429/bc862be1-eee9-4e9a-a00e-169f045a0711">

---

## Milestone 9: Creating Metrics for Users Outside the Company Using SQL

---
