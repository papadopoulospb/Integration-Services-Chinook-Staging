Use master
GO
if exists (select * from sysdatabases where name='ChinookDWSSIS')
		alter database ChinookDWSSIS set single_user with rollback immediate
		drop database ChinookDWSSIS
go

CREATE DATABASE ChinookDWSSIS
GO

USE ChinookDWSSIS
go


/*Delete tables if exist*/
DROP TABLE IF EXISTS DimEmployee;
DROP TABLE IF EXISTS DimCustomer;
DROP TABLE IF EXISTS DimTrack;
DROP TABLE IF EXISTS FactSales;
DROP TABLE IF EXISTS DimPlaylistName;

GO
------------------------------
-- CREATE TABLE DimEmployee --
------------------------------

---- DimEmployee dimension will need to include:
CREATE TABLE DimEmployee (
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
GO


-- DimCustomer dimension will need to include:
CREATE TABLE DimCustomer(
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
GO

---- DimTrack dimension will need to include:

CREATE TABLE DimTrack( 
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
GO

--FactSales table will need to include:

CREATE TABLE FactSales(
	TrackKey INT NOT NULL,
	EmployeeKey INT NOT NULL,
	CustomerKey INT NOT NULL,
	InvoiceDateKey INT NOT NULL,
	InvoiceId INT NOT NULL,
	UnitPrice FLOAT NOT NULL,
	Quantity SMALLINT DEFAULT 0 NOT NULL,
	PartialAmount FLOAT NOT NULL
);
GO

CREATE TABLE DimPlaylistName(
TrackId INT,
PlaylistN nvarchar(120)default 'Music' not null
)