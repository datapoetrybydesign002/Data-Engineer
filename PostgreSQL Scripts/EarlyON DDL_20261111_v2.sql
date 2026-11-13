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
DROP TABLE IF EXISTS public.source_province CASCADE;
CREATE TABLE public.source_province (
    id SERIAL PRIMARY KEY,
    province VARCHAR(300),
    provincecode VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.province CASCADE;
CREATE TABLE public.province (
    id SERIAL PRIMARY KEY,
    province VARCHAR(300),
    provincecode VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


TRUNCATE TABLE public.source_province RESTART IDENTITY CASCADE;

-- Procedure: Load Province
CREATE OR REPLACE PROCEDURE public.load_target_table_province()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.province AS target
    USING public.source_province AS source
    ON target.province = source.province
    WHEN NOT MATCHED THEN
        INSERT (province, provincecode)
        VALUES (source.province, source.provincecode);
END;
$$;


-- -------------------------------------------------------------------------------------
-- SERVICE MANAGER
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_servicemanager CASCADE;
CREATE TABLE public.source_servicemanager (
    id SERIAL PRIMARY KEY,
    servicemanager VARCHAR(300),
    provinceid INT,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.servicemanager CASCADE;
CREATE TABLE public.servicemanager (
    id SERIAL PRIMARY KEY,
    servicemanager VARCHAR(300) NOT NULL,
    provinceid INT,
    created_by VARCHAR(300) NOT NULL DEFAULT CURRENT_USER,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_servicemanager_servicemanager ON public.servicemanager(servicemanager);


TRUNCATE TABLE public.source_servicemanager RESTART IDENTITY CASCADE;

-- Clean duplicates from Source
DELETE FROM public.source_servicemanager 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY servicemanager ORDER BY id) as rnum 
        FROM public.source_servicemanager
    ) t WHERE t.rnum > 1
);

-- Procedure: Load ServiceManager
CREATE OR REPLACE PROCEDURE public.load_target_table_servicemanager()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.servicemanager AS target
    USING public.source_servicemanager AS source
    ON target.servicemanager = source.servicemanager
    WHEN NOT MATCHED THEN
        INSERT (servicemanager, provinceid)
        VALUES (source.servicemanager, source.provinceid);
END;
$$;


-- -------------------------------------------------------------------------------------
-- CITY
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_city CASCADE;
CREATE TABLE public.source_city (
    id SERIAL PRIMARY KEY,
    city VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.city CASCADE;
CREATE TABLE public.city (
    id SERIAL PRIMARY KEY,
    city VARCHAR(300) NOT NULL,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ix_city_city ON public.city(city);

-- Clean Data
TRUNCATE TABLE public.source_city RESTART IDENTITY CASCADE;
UPDATE public.source_city SET city = 'City of St. Catharines' WHERE city = 'City of St. Catherines';

-- Clean duplicates from Source
DELETE FROM public.source_city 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY city ORDER BY id) as rnum 
        FROM public.source_city
    ) t WHERE t.rnum > 1
);

-- Procedure: Load City
CREATE OR REPLACE PROCEDURE public.load_target_table_city()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.city AS target
    USING public.source_city AS source
    ON target.city = source.city
    WHEN NOT MATCHED THEN
        INSERT (city)
        VALUES (source.city);
END;
$$;


-- -------------------------------------------------------------------------------------
-- LOCATION
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_location CASCADE;
CREATE TABLE public.source_location (
    id SERIAL PRIMARY KEY,
    location VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.location CASCADE;
CREATE TABLE public.location (
    id SERIAL PRIMARY KEY,
    location VARCHAR(300) NOT NULL,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean Data
UPDATE public.source_location
SET location = CASE 
    WHEN location = 'E3 Community services' THEN 'E3 Community Services'
    WHEN location = 'Family Centre Carling-Thames' THEN 'Family Centre Carling Thamess'
    ELSE location
END
WHERE location IN ('E3 Community services', 'Family Centre Carling-Thames');

-- Clean duplicates from Source
DELETE FROM public.source_location 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY location ORDER BY id) as rnum 
        FROM public.source_location
    ) t WHERE t.rnum > 1
);

-- Procedure: Load Location
CREATE OR REPLACE PROCEDURE public.load_target_table_location()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.location AS target
    USING public.source_location AS source
    ON target.location = source.location
    WHEN NOT MATCHED THEN
        INSERT (location)
        VALUES (source.location);
