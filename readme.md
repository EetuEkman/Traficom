# Traficom open data based vehicle database

## Background

The Finnish Transport and Communications Agency Traficom provides [open data](https://www.traficom.fi/fi/tilastot-ja-julkaisut/avoin-data) about the registration, approval and technical information of the vehicles in use in Finland.

The data is provided as a .zip file containing a comma-separated values (CSV) text file.

## Intention

The intent is to load a contents of the .csv into a staging table. The records of the staging table can then be iterated over, converting, validating and inserting records either into the "final" tables Vehicles or Errors based on the validation rules.

## Preparation

These instructions are written for the Windows 10 operating system. The code was tested with SQL Server 2019 Developer and Microsoft Sql Server Management Studio 18.

### Csv flat file

Download the **TieliikenneAvoinData_5_8.zip** from the [Traficom open data web page](https://www.traficom.fi/fi/tilastot-ja-julkaisut/avoin-data) by clicking on the "Ajoneuvojen avoid data 5.8" and then clicking on the "Lataa Ajoneuvojen avoin data 5.8 -aineisto". Extract the contents of the downloaded .zip file to **C:\temp**.

## Database creation

Traficom.sql file contains the create statements for the database, tables, stored procedures and functions as well as necessary definitions for the open data. Execute the code to create the database.

## Database stored procedures

The database has a stored procedure for bulk inserting the records from the TieliikenneAvoidData_5_8.csv file to the staging table. Execute the stored procedure with command `EXEC dbo.Loader`.

The database uses a stored procedure to convert and validate records as well as insert the records either into Vehicles or Errors tables. The records of the staging table are iterated over using a cursor. Execute the stored procedure with command `EXEC dbo.[Commit]`.

The database has stored procedures to drop and create the final tables for testing purposes. Execute `EXEC dbo.[DropFinalTables]` to drop the final tables and `EXEC dbo.[CreateFinalTables]` to recreate them.

### Rules

### To Error table

If both the date of registration and the date of introduction are either invalid or null, the record is inserted into the Errors table.

If the vehicle class code (ajoneuvoluokka in the staging table) is not "Muu", the vehicle group code (ajoneuvoryhma in the staging table) is mandatory. If the vehicle group code is missing, the record is inserted into the Errors table.

### Other rules

If one of the date of registeration or the date of introduction is invalid or null, the other date is copied in its place. E.g. if the record has

ensirekisterointipvm = null and kayttoonottopvm = 20050713,

set ensirekisterointipvm = kayttoonottopvm

resulting in record having ensirekisterointipvm = 20050713 and kayttoonottopvm = 20050713.

This goes both ways. The record is then inserted into the Vehicles table.

## Afterword

The Commit stored procedure uses cursor to iterate and process the records in the staging table. With over 5 million records, the process is going to take a long time. Consider altering the cursor select statement to select the top 50000 to test the functionality.