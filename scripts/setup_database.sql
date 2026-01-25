-- DuckDB Database Setup Script
-- Creates schemas for medallion architecture layers
-- Note: DuckDB does not support COMMENT ON SCHEMA

-- Create Bronze layer schema (Data Lake)
-- Raw source data with minimal transformation
CREATE SCHEMA IF NOT EXISTS bronze_data_lake;

-- Create Silver layer schema (Raw Vault)
-- Data Vault 2.0 core structures (Hubs, Links, Satellites)
CREATE SCHEMA IF NOT EXISTS silver_raw_vault;

-- Create Gold layer schemas (Business Vault and Dimensional)
-- Business Vault with computed fields, bridges, and PIT tables
CREATE SCHEMA IF NOT EXISTS gold_business_vault;

-- Dimensional models (facts and dimensions)
CREATE SCHEMA IF NOT EXISTS gold_dimensional;

-- Create Platinum layer schema (Info Mart)
-- Information marts organized by use case
CREATE SCHEMA IF NOT EXISTS platinum_info_mart;

-- Create reference schema for seeds
-- Reference data: Static lookup tables loaded via dbt seeds
CREATE SCHEMA IF NOT EXISTS reference;

-- Verify schemas created
SELECT 
    schema_name
FROM information_schema.schemata
WHERE schema_name IN (
    'bronze_data_lake',
    'silver_raw_vault',
    'gold_business_vault',
    'gold_dimensional',
    'platinum_info_mart',
    'reference'
)
ORDER BY schema_name;
