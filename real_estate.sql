-- Only analyze data from Austin, Texas
CREATE VIEW airbnb_austin AS 
/* Only analyze data from Austin, Texas */
SELECT * FROM airbnb_listing
WHERE host_location LIKE 'Austin%'
;


--Zillow data that has extracted only useful features
CREATE VIEW zillow_austin AS 
/* Zillow data that has extracted only useful features 
FILTER only for places that are in Austin */
SELECT SUBSTR(latitude, 1, 9) || SUBSTR(longitude, 1, 9) AS location_id,
	latitude,
	longitude,
	zipcode,
	homeType,
	lotSizeSqFt,
	livingAreaSqFt,
	numOfBedrooms,
	numOfBathrooms,
	numOfStories,
	yearBuilt,
	hasAssociation,
	hasCooling,
	hasGarage,
	hasHeating,
	hasSpa,
	hasView,
	parkingSpaces,
	latest_saledate,
	latest_saleyear,
	latest_salemonth,
	CAST(latestPrice AS NUMERIC) latestPrice
FROM zillow_listing
WHERE city LIKE 'austin'
;



--Count by property type
CREATE VIEW property_type AS 
/* Count by property type */
SELECT  property_type, COUNT(*) AS property_num
FROM airbnb_austin
GROUP BY property_type
ORDER BY property_num DESC;

--rental room_type stats
CREATE VIEW rental_room_type AS
/* rental room_type stats */
SELECT room_type, 
	COUNT(*) AS num_room,
	AVG(accommodates) AS avg_accommodation,
	SUM(accommodates) AS total_accommodation
FROM airbnb_austin
GROUP BY 1
ORDER BY 2 DESC;

CREATE VIEW zillow_hometype AS
/* Display the distince hometypes from zillow_listing
sales data Uses DISTINCT to get the home types */
SELECT DISTINCT(homeType) FROM zillow_austin
;

CREATE VIEW zillow_num_properties AS
/* Number of Zillow listings grouped by homeType  */
SELECT homeType, COUNT(*) AS property_num
FROM zillow_listing
GROUP BY homeType
ORDER BY property_num DESC;

--get typeof price
SELECT price, typeof(price) FROM airbnb_listing;

SELECT price, PRINTF('%.2f', CAST(REPLACE(price, '$', '') AS NUMERIC)) AS num_price
FROM airbnb_listing;

--Average rental price by property type
CREATE VIEW rental_price_by_type AS
/* Average rental price by property type 
   String manipulation and type casting was used to change
   price data into a numeric value */
SELECT property_type,  PRINTF('%.2f', AVG(CAST(REPLACE(price, '$', '') AS NUMERIC))) AS ave_price
FROM airbnb_austin
GROUP BY 1
ORDER BY 2 DESC;

--Rental Price by room type
CREATE VIEW rental_price_room_type AS
/* Rental price by room type using Group By
	typecasting,  AVG function and string manipulation */
SELECT room_type,
	PRINTF('%.2f', AVG(CAST(REPLACE(price, '$', '') AS NUMERIC))) AS ave_price
FROM airbnb_austin
GROUP BY 1
ORDER BY 2 DESC;


--stats on zillow_austin data

CREATE VIEW homeType_stats AS 
/* Uses Agg functions to get summary stats for Zillow data 
 PRINTF used to format floats  */
SELECT homeType,
	 PRINTF('%.0f',MIN(CAST(latestPrice AS NUMERIC))) AS min_price,
     PRINTF('%.0f',AVG(CAST(latestPrice AS NUMERIC))) AS ave_price,
	 PRINTF('%.0f',MAX(CAST(latestPrice AS NUMERIC))) AS max_price,
	 PRINTF('%.0f',MAX(CAST(latestPrice AS NUMERIC)) - MIN(CAST(latestPrice AS NUMERIC))) AS range,
	 COUNT(*) AS num_units
FROM zillow_austin
GROUP BY 1
ORDER BY 6 DESC;



--Types of homes and rentals in Austin
SELECT DISTINCT(homeType) AS house FROM zillow_austin;
SELECT DISTINCT(property_type) AS home FROM airbnb_austin;

--Gov crime data used with zipcodes

CREATE VIEW  austin_crime_data AS 
/* Uses string manipulation to change the date format to YYYY:MM:DD
	And filter for incidents with zip codes or address data, 
	also shrunk the date ranges to match the zillow data*/
SELECT "Incident Number" AS incident_num,
		"Highest Offense Description" AS high_offense_description,
		"Highest Offense Code" AS high_offense_code,
		"Family Violence" AS fam_violence,		
		 SUBSTR("Occurred Date Time", 7, 4) || '-' || SUBSTR("Occurred Date Time", 1, 2) || '-'|| SUBSTR("Occurred Date Time", 4,2) AS occured_at,
		"Report Date Time" AS reported_at,
		Latitude AS lat,
		Longitude AS long,
		 SUBSTR(Latitude, 1, 9) || SUBSTR(Longitude, 1, 9)  AS location_id,
		"Zip Code" AS zipcode
