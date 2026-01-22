-- DuckDB Database Setup Script
-- Creates schemas for medallion architecture layers

-- Create Bronze layer schema (Data Lake)
CREATE SCHEMA IF NOT EXISTS bronze_data_lake;
COMMENT ON SCHEMA bronze_data_lake IS 'Bronze layer: Raw source data with minimal transformation';

-- Create Silver layer schema (Raw Vault)
CREATE SCHEMA IF NOT EXISTS silver_raw_vault;
COMMENT ON SCHEMA silver_raw_vault IS 'Silver layer: Data Vault 2.0 core structures (Hubs, Links, Satellites)';

-- Create Gold layer schemas (Business Vault and Dimensional)
CREATE SCHEMA IF NOT EXISTS gold_business_vault;
COMMENT ON SCHEMA gold_business_vault IS 'Gold layer: Business Vault with computed fields, bridges, and PIT tables';

CREATE SCHEMA IF NOT EXISTS gold_dimensional;
COMMENT ON SCHEMA gold_dimensional IS 'Gold layer: Dimensional models (facts and dimensions)';

-- Create Platinum layer schema (Views)
CREATE SCHEMA IF NOT EXISTS platinum_views;
COMMENT ON SCHEMA platinum_views IS 'Platinum layer: Virtualized views organized by use case';

-- Create reference schema for seeds
CREATE SCHEMA IF NOT EXISTS reference;
COMMENT ON SCHEMA reference IS 'Reference data: Static lookup tables loaded via dbt seeds';

-- Verify schemas created
SELECT 
    schema_name,
    schema_comment
FROM information_schema.schemata
WHERE schema_name IN (
    'bronze_data_lake',
    'silver_raw_vault',
    'gold_business_vault',
    'gold_dimensional',
    'platinum_views',
    'reference'
)
ORDER BY schema_name;
