#!/usr/bin/env python3
"""Initialize the DuckDB database with medallion architecture schemas."""

import duckdb
import os
from pathlib import Path

def main():
    # Database path relative to project root
    db_path = Path(__file__).parent.parent / "data" / "healthcare.duckdb"
    
    # Remove existing database file if it exists
    if db_path.exists():
        os.remove(db_path)
        print(f"Removed existing database: {db_path}")
    
    # Create fresh database
    conn = duckdb.connect(str(db_path))
    
    # Define schemas
    schemas = [
        "bronze_data_lake",
        "silver_raw_vault",
        "gold_business_vault",
        "gold_dimensional",
        "platinum_info_mart",
        "reference",
    ]
    
    # Create schemas
    for schema in schemas:
        conn.execute(f"CREATE SCHEMA IF NOT EXISTS {schema}")
        print(f"Created schema: {schema}")
    
    # Verify
    result = conn.execute("""
        SELECT schema_name 
        FROM information_schema.schemata 
        WHERE schema_name IN (
            'bronze_data_lake', 'silver_raw_vault', 
            'gold_business_vault', 'gold_dimensional',
            'platinum_info_mart', 'reference'
        )
        ORDER BY schema_name
    """).fetchall()
    
    print(f"\nVerification - {len(result)}/6 schemas exist:")
    for row in result:
        print(f"  - {row[0]}")
    
    conn.close()
    print(f"\nDatabase created successfully at: {db_path}")
    print(f"File size: {db_path.stat().st_size} bytes")

if __name__ == "__main__":
    main()
