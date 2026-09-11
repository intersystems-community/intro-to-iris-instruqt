---
slug: challenge-2
id: nbcghntewzn3
type: challenge
title: Data Platform
notes:
- type: text
  contents: |-
    # The Database

    At the core of InterSystems IRIS is a highly efficient, high-performance database designed to scale to demanding workloads — supporting database sizes of up to 8 petabytes.

    It provides a single, consistent place to store, access and manage many different types of data. Applications can work with data in the form that is most suited for the task in hand, without requiring a separate database for each use case.

    This gives applications a scalable and reliable data foundation that can adapt as requirements change.

    > **Click the right arrow for technical details >**
- type: text
  contents: |-
    # Multi-model

    InterSystems IRIS is a natively multi-model database. The underlying data is stored in flexible, hierarchical key-value arrays and can be presented through several different models.

    - **Relational**
    - **Object**
    - **Key-value**
    - **Columnar**
    - **Vector**
    - **Document**

    Different applications can therefore interact with the same underlying data using the model best suited to their needs, without duplicating data or maintaining separate databases.
tabs:
- id: dhdjss1vlojq
  title: IRIS
  type: service
  hostname: iris
  path: /csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER
  port: 52773
difficulty: ""
enhanced_loading: null
---
The most common type of database is the relational database. These are tabular databases — think giant, interlinked spreadsheets. InterSystems IRIS can be used as a standard relational database.

**Copy this command into the text box in the middle of the page, then click `Execute`.**

```sql
SELECT
SKU, Category, Name, Price, Stock
FROM HoleFoods.Product
```

This time, we are querying our `SalesTransaction` table, which is our log of the details of each sale.

This queries the `HoleFoods.Product` table, which stores information on the products sold by our fictional retailer, **HoleFoods**. HoleFoods is a shop specializing in foods with holes in them.

The *relational* part of the name refers to the tables being related to each other, meaning the data in one table might reference data from another table. Let's take a look at our table of transactions:

**Now try running this command:**

```sql
SELECT
AmountOfSale, DateTimeOfSale, Product, UnitsSold
FROM HoleFoods.SalesTransaction
```

We can see the transaction details and the Product ID (SKU) sold. In InterSystems IRIS it is very easy to find values from linked tables.

**Let's re-run the above command with a small change to show the product name:**

```sql
SELECT
AmountOfSale, DateTimeOfSale, Product->Name,  UnitsSold
FROM HoleFoods.SalesTransaction
```
This command uses `->` to fetch the Product `Name` from the `HoleFoods.Product` table, meaning this time, we can see which product is being referenced in each transaction.

These queries use SQL, or Structured Query Language, which is the universal way to query relational data.

## Adding a new Product

Before moving on from the relational table view, we've decided to start stocking gummy rings. Let's add the new item to the database.

**Execute the `INSERT` command below to enter a new product:**

```sql
INSERT INTO HoleFoods.Product
(Category, Name, Price, SKU, Stock)
VALUES
('Snack', 'Gummy Rings', 2.99, 'SKU-976', 200)
```

**And just to double-check it's been added, run:**

```sql
SELECT
SKU, Category, Name, Price, Stock
FROM HoleFoods.Product
```

You should be able to spot our new product in the list!

So far, we have run SQL through the Management Portal, but you can execute it from many other environments, including applications written in Python, Java and .Net. InterSystems IRIS also supports industry-standard ODBC and JDBC connections, making it easy to integrate with almost any existing application.