END;
$$;


-- -------------------------------------------------------------------------------------
-- ADDRESS
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_address CASCADE;
CREATE TABLE public.source_address (
    id SERIAL PRIMARY KEY,
    address VARCHAR(800),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.address CASCADE;
CREATE TABLE public.address (
    id SERIAL PRIMARY KEY,
    address VARCHAR(800) NOT NULL,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean duplicates from Source
DELETE FROM public.source_address 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY address ORDER BY id) as rnum 
        FROM public.source_address
    ) t WHERE t.rnum > 1
);

-- Procedure: Load Address
CREATE OR REPLACE PROCEDURE public.load_target_table_address()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.address AS target
    USING public.source_address AS source
    ON target.address = source.address
    WHEN NOT MATCHED THEN
        INSERT (address)
        VALUES (source.address);
END;
$$;


-- -------------------------------------------------------------------------------------
-- POSTAL CODE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_postalcode CASCADE;
CREATE TABLE public.source_postalcode (
    id SERIAL PRIMARY KEY,
    postalcode VARCHAR(800),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.postalcode CASCADE;
CREATE TABLE public.postalcode (
    id SERIAL PRIMARY KEY,
    postalcode VARCHAR(300) NOT NULL,
    latitude DECIMAL(10,6),
    longitude DECIMAL(10,6),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Clean duplicates from Source
DELETE FROM public.source_postalcode 
WHERE id IN (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY postalcode ORDER BY id) as rnum 
        FROM public.source_postalcode
    ) t WHERE t.rnum > 1
);

-- Procedure: Load PostalCode
CREATE OR REPLACE PROCEDURE public.load_target_table_postalcode()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.postalcode AS target
    USING public.source_postalcode AS source
    ON target.postalcode = source.postalcode
    WHEN NOT MATCHED THEN
        INSERT (postalcode)
        VALUES (source.postalcode);
END;
$$;


-- =====================================================================================
-- 3. BRIDGE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- CITY MANAGER BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_citymanager CASCADE;
CREATE TABLE public.source_citymanager (
    id SERIAL PRIMARY KEY,
    servicemanagerid INT,
    servicemanager VARCHAR(300),
    cityid INT,
    city VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.citymanager CASCADE;
CREATE TABLE public.citymanager (
    id SERIAL PRIMARY KEY,
    servicemanagerid INT,
    cityid INT,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procedure: Delete Duplicates
CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_citymanager_servicemanager()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.source_citymanager 
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY servicemanager, city ORDER BY id) as rnum 
            FROM public.source_citymanager
        ) t WHERE t.rnum > 1
    );
END;
$$;

-- Procedure: Map ServiceManagerID
CREATE OR REPLACE PROCEDURE public.mapid_servicemanager_source_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_citymanager a
    SET servicemanagerid = b.id
    FROM public.servicemanager b 
    WHERE b.servicemanager = a.servicemanager AND a.servicemanager IS NOT NULL;
END;
$$;

-- Procedure: Map CityID
CREATE OR REPLACE PROCEDURE public.mapid_city_source_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_citymanager a
    SET cityid = b.id
    FROM public.city b 
    WHERE b.city = a.city AND a.city IS NOT NULL;
    
    DELETE FROM public.source_citymanager WHERE cityid IS NULL;
END;
$$;

-- Procedure: Load Bridge Table
CREATE OR REPLACE PROCEDURE public.load_target_citymanager()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.citymanager AS target
    USING public.source_citymanager AS source
    ON target.servicemanagerid = source.servicemanagerid 
       AND target.cityid = source.cityid
    WHEN NOT MATCHED THEN
        INSERT (servicemanagerid, cityid)
        VALUES (source.servicemanagerid, source.cityid);
END;
$$;


