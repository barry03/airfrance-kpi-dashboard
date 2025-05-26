-- Table des vols 2023
CREATE TABLE flights2023 AS 
SELECT * FROM read_csv_auto('/Users/djouldebarry/Desktop/sources_candidate/FLIGHTS_2023.csv');

-- Table des vols 2024
CREATE TABLE flights2024 AS 
SELECT * FROM read_csv_auto('/Users/djouldebarry/Desktop/sources_candidate/FLIGHTS_2024.csv');

-- Table des types d'avions
CREATE TABLE ref_aircraft AS 
SELECT * FROM read_csv_auto('/Users/djouldebarry/Desktop/sources_candidate/REF_AIRCRAFT.csv');

-- Table des compagnies aériennes
CREATE TABLE ref_airlines AS 
SELECT * FROM read_csv_auto('/Users/djouldebarry/Desktop/sources_candidate/REF_AIRLINES.csv');

-- Table des codes de retard
CREATE TABLE ref_delay AS 
SELECT * FROM read_csv_auto('/Users/djouldebarry/Desktop/sources_candidate/REF_DELAY.csv');

-- json file
CREATE TABLE airport_ref AS 
SELECT * FROM read_json_auto('/Users/djouldebarry/Desktop/sources_candidate/airport_ref.json');



-------fusion vols 2023 et vols 2024-------------
CREATE TABLE all_flights AS
SELECT
    FLIGHT_CARRIER_CODE,
    FLIGHT_NUMBER,
    LEG_SCH_DEP_AIRPORT,
    LEG_SCH_DEP_DATE_UTC,
    CAST(LEG_SCH_DEP_TIME_UTC AS VARCHAR) AS LEG_SCH_DEP_TIME_UTC,
    LEG_ACT_DEP_DATE_UTC,
    LEG_ACT_DEP_TIME_UTC,
    LEG_SCH_ARR_AIRPORT,
    LEG_SCH_ARR_DATE_UTC,
    CAST(LEG_SCH_ARR_TIME_UTC AS VARCHAR) AS LEG_SCH_ARR_TIME_UTC,
    LEG_ACT_ARR_DATE_UTC,
    LEG_ACT_ARR_TIME_UTC,
    LEG_DELAY_CODE_1,
    LEG_DELAY_CODE_2,
    LEG_DELAY_CODE_3,
    LEG_DELAY_CODE_4,
    LEG_DELAY_CODE_5
FROM flights2023

UNION ALL

SELECT
    FLIGHT_CARRIER_CODE,
    FLIGHT_NUMBER,
    LEG_SCH_DEP_AIRPORT,
    LEG_SCH_DEP_DATE_UTC,
    CAST(LEG_SCH_DEP_TIME_UTC AS VARCHAR) AS LEG_SCH_DEP_TIME_UTC,
    LEG_ACT_DEP_DATE_UTC,
    LEG_ACT_DEP_TIME_UTC,
    LEG_SCH_ARR_AIRPORT,
    LEG_SCH_ARR_DATE_UTC,
    CAST(LEG_SCH_ARR_TIME_UTC AS VARCHAR) AS LEG_SCH_ARR_TIME_UTC,
    LEG_ACT_ARR_DATE_UTC,
    LEG_ACT_ARR_TIME_UTC,
    LEG_DELAY_CODE_1,
    LEG_DELAY_CODE_2,
    LEG_DELAY_CODE_3,
    LEG_DELAY_CODE_4,
    LEG_DELAY_CODE_5
FROM flights2024;



-----------Création de la table flat_airports---------------
CREATE TABLE flat_airports AS
WITH countries AS (
  SELECT UNNEST(COUNTRY_LIST) AS country FROM airport_ref
),
cities AS (
  SELECT 
    country['COUNTRY_NAME'] AS COUNTRY_NAME,
    UNNEST(country['CITY_LIST']) AS city
  FROM countries
),
airports AS (
  SELECT 
    COUNTRY_NAME,
    UNNEST(city['AIRPORT_LIST']) AS airport
  FROM cities
)

SELECT 
  COUNTRY_NAME,
  airport['AIRPORT_CODE'] AS AIRPORT_CODE
FROM airports;