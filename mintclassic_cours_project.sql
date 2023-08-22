use mintclassics;

## Exploring Current Inventory.

# Q.1 How many unique products are currently in the inventory?
SELECT 
    COUNT(DISTINCT productName)
FROM
    products; 
/* There are 110 currently unique products  in the inventory */

# Q.2 Can you list all the product categories and the count of products within each category?
SELECT 
    COUNT(productline) as total_products ,
    productLine
FROM
    products
GROUP BY productLine;
/* there are total 7 product category in an inventory */ 

# Q.3 What is the total quantity of each product available in the inventory?
SELECT 
  sum(quantityInStock), productName
FROM
    products
    GROUP BY productName;
    
# Q.4 Which products have the highest and lowest quantities in the inventory?  
SELECT 
    MAX(quantityInStock) AS highest_quantity_product,
    productName
FROM
    products
GROUP BY productName
limit 1
;
SELECT 
    min(quantityInStock),
     productName
   
FROM
    products
GROUP BY productName
order by  min(quantityInStock) asc
limit 1;

/* product 1969 Harley Davidson Ultimate Chopper has maximum stock */ 
/* product 1960 BSA Gold Star DBD34 has minimum stock */ 


##Inventory Reorganization and Reduction:
# Q.5 What is the current storage location of each product?
SELECT 
    p.productname,
    p.quantityinstock,
    w.warehousecode,
    w.warehousename
FROM
    products p
        JOIN
    warehouses w ON p.warehouseCode = w.warehouseCode;
    
 # Q.6 Can you identify products that share the same storage location?   
 SELECT 
    productname, 
    warehouseCode
FROM
    products
    order by warehouseCode;

# Q.7 Are there products with low quantities that can be consolidated into fewer storage locations?
 SELECT 
    productcode,
    productname,
    warehousecode,
    SUM(quantityinstock) AS total_quantity
FROM
   products
GROUP BY productcode ,warehousecode
order by total_quantity ,warehouseCode asc;
/*from abovr question we can suggest that warehouse */
/*code a has 1960 BSA Gold Star DBD34 product in very less quantity 15 and warehouse b having 68 quantity of 1968 Ford Mustang */
   
## Identifying Slow-Moving Products:
# Q.8 Are there any storage locations that can be eliminated by rearranging the products?
  SELECT 
    p.productCode,
    p.productname,
    sum(p.quantityinstock) as total_quantity,
    sum(o.quantityOrdered) as total_sale,
     warehouseCode,
     count(p.warehouseCode)
   
FROM
    orderdetails o
        JOIN
    products p ON p.productCode = o.productCode
    group by p.productCode
    order by total_sale asc;
    /* from belew table we get the list of products and warecousecode that has the low */
    /* sale over the overall database there is need to rearrange the products */

# Q.9 Which products which is in warehouse D and not in A,B,C ? 

SELECT DISTINCT
    p.productName
FROM
    products p
        INNER JOIN
    orderdetails o ON p.productCode = o.productCode
WHERE
    p.warehouseCode = 'D'
        AND p.productCode NOT IN (SELECT DISTINCT
            p2.productCode
        FROM
            products p2
                INNER JOIN
            orderdetails o2 ON p2.productCode = o2.productCode
        WHERE
            p2.warehouseCode IN ('A' , 'B', 'c'));

# Q.10 Can you identify products that have not been sold for a specific period of time?
SELECT 
    o.orderDate,
    od.quantityOrdered,
    p.productName,
    od.productCode,
    p.productName,
    p.quantityInStock,
    p.warehouseCode
FROM
    orders o
        INNER JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
        INNER JOIN
    products p ON p.productcode = od.productcode
   WHERE
     o.orderDate IS NULL
   OR o.orderDate < DATE_SUB(NOW(), INTERVAL 300 DAY)
    ;
   /*frm above we get products that have not been sold for a specific period of time*/ 
# Q.11 Identify products with low turnover rates that might be candidates for reevaluation or reduction.
SELECT 
    sum(py.amount) as total_amount,
   sum(od.quantityordered) as total_orders,
    p.productname,
    p.warehouseCode,
  sum(p.quantityInStock),
     count( p.productname)
FROM
    payments py
        JOIN
    orders o ON py.customernumber = o.customernumber
        JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
        JOIN
    products p ON od.productcode = p.productcode
  group by p.productName,  p.warehouseCode
  order by p.warehouseCode, total_amount asc;
/* The product 1960 BSA Gold Star DBD34 has less orders as well as low revenue in overall sell in warehousecode 'A'*/
/*In ware housecode 'B' the product 1972 Alfa Romeo GTA has less revenue */
/*In ware housecode 'c' from quantity in stock we can  say that 1941 Chevrolet Special Deluxe Cabriolet has less revenue and less sell in overall sell but has more stock */

# Q.12 Are there products that consistently have high sales but low inventory, indicating a potential opportunity for increased stocking?
 SELECT 
    SUM(py.amount) AS total_amount,
    SUM(od.quantityordered) AS total_orders,
    p.productname,
    p.warehouseCode,
    SUM(p.quantityInStock),
    COUNT(p.productname)
