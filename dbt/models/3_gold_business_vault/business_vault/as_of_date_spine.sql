{{- config(materialized='table') -}}

SELECT
    UNNEST(generate_series(DATE '2020-01-01', current_date, INTERVAL 1 DAY))::DATE AS as_of_date
