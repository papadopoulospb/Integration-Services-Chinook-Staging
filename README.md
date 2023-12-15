# Extract Transform Load (ETL) process in SSIS
ETL is the process of extracting data from OLTP databse , transform them into appropriate values and drive them to the data warehouse. This project propose a solution of this process using packages instead of executing sql scripts and you must to customize these packages to your own database.
## Prerequisites
1. Install <img height="15" width="15" src="https://upload.wikimedia.org/wikipedia/commons/2/2c/Visual_Studio_Icon_2022.svg" /> [Microsoft Visual Studio](https://visualstudio.microsoft.com/)  to execute the project and navigate through the packages.
2. Install [Microsoft SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/sql-server-management-studio-ssms?view=sql-server-ver16) to connect to SQL server and execute a couple of actions before execute the packages of the project.
## Getting Started
After installing the above, you have to execute the following sql scripts into SSMS to create the databases in SQL server. 
1. **SQL_create_database_for_ssis**
2. **Create_DW_ssis**

The first one creates the staging area and the second one creates the data warehouse. 
It is not recommended to create new databases during runtime, so you create them before, so that the packages can access them.
From now on, you can execute the solution's packages.
## Executing the solution's packages
The order of the execution is:
1. Load_staging_ssis
2. CreateDimTDW_ssis
3. Load_tables_in_DW_ssis
4. Make_relationshipDW_ssis
5. Make_changes_in OLTP
6. Remove_relationship_DW_ssis
7. SCD_type2_ssis
8. Make_relationshipDW_ssis

It is very crusial to note that **before executing** SCD_type2_ssis, you must "cut" the relationship between the dimension tables and the fact table.

> [!IMPORTANT]
> It is essential to configure the **Connection Managers** and the **OLE DB** connections according to your own pc and sql server. Otherwise errors will occur.
