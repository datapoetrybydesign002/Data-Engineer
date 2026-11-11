USE master

/*#####################################################################################*/

-- Check if database exists and create if it doesn't
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'EarlyON')
BEGIN
    CREATE DATABASE EarlyON;
    PRINT 'Database EarlyON created successfully.';
END
ELSE
BEGIN
    PRINT 'Database EarlyON already exists.';
END
GO

/*#####################################################################################*/

USE EarlyON_v2;
GO

-- Create tables

/***************************************************************************************
Province
****************************************************************************************/

--DROP TABLE dbo.Province
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Province') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Province (
        ID INT IDENTITY(1,1) NOT NULL,
        Province VARCHAR(300),
        ProvinceCode VARCHAR(300),
        CreatedDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_Province PRIMARY KEY CLUSTERED (ID)
       
    );
  END

  SELECT * FROM dbo.Province


/***************************************************************************************
Service Manager
****************************************************************************************/
--DROP TABLE dbo.Source_ServiceManager
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_ServiceManager') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_ServiceManager (
        ID INT IDENTITY(1,1) NOT NULL,
        ServiceManager VARCHAR(300),
        ProvinceID  INT,
        CreatedBy VARCHAR(300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()       
    );
  END


 --DROP TABLE dbo.ServiceManager
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ServiceManager') AND type = N'U')
BEGIN
    CREATE TABLE dbo.ServiceManager (
        ID INT IDENTITY(1,1) NOT NULL,
        ServiceManager VARCHAR(300) NOT NULL,
        ProvinceID  INT,
        CreatedBy VARCHAR(300) NOT NULL CONSTRAINT DF_ServiceManager_CreatedBy DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_ServiceManager_CreatedDate DEFAULT GETDATE(),
        CONSTRAINT PK_ServiceManager PRIMARY KEY CLUSTERED (ID),
        --CONSTRAINT FK_ServiceManager_Province FOREIGN KEY (ProvinceID) 
        --    REFERENCES dbo.Province(ID)
    );
  END

  -- Create indexes
    CREATE INDEX IX_ServiceManager_ServiceManager 
        ON dbo.ServiceManager(ServiceManager);


-- Delete duplicates from source data
  WITH Duplicates AS (
    SELECT 
        ID,
        ServiceManager,
        ROW_NUMBER() OVER (PARTITION BY ServiceManager ORDER BY ID) AS RowNum
    FROM dbo.Source_ServiceManager
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO


-- Load Target Table Data
CREATE PROCEDURE dbo.load_target_table_ServiceManager AS
MERGE dbo.ServiceManager AS TARGET
USING dbo.Source_ServiceManager AS SOURCE
    ON TARGET.ServiceManager = SOURCE.ServiceManager
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ServiceManager, ProvinceID)
    VALUES (SOURCE.ServiceManager, SOURCE.ProvinceID);
GO

SELECT * from dbo.Source_ServiceManager
SELECT * from dbo.ServiceManager

