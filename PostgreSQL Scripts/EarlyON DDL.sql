-- =====================================================================================
-- 1. CREATE DATABASE
-- =====================================================================================
-- Note: In PostgreSQL, you cannot create a database and switch to it in the same script 
-- block easily. If the database doesn't exist, it's best to create it first via pgAdmin 
-- GUI (Right-click Databases -> Create), then run the rest of this script inside it.

-- If you want to run this in pgAdmin Query Tool (connected to the 'postgres' db), 
-- you can uncomment these lines to create it:
-- CREATE DATABASE EarlyON_v2;
-- PRINT 'Database EarlyON_v2 created successfully.';

-- =====================================================================================
-- 2. CREATE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Province
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Province CASCADE;

CREATE TABLE Province (
    ID SERIAL PRIMARY KEY,
    Province VARCHAR(300),
    ProvinceCode VARCHAR(300),
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- -------------------------------------------------------------------------------------
-- Service Manager
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_ServiceManager CASCADE;
CREATE TABLE Source_ServiceManager (
    ID SERIAL PRIMARY KEY,
    ServiceManager VARCHAR(300),
    ProvinceID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS ServiceManager CASCADE;
CREATE TABLE ServiceManager (
    ID SERIAL PRIMARY KEY,
    ServiceManager VARCHAR(300) NOT NULL,
    ProvinceID INT,
    CreatedBy VARCHAR(300) NOT NULL DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IX_ServiceManager_ServiceManager ON ServiceManager(ServiceManager);

-- Delete duplicates from source data
DELETE FROM Source_ServiceManager 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY ServiceManager ORDER BY ID) as rnum 
        FROM Source_ServiceManager
    ) t WHERE t.rnum > 1
);

-- Load Target Table Data using INSERT ... ON CONFLICT (Since we don't have unique constraints, we use NOT EXISTS)
INSERT INTO ServiceManager (ServiceManager, ProvinceID)
SELECT SOURCE.ServiceManager, SOURCE.ProvinceID
FROM Source_ServiceManager SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM ServiceManager TARGET WHERE TARGET.ServiceManager = SOURCE.ServiceManager
);


-- -------------------------------------------------------------------------------------
-- City
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_City CASCADE;
CREATE TABLE Source_City (
    ID SERIAL PRIMARY KEY,
    City VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS City CASCADE;
CREATE TABLE City (
    ID SERIAL PRIMARY KEY,
    City VARCHAR(300) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IX_City_City ON City(City);

TRUNCATE TABLE Source_City RESTART IDENTITY CASCADE;
TRUNCATE TABLE City RESTART IDENTITY CASCADE;

UPDATE Source_City
SET City = 'City of St. Catharines'
WHERE City = 'City of St. Catherines';

-- Delete duplicates from source data
DELETE FROM Source_City 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY City ORDER BY ID) as rnum 
        FROM Source_City
    ) t WHERE t.rnum > 1
);

-- Load Target Table Data
INSERT INTO City (City)
SELECT SOURCE.City
FROM Source_City SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM City TARGET WHERE TARGET.City = SOURCE.City
);


-- -------------------------------------------------------------------------------------
-- Location
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_Location CASCADE;
CREATE TABLE Source_Location (
    ID SERIAL PRIMARY KEY,
    "Location" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS "Location" CASCADE;
CREATE TABLE "Location" (
    ID SERIAL PRIMARY KEY,
    "Location" VARCHAR(300) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

UPDATE Source_Location
SET "Location" = CASE 
    WHEN "Location" = 'E3 Community services' THEN 'E3 Community Services'
    WHEN "Location" = 'Family Centre Carling-Thames' THEN 'Family Centre Carling Thamess'
    ELSE "Location"
END
WHERE "Location" IN ('E3 Community services', 'Family Centre Carling-Thames');

-- Delete duplicates from source data
DELETE FROM Source_Location 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location" ORDER BY ID) as rnum 
        FROM Source_Location
    ) t WHERE t.rnum > 1
);

-- Load Target Table Data
INSERT INTO "Location" ("Location")
SELECT SOURCE."Location"
FROM Source_Location SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM "Location" TARGET WHERE TARGET."Location" = SOURCE."Location"
);


-- -------------------------------------------------------------------------------------
-- Address
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_Address CASCADE;
CREATE TABLE Source_Address (
    ID SERIAL PRIMARY KEY,
    "Address" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delete duplicates from source data
DELETE FROM Source_Address 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Address" ORDER BY ID) as rnum 
        FROM Source_Address
    ) t WHERE t.rnum > 1
);