FROM
    payments py
        JOIN
    orders o ON py.customernumber = o.customernumber
        JOIN
    orderdetails od ON o.orderNumber = od.orderNumber
        JOIN
    products p ON od.productcode = p.productcode
GROUP BY p.productName , p.warehouseCode
ORDER BY p.warehouseCode , total_amount ASC;

/*product 1928 Ford Phaeton Deluxe In ware housecode 'c' from quantity in stock  1928 Ford Phaeton Deluxe need of keeping more stock */
/*In ware housecode 'B' ,1968 Ford Mustang has more revenue and has more orders but has very less in stock there is a need of keeping more stock of this model  */
/* In warehouse code 'D' the model The Mayflower has more orders and more revenue from it but we have less stock of it */

# Q.13 Can you identify products that have not been sold within a lat year ? 
SELECT 
    p.productName, p.warehouseCode, o.orderdate 
FROM
    products p
        LEFT JOIN
    orderdetails od ON p.productCode = od.productCode
        JOIN
    orders o ON o.ordernumber = od.orderNumber
WHERE
    o.orderDate IS NULL
        or (o.orderDate >= '2004-01-01' AND o.orderDate <= '2005-12-01')
        ORDER BY p.warehouseCode;


/* Below is the list of product are not orderd in last year */
/* there is a need of focusing and thinking more about this products they are remain as it is in inventory */

## Analyzing Supplier Relationships
# Q.14 Which customer borrow  the most products from the inventory?
SELECT 
    c.customerName,
   c.customerNumber,
    c.country,
    sum(od.quantityOrdered) as total_order

FROM
    customers c
        JOIN
    orders o ON c.customerNumber = o.customerNumber
        JOIN
    orderdetails od ON od.ordernumber = o.orderNumber
    group by c.customerNumber,c.city,c.country
    order by total_order desc  ;
/*from above code we get the top customers of inventory*/

# Q.15 how many unique customer inventory has ?
SELECT 
    COUNT(DISTINCT customername) as total_unique_customers
FROM
    customers;
/* inventory has 122 unique customers */
# Q.16 top 10 customer bought the products from the inventory?
SELECT 
    c.customerName,
    c.customerNumber,
    c.country,
    SUM(od.quantityOrdered) AS total_order
FROM
    customers c
        JOIN
    orders o ON c.customerNumber = o.customerNumber
        JOIN
    orderdetails od ON od.ordernumber = o.orderNumber
        JOIN
    products p ON p.productCode = od.productCode
GROUP BY c.customerNumber , c.country 
ORDER BY total_order DESC
LIMIT 10;
/* from above code we get the top 10 customers that bought product */

# Q.17 which  top customers bought products from the inventorry ? ,provide warehouse core with it .
SELECT 
    c.customerName,
   c.customerNumber,
    c.country,
    sum(od.quantityOrdered) as total_order,
    p.warehouseCode

FROM
    customers c
        JOIN
    orders o ON c.customerNumber = o.customerNumber
        JOIN
    orderdetails od ON od.ordernumber = o.orderNumber
    join
    products p on p.productCode=od.productCode
    group by c.customerNumber,c.country,p.warehouseCode
    order by p.warehouseCode   ;
 /* from above code we get the top 10 customers that bought product from particular warehouse*/ 
 
 # Q.18 How are inventory numbers related to sales figures? Do the inventory counts seem appropriate for each item?
SELECT 
   
    sum(od.quantityOrdered) as total_order,
    p.warehouseCode

FROM

    orderdetails od 
    join
    products p on p.productCode=od.productCode
    group by p.warehouseCode
    order by p.warehouseCode   ; 
    /* the warehouse 'A' has 24650 orders, 'B' has 35582 orders ,'d' has the less orders  than other 3 warehouses */
    
    # Q.19 identifying suppliers whose products consistently sell well or have high demand?
    SELECT 
   
    p.productVendor,
    SUM(od.quantityOrdered) AS total_order,
    p.warehousecode
FROM
    orderdetails od
    JOIN
    products p ON p.productCode = od.productCode
GROUP BY  p.productVendor,p.warehouseCode
order by p.warehouseCode desc
  ; 
 
 /* we get vendors and their total orders by warehousecode */
 
 # Q.20 find top 10 vendors whose products have not been selling well and might need revaluation?
  SELECT 
    p.productVendor, SUM(od.quantityOrdered) AS total_order
FROM
    orderdetails od
        JOIN
    products p ON p.productCode = od.productCode
GROUP BY p.productVendor
ORDER BY total_order ASC
limit 10; 
/*we get venders that not selling products fast*/

# 21. which customer have highest shopping and from which warehouse /top 50 customers?
SELECT 
    c.customerName,
   c.customerNumber,
    c.country,
    count(c.country) as no_of_customer,
    sum(od.quantityOrdered) as total_order,
    p.warehousecode,
    p.productName

FROM
    customers c
        JOIN
    orders o ON c.customerNumber = o.customerNumber
        JOIN
    orderdetails od ON od.ordernumber = o.orderNumber
    join
    products p on p.productCode=od.productCode
    
    group by c.customerNumber,c.city,c.country,warehouseCode,p.productName
    order by no_of_customer desc  
    limit 50;
