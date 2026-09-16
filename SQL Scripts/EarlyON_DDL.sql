/**********************************************************************************
Project Name: EarlyON
Created Date: 2026-07-30
Created By: Victor Mazariegos; Wyman Ma
Description: Contains DDL for all the tables realated to the EarlyON dataset

Tables: 
====================================================================================
-- 1)   dbo.Province - Hugo
        dbo.Source_Province 
-- 2)   dbo.ServiceManager - Wyman
        dbo.Source_ServiceManager
-- 3)   dbo.CityManager - Hugo
        dbo.Source_CityManager        
-- 4)   dbo.City - Wyman
        dbo.Source_City
-- 5)   dbo.Municipality - Hugo
        dbo.Source_Municipality
-- 6)   dbo.CityLocation - Wyman
        dbo.Source_CityLocation
-- 7)   dbo.Location - Hugo
        dbo.Source_Location
-- 8)   dbo.LocationAddress - Wyman
        dbo.Source_LocationAddress
-- 9)   dbo.Address - Hugo
        dbo.Source_Address
-- 10)  dbo.AddressPostalCode - Wyman
        dbo.Source_AddressPostalCode
-- 11)  dbo.PostalCode - Hugo & Wyman
        dbo.Source_PostalCode
************************************************************************************/
USE EarlyON_v2

/***************************************************************************************
PROVINCE
***************************************************************************************/


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

-- dbo.Source_Province

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_Province]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_Province];   
END

BEGIN
    CREATE TABLE [dbo].[Source_Province] (
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
        CONSTRAINT PK_Source_Province_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END


TRUNCATE TABLE [EarlyON_v2].[dbo].[Source_Province]

SELECT * FROM [EarlyON_v2].[dbo].[Source_Province]
SELECT * FROM [EarlyON_v2].[dbo].[Province]


-- MERGE

MERGE [dbo].[Province] AS TARGET
USING [dbo].[Source_Province] AS SOURCE
    ON TARGET.[ID] = SOURCE.[ID] 
WHEN MATCHED 
    THEN UPDATE SET
        TARGET.[Province]       = SOURCE.[Province],
        TARGET.[ProvinceCode]   = SOURCE.[ProvinceCode],
        TARGET.[ModifiedDateTime] = GETDATE(),
        TARGET.[ModifiedBy]       = SUSER_SNAME()
WHEN NOT MATCHED BY TARGET
    THEN INSERT (
        [Province],
        [ProvinceCode],
        [CreatedDateTime],
        [CreatedBy],
        [ModifiedDateTime],
        [ModifiedBy]
    )
    VALUES (
        SOURCE.[Province],
        SOURCE.[ProvinceCode],
        GETDATE(),
        SUSER_SNAME(),
        GETDATE(),
        SUSER_SNAME()
    );

/***************************************************************************************
SERVICE MANAGER
***************************************************************************************/

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

-- Source_ServiceManager

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_ServiceManager]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_ServiceManager];    
END

BEGIN
    CREATE TABLE [dbo].[Source_ServiceManager] (
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
        CONSTRAINT PK_Source_ServiceManager_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_CityManager

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_CityManager]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_CityManager];    
END

BEGIN
    CREATE TABLE [dbo].[Source_CityManager] (
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
        CONSTRAINT PK_Source_City_Manager_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_City

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_City]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_City];    
END

BEGIN
    CREATE TABLE [dbo].[Source_City] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [City] VARCHAR(300) NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Source_City_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_Municipality
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_Municipality]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_Municipality];    
END

BEGIN
    CREATE TABLE [dbo].[Source_Municipality] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Municipality] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Source_Municipality_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_CityLocation
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_CityLocation]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_CityLocation];    
END

BEGIN
    CREATE TABLE [dbo].[Source_CityLocation] (
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
        CONSTRAINT PK_Source_City_Location_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_Location
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_Location]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_Location];    
END

BEGIN
    CREATE TABLE [dbo].[Source_Location] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Location] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Source_Location_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_LocationAddress
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_LocationAddress]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_LocationAddress];    
END

BEGIN
    CREATE TABLE [dbo].[Source_LocationAddress] (
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
        CONSTRAINT PK_Source_Location_Address_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_Address
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_Address]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_Address];    
END

BEGIN
    CREATE TABLE [dbo].[Source_Address] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Address] VARCHAR(300) NULL,       

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Source_Address_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_AddressPostalCode
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_AddressPostalCode]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_AddressPostalCode];    
END

BEGIN
    CREATE TABLE [dbo].[Source_AddressPostalCode] (
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
        CONSTRAINT PK_Source_Address_PostalCode_ID PRIMARY KEY CLUSTERED ([ID] ASC)
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

-- Source_PostalCode
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Source_PostalCode]') AND type in (N'U'))
BEGIN
    DROP TABLE [dbo].[Source_PostalCode];    
END

BEGIN
    CREATE TABLE [dbo].[Source_PostalCode] (
        -- Primary key with IDENTITY (auto-increment by 1)
        [ID] INT IDENTITY(1,1) NOT NULL,
        [PostalCode] VARCHAR(300) NULL,

        -- Audit columns with SQL Server predefined values
        [CreatedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [CreatedBy] VARCHAR(300) NOT NULL DEFAULT SUSER_SNAME(),
        [ModifiedDateTime] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [ModifiedBy] VARCHAR(128) NOT NULL DEFAULT SUSER_SNAME(),
        
        -- PRIMARY KEY constraint defined at the end
        CONSTRAINT PK_Source_PostalCode_ID PRIMARY KEY CLUSTERED ([ID] ASC)
    );    
END