/***************************************************************************************
City
****************************************************************************************/
--DROP TABLE dbo.Source_City
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_City') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_City (
        ID INT IDENTITY(1,1),
        City VARCHAR(300),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()       
    );
  END


   --DROP TABLE dbo.City
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.City') AND type = N'U')
BEGIN
    CREATE TABLE dbo.City (
        ID INT IDENTITY(1,1),
        City VARCHAR(300) NOT NULL,
        CreatedBy VARCHAR(300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_City_CreatedDate DEFAULT GETDATE(),
        CONSTRAINT PK_City PRIMARY KEY (ID)
    );
  END

  -- Create indexes
    CREATE INDEX IX_City_City 
        ON dbo.City(City);


  TRUNCATE TABLE dbo.Source_City
    TRUNCATE TABLE dbo.City

  SELECT * FROM dbo.Source_City
  SELECT * FROM dbo.City

  UPDATE dbo.Source_City
    SET City = 
        CASE
            WHEN City = 'City of St. Catherines' THEN 'City of St. Catharines'
        END
    WHERE City = 'City of St. Catherines'


-- Delete duplicates from source data
  WITH Duplicates AS (
    SELECT 
        ID,
        City,
        ROW_NUMBER() OVER (PARTITION BY City ORDER BY ID) AS RowNum
    FROM dbo.Source_City
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO



-- Load Target Table Data
CREATE PROCEDURE dbo.load_target_table_city AS
MERGE dbo.City AS TARGET
USING Source_City AS SOURCE
    ON TARGET.City = SOURCE.City
WHEN NOT MATCHED BY TARGET THEN
    INSERT (City)
    VALUES (SOURCE.City);

    select * from dbo.City


    
/***************************************************************************************
Location
****************************************************************************************/
--DROP TABLE dbo.Source_Location
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_Location') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_Location (
        ID INT IDENTITY(1,1),
        [Location] VARCHAR(300),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()       
    );
  END


--DROP TABLE dbo.Location
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Location') AND type = N'U')
BEGIN
    CREATE TABLE dbo.[Location] (
        ID INT IDENTITY(1,1),
        [Location] VARCHAR(300) NOT NULL,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_Location_CreatedDate DEFAULT GETDATE(),
        CONSTRAINT PK_Location PRIMARY KEY (ID)
    );
  END




  SELECT 
  * 
  FROM dbo.Source_Location
  where Location = 'family centre carling-thames'

  UPDATE dbo.Source_Location
    SET Location = 
        CASE 
            WHEN [Location] = 'E3 Community services' THEN 'E3 Community Services'
            WHEN [Location] = 'Family Centre Carling-Thames' THEN 'Family Centre Carling Thamess'
        ELSE [Location]
        END
            WHERE [Location] = 'E3 Community services'
             OR [Location] = 'Family Centre Carling-Thames'
    

  WITH Duplicates AS (
    SELECT 
        ID,
        [Location],
        ROW_NUMBER() OVER (PARTITION BY [Location] ORDER BY ID) AS RowNum
    FROM dbo.Source_Location
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO

CREATE PROCEDURE dbo.load_target_table_location AS
MERGE dbo.[Location] AS TARGET
USING Source_Location AS SOURCE
    ON TARGET.[Location] = SOURCE.[Location]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Location])
    VALUES (SOURCE.[Location]);


truncate table dbo.[Location]
select * from dbo.Source_Location
select * from dbo.[Location]


/***************************************************************************************
Address
****************************************************************************************/
--DROP TABLE dbo.Source_Address
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_Address') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_Address (
        ID INT IDENTITY(1,1),
        [Address] VARCHAR(800),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()       
    );
  END


    WITH Duplicates AS (
    SELECT 
        ID,
        [Address],
        ROW_NUMBER() OVER (PARTITION BY [Address] ORDER BY ID) AS RowNum
    FROM dbo.Source_Address
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO


--DROP TABLE dbo.Address
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Address') AND type = N'U')
BEGIN
    CREATE TABLE dbo.[Address] (
        ID INT IDENTITY(1,1),
        [Address] VARCHAR(800) NOT NULL,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_Address_CreatedDate DEFAULT GETDATE(),
        CONSTRAINT PK_Address PRIMARY KEY (ID)
    );
  END

 CREATE PROCEDURE dbo.load_target_table_address AS
 MERGE dbo.[Address] AS TARGET
    USING Source_Address AS SOURCE
        ON TARGET.[Address] = SOURCE.[Address]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([Address])
        VALUES (SOURCE.[Address]);


  select * from dbo.Source_Address
  select * from dbo.[Address]

/***************************************************************************************
Postal Code
****************************************************************************************/
--DROP TABLE dbo.Source_PostalCode
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_PostalCode') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_PostalCode (
        ID INT IDENTITY(1,1),
        [PostalCode] VARCHAR(800),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()       
    );
  END


  WITH Duplicates AS (
    SELECT 
        ID,
        [PostalCode],
        ROW_NUMBER() OVER (PARTITION BY [PostalCode] ORDER BY ID) AS RowNum
    FROM dbo.Source_PostalCode
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO


--DROP TABLE dbo.PostalCode
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.PostalCode') AND type = N'U')
BEGIN
    CREATE TABLE dbo.[PostalCode] (
        ID INT IDENTITY(1,1),
        [PostalCode] VARCHAR(300) NOT NULL,
        Latitude DECIMAL(10,6),
        Longitude DECIMAL(10,6),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_PostalCode_CreatedDate DEFAULT GETDATE(),
        CONSTRAINT PK_PostalCode PRIMARY KEY (ID)
    );
  END


  CREATE PROCEDURE dbo.load_target_table_postalcode AS
  MERGE dbo.[PostalCode] AS TARGET
    USING Source_PostalCode AS SOURCE
        ON TARGET.[PostalCode] = SOURCE.[PostalCode]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([PostalCode])
        VALUES (SOURCE.[PostalCode]);



  SELECT * FROM dbo.Source_PostalCode
  SELECT * FROM dbo.PostalCode 


/***************************************************************************************
Creating Bridge Tables
****************************************************************************************/

-------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE dbo.Source_CityManager
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_CityManager') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_CityManager (
        ID INT IDENTITY(1,1),
        ServiceManagerID INT,
        ServiceManager VARCHAR(300),
        CityID INT,
        City VARCHAR(300),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()
    );
  END