# Q 22  which seller sale less products and from which warehouse they belongs ?
SELECT 
    c.customerName,
   c.customerNumber,
    c.country,
    count(c.country) as no_of_customer,
    sum(od.quantityOrdered) as total_order,
    p.warehousecode,
    p.productName

FROM
    customers c
        JOIN
    orders o ON c.customerNumber = o.customerNumber
        JOIN
    orderdetails od ON od.ordernumber = o.orderNumber
    join
    products p on p.productCode=od.productCode
    
    group by c.customerNumber,c.city,c.country,p.warehouseCode,p.productName
    order by p.warehouseCode desc  
    ;    
    /*from above we will suggest that which seller sale less products and from which warehouse it belong*/
# major findings
# 1. There are 110 currently unique products  in the inventory.
# 2. There are total 7 product category in an inventory. 
# 3. product 1969 Harley Davidson Ultimate Chopper has maximum stock . 
# 4. product 1960 BSA Gold Star DBD34 has minimum stock.
# 5. list of products and warecousecode that has the low sale over the overall database there is need to rearrange the products .
# 6. The product 1960 BSA Gold Star DBD34 has less orders as well as low revenue in overall sell in warehousecode 'A',In ware housecode 'B' the product 1972 Alfa Romeo GTA has less revenue .In ware housecode 'c' from quantity in stock we can  say that 1941 Chevrolet Special Deluxe Cabriolet has less revenue and less sell in overall sell but has more stock */
# 7. from above we get products that have not been sold for a specific period of time.
# 8. product 1928 Ford Phaeton Deluxe In ware housecode 'c' from quantity in stock  1928 Ford Phaeton Deluxe need of keeping more stock ,In ware housecode 'B' ,1968 Ford Mustang has more revenue and has more orders but has very less in stock there is a need of keeping more stock of this model  ,In warehouse code 'D' the model The Mayflower has more orders and more revenue from it but we have less stock of it .alter
# 9. Below is the list of product are not orderd in last year .there is a need of focusing and thinking more about this products they are remain as it is in inventory.
# 10. from above code we get the top customers of inventory.
# 11. from above code we get the top 10 customers that bought product from particular warehouse.
# 12. the warehouse 'A' has 24650 orders, 'B' has 35582 orders ,'d' has the less orders  than other 3 warehouses .
# 13.  we get vendors and their total orders by warehousecode.
# 14. we get venders that not selling products fast.
# 15. from above we will suggest that which seller sale top products and from which warehouse it belong.

# conclusion 
# In this inventory there is 110 total products present with 7 total categories .
# In this inventory the 1969 Harley Davidson Ultimate Chopper has maximum stock and 1960 BSA Gold Star DBD34 has minimum stock.
# product F/A 18 Hornet 1/72	has 15428 product in inventory but has 1047 sale which is close to maximum sell , this product has need to restock 
# this productcode has low sale but stored in high quantity S18_4933,S24_1046,S24_3969,S18_2248,S18_2870,S18_4409,S24_4048,S24_3191,S24_2887,S18_2795,S18_3140,S24_3420,S24_3432,S700_1691,S700_3962,S700_2047,S32_4485,S700_1938 need to be rearrange. 
# The product 1960 BSA Gold Star DBD34 has less orders as well as low revenue in overall sell in warehousecode 'A',In ware housecode 'B' the product 1972 Alfa Romeo GTA has less revenue .In ware housecode 'c' from quantity in stock we can  say that 1941 Chevrolet Special Deluxe Cabriolet has less revenue and less sell in overall sell but has more stock there is need of removel such products . 
#  the list of product are not orderd in last year .there is a need of focusing and thinking more about this products they are remain as it is in inventory.
# from Q 17 we get the top 10 customers that bought product from particular warehouse and their country ,so from this we can think about to open new warehouse at paticular country or close from a country 
#  the warehouse 'A' has 24650 orders, 'B' has 35582 orders ,'d' has the less orders  than other 3 warehouses
# Q 19 gives us the hint to which vendor we need to inspect and for which we need replace vendor and add new vendor which has more ability to sell product . 
# From  Q 20 we get venders that not selling their products fast. we will decrese the stocking for that venders. 
# Q 21  suggest us that which vendor sale top products and from which warehouse it belong. we can see the result and then stock more products for that warehouse and for that vendor.
# Q 21  gives us that the which customer is frequant and top buyer  and from whivh city they belongs, we will give them offer for more sale and think about the rearrangement of products . 
# from Q 21 we can also say that which country has top buyer or top customer and from which warehouse,customer Euro+ Shopping Channel has customer no 141 from country	Spainand	8 total customers	308	total orders from warehouse 'b'.alter
# and which country,vender and from which warehouse we have less orders and revenue we can  rearrange the warehouse and stocking . 
# Q 22 can tell us that the warehouse b has very high customers in spain and c has 6 orders  from usa and warehouse c  , also c has less no of orders . we can see the country and rearrangen the warehouses and products . 