-- -------------------------------------------------------------------------------------
-- CITY LOCATION BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_citylocation CASCADE;
CREATE TABLE public.source_citylocation (
    id SERIAL PRIMARY KEY,
    cityid INT,
    city VARCHAR(300),
    locationid INT,
    location VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.citylocation CASCADE;
CREATE TABLE public.citylocation (
    id SERIAL PRIMARY KEY,
    cityid INT,
    locationid INT,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_citylocation_city()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.source_citylocation 
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY location, city ORDER BY id) as rnum 
            FROM public.source_citylocation
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_citylocation_location()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_citylocation a
    SET locationid = b.id
    FROM public.location b 
    WHERE b.location = a.location AND a.location IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_citylocation_city()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_citylocation a
    SET cityid = b.id
    FROM public.city b 
    WHERE b.city = a.city AND a.city IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_citylocation()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.citylocation AS target
    USING public.source_citylocation AS source
    ON target.cityid = source.cityid 
       AND target.locationid = source.locationid
    WHEN NOT MATCHED THEN
        INSERT (cityid, locationid)
        VALUES (source.cityid, source.locationid);
END;
$$;


-- -------------------------------------------------------------------------------------
-- LOCATION ADDRESS BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_locationaddress CASCADE;
CREATE TABLE public.source_locationaddress (
    id SERIAL PRIMARY KEY,
    locationid INT,
    location VARCHAR(300),
    addressid INT,
    address VARCHAR(800),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.locationaddress CASCADE;
CREATE TABLE public.locationaddress (
    id SERIAL PRIMARY KEY,
    locationid INT,
    addressid INT,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_locationaddress_address()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.source_locationaddress 
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY location, address ORDER BY id) as rnum 
            FROM public.source_locationaddress
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_locationaddress_location()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_locationaddress a
    SET locationid = b.id
    FROM public.location b 
    WHERE b.location = a.location AND a.location IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_locationaddress_address()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_locationaddress a
    SET addressid = b.id
    FROM public.address b 
    WHERE b.address = a.address AND a.address IS NOT NULL;
    
    DELETE FROM public.source_locationaddress WHERE locationid IS NULL OR addressid IS NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_locationaddress()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.locationaddress AS target
    USING public.source_locationaddress AS source
    ON target.locationid = source.locationid 
       AND target.addressid = source.addressid
    WHEN NOT MATCHED THEN
        INSERT (locationid, addressid)
        VALUES (source.locationid, source.addressid);
END;
$$;


-- -------------------------------------------------------------------------------------
-- ADDRESS POSTALCODE BRIDGE
-- -------------------------------------------------------------------------------------
DROP TABLE IF EXISTS public.source_addresspostalcode CASCADE;
CREATE TABLE public.source_addresspostalcode (
    id SERIAL PRIMARY KEY,
    addressid INT,
    address VARCHAR(800),
    postalcodeid INT,
    postalcode VARCHAR(300),
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS public.addresspostalcode CASCADE;
CREATE TABLE public.addresspostalcode (
    id SERIAL PRIMARY KEY,
    addressid INT,
    postalcodeid INT,
    created_by VARCHAR(300) DEFAULT CURRENT_USER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE PROCEDURE public.delete_duplicates_source_addresspostalcode_postalcode()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM public.source_addresspostalcode 
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY address, postalcode ORDER BY id) as rnum 
            FROM public.source_addresspostalcode
        ) t WHERE t.rnum > 1
    );
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_addresspostalcode_address()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_addresspostalcode a
    SET addressid = b.id
    FROM public.address b 
    WHERE b.address = a.address AND a.address IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.mapid_source_addresspostalcode_postalcode()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.source_addresspostalcode a
    SET postalcodeid = b.id
    FROM public.postalcode b 
    WHERE b.postalcode = a.postalcode AND a.postalcode IS NOT NULL;
END;
$$;

CREATE OR REPLACE PROCEDURE public.load_target_addresspostalcode()
LANGUAGE plpgsql AS $$
BEGIN
    MERGE INTO public.addresspostalcode AS target
    USING public.source_addresspostalcode AS source
    ON target.addressid = source.addressid 
       AND target.postalcodeid = source.postalcodeid
    WHEN NOT MATCHED THEN
        INSERT (addressid, postalcodeid)
        VALUES (source.addressid, source.postalcodeid);
END;
$$;


-- =====================================================================================
-- 4. FINAL FACT/DIM TABLE
-- =====================================================================================
DROP TABLE IF EXISTS public.ontariolocations CASCADE;
CREATE TABLE public.ontariolocations (
    id SERIAL PRIMARY KEY,
    provinceid INT,
    province VARCHAR(300),
    provincecode VARCHAR(300),
    servicemanagerid INT,
    servicemanager VARCHAR(300),
    cityid INT,
    city VARCHAR(300),
    locationid INT,
    location VARCHAR(300),
    addressid INT,
    address VARCHAR(800),
    postalcodeid INT,
    postalcode VARCHAR(20),  
    longitude DECIMAL(10, 6),  
    latitude DECIMAL(10, 6),   
    geometry VARCHAR(255), 
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP
);