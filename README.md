# Soprts Company Database Analysis with SQL

![featured](https://github.com/pabloelt/sports-company-database-analysis-with-sql//blob/main/Data/Images/featured.jpg?raw=true)

##### Table of Contents 
* [Introduction](#introduction)
* [Objectives](#objectives)
* [Project results](#project-results)
* [Project structure](#project-structure)
* [Instructions](#instructions)

<div align="justify">
 
## Introduction

The client for this project is a sports company specializing in extreme activities, including modalities like skiing, hiking, climbing, and scuba diving, among others. However, the company’s database has not been properly analyzed, leaving many potential insights unexplored. The company seeks to uncover valuable information, particularly related to sales, clients, products, and distribution channels. To achieve this, a plan involving five sprint weeks, managed by the directors of various departments, has been proposed to extract and analyze this critical data.

 * [See a technical explanation of the project here](https://pabloelt.github.io/project/project8/)

## Objectives

The main objective of this project is to thoroughly analyze the company’s database to extract insights and valuable information related to sales, clients, products, and distribution channels. The project is designed to simulate real-world operations, with five sprint weeks planned and regular interactions with various departments. The insights gained from this analysis are expected to significantly enhance the company’s performance, leading to increased profitability and reduced costs.

This entire project is conducted using MySQL, an open-source relational database management system. Specifically, the MySQL Workbench IDE (Integrated Development Environment) is used for the database analysis. 

## Project results

The main results obtained from this Discovery Project are summarized below:

**1. Ten neighborhoods with a high investment potential have been identified**
* They can be segmented into 4 groups depending on the type, quality, and property location.
* These 4 groups, which have been identified, are the following:
  * *Low cost Investment*: Simancas, Ambroz, Marroquina, San Juan Bautista.
  * *Medium cost investment*: El Plantio, Valdemarín, Valdefuentes.
  * *Medium-high cost investment*: Jerónimos, Fuentela reina.
  * *High cost investment*: Recoletos.

**2. It is recommended to search for two-bedroom properties that can accommodate 4 guests**
* The number of guests that maximize the rental price while minimizing the property's purchase price is 4.

**3. It is recommended to search for properties in one of the identified neighborhoods that are not necessarily close to points of interest**
* These properties are expected to have a lower purchase price.
* It seems that proximity to points of interest does not have a particular impact on rental prices.
  
**4. A new business model based on rentals for specific moments of high sporting interest should be explored**
* It is advisable to look for opportunities in the San Blas neighborhood.
* These properties present a particularly high cost-income ratio per night.
* There are still many rentals that are not exploiting this potential.

## Project structure

* 📁 Datos: Project datasets.
  * 📁 Imagenes: Contains project images.
* 📁 Notebooks:
  * <mark>01_Diseño del proyecto.ipynb</mark>: Notebook compiling the initial design of the project.
  * <mark>02_Analisis de ficheros y preparacion del caso.ipynb</mark>: Notebook analyzing the main data and how to obtain those.
  * <mark>03_Creacion del Datamart Analitico.ipynb</mark>: Notebook creating analytic data mart (loading and unifying data, applying data quality processes, and so on).
  * <mark>04_Preparacion de datos.ipynb</mark>: Notebook compilling feature engineering processes.
  * <mark>05_Analisis e Insights.ipynb</mark>: Notebook used for the execution of the exploratory data analysis, which collects the business insights and the recommended actionable initiatives.
  * <mark>06_Comunicacion de resultados.ipynb</mark>: Brief executive report for the communication of results using McKinsey's Exhibits methodology.

## Instructions

* Unzip airbnb.rar under 'Datos' folder.
* Remember to update the <mark>project_path</mark> to the path where you have replicated the project.

</div>