FROM gov_crime
WHERE ((zipcode NOT LIKE '') OR (lat NOT LIKE '')) AND (occured_at BETWEEN '2018-01-22' AND '2021-01-30')


SELECT *
FROM zillow_austin
LIMIT 10;

--Zillow data for analysis
SELECT 
	SUBSTR(latitude, 1, 9) || SUBSTR(longitude, 1, 9) ||  AS location_id,
	zipcode,
	homeType,
	lotSizeSqFt,
	livingAreaSqFt,
	numOfBedrooms,
	numOfBathrooms,
	numOfStories,
	yearBuilt,
	hasAssociation,
	hasCooling,
	hasGarage,
	hasHeating,
	hasSpa,
	hasView,
	parkingSpaces,
	latest_saledate,
	latestPrice
FROM zillow_austin

--Check to see if rentals are all unique
SELECT 
	COUNT(DISTINCT(id)) AS rentals,
	COUNT(*)
FROM airbnb_austin
;

--Austin data for analysis
CREATE VIEW airbnb_data 
/* Table for analyzing airbnb data 
 Uses CASE statement shrink property type from 64 to 4 into a synthetic column
 */
AS SELECT
	 SUBSTR(latitude, 1, 9) ||  SUBSTR(longitude, 1, 9)  AS location_id,
	neighbourhood_cleansed AS zipcode,
	host_since,
	host_response_time,
	CASE WHEN host_response_rate LIKE 'N/A' THEN 0 ELSE CAST((REPLACE(host_response_rate, '%', '') / 100.0) AS NUMERIC) END AS host_response_rate,
	CAST((REPLACE(host_acceptance_rate, '%', '') / 100.0) AS NUMERIC) AS host_acceptance_rate,
	property_type,
	room_type,
	accommodates,
	bathrooms_text,
	CAST(SUBSTR(bathrooms_text, 1, INSTR(bathrooms_text, ' ')-1) AS NUMERIC) AS num_bathrooms,--INSTR for whitespace postition
	CAST(bedrooms AS NUMERIC) AS num_bedrooms,
	CAST(beds AS NUMERIC) AS num_beds,
	PRINTF('%.2f', CAST(REPLACE(price, '$', '') AS NUMERIC)) AS num_price,
	CASE WHEN property_type IN ('Entire guesthouse', 'Entire residential home', 'Entire Townhouse','Entire Condominium(Condo)',
		'Entire home', 'Entire rental unit', 'Entire Bungalow', 'Entire condo', 'Entire Villa', 'Entire Cottage', 'Entire Cabin', 'Tiny House', 'Entire serviced apartment', 'Tiny home',
			'Dome house', 'Earth house', 'casa particular', 'Entire loft', 'Entire place')
			THEN 'Private_Home' 
		 WHEN property_type IN
			('Private room in house', 'Entire guest suite', 'Private room in residential home', 'Private room in cabin', 'Room in bed and breakfast', 'Private room in bungalow', 'Private room in rental unit', 'Private room in condo', 'Private room in twonhouse', 'Private room in bed and breakfast', 'Private room in tiny house', 'Private room in condominium (condo)','Private room in tiny house', 'Private room in floor', 'Room in boutique hotel',
			'Room in hotel', 'Private room in cottage', 'Room in aparthotel','Private room in serviced apartment','Private room in hostel', 'Private room in villa', 'Private room in casa particular')
			THEN 'Private_Room' 
		WHEN property_type IN
			('Shared room in home', 'Shared room in rental unit', 'Shared room in townhouse', 'Shared room in loft', 'Shared room in condo', 'Shared room in hotel', 'Shared room in cabin', 'Shared room in guest suite', 'Shared room in condominium (condo)')
			THEN 'Shared room'
			ELSE
			'Other' END AS house_type
FROM airbnb_austin

CREATE VIEW rental_type_stats AS
/* Uses Agg functions to get summary stats for airbnb data */
SELECT house_type,
	 MIN(num_price) AS min_price,
     AVG(num_price) AS ave_price,
	 MAX(num_price) AS max_price,
	 MAX(num_price) - MIN(num_price) AS range,
	 COUNT(*) AS num_units
FROM airbnb_table
GROUP BY 1

SELECT DISTINCT(property_type)
FROM airbnb_austin;

SELECT COUNT(*)
FROM gov_authorized_rentals
;

SELECT *
FROM gov_authorized_rentals
LIMIT 10;

--Number of authorized rentals per zip code
SELECT PROP_ZIP AS zipcode,
		COUNT(*) as num_auth_rentals
FROM gov_authorized_rentals
GROUP BY 1;

--Criminal instance per zip code
CREATE VIEW crime_with_zipcode AS 
SELECT *
FROM austin_crime_data
WHERE (zipcode  NOT LIKE '') AND (zipcode  NOT LIKE 0)
;

CREATE VIEW crime_by_zipcode AS 
/* Uses group by aggregate incidents by zipcodes */
SELECT zipcode,
	COUNT(*) AS num_crimes
