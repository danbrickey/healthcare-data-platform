#!/bin/bash
# Synthea Data Generation Script (Unix/Linux/macOS)
# Generates synthetic healthcare data using Synthea

set -e

# Default values
PATIENT_COUNT=${1:-1000}
OUTPUT_PATH=${2:-data/synthea}

# Synthea download URL and version
SYNTHEA_VERSION="3.0.0"
SYNTHEA_URL="https://github.com/synthetichealth/synthea/releases/download/v${SYNTHEA_VERSION}/synthea-with-dependencies.jar"
SYNTHEA_JAR="synthea-with-dependencies.jar"

echo "Synthea Data Generation Script"
echo "Target patient count: $PATIENT_COUNT"
echo "Output directory: $OUTPUT_PATH"
echo ""

# Check for Java
echo "Checking for Java..."
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed or not in PATH"
    echo "Please install Java 11 or higher"
    echo "  macOS: brew install openjdk@11"
    echo "  Ubuntu/Debian: sudo apt-get install openjdk-11-jdk"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo "Java found: $JAVA_VERSION"

# Create output directory
if [ ! -d "$OUTPUT_PATH" ]; then
    echo "Creating output directory: $OUTPUT_PATH"
    mkdir -p "$OUTPUT_PATH"
fi

# Download Synthea if not present
if [ ! -f "$SYNTHEA_JAR" ]; then
    echo "Downloading Synthea v${SYNTHEA_VERSION}..."
    if command -v curl &> /dev/null; then
        curl -L -o "$SYNTHEA_JAR" "$SYNTHEA_URL"
    elif command -v wget &> /dev/null; then
        wget -O "$SYNTHEA_JAR" "$SYNTHEA_URL"
    else
        echo "ERROR: Neither curl nor wget found. Please install one to download Synthea."
        exit 1
    fi
    echo "Synthea downloaded successfully"
else
    echo "Synthea JAR found, skipping download"
fi

# Generate data
echo ""
echo "Generating $PATIENT_COUNT patients..."
echo "This may take several minutes..."

CSV_FLAG="-Dexporter.csv.export=true"
OUTPUT_FLAG="-Dexporter.baseDirectory=$OUTPUT_PATH"

if java -jar "$SYNTHEA_JAR" $CSV_FLAG $OUTPUT_FLAG -p "$PATIENT_COUNT"; then
    echo ""
    echo "Data generation completed successfully!"
    echo "CSV files are available in: $OUTPUT_PATH"
    echo ""
    echo "Generated files:"
    ls -1 "$OUTPUT_PATH"/*.csv | xargs -n1 basename | sed 's/^/  - /'
else
    echo ""
    echo "ERROR: Data generation failed"
    exit 1
fi