--DROP TABLE dbo.CityManager
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CityManager') AND type = N'U')
BEGIN
    CREATE TABLE dbo.CityManager (
        ID INT IDENTITY(1,1),
        ServiceManagerID INT,
        CityID INT,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_City_Manager PRIMARY KEY CLUSTERED (ID)
        --CONSTRAINT FK_City_Manager FOREIGN KEY (CityID) REFERENCES dbo.City(ID),
        --CONSTRAINT FK_Manager_City FOREIGN KEY (ServiceManagerID) REFERENCES dbo.ServiceManager(ID)
    );
  END


CREATE PROCEDURE dbo.delete_duplicates_source_citymanager_servicemanager AS
WITH Duplicates AS (
    SELECT 
        ID,
        City
        ServiceManager,
        ROW_NUMBER() OVER (PARTITION BY ServiceManager, City ORDER BY ID) AS RowNum
    FROM dbo.Source_CityManager
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO


CREATE PROCEDURE dbo.mapid_servicemanager_source_citymanager AS
UPDATE A
SET A.ServiceManagerID = B.ID
FROM dbo.Source_CityManager A
INNER JOIN dbo.ServiceManager B ON B.ServiceManager = A.ServiceManager
WHERE A.ServiceManager IS NOT NULL


CREATE PROCEDURE dbo.mapid_city_source_citymanager AS
UPDATE A
SET A.CityID = B.ID
FROM dbo.Source_CityManager A
INNER JOIN dbo.City B ON B.City = A.City
WHERE A.City IS NOT NULL


DELETE dbo.Source_CityManager WHERE CityID IS NULL


CREATE PROCEDURE dbo.load_target_citymanager AS
  MERGE dbo.CityManager AS TARGET
USING dbo.Source_CityManager AS SOURCE
    ON TARGET.ServiceManagerID = SOURCE.ServiceManagerID
   AND TARGET.CityID = SOURCE.CityID
   AND SOURCE.CityID IS NOT NULL
   AND SOURCE.ServiceManagerID IS NOT NULL
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ServiceManagerID, CityID)
    VALUES (SOURCE.ServiceManagerID, SOURCE.CityID);


select * from dbo.Source_CityManager where CityID is null
truncate table dbo.CityManager
select * from dbo.CityManager

-------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE dbo.Source_CityLocation
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_CityLocation') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_CityLocation (
        ID INT IDENTITY(1,1),
        CityID INT,
        City VARCHAR(300),
        LocationID INT,
        [Location] VARCHAR(300),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()
    );
END