DROP TABLE IF EXISTS "Address" CASCADE;
CREATE TABLE "Address" (
    ID SERIAL PRIMARY KEY,
    "Address" VARCHAR(800) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Load Target Table Data
INSERT INTO "Address" ("Address")
SELECT SOURCE."Address"
FROM Source_Address SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM "Address" TARGET WHERE TARGET."Address" = SOURCE."Address"
);


-- -------------------------------------------------------------------------------------
-- Postal Code
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_PostalCode CASCADE;
CREATE TABLE Source_PostalCode (
    ID SERIAL PRIMARY KEY,
    "PostalCode" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delete duplicates from source data
DELETE FROM Source_PostalCode 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "PostalCode" ORDER BY ID) as rnum 
        FROM Source_PostalCode
    ) t WHERE t.rnum > 1
);

DROP TABLE IF EXISTS "PostalCode" CASCADE;
CREATE TABLE "PostalCode" (
    ID SERIAL PRIMARY KEY,
    "PostalCode" VARCHAR(300) NOT NULL,
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Load Target Table Data
INSERT INTO "PostalCode" ("PostalCode")
SELECT SOURCE."PostalCode"
FROM Source_PostalCode SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM "PostalCode" TARGET WHERE TARGET."PostalCode" = SOURCE."PostalCode"
);


-- =====================================================================================
-- 3. CREATING BRIDGE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- City Manager Bridge
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_CityManager CASCADE;
CREATE TABLE Source_CityManager (
    ID SERIAL PRIMARY KEY,
    ServiceManagerID INT,
    ServiceManager VARCHAR(300),
    CityID INT,
    City VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS CityManager CASCADE;
CREATE TABLE CityManager (
    ID SERIAL PRIMARY KEY,
    ServiceManagerID INT,
    CityID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    -- FOREIGN KEY (CityID) REFERENCES City(ID),
    -- FOREIGN KEY (ServiceManagerID) REFERENCES ServiceManager(ID)
);

-- Delete duplicates
DELETE FROM Source_CityManager 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY ServiceManager, City ORDER BY ID) as rnum 
        FROM Source_CityManager
    ) t WHERE t.rnum > 1
);

-- Map IDs (PostgreSQL UPDATE FROM syntax)
UPDATE Source_CityManager A
SET ServiceManagerID = B.ID
FROM ServiceManager B 
WHERE B.ServiceManager = A.ServiceManager AND A.ServiceManager IS NOT NULL;

UPDATE Source_CityManager A
SET CityID = B.ID
FROM City B 
WHERE B.City = A.City AND A.City IS NOT NULL;

DELETE FROM Source_CityManager WHERE CityID IS NULL;

-- Load Target
INSERT INTO CityManager (ServiceManagerID, CityID)
SELECT SOURCE.ServiceManagerID, SOURCE.CityID
FROM Source_CityManager SOURCE
WHERE SOURCE.CityID IS NOT NULL AND SOURCE.ServiceManagerID IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM CityManager TARGET 
    WHERE TARGET.ServiceManagerID = SOURCE.ServiceManagerID AND TARGET.CityID = SOURCE.CityID
);


-- -------------------------------------------------------------------------------------
-- City Location Bridge
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_CityLocation CASCADE;
CREATE TABLE Source_CityLocation (
    ID SERIAL PRIMARY KEY,
    CityID INT,
    City VARCHAR(300),
    LocationID INT,
    "Location" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delete duplicates
DELETE FROM Source_CityLocation 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location", City ORDER BY ID) as rnum 
        FROM Source_CityLocation
    ) t WHERE t.rnum > 1
);

-- Map IDs
UPDATE Source_CityLocation A
SET LocationID = B.ID
FROM "Location" B 
WHERE B."Location" = A."Location" AND A."Location" IS NOT NULL;

UPDATE Source_CityLocation A
SET CityID = B.ID
FROM City B 
WHERE B.City = A.City AND A.City IS NOT NULL;

DROP TABLE IF EXISTS CityLocation CASCADE;
CREATE TABLE CityLocation (
    ID SERIAL PRIMARY KEY,
    CityID INT,
    LocationID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Load Target
INSERT INTO CityLocation (CityID, LocationID)
SELECT SOURCE.CityID, SOURCE.LocationID
FROM Source_CityLocation SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM CityLocation TARGET 
    WHERE TARGET.CityID = SOURCE.CityID AND TARGET.LocationID = SOURCE.LocationID
);


