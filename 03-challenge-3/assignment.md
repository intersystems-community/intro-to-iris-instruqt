---
slug: challenge-3
id: xybfziqqhu7u
type: challenge
title: Execution Engine
notes:
- type: text
  contents: |-
    # Execution Engine

    InterSystems IRIS is not just a database.

    In this platform, you can run application code directly on the database server, allowing complex applications to work close to the data they use. Developers can build these applications using InterSystems ObjectScript<sup>*1*</sup> or Python. Because this code runs within the same platform as the database, applications can process data efficiently without relying on separate systems.

    Executing workflows and procedures inside the platform reduces the need to move data and improves efficiency for data-intensive tasks. This is one of the many features that makes InterSystems IRIS such an efficient data platform.

    *<sup>1</sup>ObjectScript is a high-performance, object-oriented language developed by InterSystems.*
tabs:
- id: cmjfuvm3hbxl
  title: VS Code
  type: service
  hostname: vscode
  path: /?folder=/opt/intersystems/src/exercise-3/
  port: 8080
- id: cojcqvwdgnwj
  title: IRIS
  type: service
  hostname: iris
  path: /csp/sys/exp/%25CSP.UI.Portal.SQL.Home.zen?$NAMESPACE=USER
  port: 52773
- id: zpc4etchbw9t
  title: Terminal
  type: terminal
  hostname: iris
difficulty: ""
enhanced_loading: null
---
This is Visual Studio Code, a standard Integrated Development Environment (IDE) — in other words, a fancy code editor. VS Code is the recommended IDE for InterSystems IRIS, and there are several extensions that supercharge the connection between VS Code and InterSystems IRIS.

**From the explorer menu on the left, open the HoleFoods/ProductChanges.cls file**

This is an InterSystems IRIS class. We won't go into detail about the code at the moment, although there are plenty more tutorials available if you would like to find out more. Instead, we are going to use the two functions inside the class to demonstrate how to run code in InterSystems IRIS.

**Switch to the [Terminal](tab-2) tab and run the following command**

```objectscript,run,nocopy
do ##class(HoleFoods.ProductChanges).PrintProductDetails("SKU-976")
```

You should see the properties of our new product printed out. If don't see the command being run, try refreshing the window and running it again.

This function retrieves the product details from the database by SKU ID and prints them to the Terminal. The method is defined in the file we were looking at in [VS Code](tab-0) and written in ObjectScript.

To confirm it is reading live data from the database, **try running it with a different ID:**

```objectscript,run,nocopy
do ##class(HoleFoods.ProductChanges).PrintProductDetails("SKU-199")
```

Let's try the other method in the file, which is used to restock a product in the database. We've just had a shipment of 100 new bags of Gummy Rings!

**In the Terminal, run the following command**

```objectscript,run,nocopy
do ##class(HoleFoods.ProductChanges).Restock("SKU-976", 100)
```

This function is contained in the same file as the `PrintProductDetails` function but written in a different language. This time we are accessing the data directly with Python.

Since 2022, InterSystems IRIS has supported Python as an embedded language, allowing developers to combine the performance benefits of running code close to the data with the accessibility of the world’s most popular programming language.

**Just to double-check our restock worked, let's run the first command again:**

```objectscript,run,nocopy
do ##class(HoleFoods.ProductChanges).PrintProductDetails("SKU-976")
```

Finally, let's return to the Management Portal to see the change from there.

**Open the [IRIS](tab-1) tab, then paste the following SQL command into the command box, and click execute**

```sql
SELECT SKU, Category, Name, Price, Stock FROM HoleFoods.Product WHERE ID='SKU-976'
```

We have restocked the Gummy Rings! Here you have seen how to access the same data using SQL, ObjectScript and Python. This gives you the flexibility to read, write, and use data from across many different application contexts.

Let's continue to see how we can use InterSystems IRIS to integrate systems.