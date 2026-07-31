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
-- 3)  dbo.CityManager - Hugo
-- 4)  dbo.City - Wyman
-- 5)  dbo.Municipality - Hugo
-- 6)  dbo.CityLocation - Wyman
-- 7)  dbo.Location - Hugo
-- 8)  dbo.LocationAddress - Wyman
-- 9)  dbo.Address - Hugo
-- 10) dbo.AddressPostalCode - Wyman
-- 11) dbo.PostalCode - Hugo & Wyman