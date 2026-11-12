-- =====================================================================================
-- 1. DATABASE CREATION (Run this manually if the DB doesn't exist)
-- =====================================================================================
-- Note: You cannot create a database and switch to it in the same script. 
-- If 'EarlyON_v2' doesn't exist, right-click 'Databases' in pgAdmin -> Create -> EarlyON_v2.
-- Then open the Query Tool connected to EarlyON_v2 and run everything below.

-- =====================================================================================
-- 2. DIMENSION TABLES (Source & Target)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- PROVINCE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public."source_province" CASCADE;
CREATE TABLE public.Source_Province (
    ID SERIAL PRIMARY KEY,
    Province VARCHAR(300),
    ProvinceCode VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO public.source_province (province) VALUES('TEST'), ('test')
INSERT INTO public.source_province (province) VALUES('test')

TRUNCATE TABLE public.source_province RESTART IDENTITY;
TRUNCATE TABLE public.province RESTART IDENTITY;
select * from public.source_province
select * from public.province

DROP TABLE IF EXISTS public.province CASCADE;
CREATE TABLE public.province (
    ID SERIAL PRIMARY KEY,
    province VARCHAR(300),
    provinceCode VARCHAR(300),
    createdBy VARCHAR(300) DEFAULT CURRENT_USER,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedure: Load Province
CREATE OR REPLACE PROCEDURE public.load_target_table_Province()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.Province AS TARGET
    USING public.Source_Province AS SOURCE
    ON TARGET.Province = SOURCE.Province
    WHEN NOT MATCHED THEN
        INSERT (Province, ProvinceCode)
        VALUES (SOURCE.Province, SOURCE.ProvinceCode);
END;
$$;

SELECT * From public.source_province
SELECT * FROM public.province

insert into public.Province (Province) values ('test')

-- -------------------------------------------------------------------------------------
-- SERVICE MANAGER
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_ServiceManager CASCADE;
CREATE TABLE public.Source_ServiceManager (
    ID SERIAL PRIMARY KEY,
    ServiceManager VARCHAR(300),
    ProvinceID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.ServiceManager CASCADE;
CREATE TABLE public.ServiceManager (
    ID SERIAL PRIMARY KEY,
    ServiceManager VARCHAR(300) NOT NULL,
    ProvinceID INT,
    CreatedBy VARCHAR(300) NOT NULL DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IX_ServiceManager_ServiceManager ON public.ServiceManager(ServiceManager);

-- Clean duplicates from Source
DELETE FROM public.Source_ServiceManager 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY ServiceManager ORDER BY ID) as rnum 
        FROM public.Source_ServiceManager
    ) t WHERE t.rnum > 1
);

-- Procedure: Load ServiceManager
CREATE OR REPLACE PROCEDURE public.load_target_table_ServiceManager()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.ServiceManager AS TARGET
    USING public.Source_ServiceManager AS SOURCE
    ON TARGET.ServiceManager = SOURCE.ServiceManager
    WHEN NOT MATCHED THEN
        INSERT (ServiceManager, ProvinceID)
        VALUES (SOURCE.ServiceManager, SOURCE.ProvinceID);
END;
$$;


-- -------------------------------------------------------------------------------------
-- CITY
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_City CASCADE;
CREATE TABLE public.Source_City (
    ID SERIAL PRIMARY KEY,
    City VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.City CASCADE;
CREATE TABLE public.City (
    ID SERIAL PRIMARY KEY,
    City VARCHAR(300) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IX_City_City ON public.City(City);

-- Clean Data
TRUNCATE TABLE public.Source_City RESTART IDENTITY CASCADE;
UPDATE public.Source_City SET City = 'City of St. Catharines' WHERE City = 'City of St. Catherines';

-- Clean duplicates from Source
DELETE FROM public.Source_City 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY City ORDER BY ID) as rnum 
        FROM public.Source_City
    ) t WHERE t.rnum > 1
);

-- Procedure: Load City
CREATE OR REPLACE PROCEDURE public.load_target_table_City()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.City AS TARGET
    USING public.Source_City AS SOURCE
    ON TARGET.City = SOURCE.City
    WHEN NOT MATCHED THEN
        INSERT (City)
        VALUES (SOURCE.City);
END;
$$;


-- -------------------------------------------------------------------------------------
-- LOCATION
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_Location CASCADE;
CREATE TABLE public.Source_Location (
    ID SERIAL PRIMARY KEY,
    "Location" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public."Location" CASCADE;
CREATE TABLE public."Location" (
    ID SERIAL PRIMARY KEY,
    "Location" VARCHAR(300) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean Data
UPDATE public.Source_Location
SET "Location" = CASE 
    WHEN "Location" = 'E3 Community services' THEN 'E3 Community Services'
    WHEN "Location" = 'Family Centre Carling-Thames' THEN 'Family Centre Carling Thamess'
    ELSE "Location"
END
WHERE "Location" IN ('E3 Community services', 'Family Centre Carling-Thames');

-- Clean duplicates from Source
DELETE FROM public.Source_Location 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location" ORDER BY ID) as rnum 
        FROM public.Source_Location
    ) t WHERE t.rnum > 1
);

-- Procedure: Load Location
CREATE OR REPLACE PROCEDURE public.load_target_table_Location()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public."Location" AS TARGET
    USING public.Source_Location AS SOURCE
    ON TARGET."Location" = SOURCE."Location"
    WHEN NOT MATCHED THEN
        INSERT ("Location")
        VALUES (SOURCE."Location");
END;
$$;


-- -------------------------------------------------------------------------------------
-- ADDRESS
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_Address CASCADE;
CREATE TABLE public.Source_Address (
    ID SERIAL PRIMARY KEY,
    "Address" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public."Address" CASCADE;
CREATE TABLE public."Address" (
    ID SERIAL PRIMARY KEY,
    "Address" VARCHAR(800) NOT NULL,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean duplicates from Source
DELETE FROM public.Source_Address 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Address" ORDER BY ID) as rnum 
        FROM public.Source_Address
    ) t WHERE t.rnum > 1
);

-- Procedure: Load Address
CREATE OR REPLACE PROCEDURE public.load_target_table_Address()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public."Address" AS TARGET
    USING public.Source_Address AS SOURCE
    ON TARGET."Address" = SOURCE."Address"
    WHEN NOT MATCHED THEN
        INSERT ("Address")
        VALUES (SOURCE."Address");
END;
$$;


-- -------------------------------------------------------------------------------------
-- POSTAL CODE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_PostalCode CASCADE;
CREATE TABLE public.Source_PostalCode (
    ID SERIAL PRIMARY KEY,
    "PostalCode" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public."PostalCode" CASCADE;
CREATE TABLE public."PostalCode" (
    ID SERIAL PRIMARY KEY,
    "PostalCode" VARCHAR(300) NOT NULL,
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean duplicates from Source
DELETE FROM public.Source_PostalCode 
WHERE ID IN (
    SELECT ID FROM (
        SELECT ID, ROW_NUMBER() OVER (PARTITION BY "PostalCode" ORDER BY ID) as rnum 
        FROM public.Source_PostalCode
    ) t WHERE t.rnum > 1
);

-- Procedure: Load PostalCode
CREATE OR REPLACE PROCEDURE public.load_target_table_PostalCode()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public."PostalCode" AS TARGET
    USING public.Source_PostalCode AS SOURCE
    ON TARGET."PostalCode" = SOURCE."PostalCode"
    WHEN NOT MATCHED THEN
        INSERT ("PostalCode")
        VALUES (SOURCE."PostalCode");
END;
$$;


-- =====================================================================================
-- 3. BRIDGE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- CITY MANAGER BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_CityManager CASCADE;
CREATE TABLE public.Source_CityManager (
    ID SERIAL PRIMARY KEY,
    ServiceManagerID INT,
    ServiceManager VARCHAR(300),
    CityID INT,
    City VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.CityManager CASCADE;
CREATE TABLE public.CityManager (
    ID SERIAL PRIMARY KEY,
    ServiceManagerID INT,
    CityID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedure: Delete Duplicates
CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_citymanager_servicemanager()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.Source_CityManager 
    WHERE ID IN (
        SELECT ID FROM (
            SELECT ID, ROW_NUMBER() OVER (PARTITION BY ServiceManager, City ORDER BY ID) as rnum 
            FROM public.Source_CityManager
        ) t WHERE t.rnum > 1
    );
END;
$$;

-- Procedure: Map ServiceManagerID
CREATE OR REPLACE PROCEDURE public.mapid_servicemanager_source_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_CityManager A
    SET ServiceManagerID = B.ID
    FROM public.ServiceManager B 
    WHERE B.ServiceManager = A.ServiceManager AND A.ServiceManager IS NOT NULL;
END;
$$;

-- Procedure: Map CityID
CREATE OR REPLACE PROCEDURE public.mapid_city_source_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_CityManager A
    SET CityID = B.ID
    FROM public.City B 
    WHERE B.City = A.City AND A.City IS NOT NULL;
    
    DELETE FROM public.Source_CityManager WHERE CityID IS NULL;
END;
$$;

-- Procedure: Load Bridge Table
CREATE OR REPLACE PROCEDURE public.load_target_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.CityManager AS TARGET
    USING public.Source_CityManager AS SOURCE
    ON TARGET.ServiceManagerID = SOURCE.ServiceManagerID 
       AND TARGET.CityID = SOURCE.CityID
    WHEN NOT MATCHED THEN
        INSERT (ServiceManagerID, CityID)
        VALUES (SOURCE.ServiceManagerID, SOURCE.CityID);
END;
$$;


-- -------------------------------------------------------------------------------------
-- CITY LOCATION BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_CityLocation CASCADE;
CREATE TABLE public.Source_CityLocation (
    ID SERIAL PRIMARY KEY,
    CityID INT,
    City VARCHAR(300),
    LocationID INT,
    "Location" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.CityLocation CASCADE;
CREATE TABLE public.CityLocation (
    ID SERIAL PRIMARY KEY,
    CityID INT,
    LocationID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_cityLocation_city()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.Source_CityLocation 
    WHERE ID IN (
        SELECT ID FROM (
            SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location", City ORDER BY ID) as rnum 
            FROM public.Source_CityLocation
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_cityLocation_location()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_CityLocation A
    SET LocationID = B.ID
    FROM public."Location" B 
    WHERE B."Location" = A."Location" AND A."Location" IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_cityLocation_city()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_CityLocation A
    SET CityID = B.ID
    FROM public.City B 
    WHERE B.City = A.City AND A.City IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_citylocation()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.CityLocation AS TARGET
    USING public.Source_CityLocation AS SOURCE
    ON TARGET.CityID = SOURCE.CityID 
       AND TARGET.LocationID = SOURCE.LocationID
    WHEN NOT MATCHED THEN
        INSERT (CityID, LocationID)
        VALUES (SOURCE.CityID, SOURCE.LocationID);
END;
$$;


-- -------------------------------------------------------------------------------------
-- LOCATION ADDRESS BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_LocationAddress CASCADE;
CREATE TABLE public.Source_LocationAddress (
    ID SERIAL PRIMARY KEY,
    LocationID INT,
    "Location" VARCHAR(300),
    AddressID INT,
    "Address" VARCHAR(800),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.LocationAddress CASCADE;
CREATE TABLE public.LocationAddress (
    ID SERIAL PRIMARY KEY,
    LocationID INT,
    AddressID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_locationaddress_address()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.Source_LocationAddress 
    WHERE ID IN (
        SELECT ID FROM (
            SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Location", "Address" ORDER BY ID) as rnum 
            FROM public.Source_LocationAddress
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_locationaddress_location()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_LocationAddress A
    SET LocationID = B.ID
    FROM public."Location" B 
    WHERE B."Location" = A."Location" AND A."Location" IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_locationaddress_address()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_LocationAddress A
    SET AddressID = B.ID
    FROM public."Address" B 
    WHERE B."Address" = A."Address" AND A."Address" IS NOT NULL;
    
    DELETE FROM public.Source_LocationAddress WHERE LocationID IS NULL OR AddressID IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_locationaddress()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.LocationAddress AS TARGET
    USING public.Source_LocationAddress AS SOURCE
    ON TARGET.LocationID = SOURCE.LocationID 
       AND TARGET.AddressID = SOURCE.AddressID
    WHEN NOT MATCHED THEN
        INSERT (LocationID, AddressID)
        VALUES (SOURCE.LocationID, SOURCE.AddressID);
END;
$$;


-- -------------------------------------------------------------------------------------
-- ADDRESS POSTALCODE BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.Source_AddressPostalCode CASCADE;
CREATE TABLE public.Source_AddressPostalCode (
    ID SERIAL PRIMARY KEY,
    AddressID INT,
    "Address" VARCHAR(800),
    PostalCodeID INT,
    "PostalCode" VARCHAR(300),
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.AddressPostalCode CASCADE;
CREATE TABLE public.AddressPostalCode (
    ID SERIAL PRIMARY KEY,
    AddressID INT,
    PostalCodeID INT,
    CreatedBy VARCHAR(300) DEFAULT CURRENT_USER,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_addresspostalcode_postalcode()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.Source_AddressPostalCode 
    WHERE ID IN (
        SELECT ID FROM (
            SELECT ID, ROW_NUMBER() OVER (PARTITION BY "Address", "PostalCode" ORDER BY ID) as rnum 
            FROM public.Source_AddressPostalCode
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_addresspostalcode_address()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_AddressPostalCode A
    SET AddressID = B.ID
    FROM public."Address" B 
    WHERE B."Address" = A."Address" AND A."Address" IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_addresspostalcode_postalcode()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.Source_AddressPostalCode A
    SET PostalCodeID = B.ID
    FROM public."PostalCode" B 
    WHERE B."PostalCode" = A."PostalCode" AND A."PostalCode" IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_addresspostalcode()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.AddressPostalCode AS TARGET
    USING public.Source_AddressPostalCode AS SOURCE
    ON TARGET.AddressID = SOURCE.AddressID 
       AND TARGET.PostalCodeID = SOURCE.PostalCodeID
    WHEN NOT MATCHED THEN
        INSERT (AddressID, PostalCodeID)
        VALUES (SOURCE.AddressID, SOURCE.PostalCodeID);
END;
$$;


-- =====================================================================================
-- 4. FINAL FACT/DIM TABLE
-- =====================================================================================
DROP TABLE IF EXISTS public.OntarioLocations CASCADE;
CREATE TABLE public.OntarioLocations (
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
    Geometry VARCHAR(255), 
    CreatedDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate TIMESTAMP
);