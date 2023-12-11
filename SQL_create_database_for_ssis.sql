USE master
GO
if exists (select * from sysdatabases where name='ChinookStagingSSIS')
		alter database ChinookStagingSSIS set single_user with rollback immediate
		drop database ChinookStagingSSIS
go

CREATE DATABASE ChinookStagingSSIS
GO
USE ChinookStagingSSIS 
Go

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------
CREATE TABLE [dbo].[Customer](
	[CustomerId] [int] NULL,
	[FirstName] [nvarchar](40) NULL,
	[LastName] [nvarchar](20) NULL,
	[Company] [nvarchar](80) NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
	[Email] [nvarchar](60) NULL,
	[SupportRepId] [int] NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Employee](
	[EmployeeId] [int] NULL,
	[LastName] [nvarchar](20) NULL,
	[FirstName] [nvarchar](20) NULL,
	[Title] [nvarchar](30) NULL,
	[ReportsTo] [int] NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Address] [nvarchar](70) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](40) NULL,
	[Country] [nvarchar](40) NULL,
	[PostalCode] [nvarchar](10) NULL,
	[Phone] [nvarchar](24) NULL,
	[Fax] [nvarchar](24) NULL,
	[Email] [nvarchar](60) NULL
) ON [PRIMARY]
GO


CREATE TABLE [dbo].[Track](
	[TrackId] [int] NULL,
	[TrackName] [nvarchar](200) NULL,
	[MediaTypeName] [nvarchar](120) NULL,
	[GenreName] [nvarchar](120) NULL,
	[Composer] [nvarchar](220) NULL,
	[Milliseconds] [int] NULL,
	[Bytes] [int] NULL,
	[AlbumTitle] [nvarchar](160) NULL,
	[ArtistName] [nvarchar](120) NULL,
	[PlaylistName] [nvarchar](120) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Sales](
	[InvoiceId] [int] NULL,
	[CustomerId] [int] NULL,
	[InvoiceDate] [datetime] NULL,
	[UnitPrice] [numeric](10, 2) NULL,
	[Quantity] [int] NULL,
	[TrackId] [int] NULL,
	[EmployeeId] [int] NULL
) ON [PRIMARY]
GO

