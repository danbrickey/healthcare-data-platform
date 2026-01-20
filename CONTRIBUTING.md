# Contributing to Healthcare Data Platform

Welcome! This guide will help you set up the Healthcare Data Platform on your local machine. Whether you're a developer or an AI assistant, these instructions will get you from zero to a working environment.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Python 3.9 or higher**
  - Check your version: `python3 --version`
  - Download from: https://www.python.org/downloads/

- **pip** (Python package manager)
  - Usually comes with Python
  - Check: `pip3 --version`

- **Git**
  - Check: `git --version`
  - Download from: https://git-scm.com/downloads

- **DuckDB CLI** (recommended for local development)
  - Download from: https://duckdb.org/docs/installation/
  - Optional but helpful for debugging database issues

### Recommended Tools

- **VS Code** - Recommended IDE
  - Download from: https://code.visualstudio.com/

- **VS Code Extensions**:
  - `dbt Power User` - Enhanced dbt development experience
  - `GitHub Copilot` - AI-powered code suggestions
  - `Python` - Python language support
  - `Better Jinja` - Jinja/Jinja2 syntax highlighting
  - `Rainbow CSV` - CSV file highlighting

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/danbrickey/healthcare-data-platform.git
cd healthcare-data-platform
```

### 2. Set Up Python Virtual Environment

Using `venv` (recommended):

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate

# On Windows:
venv\Scripts\activate
```

### 3. Install dbt with DuckDB Adapter

```bash
# Install dbt-duckdb (includes dbt-core)
pip install dbt-duckdb

# Verify installation
dbt --version
```

### 4. Configure dbt Profile

The dbt profile tells dbt how to connect to your database.

```bash
# Create dbt profile directory if it doesn't exist
mkdir -p ~/.dbt

# Copy the example profile to your dbt profiles directory
cp dbt/profiles.yml.example ~/.dbt/profiles.yml
```

**Important**: The `profiles.yml` is configured to use a relative path to the DuckDB database file. All dbt commands should be run from the `dbt/` directory.

### 5. Install dbt Dependencies

```bash
# Navigate to the dbt directory
cd dbt

# Install dbt packages (dbt_utils, etc.)
dbt deps
```

### 6. Verify dbt Setup

```bash
# Still in the dbt/ directory
dbt debug
```

You should see output indicating successful connection to DuckDB. If you see errors, check the Troubleshooting section below.

### 7. Initialize the Database

The first time you set up the project, you'll need to create the database structure:

```bash
# Still in the dbt/ directory
# Run all models to build the data warehouse
dbt run

# Run tests to verify data quality
dbt test
```

## Development Workflow

### Working with dbt

**Important**: Always run dbt commands from the `dbt/` directory to ensure the database path resolves correctly.

```bash
cd dbt
```

#### Common dbt Commands

```bash
# Build all models
dbt run

# Build specific model
dbt run --select model_name

# Build a model and all its downstream dependencies
dbt run --select model_name+

# Build a model and all its upstream dependencies
dbt run --select +model_name

# Run all tests
dbt test

# Run tests for specific model
dbt test --select model_name

# Generate documentation
dbt docs generate

# Serve documentation locally (opens in browser)
dbt docs serve

# Clean generated artifacts
dbt clean

# Compile models without running them
dbt compile

# Show model dependencies
dbt ls --select model_name
```

#### Development Best Practices

1. **Make incremental changes**: Test each model as you build it
2. **Write tests**: Add schema tests in `.yml` files
3. **Document models**: Add descriptions to models and columns
4. **Use staging models**: Clean and standardize source data before transformation
5. **Follow naming conventions**: See `dbt/README.md` for Data Vault 2.0 conventions

### Project Structure

```
healthcare-data-platform/
├── CONTRIBUTING.md          # This file
├── README.md                # Project overview
├── SPECIFICATION.md         # Detailed technical specification
├── data/                    # DuckDB database files (gitignored)
└── dbt/                     # dbt project root
    ├── dbt_project.yml      # dbt project configuration
    ├── profiles.yml.example # Example connection profile
    ├── packages.yml         # dbt package dependencies
    ├── models/              # Data models
    │   ├── staging/         # Source data cleaning
    │   ├── raw_vault/       # Data Vault 2.0 core
    │   │   ├── hubs/        # Business keys
    │   │   ├── links/       # Relationships
    │   │   └── sats/        # Attributes
    │   ├── business_vault/  # Business logic layer
    │   └── marts/           # Reporting layer
    ├── macros/              # Reusable SQL functions
    ├── seeds/               # Static reference data
    ├── tests/               # Custom data tests
    ├── snapshots/           # Slowly changing dimensions
    └── analyses/            # Ad-hoc queries
```

## Working with Evidence (Future)

Evidence is a modern BI tool for creating data visualizations and reports. The Evidence integration is planned for this project but not yet implemented.

### Planned Evidence Setup

When Evidence is added to the project, setup will involve:

