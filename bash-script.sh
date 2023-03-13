#!/bin/bash

# Load AWS credentials from environment variables
AWS_ACCESS_KEY="$AWS_ACCESS_KEY"
AWS_SECRET_KEY="$AWS_SECRET_KEY"
S3_BUCKET="$S3_BUCKET"

# Load MySQL credentials from environment variables
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"

# Create a temporary directory
TMP_DIR=$(mktemp -d)

# Dump MySQL database to temporary directory, ignoring logs table
mysqldump --no-tablespaces -u $DB_USER -p$DB_PASS --single-transaction --skip-lock-tables --ignore-table=$DB_NAME.logs $DB_NAME > $TMP_DIR/db.sql


# Create a timestamped zip archive of the dump file
ZIP_FILE="$TMP_DIR/db-$(date +'%Y-%m-%d_%H-%M-%S').zip"
zip -j $ZIP_FILE $TMP_DIR/db.sql

# Copy the zip archive to S3 bucket
aws s3 cp $ZIP_FILE s3://$S3_BUCKET/

# Cleanup
rm -rf $TMP_DIR
