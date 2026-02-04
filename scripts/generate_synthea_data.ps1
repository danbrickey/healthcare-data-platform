# Synthea Data Generation Script (Windows PowerShell)
# Generates synthetic healthcare data using Synthea
#
# ALTERNATIVE: If Java is not available, you can download pre-generated sample data:
#   Invoke-WebRequest -Uri "https://synthetichealth.github.io/synthea-sample-data/downloads/synthea_sample_data_csv_apr2020.zip" -OutFile "data/synthea_sample.zip"
#   Expand-Archive -Path "data/synthea_sample.zip" -DestinationPath "data/synthea" -Force

param(
    [int]$PatientCount = 1000,
    [string]$OutputPath = "data/synthea"
)

$ErrorActionPreference = "Stop"

# Synthea download URL and version
$SYNTHEA_VERSION = "3.0.0"
$SYNTHEA_URL = "https://github.com/synthetichealth/synthea/releases/download/v${SYNTHEA_VERSION}/synthea-with-dependencies.jar"
$SYNTHEA_JAR = "synthea-with-dependencies.jar"

Write-Host "Synthea Data Generation Script" -ForegroundColor Cyan
Write-Host "Target patient count: $PatientCount" -ForegroundColor Cyan
Write-Host "Output directory: $OutputPath" -ForegroundColor Cyan
Write-Host ""

# Check for Java
Write-Host "Checking for Java..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "Java found: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Java is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Java 11 or higher from https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    Write-Host "Creating output directory: $OutputPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

# Download Synthea if not present
if (-not (Test-Path $SYNTHEA_JAR)) {
    Write-Host "Downloading Synthea v${SYNTHEA_VERSION}..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $SYNTHEA_URL -OutFile $SYNTHEA_JAR
        Write-Host "Synthea downloaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to download Synthea" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Synthea JAR found, skipping download" -ForegroundColor Green
}

# Generate data
Write-Host ""
Write-Host "Generating $PatientCount patients..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Yellow

$csvFlag = "-Dexporter.csv.export=true"
$outputFlag = "-Dexporter.baseDirectory=$OutputPath"

try {
    java -jar $SYNTHEA_JAR $csvFlag $outputFlag -p $PatientCount
    Write-Host ""
    Write-Host "Data generation completed successfully!" -ForegroundColor Green
    Write-Host "CSV files are available in: $OutputPath" -ForegroundColor Green
    
    # List generated files
    $csvFiles = Get-ChildItem -Path $OutputPath -Filter "*.csv" | Select-Object -ExpandProperty Name
    Write-Host ""
    Write-Host "Generated files:" -ForegroundColor Cyan
    foreach ($file in $csvFiles) {
        Write-Host "  - $file" -ForegroundColor White
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Data generation failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