CREATE PROCEDURE dbo.delete_duplicates_source_cityLocation_city AS
 WITH Duplicates AS (
    SELECT 
        ID,  
        [Location],
        City,
        ROW_NUMBER() OVER (PARTITION BY [Location], City ORDER BY ID) AS RowNum
    FROM dbo.Source_CityLocation
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO



CREATE PROCEDURE dbo.mapid_source_cityLocation_location AS
UPDATE A
SET A.LocationID = B.ID
FROM dbo.Source_CityLocation A
INNER JOIN dbo.Location B ON B.[Location] = A.[Location]
WHERE A.[Location] IS NOT NULL

CREATE PROCEDURE dbo.mapid_source_cityLocation_city AS
UPDATE A
SET A.CityID = B.ID
FROM dbo.Source_CityLocation A
INNER JOIN dbo.City B ON B.City = A.City
WHERE A.City IS NOT NULL



--DROP TABLE dbo.CityLocation
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.CityLocation') AND type = N'U')
BEGIN
    CREATE TABLE dbo.CityLocation (
        ID INT IDENTITY(1,1),
        CityID INT,       
        LocationID INT,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_City_Location PRIMARY KEY CLUSTERED (ID),
        --CONSTRAINT FK_City_Location FOREIGN KEY (CityID) REFERENCES dbo.City(ID),
        --CONSTRAINT FK_Location_City FOREIGN KEY (LocationID) REFERENCES dbo.[Location](ID)
    );
  END

  CREATE PROCEDURE dbo.load_target_citylocation AS
      MERGE dbo.CityLocation AS TARGET
    USING dbo.Source_CityLocation AS SOURCE
        ON TARGET.CityID = SOURCE.CityID
       AND TARGET.LocationID = SOURCE.LocationID
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CityID, LocationID)
        VALUES (SOURCE.CityID, SOURCE.LocationID);



SELECT * FROM dbo.Source_CityLocation
truncate table dbo.CityLocation
SELECT * FROM dbo.CityLocation

-------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE dbo.Source_LocationAddress
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_LocationAddress') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_LocationAddress (
        ID INT IDENTITY(1,1),
        LocationID INT,
        [Location] VARCHAR(300),
        AddressID INT,
        [Address] VARCHAR(800),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()
    );
END


