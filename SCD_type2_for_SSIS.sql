/* SQL Script for SCD type 2 for Chinook */

USE [ChinookStagingSSIS] 
GO
declare @etl_date AS date ='2013-12-22' ;
/* New Staging for Employee */

TRUNCATE TABLE [ChinookStagingSSIS].[dbo].[Employee];

INSERT INTO [dbo].[Employee](
[EmployeeId],[LastName],[FirstName],[Title],[ReportsTo],[BirthDate],[HireDate],[Address],[City],[State],[Country],[PostalCode],
[Phone],[Fax],[Email])

SELECT [EmployeeId],[LastName],[FirstName],[Title],[ReportsTo],[BirthDate],[HireDate],[Address],[City],[State],[Country],[PostalCode],
[Phone],[Fax],[Email]
FROM [Chinook].[dbo].[Employee]
;

/* New Staging for Customer */ 

TRUNCATE TABLE [ChinookStagingSSIS].[dbo].[Customer];

INSERT INTO [dbo].[Customer](
[CustomerId],[FirstName],[LastName],[Company],[Address],[City],[State],[Country],[PostalCode],[Phone],[Fax],[Email],[SupportRepId]
)

SELECT [CustomerId],[FirstName],[LastName],[Company],[Address],[City],[State],[Country],[PostalCode],[Phone],[Fax],[Email],[SupportRepId]

FROM [Chinook].[dbo].[Customer];

/* New Staging for Track */
TRUNCATE TABLE [ChinookStagingSSIS].[dbo].[Track];

INSERT INTO [ChinookStagingSSIS].[dbo].[Track](
[TrackId],[TrackName],[AlbumTitle],[ArtistName],[MediaTypeName],[GenreName],[Composer],[Milliseconds],[Bytes]
)

SELECT t.TrackId,
	   t.[Name] 
      ,a.[Title] 
	  ,artist.[Name]  
      ,mt.[Name] 
      ,g.[Name] 
      ,t.[Composer]
      ,t.[Milliseconds]
      ,t.[Bytes]
--	  ,p.[Name] as PlayListName 

FROM [Chinook].[dbo].[Track] t
INNER JOIN Chinook.[dbo].[Album] a ON a.AlbumId = t.AlbumId 
INNER JOIN Chinook.[dbo].[Artist] artist ON artist.ArtistId = a.ArtistId

INNER JOIN [Chinook].[dbo].[MediaType] mt ON mt.MediaTypeId=t.MediaTypeId

INNER JOIN [Chinook].[dbo].[Genre] g ON g.GenreId = t.GenreId 
/*
INNER JOIN Chinook.[dbo].[PlaylistTrack] plt ON plt.TrackId = t.TrackId
INNER JOIN [Chinook].[dbo].[Playlist] p ON p.PlaylistId = plt.PlaylistId ;
*/

/* New Staging For Sales */ 


TRUNCATE TABLE [ChinookStagingSSIS].[dbo].[Sales];
INSERT INTO [ChinookStagingSSIS].[dbo].[Sales] (
[TrackId],[InvoiceId],[CustomerId],[EmployeeId],[InvoiceDate],[UnitPrice],[Quantity]
)

SELECT il.[TrackId]      -- productID
      ,i.[InvoiceId]     -- the order (timologio)
      ,i.[CustomerId]    -- the customer that made the order
	  ,e.[EmployeeId]    --the employee who helped the customer for the order
      ,i.[InvoiceDate]   -- the date
      ,il.[UnitPrice]    -- track price
      ,il.[Quantity]     -- track quantity - always 1

FROM [Chinook].[dbo].[Invoice] i
INNER JOIN [Chinook].[dbo].[InvoiceLine] il ON il.InvoiceId = i.InvoiceId
INNER JOIN [Chinook].[dbo].[Customer] c ON c.CustomerId = i.CustomerId
INNER JOIN [Chinook].[dbo].[Employee] e ON e.EmployeeId = c.SupportRepId 

WHERE CAST(i.[InvoiceDate] as date) >= @etl_date;

/*  SCD for Employee of the ChinookDB */
DROP TABLE IF EXISTS [ChinookStagingSSIS].[dbo].[Staging_DimEmployee];