-- -------------------------------------------------------------------------------------
-- Location Address Bridge
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_LocationAddress CASCADE;
CREATE TABLE Source_LocationAddress (
    ID SERIAL PRIMARY KEY,
    LocationID INT,
    "Location" VARCHAR(300),
    AddressID INT,
    "Address" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delete duplicates
DELETE FROM Source_LocationAddress 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location", "Address" ORDER BY ID) as rnum 
        FROM Source_LocationAddress
    ) t WHERE t.rnum > 1
);

-- Map IDs
UPDATE Source_LocationAddress A
SET LocationID = B.ID
FROM "Location" B 
WHERE B."Location" = A."Location" AND A."Location" IS NOT NULL;

UPDATE Source_LocationAddress A
SET AddressID = B.ID
FROM "Address" B 
WHERE B."Address" = A."Address" AND A."Address" IS NOT NULL;

DELETE FROM Source_LocationAddress WHERE LocationID IS NULL;
DELETE FROM Source_LocationAddress WHERE AddressID IS NULL;

DROP TABLE IF EXISTS LocationAddress CASCADE;
CREATE TABLE LocationAddress (
    ID SERIAL PRIMARY KEY,
    LocationID INT,
    AddressID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Load Target
INSERT INTO LocationAddress (LocationID, AddressID)
SELECT SOURCE.LocationID, SOURCE.AddressID
FROM Source_LocationAddress SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM LocationAddress TARGET 
    WHERE TARGET.LocationID = SOURCE.LocationID AND TARGET.AddressID = SOURCE.AddressID
);


-- -------------------------------------------------------------------------------------
-- Address PostalCode Bridge
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Source_AddressPostalCode CASCADE;
CREATE TABLE Source_AddressPostalCode (
    ID SERIAL PRIMARY KEY,
    AddressID INT,
    "Address" VARCHAR(800),
    PostalCodeID INT,
    "PostalCode" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delete duplicates
DELETE FROM Source_AddressPostalCode 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Address", "PostalCode" ORDER BY ID) as rnum 
        FROM Source_AddressPostalCode
    ) t WHERE t.rnum > 1
);

-- Map IDs
UPDATE Source_AddressPostalCode A
SET AddressID = B.ID
FROM "Address" B 
WHERE B."Address" = A."Address" AND A."Address" IS NOT NULL;

UPDATE Source_AddressPostalCode A
SET PostalCodeID = B.ID
FROM "PostalCode" B 
WHERE B."PostalCode" = A."PostalCode" AND A."PostalCode" IS NOT NULL;

DROP TABLE IF EXISTS AddressPostalCode CASCADE;
CREATE TABLE AddressPostalCode (
    ID SERIAL PRIMARY KEY,
    AddressID INT,
    PostalCodeID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Load Target
INSERT INTO AddressPostalCode (AddressID, PostalCodeID)
SELECT SOURCE.AddressID, SOURCE.PostalCodeID
FROM Source_AddressPostalCode SOURCE
WHERE NOT EXISTS (
    SELECT 1 FROM AddressPostalCode TARGET 
    WHERE TARGET.AddressID = SOURCE.AddressID AND TARGET.PostalCodeID = SOURCE.PostalCodeID
);


-- =====================================================================================
-- 4. FINAL TABLE (OntarioLocations)
-- =====================================================================================
DROP TABLE IF EXISTS OntarioLocations CASCADE;
CREATE TABLE OntarioLocations (
    ID SERIAL PRIMARY KEY,
    
    ProvinceID INT,
    Province VARCHAR(300),
    ProvinceCode VARCHAR(300),
    
    ServiceManagerID INT,
    ServiceManager VARCHAR(300),
    
    CityID INT,
    City VARCHAR(300),
    
    LocationID INT,
    "Location" VARCHAR(300),
    
    AddressID INT,
    "Address" VARCHAR(800),
    
    PostalCodeID INT,
    "PostalCode" VARCHAR(20),
    Longitude DECIMAL(10, 6),
    Latitude DECIMAL(10, 6),
    
    -- Note: PostgreSQL uses PostGIS extension for spatial data. 
    -- If you don't have PostGIS installed, you can use VARCHAR for now.
    Geometry VARCHAR(255), 
    
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP
);

-- Note: Spatial indexes in PostgreSQL require the PostGIS extension. 
-- CREATE INDEX SIndx_OntarioLocations_Geometry ON OntarioLocations(Geometry);