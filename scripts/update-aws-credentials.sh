#!/bin/bash

# Exit on any error
set -e

# Ensure account ID is passed
if [ -z "$1" ]; then
  echo "Usage: $0 <account_id>"
  exit 1
fi
doormat login

ACCOUNT_ID="$1"

# Run doormat command and capture the output
DOORMAT_OUTPUT=$(doormat aws export --account "$ACCOUNT_ID")

# Extract values using regex
eval "$DOORMAT_OUTPUT"

# Validate that variables are set
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_SESSION_TOKEN" ]]; then
  echo "Failed to extract AWS credentials"
  exit 1
fi

# Write to ~/.aws/credentials
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
aws_session_token = $AWS_SESSION_TOKEN
EOF

echo "✅ AWS credentials updated in ~/.aws/credentials"