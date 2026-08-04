/**********************************************************************************
Project Name: EarlyON
Created Date: 2026-07-30
Created By: Victor Mazariegos; Wyman Ma
Description: Contains DDL for all the tables realated to the EarlyON dataset

Tables: 
====================================================================================
-- 1)  dbo.Province - Hugo
-- 2)  dbo.ServiceManager - Wyman
-- 3)  dbo.CityManager - Hugo
-- 4)  dbo.City - Wyman
-- 5)  dbo.Municipality - Hugo
-- 6)  dbo.CityLocation - Wyman
-- 7)  dbo.Location - Hugo
-- 8)  dbo.LocationAddress - Wyman
-- 9)  dbo.Address - Hugo
-- 10) dbo.AddressPostalCode - Wyman
-- 11) dbo.PostalCode - Hugo & Wyman
************************************************************************************/

-- 1) dbo.Province - Hugo

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Province]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Province];    
END

BEGIN
    CREATE TABLE [dbo].[Province] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Province] VARCHAR(300) NULL,
        [ProvinceCode] VARCHAR(2) NULL,
        
        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Province_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END


-- 2)  dbo.ServiceManager - Wyman

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ServiceManager]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[ServiceManager];    
END

BEGIN
    CREATE TABLE [dbo].[ServiceManager] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Service_Manager] VARCHAR(300) NULL,
        [ProvinceID] INT NULL,
        
        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_ServiceManager_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END


-- 3)  dbo.CityManager - Hugo
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CityManager]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[CityManager];    
END

BEGIN
    CREATE TABLE [dbo].[CityManager] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [ServiceManagerID] INT NULL,
        [CityID] INT NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_City_Manager_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END




-- 4)  dbo.City - Wyman
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[City]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[City];    
END

BEGIN
    CREATE TABLE [dbo].[City] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [City] VARCHAR(300) NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_City_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END

-- 5)  dbo.Municipality - Hugo
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Municipality]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Municipality];    
END

BEGIN
    CREATE TABLE [dbo].[Municipality] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Municipality] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Municipality_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END


-- 6)  dbo.CityLocation - Wyman
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CityLocation]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[CityLocation];    
END

BEGIN
    CREATE TABLE [dbo].[CityLocation] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [CityID] INT NULL,
        [LocationID] INT NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_City_Location_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END

-- 7)  dbo.Location - Hugo
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Location]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Location];    
END

BEGIN
    CREATE TABLE [dbo].[Location] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Location] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Location_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END


-- 8)  dbo.LocationAddress - Wyman
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LocationAddress]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[LocationAddress];    
END

BEGIN
    CREATE TABLE [dbo].[LocationAddress] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [locationID] INT NULL,
        [AddressID] INT NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Location_Address_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END

-- 9)  dbo.Address - Hugo
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Address]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Address];    
END

BEGIN
    CREATE TABLE [dbo].[Address] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Address] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Address_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END

-- 10) dbo.AddressPostalCode - Wyman
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddressPostalCode]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[AddressPostalCode];    
END

BEGIN
    CREATE TABLE [dbo].[AddressPostalCode] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [AddressID] INT NULL,
        [PostalCodeID] INT NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Address_PostalCode_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END

-- 11) dbo.PostalCode - Hugo & Wyman
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PostalCode]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[PostalCode];    
END

BEGIN
    CREATE TABLE [dbo].[PostalCode] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [PostalCode] VARCHAR(300) NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_PostalCode_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END