FROM crime_with_zipcode 
GROUP BY 1
ORDER BY 2 DESC
;

-- Price by Zip Code for zillow austin data
CREATE VIEW price_by_zipcode AS
/* Price by Zip Code for zillow austin data 
	Using Group By and AVG */ 
SELECT zipcode, AVG(latestPrice) avg_price
FROM zillow_austin
GROUP BY 1;


CREATE VIEW sale_price_with_crime AS
/* Use a left join to get all the zip codes from crime data 
   That are not included in Zillow sales data */
SELECT c.zipcode, num_crimes, PRINTF('%.0f', avg_price) avg_price
FROM crime_by_zipcode c
LEFT JOIN price_by_zipcode p
ON c.zipcode = p.zipcode;


--How many distnct zip codes in crime data
SELECT COUNT(*) AS num_zip_codes
FROM(
SELECT  DISTINCT(zipcode)
FROM austin_crime_data
WHERE (zipcode  NOT LIKE '') AND (zipcode  NOT LIKE 0));



--Calculate time from last sale zillow
CREATE VIEW sales_delta AS
/* Uses julianday and printf functions to  calculate how the and price of each
	home sold*/
SELECT latest_saledate , 
	 PRINTF('%.2f', (JULIANDAY('2022-06-01') - JULIANDAY(latest_saledate)) / 365) AS delta_years,
	 latestPrice  
FROM zillow_austin
ORDER BY 2
;


--Create buckets for 
CREATE VIEW housing_age AS
/* Create buckets for the the age of the housing stock
	Using the NTILE() Window function 
	Uses JULIANDAY fundtion for date manipulation,
	PRINTF was use to format the string to a float with 2 decimals*/
SELECT latest_saledate , 
	  PRINTF('%.2f', (JULIANDAY('2022-06-01') - JULIANDAY(DATE(yearBuilt || '-' ||'01'|| '-'  ||'01'))) / 365)AS delta_years,
	 latestPrice,
	 NTILE(20) OVER ( ORDER BY PRINTF('%.2f', (JULIANDAY('2022-06-01') - JULIANDAY(DATE(yearBuilt || '-' ||'01'|| '-'  ||'01'))) / 365)) buckets
FROM zillow_austin

SELECT buckets,
	PRINTF('%.0f', AVG(delta_years)) five_pct_years	
FROM housing_age
GROUP BY 1;




--Create hometype histogram us NTILE window
CREATE VIEW apt_freq AS SELECT homeType, latestPrice,
       NTILE (10) OVER (
	   PARTITION BY hometype
	   ORDER BY latestPrice) buckets
FROM zillow_austin



SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.2f', AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Single Family'
GROUP BY 1
;

SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Residential'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Mobile / Manufactured'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Townhouse'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Condo'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Multiple Occupancy'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Apartment'
GROUP BY 1
;

SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'MultiFamily'
GROUP BY 1
;


SELECT buckets,
		COUNT(*) freq,
		PRINTF('%.0f',AVG(latestPrice)) ave_price
FROM apt_freq
WHERE homeType LIKE 'Other'
GROUP BY 1
;



--Authorized rental number versus for number
CREATE VIEW auth_rental_num AS
/* Authorized rental number  joined with gov crime data 
	Used a CTE to simplify the query */
WITH zip_auth AS (SELECT PROP_ZIP, COUNT(*) AS num_auth
    FROM gov_authorized_rentals
	GROUP BY 1),
	zip_zillow AS (SELECT zipcode, COUNT(*) AS num_sales
	FROM zillow_austin
	GROUP BY 1)
	
SELECT a.PROP_ZIP, a.num_auth, z.num_sales
FROM zip_zillow z
JOIN zip_auth a
ON a.PROP_ZIP = z.zipcode
	



--Calculate price vs. date by month
CREATE VIEW price_trends AS
/* Price versus month with a ROW_NUMBER() in a WINDOW FUNCTION to track by date 
	Also, uses a CTE to make the query simplier to read */
WITH sale_month AS (SELECT latest_saleyear,
	CAST(latest_salemonth AS INTEGER) sale_month, 
	PRINTF('%.0f', AVG(latestPrice)) ave_price,
	SUM(latestPrice) total_sales
FROM zillow_austin
GROUP BY 1, 2
ORDER BY 1, 2)


SELECT latest_saleyear, sale_month,  ROW_NUMBER() OVER ( ORDER BY latest_saleyear) month_number, ave_price, total_sales
FROM sale_month;

 
--Zillow sales per zip code
CREATE VIEW zillow_zip_code AS
/* Zillow sales per zip code */
SELECT zipcode, COUNT(*)
FROM zillow_austin
GROUP BY 1;


--Union
CREATE VIEW housing_coordinates AS
/* UNION  the zillow and airbnb data to create a table with coordinates for mapping */
SELECT latitude, longitude, 'Sale' AS type
FROM zillow_austin
UNION
SELECT latitude, longitude, 'Rental'
FROM airbnb_austin