CREATE PROCEDURE dbo.delete_duplicates_source_locationaddress_address AS
 WITH Duplicates AS (
    SELECT 
        ID,  
        [Location],
        [Address],
        ROW_NUMBER() OVER (PARTITION BY [Location], [Address] ORDER BY ID) AS RowNum
    FROM dbo.Source_LocationAddress
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO


CREATE PROCEDURE dbo.mapid_source_locationaddress_location AS
UPDATE A
SET A.LocationID = B.ID
FROM dbo.Source_LocationAddress A
INNER JOIN dbo.[Location] B ON B.[Location] = A.[Location]
WHERE A.[Location] IS NOT NULL

CREATE PROCEDURE dbo.mapid_source_locationaddress_address AS
UPDATE A
SET A.AddressID = B.ID
FROM dbo.Source_LocationAddress A
INNER JOIN dbo.[Address] B ON B.[Address] = A.[Address]
WHERE A.[Address] IS NOT NULL


DELETE dbo.Source_LocationAddress WHERE LocationID IS NULL

DELETE dbo.Source_LocationAddress WHERE AddressID IS NULL


--DROP TABLE dbo.LocationAddress
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.LocationAddress') AND type = N'U')
BEGIN
    CREATE TABLE dbo.LocationAddress (
        ID INT IDENTITY(1,1),
        LocationID INT,       
        AddressID INT,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_Location_Address PRIMARY KEY CLUSTERED (ID),
        --CONSTRAINT FK_Location_Address FOREIGN KEY (LocationID) REFERENCES dbo.Location(ID),
        --CONSTRAINT FK_Address_Location FOREIGN KEY (AddressID) REFERENCES dbo.[Address](ID)
    );
  END



  CREATE PROCEDURE dbo.load_target_locationaddress AS
  MERGE dbo.LocationAddress AS TARGET
USING dbo.Source_LocationAddress AS SOURCE
    ON TARGET.LocationID = SOURCE.LocationID
   AND TARGET.AddressID = SOURCE.AddressID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (LocationID, AddressID)
    VALUES (SOURCE.LocationID, SOURCE.AddressID);



select *  from dbo.Source_LocationAddress
select *  from dbo.LocationAddress

-------------------------------------------------------------------------------------------------------------------------------------------
--DROP TABLE dbo.Source_AddressPostalCode
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.Source_AddressPostalCode') AND type = N'U')
BEGIN
    CREATE TABLE dbo.Source_AddressPostalCode (
        ID INT IDENTITY(1,1),
        AddressID INT,
        [Address] VARCHAR(800),
        PostalCodeID INT,
        PostalCode VARCHAR(300),
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE()
    );
END


CREATE PROCEDURE dbo.delete_duplicates_source_addresspostalcode_postalcode AS
 WITH Duplicates AS (
    SELECT 
        ID,  
        [Address],
        PostalCode,
        ROW_NUMBER() OVER (PARTITION BY [Address], PostalCode ORDER BY ID) AS RowNum
    FROM dbo.Source_AddressPostalCode
)
DELETE FROM Duplicates
WHERE RowNum > 1;
GO



CREATE PROCEDURE dbo.mapid_source_addresspostalcode_address AS
    UPDATE A
    SET A.AddressID = B.ID
    FROM dbo.Source_AddressPostalCode A
    INNER JOIN dbo.[Address] B ON B.[Address] = A.[Address]
    WHERE A.[Address] IS NOT NULL


CREATE PROCEDURE dbo.mapid_source_addresspostalcode_postalcode AS
    UPDATE A
    SET A.PostalCodeID = B.ID
    FROM dbo.Source_AddressPostalCode A
    INNER JOIN dbo.PostalCode B ON B.PostalCode = A.PostalCode
    WHERE A.PostalCode IS NOT NULL

--DROP TABLE dbo.AddressPostalCode
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AddressPostalCode') AND type = N'U')
BEGIN
    CREATE TABLE dbo.AddressPostalCode (
        ID INT IDENTITY(1,1),      
        AddressID INT,
        PostalCodeID INT,
        CreatedBy VARCHAR (300) DEFAULT SUSER_SNAME(),
        CreatedDate DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT PK_Address_PostalCode PRIMARY KEY CLUSTERED (ID),
        --CONSTRAINT FK_Address_PostalCode FOREIGN KEY (PostalCodeID) REFERENCES dbo.PostalCode(ID),
        --CONSTRAINT FK_PostalCode_Address FOREIGN KEY (AddressID) REFERENCES dbo.[Address](ID)
    );
  END

 CREATE PROCEDURE dbo.load_target_addresspostalcode AS
  MERGE dbo.AddressPostalCode AS TARGET
USING dbo.Source_AddressPostalCode AS SOURCE
    ON TARGET.AddressID = SOURCE.AddressID
   AND TARGET.PostalCodeID = SOURCE.PostalCodeID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (AddressID, PostalCodeID)
    VALUES (SOURCE.AddressID, SOURCE.PostalCodeID);


truncate table dbo.AddressPostalCode

select * from dbo.Source_AddressPostalCode
select * from dbo.AddressPostalCode

-------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.OntarioLocations') AND type = N'U')
BEGIN
    CREATE TABLE dbo.OntarioLocations (
        -- Surrogate key
        ID INT IDENTITY(1,1) NOT NULL,
        
        -- Province information
        ProvinceID INT NULL,
        Province VARCHAR(300) NULL,
        ProvinceCode VARCHAR(300) NULL,
        
        -- Service Manager information
        ServiceManagerID INT NULL,
        ServiceManager VARCHAR(300) NULL,
        
        -- City information
        CityID INT NULL,
        City VARCHAR(300) NULL,
        
        -- Location information
        LocationID INT NULL,
        [Location] VARCHAR(300) NULL,
        
        -- Address information
        AddressID INT NULL,
        [Address] VARCHAR(800) NULL,
        
        -- Postal Code information
        PostalCodeID INT NULL,
        PostalCode VARCHAR(20) NULL,  
        Longitude DECIMAL(10, 6) NULL,  
        Latitude DECIMAL(10, 6) NULL,   
        
        Geometry geography NULL,
        
        CreatedDate DATETIME2 NOT NULL CONSTRAINT DF_OntarioLocations_CreatedDate DEFAULT GETDATE(),
        ModifiedDate DATETIME2 NULL,

        CONSTRAINT PK_OntarioLocations PRIMARY KEY CLUSTERED (ID)
    );
    
END


-- Drop existing index
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'SIndx_OntarioLocations_Geometry' AND object_id = OBJECT_ID('dbo.OntarioLocations'))
    DROP INDEX SIndx_OntarioLocations_Geometry ON dbo.OntarioLocations;
GO

-- Simple spatial index creation
CREATE SPATIAL INDEX SIndx_OntarioLocations_Geometry 
ON dbo.OntarioLocations(Geometry);
GO




select * from dbo.OntarioLocations