CREATE TABLE [Staging_DimEmployee] (
    EmployeeKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeId INT NOT NULL,
    EmployeeName VARCHAR(40) NOT NULL,
    EmployeeTitle VARCHAR(40) NOT NULL,
	EmployeeManagerName VARCHAR(40) NOT NULL,
	EmployeeBirthDate DATE NOT NULL,
    [HireDate] DATE NOT NULL,
    [EmployeeAddress] NVARCHAR(70) NOT NULL,
    [EmployeeCity] NVARCHAR(40) NOT NULL,
    [EmployeeState] NVARCHAR(40) DEFAULT 'N/A' NOT NULL,
    [EmployeeCountry] NVARCHAR(40) NOT NULL,
    [EmployeePostalCode] NVARCHAR(10) DEFAULT 'N/A' NOT NULL,
    [EmployeePhone] NVARCHAR(24) NOT NULL,
    [EmployeeFax] NVARCHAR(24) DEFAULT 'N/A' NOT NULL,
    [EmployeeEmail] NVARCHAR(60) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2009-01-01' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

INSERT INTO [ChinookStagingSSIS].[dbo].[Staging_DimEmployee] (
	--EmployeeKey,
    EmployeeId ,
    EmployeeName ,
    EmployeeTitle ,
	EmployeeManagerName ,
	EmployeeBirthDate ,
    [HireDate] ,
    [EmployeeAddress] ,
    [EmployeeCity] ,
    [EmployeeState],
    [EmployeeCountry] ,
    [EmployeePostalCode] ,
    [EmployeePhone] ,
    [EmployeeFax],
    [EmployeeEmail]
)
SELECT e1.EmployeeID, e1.[FirstName] + ' ' + e1.[LastName], e1.Title, COALESCE(manager.[FirstName]+' '+manager.[LastName],'N/A') , CAST (e1.[BirthDate] as DATE) , CAST (e1.[HireDate] as DATE),
	e1.[Address] , e1.[City] , COALESCE(e1.[State],'N/A') , e1.[Country], COALESCE(e1.[PostalCode],'N/A') ,e1.[Phone] , COALESCE(e1.[Fax],'N/A') ,e1.[Email]

FROM ChinookStagingSSIS.dbo.Employee e1
LEFT JOIN ChinookStagingSSIS.dbo.Employee manager ON manager.[EmployeeId] = e1.[ReportsTo];

/* REMOVE THE CONSTRAINTS IN DATA WAREHOUSE TO USE MERGE */ 
/*
ALTER TABLE [ChinookDWSSIS].[dbo].[FactSales] DROP CONSTRAINT [FactSalesDimCustomer];

ALTER TABLE [ChinookDWSSIS].[dbo].[FactSales] DROP CONSTRAINT [FactSalesDimDateInvoice];

ALTER TABLE [ChinookDWSSIS].[dbo].[FactSales] DROP CONSTRAINT [FactSalesDimEmployee];

ALTER TABLE [ChinookDWSSIS].[dbo].[FactSales] DROP CONSTRAINT [FactSalesDimTrack] ;
*/
/* Update - Insert - Delete rows in DimEmployee */

INSERT INTO [ChinookDWSSIS].[dbo].[DimEmployee](
	EmployeeID, EmployeeName, EmployeeTitle, EmployeeManagerName, EmployeeBirthDate, HireDate,
	EmployeeAddress, EmployeeCity, EmployeeState, EmployeeCountry, EmployeePostalCode, EmployeePhone, EmployeeFax,
	EmployeeEmail, RowStartDate, RowChangeReason
)
SELECT
	EmployeeID, EmployeeName, EmployeeTitle, EmployeeManagerName, EmployeeBirthDate, HireDate,
	EmployeeAddress, EmployeeCity, EmployeeState, EmployeeCountry, EmployeePostalCode, EmployeePhone, EmployeeFax,
	EmployeeEmail,  @etl_date	  , ActionName

FROM(

MERGE [ChinookDWSSIS].[dbo].[DimEmployee] as target
USING [ChinookStagingSSIS].[dbo].[Staging_DimEmployee] as source
ON target.[EmployeeId] = source.[EmployeeId]

WHEN MATCHED  AND target.[RowIsCurrent]=1 AND (source.EmployeeCity <> target.EmployeeCity OR source.EmployeePhone<>target.EmployeePhone OR source.EmployeeEmail<>target.EmployeeEmail
OR source.EmployeeTitle<>target.EmployeeTitle OR source.EmployeeManagerName<>target.EmployeeManagerName)

THEN UPDATE SET
target.RowIsCurrent = 0,
target.RowEndDate = dateadd(day, -1, @etl_date ) ,
target.RowChangeReason = 'UPDATED NOT CURRENT'

WHEN NOT MATCHED THEN
	INSERT (EmployeeID, EmployeeName, EmployeeTitle, EmployeeManagerName, EmployeeBirthDate, HireDate,
	EmployeeAddress, EmployeeCity, EmployeeState, EmployeeCountry, EmployeePostalCode, EmployeePhone, EmployeeFax,
	EmployeeEmail,  RowStartDate,   RowChangeReason
	)
	VALUES(source.EmployeeID, source.EmployeeName,source.EmployeeTitle, source.EmployeeManagerName, source.EmployeeBirthDate, source.HireDate,
	source.EmployeeAddress, source.EmployeeCity, source.EmployeeState, source.EmployeeCountry, source.EmployeePostalCode, source.EmployeePhone, source.EmployeeFax,
	source.EmployeeEmail,  @etl_date,  'NEW_RECORD' )

WHEN NOT MATCHED BY Source THEN
	UPDATE SET
	 target.RowEndDate= dateadd(day, -1, @etl_date)
	,target.RowIsCurrent = 0
	,target.RowChangeReason  = 'FIRED/RESIGNED'
OUTPUT
	source.EmployeeID, source.EmployeeName,source.EmployeeTitle, source.EmployeeManagerName, source.EmployeeBirthDate, source.HireDate,
	source.EmployeeAddress, source.EmployeeCity, source.EmployeeState, source.EmployeeCountry, source.EmployeePostalCode, source.EmployeePhone, source.EmployeeFax,
	source.EmployeeEmail,$Action as ActionName
	

) as MrgEmpl
WHERE MrgEmpl.ActionName = 'UPDATE' AND [EmployeeId] IS NOT NULL;


/*  SCD for Customer of the ChinookDB */
DROP TABLE IF EXISTS [ChinookStagingSSIS].[dbo].[Staging_DimCustomer];

CREATE TABLE [Staging_DimCustomer] (
    CustomerKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CustomerId INT NOT NULL,
    CustomerFullName VARCHAR(60) NOT NULL,
    CustomerCompany VARCHAR(80) DEFAULT 'N/A' NOT NULL,
	CustomerAddress NVARCHAR(70) NOT NULL,
    CustomerCity NVARCHAR(40) NOT NULL,
    [CustomerState] NVARCHAR(40) NOT NULL,
    [CustomerCountry] NVARCHAR(40) NOT NULL,
    [CustomerPostalCode] NVARCHAR(10) DEFAULT 'N/A' NOT NULL,
    [CustomerFax] NVARCHAR(24) DEFAULT 'N/A' NOT NULL,
	[CustomerEmail] NVARCHAR(60) NOT NULL,
    [SupportBy] VARCHAR(40) NOT NULL,
    RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2009-01-01' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);

INSERT INTO [ChinookStagingSSIS].[dbo].[Staging_DimCustomer] (
    CustomerId ,
    CustomerFullName ,
    CustomerCompany ,
	CustomerAddress ,
    CustomerCity ,
    [CustomerState] ,
    [CustomerCountry] ,
    [CustomerPostalCode] ,
    [CustomerFax] ,
	[CustomerEmail] ,
    [SupportBy] 
)
SELECT c.CustomerID, c.[FirstName]+' '+c.[LastName], COALESCE([Company],'N/A') , c.[Address], c.[City], COALESCE(c.[State], 'N/A') , c.[Country],
	COALESCE(c.[PostalCode],'N/A') , COALESCE(c.[Fax] , 'N/A') , c.[Email] , e.FirstName+' '+e.LastName

    FROM ChinookStagingSSIS.dbo.Customer c
	INNER JOIN ChinookStagingSSIS.dbo.Employee as e ON c.SupportRepId=e.EmployeeId
	
/* Update - Insert - Delete rows in DimCustomer */
INSERT INTO [ChinookDWSSIS].[dbo].[DimCustomer](
	CustomerId ,
    CustomerFullName ,
    CustomerCompany ,
	CustomerAddress ,
    CustomerCity ,
    [CustomerState] ,
    [CustomerCountry] ,
    [CustomerPostalCode] ,
    [CustomerFax] ,
	[CustomerEmail] ,
    [SupportBy], RowStartDate, RowChangeReason
)
SELECT
	CustomerId ,
    CustomerFullName ,
    CustomerCompany ,
	CustomerAddress ,
    CustomerCity ,
    [CustomerState] ,
    [CustomerCountry] ,
    [CustomerPostalCode] ,
    [CustomerFax] ,
	[CustomerEmail] ,
    [SupportBy],  @etl_date	  , ActionNameCustomer

FROM(

MERGE [ChinookDWSSIS].[dbo].[DimCustomer] as target
USING [ChinookStagingSSIS].[dbo].[Staging_DimCustomer] as source
ON target.[CustomerId] = source.[CustomerId]

WHEN MATCHED  AND target.[RowIsCurrent]=1 AND (source.CustomerAddress <> target.CustomerAddress OR source.CustomerCity<>target.CustomerCity OR source.CustomerEmail<>target.CustomerEmail
OR source.CustomerCompany<>target.CustomerCompany OR source.CustomerCountry<>target.CustomerCountry OR source.[SupportBy]<>target.[SupportBy] )

THEN UPDATE SET
target.RowIsCurrent = 0,
target.RowEndDate = dateadd(day, -1, @etl_date ) ,
target.RowChangeReason = 'UPDATED NOT CURRENT'

WHEN NOT MATCHED THEN
	INSERT (CustomerId ,
    CustomerFullName ,
    CustomerCompany ,
	CustomerAddress ,
    CustomerCity ,
    [CustomerState] ,
    [CustomerCountry] ,
    [CustomerPostalCode] ,
    [CustomerFax] ,
	[CustomerEmail] ,
    [SupportBy],  RowStartDate,   RowChangeReason
	)
	VALUES(source.CustomerId, source.CustomerFullName,source.CustomerCompany, source.CustomerAddress, source.CustomerCity, source.CustomerState,
	source.CustomerCountry, source.CustomerPostalCode, source.CustomerFax, source.CustomerEmail, source.SupportBy,  @etl_date,  'NEW_RECORD' )

WHEN NOT MATCHED BY Source THEN
	UPDATE SET
	 target.RowEndDate= dateadd(day, -1, @etl_date)
	,target.RowIsCurrent = 0
	,target.RowChangeReason  = 'SOFT DELETE'
OUTPUT
	source.CustomerId, source.CustomerFullName,source.CustomerCompany, source.CustomerAddress, source.CustomerCity, source.CustomerState,
	source.CustomerCountry, source.CustomerPostalCode, source.CustomerFax, source.CustomerEmail, source.SupportBy,$Action as ActionNameCustomer
	

) as MrgCust
WHERE MrgCust.ActionNameCustomer = 'UPDATE' AND [CustomerId] IS NOT NULL;




DROP TABLE IF EXISTS [ChinookStagingSSIS].[dbo].[Staging_DimTrack];

CREATE TABLE Staging_DimTrack( 
	TrackKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	TrackId INT NOT NULL,
	[TrackName] NVARCHAR(200) NOT NULL,
	[AlbumTitle] NVARCHAR(160) NOT NULL,
	[ArtistName] NVARCHAR(120) NOT NULL,
	[MediaTypeName] NVARCHAR(120) NOT NULL,
	[GenreName] NVARCHAR(120) NOT NULL,
	[Composer] NVARCHAR(220) NOT NULL,
	[Milliseconds] INT NOT NULL,
	[Bytes] INT NOT NULL,
	--[PlayListName] NVARCHAR(120) NOT NULL, -- Must configure many-to-many relationship . Star schema does not allow this, instead we need snowflake.
	RowIsCurrent INT DEFAULT 1 NOT NULL,
    RowStartDate DATE DEFAULT '2009-01-01' NOT NULL,
    RowEndDate DATE DEFAULT '9999-12-31' NOT NULL,
    RowChangeReason VARCHAR(200) NULL
);




INSERT INTO [ChinookStagingSSIS].[dbo].[Staging_DimTrack] (
    [TrackID], [TrackName], [AlbumTitle], [ArtistName], [MediaTypeName], [GenreName],[Composer],[Milliseconds],[Bytes] 
)
SELECT [TrackId],[TrackName],[AlbumTitle],[ArtistName],[MediaTypeName],[GenreName],COALESCE([Composer],'N/A'),[Milliseconds],[Bytes]
-- PlayListName 

FROM [ChinookStagingSSIS].[dbo].[Track]

/*
INNER JOIN Chinook.[dbo].[Album] a ON a.AlbumId = t.AlbumId 
INNER JOIN Chinook.[dbo].[Artist] artist ON artist.ArtistId = a.ArtistId

INNER JOIN [Chinook].[dbo].[MediaType] mt ON mt.MediaTypeId=t.MediaTypeId

INNER JOIN [Chinook].[dbo].[Genre] g ON g.GenreId = t.GenreId 


INNER JOIN Chinook.[dbo].[PlaylistTrack] plt ON plt.TrackId = t.TrackId
INNER JOIN [Chinook].[dbo].[Playlist] p ON p.PlaylistId = plt.PlaylistId ;
*/

/* Update - Insert - Delete rows in DimTrack*/


INSERT INTO [ChinookDWSSIS].[dbo].[DimTrack](
	[TrackID], [TrackName], [AlbumTitle], [ArtistName], [MediaTypeName], [GenreName],[Composer],[Milliseconds],[Bytes], RowStartDate, RowChangeReason
)
SELECT
	[TrackID], [TrackName], [AlbumTitle], [ArtistName], [MediaTypeName], [GenreName],[Composer],[Milliseconds],[Bytes] ,  @etl_date	  , ActionNameTrack

FROM(

MERGE [ChinookDWSSIS].[dbo].[DimTrack] as target
USING [ChinookStagingSSIS].[dbo].[Staging_DimTrack] as source
ON target.[TrackId] = source.[TrackId]

WHEN MATCHED  AND target.[RowIsCurrent]=1 
/*AND (source.CustomerAddress <> target.CustomerAddress OR source.CustomerCity<>target.CustomerCity OR source.CustomerEmail<>target.CustomerEmail
OR source.CustomerCompany<>target.CustomerCompany OR source.CustomerCountry<>target.CustomerCountry OR source.[SupportBy]<>target.[SupportBy] )*/

THEN UPDATE SET
target.RowIsCurrent = 0,
target.RowEndDate = dateadd(day, -1, @etl_date ) ,
target.RowChangeReason = 'UPDATED NOT CURRENT'

WHEN NOT MATCHED THEN
	INSERT ([TrackID], [TrackName], [AlbumTitle], [ArtistName], [MediaTypeName], [GenreName],[Composer],[Milliseconds],[Bytes] ,  RowStartDate,   RowChangeReason
	)
	VALUES(source.TrackId, source.TrackName,source.AlbumTitle, source.ArtistName, source.MediaTypeName, source.GenreName,
	source.Composer, source.Milliseconds, source.Bytes,  @etl_date,  'NEW_RECORD' )

WHEN NOT MATCHED BY Source THEN
	UPDATE SET
	 target.RowEndDate= dateadd(day, -1, @etl_date)
	,target.RowIsCurrent = 0
	,target.RowChangeReason  = 'SOFT DELETE'
OUTPUT
	source.TrackId, source.TrackName,source.AlbumTitle, source.ArtistName, source.MediaTypeName, source.GenreName,
	source.Composer, source.Milliseconds, source.Bytes,$Action as ActionNameTrack
	

) as MrgTrack
WHERE MrgTrack.ActionNameTrack = 'UPDATE' AND [TrackId] IS NOT NULL;

/* Insert New Facts */

INSERT INTO [ChinookDWSSIS].[dbo].FactSales(
[TrackKey],[EmployeeKey],[CustomerKey],[InvoiceDateKey],[InvoiceID],[UnitPrice],[Quantity],[PartialAmount]
)
SELECT  t.[TrackKey] , e.[EmployeeKey], c.[CustomerKey], 
CAST(FORMAT([InvoiceDate],'yyyyMMdd') AS INT), 
[InvoiceID], [UnitPrice], [Quantity], [UnitPrice]*[Quantity]

FROM ChinookStagingSSIS.dbo.Sales s
INNER JOIN  ChinookDWSSIS.dbo.DimTrack t ON s.TrackId = t.TrackId AND t.RowIsCurrent=1
INNER JOIN ChinookDWSSIS.dbo.DimEmployee e ON e.EmployeeId=s.EmployeeId AND e.RowIsCurrent=1
INNER JOIN ChinookDWSSIS.dbo.DimCustomer c ON c.CustomerId = s.CustomerId AND c.RowIsCurrent=1



/* !!! DON'T FORGET TO MAKE RELATIONSHIPS AGAIN IN DATA WAREHOUSE !!! */
