-- Staging model for patients source
-- This model reads from Synthea CSV and applies minimal transformations

{{ config(
    materialized='view',
    schema='bronze_data_lake'
) }}

SELECT
    Id as patient_id,
    BIRTHDATE as birth_date,
    DEATHDATE as death_date,
    SSN as ssn,
    FIRST as first_name,
    LAST as last_name,
    GENDER as gender,
    RACE as race,
    ETHNICITY as ethnicity,
    BIRTHPLACE as birth_place,
    ADDRESS as address,
    CITY as city,
    STATE as state,
    ZIP as zip,
    LAT as latitude,
    LON as longitude
FROM {{ source('synthea', 'patients') }}
