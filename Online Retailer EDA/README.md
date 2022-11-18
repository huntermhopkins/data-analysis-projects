# Business Case
In today's world, retailers do a ton of business online. This allows them to reach customers and markets that weren't possible to do business in before. By leveraging their sales data, retailers can increase their profits by focusing on certain markets or products. My goal is to reshape the retailer's sales data to provide them with information on the products they sell, their customers, and the markets they are involved in. After creating these new tables, I will be able to analyze the data and provide suggestions that will help the retailer increase profits, optimize their shelf space by dropping unpopular or low-quality products, and increase customer retention. I have also created a dashboard in Tableau, so that the retailer may track how their performance after these changes are implemented.

**Check out the dashboard here:** https://public.tableau.com/views/OnlineRetailDashboard_16687209398630/OnlineRetailDashboard?:language=en-US&:display_count=n&:origin=viz_share_link

Email: hopkinshunterm@gmail.com

# Table of Contents
<details open>
<summary>Show/Hide</summary>
<br>

1. [File Descriptions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#file-descriptions)
2. [Executive Summary](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#executive-summary)
    1. [Investigating Missingness in Original Dataset](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#investigating-missingness-in-original-dataset)
    2. [Reshaping Data](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#reshaping-data)
        * [Products](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#products)
        * [Customers](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#customers)
        * [Countries](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#countries)
        * [Calendar](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#calendar)
    3. [Conclusions and Suggestions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#conclusions-and-suggestions)
        * [Business Suggestions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#business-suggestions)
        * [Data Integrity Suggestions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/README.md#data-integrity-suggestions)
</details>

# File Descriptions
<details>
<summary>Show/Hide</summary>
<br>

* [images](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/images): Folder containing screenshots of tables and figures.
* [workbooks](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Online%20Retailer%20EDA/workbooks): contains excel workbooks including analysis and original dataset.
    * **00_online_retail_original.xlsb**: Original dataset.
    * **01_online_retail_analysis.xlsb***: Includes cleaned dataset and new sheets containing reshaped data.

\* To reduce file size, most columns using a function only contain the function in the first row. Please look at this row when reviewing the functions used to manipulate the data.

</details>

# Executive Summary
## Investigating Missingness in Original Dataset
<details open>
<summary>Show/Hide</summary>
<br>

Before doing any analysis on the data, it is important to make sure the data is correct. To start this process, I looked at which columns had missing observations. The figure below shows that 1,454 observations are missing an item description and 135,080 observations are missing a customer ID. It should also be noted that over 2,500 observations have a unit price and total sale of zero. This is obviously an error and should be addressed if possible. 

![](images/missingness_matrix_original.png)

To see how to fill in the missing data, let's look at an example of some observations with a missing description and a price of zero.

![](images/why_description_price_missing.png)

Since each of these observations include a valid stock code, or product ID, it may be possible to see if other observations of the same product have this information available and impute these values. Let's test this theory by looking at some observations that include the product *22712*.

![](images/example_1.png)

It appears that the product *22712* should have the description *CARD DOLLY GIRL*. However, the prices seem to vary. Most records have a unit price of 0.42, while some are upwards of 0.80. This will make it more difficult to impute accurate prices.

Let's look at another product to make sure all products have similar data.

![](images/example_2.png)

Here are some records for the product *22139*. This product should have the description *RETROSPOT TEA SET CERAMIC 11 PC*. Again, the prices vary in some cases. Due to this, I believe the best way to impute the missing prices would be to replace them with a weighted average price, using the quantity as the weight. This will ensure that the average price skews towards the price that appears most often and will adjust for one-off prices or prices that were inputted incorrectly.

Below is a table outlining the amount of missing data in each column after cleaning the price and description data. While my imputation method fixed most of the missing prices, there are still 4 observations with a price of zero. Another problem is that my method created 137 errors. First, let's examine why my method created errors.

![](images/missingness_first_clean.png)

To fix this, let's look at all the products that had missing information before cleaning the data. In the figure below, I have calculated the percentage of orders that contain missing information for each product. Some products have a percentage of 100%, meaning there are no records with a non-zero price to reference, which leads to an error.

![](images/product_missingness.png)

Because there are only 115 products with no reference price out of roughly 4000 products and only 120 orders containing these products out of over 500,000 orders, I decided to remove any records containing these products from the data set.

Next, the unit prices that are still zero need to be investigated. These come from a product with the stock code *PADS*. Originally, they had a price of 0.001, but since my new weighted price is rounded to 2 decimal points, the price was rounded down to zero. 

![](images/pads_products.png)

This could easily be fixed by using an *IF* function. I opted to manually enter the price to keep the number of calculations being done in the workbook down. The price was also changed to 0.01, as it doesn't make sense for an item to cost 0.001.

![](images/missingness_second_clean.png)

</details>


## Reshaping Data
<details open>
<summary>Show/Hide</summary>
<br>

Now that the dataset is cleaned, I can begin reshaping the data to gain further insights into other aspects of the data. Currently, the data is designed to have each order as a row with each column containing information about that order. I would like to reorganize the data in different ways to show information about each product, customer, country, etc. This will allow the retailer to make more informed business decisions in the future.

### Products
First, I will create a new sheet containing information on each product. On this sheet, the retailer will be able to track the quantity purchased, quantity returned, quantity kept, percentage of quantity returned, and revenue for each product. This allows them to see what their top selling products are, or which products have a high return rate. Low selling products may want to be dropped by the retailer to make room for more desirable products.

After calculating the return rates for each item, several products had a return rate over 100%, which is seemingly impossible.

![](images/high_return_rates0.png)

After investigating why this is happening, I discovered that the retailer lists products that were thrown away, lost, or damaged in their register. This means that not every order with a negative quantity is an item returned by the customer. Examples for products *21018*, *84352*, and *84614A* are listed below, respectively.

![](images/high_return_rate1.png)

![](images/high_return_rate2.png)

![](images/high_return_rate3.png)

Entries of this type have a missing customer ID because these invoices are not made by a customer. This explains why some customer IDs are missing, but there are other invoices with a missing customer ID that appear to be normal orders.

While it may be misleading to count these damaged or lost products as returned, they lead to the same conclusions in the analysis. The point of tracking the return rate for each product is to identify products that customers don't like or are manufactured poorly. This allows the retailer to decide if the product is worth keeping in stock. It is important for the retailer to know that a product is arriving damaged or thrown away at a high rate. Later, you will see that I am also tracking the return rate of each customer as well. These entries will not negatively affect any customer's return rate because each entry of this type has a missing customer ID. For these reasons, these entries were categorized as "returns".

![](images/product_sheet_snapshot.png)

### Customers
Another useful area for a retailer to investigate is its customers. In this sheet, data such as country of origin, quantity purchased, quantity returned, quantity kept, percentage of quantity returned, revenue, revenue per order, quantity per order, first purchase date, last purchase date, and purchase duration in months is tracked. The retailer may use this information to start a loyalty program to reward high spending customers, or customers who have shopped at the retailer for a certain period. They may also want to flag customers with a high return rate.

![](images/customer_sheet_snapshot.png)

### Countries
This sheet computes relevant data for each country the retailer has customers based in. Total customers, total quantity, total orders, revenue, revenue per customer, revenue per order, orders per customer, orders with missing customer, and percentage of orders with missing customer are available. The retailer may want to increase marketing in countries with a higher revenue per customer to increase sales.

![](images/countries_sheet_snapshot.png)

### Calendar
Finally, I will aggregate the data for each month. This sheet includes columns detailing the total customers, total quantity, total orders, total revenue, revenue per customer, revenue per order, orders per customer, quantity returned, quantity kept, and percentage of quantity returned.

While organizing this sheet, I realized that one more column had to be fixed. Some dates were formatted as *DAY-MONTH-YEAR* which Excel does not automatically recognize.

![](images/unique_dates.png)

 This was remedied by using a combination of the *LEFT*, *MID*, and *RIGHT* functions to reorder the dates. Upon fixing the dates, I noticed that the retailer didn't start properly tracking their data until 2011. Prior to that year, the retailer only had sales data for one day out of each month. This will cause sales before 2011 to be much smaller than they actually were. In order to adjust for this error, I added the columns revenue per day, customers per day, quantity per day, orders per day, and quantity returned per day to help make comparisons between these periods more accurate.

 ![](images/calendar_sheet_snapshot.png)

</details>

## Conclusions and Suggestions
<details open>
<summary>Show/Hide</summary>
<br>

### Business Suggestions
Based on the data, I believe this retailer is based in the United Kingdom. Their sales in the U.K. dwarf any other country, and the countries that round out the top 5 are European. Despite their astronomical sales in their probable home country, I would recommend that the retailer makes a push to increase sales in other countries. Specifically, Ireland and The Netherlands. In these countries, the retailer makes much more money per customer. If they are able to increase the number of customers in these countries, they should see a much higher rise in revenue than if they attracted more customers in the U.K.

![](images/revenue_per_customer.png)

Another suggestion would be to drop any products with a quantity sold in the 3rd percentile. This would eliminate 116 products from their shelves. Dropping these low-selling products would free up inventory space and allow more room for products that are making more money for the retailer. One caveat to this suggestion is that profits for each product is not included in the dataset. It is possible that a low selling product has a large profit margin to make it worth keeping on the shelf. If possible, the retailer should look to include this information and take it into consideration before removing any products from their inventory.

Looking at the products with the highest return rates, it appears that the word "PINK" appears frequently. If the retailer is responsible for manufacturing these products, they may want to investigate if the dye, coloring, or machine used in these products is working as intended. If these products are coming from the same third-party manufacturer, they should notify this manufacturer or stop selling their products. The retailer could also look into setting up a review system on their website so the customers can explain why they returned the product. These complaints could then be analyzed to understand why products are being returned.

![](images/top_return_rates.png)

The online retailer has a large number of customers that have begun shopping with them in the past month. To reward loyal customers, the retailer could begin a loyalty program that awards longstanding customers with coupons. This will incentivize new customers to keep shopping with the retailer and increase their customer retention rate.

![](images/customer_loyalty.png)

### Data Integrity Suggestions
While working with this dataset, it is clear that there are issues with data integrity. Although it is difficult to be certain without knowing how the data is sourced. One problem in the dataset is missing entries. Specifically, customer IDs, item prices, and product descriptions. Missing customer IDs can be a problem as it makes it difficult to gauge how many customers the retailer has. For example, in the United Kingdom, there are 3,501 orders with a missing customer ID. It's possible that this is just one customer, or it could be 3,501 separate customers. If these are all individual customers, the total amount of customers in the country would almost double. This change could greatly affect how decision makers view the numbers in each country. The retailer is also possibly missing out on getting more information on certain customers that could help them improve their shopping experience.

Again, however, it is difficult to say this is a problem with data integrity. Previously, we saw that some orders with a missing customer ID are due to the retailer listing damaged goods as an invoice. The others could be instances where a customer checked out as a guest. From the outside looking in, this is a suggestion that may help the retailer, but is possible that there is nothing they can do to fix it.

Another issue in the dataset is unreasonably high return rates. Some of these are, again, due to the retailer including lost goods in the dataset, but there are other instances where this is not the case.

![](images/return_error_example.png)

In the figure above, there are orders for the product *84352* listed chronologically. Customer *16810* returned two tree stands, but there is no record of them purchasing any. How can they return an item that they never purchased? It is possible that this is a sample of the retailer's record and the sale happened outside of this sample. However, if this is in fact a problem, the retailer's data team needs to investigate it.

By following these suggestions, I am confident the retailer will be able to expand their market, and increase their revenue, customer retention, and data integrity.

</details>