```bash
# Install Node.js (prerequisite for Evidence)
# Download from: https://nodejs.org/

# Navigate to evidence project directory (when created)
cd evidence_project

# Install dependencies
npm install

# Start development server
npm run dev
```

The Evidence project will connect to the same DuckDB database that dbt uses, allowing you to query the transformed data for visualizations.

## Data Generation

This project uses synthetic healthcare data generated by Synthea. If you need to generate new data:

1. Download Synthea: https://github.com/synthetichealth/synthea
2. Generate synthetic patients:
   ```bash
   java -jar synthea-with-dependencies.jar -p 1000 Massachusetts
   ```
3. Place the generated CSV files in the `data/raw/` directory
4. Update dbt sources to point to the new files

**Note**: The project is designed to work without raw data files initially, as the Data Vault structure can be built first.

## Troubleshooting

### Common Issues and Solutions

#### `dbt: command not found`

**Problem**: dbt is not installed or not in your PATH.

**Solution**:
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
# or
venv\Scripts\activate     # Windows

# Install or reinstall dbt
pip install dbt-duckdb
```

#### `Credentials in profile.yml invalid`

**Problem**: dbt cannot find or read your profiles.yml file.

**Solution**:
```bash
# Verify profile exists
cat ~/.dbt/profiles.yml

# If not, copy from example
cp dbt/profiles.yml.example ~/.dbt/profiles.yml

# Ensure you're running dbt commands from the dbt/ directory
cd dbt
dbt debug
```

#### `Database path not found`

**Problem**: DuckDB database file path is incorrect.

**Solution**:
- Ensure you're running dbt commands from the `dbt/` directory
- The `profiles.yml` uses a relative path: `../data/healthcare.duckdb`
- This path is relative to the `dbt/` directory

```bash
cd dbt  # Must be in this directory
dbt run
```

#### `Package installation fails`

**Problem**: `dbt deps` fails to install packages.

**Solution**:
```bash
# Clean existing packages
dbt clean

# Clear dbt package cache
rm -rf ~/.dbt/packages

# Reinstall
dbt deps
```

#### `Python version mismatch`

**Problem**: Your Python version is below 3.9.

**Solution**:
- Install Python 3.9 or higher
- Create a new virtual environment with the correct Python version:
```bash
python3.9 -m venv venv
source venv/bin/activate
pip install dbt-duckdb
```

#### `Models fail to run`

**Problem**: `dbt run` fails with SQL errors.

**Solution**:
1. Check the error message for the specific model
2. Run the failing model individually:
   ```bash
   dbt run --select model_name --debug
   ```
3. Verify your source data exists and is in the correct format
4. Check model dependencies: `dbt ls --select +model_name`

### Getting Help

If you encounter issues not covered here:

1. Check the [dbt documentation](https://docs.getdbt.com/)
2. Review the [DuckDB documentation](https://duckdb.org/docs/)
3. Look at project-specific documentation in `SPECIFICATION.md`
4. Open an issue on GitHub with:
   - Your Python and dbt versions
   - Complete error message
   - Steps to reproduce the issue

## Testing Your Setup

To verify everything is working correctly:

```bash
# 1. Navigate to dbt directory
cd dbt

# 2. Check dbt can connect to database
dbt debug

# 3. Install dependencies
dbt deps

# 4. Compile models (doesn't run them)
dbt compile

# 5. If you have source data, run the full pipeline
dbt run
dbt test

# 6. Generate and view documentation
dbt docs generate
dbt docs serve
```

## Code Style and Conventions

### SQL Style

- Use lowercase for SQL keywords: `select`, `from`, `where`
- Use snake_case for table and column names
- Indent nested queries consistently
- Use meaningful CTEs with descriptive names

### Data Vault Naming Conventions

Follow the naming conventions defined in the project:

- **Staging models**: `stg_<source>__<entity>.sql`
- **Hubs**: `hub_<business_key>.sql`
- **Links**: `link_<relationship>.sql`
- **Satellites**: `sat_<hub>_<descriptor>.sql`

See `dbt/README.md` for more details on Data Vault 2.0 conventions.

## Contributing Changes

1. Create a new branch for your work:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and test thoroughly:
   ```bash
   cd dbt
   dbt run --select your_model
   dbt test --select your_model
   ```

3. Commit your changes with clear messages:
   ```bash
   git add .
   git commit -m "Add descriptive commit message"
   ```

4. Push your branch and create a pull request:
   ```bash
   git push origin feature/your-feature-name
   ```

## Additional Resources

- **dbt Documentation**: https://docs.getdbt.com/
- **DuckDB Documentation**: https://duckdb.org/docs/
- **Data Vault 2.0**: https://danlinstedt.com/solutions-2/data-vault-basics/
- **dbt Utils Package**: https://github.com/dbt-labs/dbt-utils
- **Evidence.dev**: https://evidence.dev/
- **Synthea Data Generator**: https://github.com/synthetichealth/synthea

## License

This project is for portfolio and educational purposes. See the repository for licensing information.
