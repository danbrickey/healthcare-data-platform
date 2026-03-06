{{- config(
    materialized='incremental',
    unique_key=['hk_patient', 'as_of_date']
) -}}

WITH spine AS (
    SELECT as_of_date FROM {{ ref('as_of_date_spine') }}
),

hub AS (
    SELECT hk_patient FROM {{ ref('h_patient') }}
),

hub_dates AS (
    SELECT
        h.hk_patient,
        s.as_of_date
    FROM hub h
    CROSS JOIN spine s
),

sat_latest AS (
    SELECT
        hd.hk_patient,
        hd.as_of_date,
        MAX(sat.hk_patient) AS s_patient_demographics_pk,
        MAX(sat.load_date) AS s_patient_demographics_ldts
    FROM hub_dates hd
    LEFT JOIN {{ ref('s_patient_demographics') }} sat
        ON hd.hk_patient = sat.hk_patient
        AND sat.load_date <= hd.as_of_date
    GROUP BY hd.hk_patient, hd.as_of_date
)

SELECT
    hk_patient,
    as_of_date,
    s_patient_demographics_pk,
    s_patient_demographics_ldts
FROM sat_latest
