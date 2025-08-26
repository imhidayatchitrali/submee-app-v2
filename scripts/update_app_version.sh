#!/bin/bash

APP_VERSION=$(grep -m 1 'version:' pubspec.yaml | sed 's/version: //')

# Execute the API request
echo "Updating app version to $APP_VERSION for $ENVIRONMENT environment..."

# Create the JSON payload with single quotes around the entire JSON object
# and double quotes within the JSON structure
RESPONSE=$(curl -s -X PUT "$API_BASE_URL/version" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"version":"'"$APP_VERSION"'","androidBuildNumber":'"$ANDROID_BUILD_NUMBER"',"iosBuildNumber":'"$IOS_BUILD_NUMBER"',"environment":"'"$ENVIRONMENT"'","requiredUpdate":'"$REQUIRED_UPDATE"'}')

echo "Response: $RESPONSE"
# Check if the request was successful
if echo "$RESPONSE" | grep -q '"success":true'; then
  echo "✅ Successfully updated app version!"
else
  echo "❌ Failed to update app version!"
  echo "Response: $RESPONSE"
  exit 1
fi