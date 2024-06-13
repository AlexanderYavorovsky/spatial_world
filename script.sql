CREATE EXTENSION IF NOT EXISTS postgis;


/* START TABLE DEFINITIONS */

CREATE TABLE IF NOT EXISTS oceans (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(MULTIPOLYGON, 4326),
	maxdepth DECIMAL
);

CREATE TABLE IF NOT EXISTS seas (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(MULTIPOLYGON, 4326),
	maxdepth INTEGER
);

CREATE TABLE IF NOT EXISTS continents (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(MULTIPOLYGON, 4326)
);

CREATE TABLE IF NOT EXISTS islands (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(MULTIPOLYGON, 4326)
);

CREATE TABLE IF NOT EXISTS cities (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(POINT, 4326)
);

CREATE TABLE IF NOT EXISTS flight (
	id SERIAL PRIMARY KEY,
	ftime TIMESTAMP,
	geogr GEOGRAPHY(POINT, 4326)
);

CREATE TABLE IF NOT EXISTS paths (
	id SERIAL PRIMARY KEY,
	name VARCHAR(128),
	geogr GEOGRAPHY(LINESTRING, 4326)
);

/* END TABLE DEFINITIONS */


/* START QUERIES */

-- 0
SELECT * FROM cities;

-- 1
SELECT c.name, ST_AsText(c.geogr) FROM cities c;

-- 2
INSERT INTO cities (name, geogr) 
VALUES ('Rome2', 'POINT(12.483254083802244 41.8943515710597)');

-- 3
SELECT * FROM cities c1
JOIN cities c2 
	ON ST_Equals(c1.geogr::geometry, c2.geogr::geometry) 
		AND c1.id < c2.id;

-- 4
SELECT DISTINCT(o.name) FROM continents c
JOIN oceans o 
	ON ST_Touches(c.geogr::geometry, o.geogr::geometry) 
		OR ST_Intersects(c.geogr, o.geogr)
WHERE c.name = 'Eurasia';

-- 5
SELECT ST_Area(i.geogr) / 1000000 AS area_km 
FROM islands i
WHERE i.name = 'Madagascar';

-- 6
SELECT ST_Perimeter(i.geogr) / 1000 AS perimeter_km
FROM islands i
WHERE i.name = 'Jamaica';

-- 7
SELECT ST_Distance(c1.geogr, c2.geogr) / 1000 AS distance_km
FROM cities c1, cities c2
WHERE c1.name = 'Rome' AND c2.name = 'Florence';

-- 8
SELECT c.name FROM cities c
JOIN paths p ON ST_DWithin(p.geogr, c.geogr, 1000)
WHERE p.name = 'Flight';

-- 8.2
SELECT c.name FROM cities c
JOIN paths p ON ST_DWithin(p.geogr, c.geogr, 10000)
WHERE p.name = 'Flight';

-- 9
SELECT ST_AsText(ST_Intersection(i.geogr, c.geogr))
FROM islands i, cities c
WHERE i.name = 'Ireland' AND c.name = 'Dublin';


-- 10
SELECT o.name FROM oceans o
JOIN paths p ON ST_Intersects(p.geogr, o.geogr)
WHERE p.name = 'Flight';


-- 11
SELECT ST_CoveredBy(p.geogr, c.geogr)
FROM paths p, continents c
WHERE p.name = 'Flight' AND c.name = 'Eurasia';


-- 12
SELECT i.name FROM islands i
JOIN oceans o ON ST_Contains(o.geogr::geometry, i.geogr::geometry)
WHERE o.name = 'Atlantic Ocean';


-- 13
SELECT ST_AREA(ST_Union(i1.geogr::geometry, i2.geogr::geometry)::geography) / 1000000 
	AS total_area_km1
FROM islands i1, islands i2
WHERE i1.name = 'Great Britain' AND
	i2.name = 'Ireland';
	
-- 13.2
SELECT SUM(ST_AREA(i.geogr)) / 1000000 AS total_area_km2
FROM islands i
WHERE i.name = 'Great Britain' OR i.name = 'Ireland';

/* END QUERIES */

/* START CLEAR MESS */
DELETE FROM cities WHERE name = 'Rome2';
/* END CLEAR MESS */
