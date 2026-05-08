#!/bin/bash

# Load environment variables
if [ -f .env.local ]; then
	export $(grep -v '^#' .env.local | xargs)
else
	echo "Error: .env.local file not found."
	exit 1
fi

BASE="https://$DOMAIN"
HANDLE="$CHANNEL@$DOMAIN"

# Obtain Access Token
echo "Authenticating as $USERNAME@$DOMAIN..."
TOKEN_JSON=$(curl -s -X POST "$BASE/api/v1/users/token" \
	-d "client_id=$CLIENT_ID" \
	-d "client_secret=$CLIENT_SECRET" \
	-d "grant_type=password" \
	-d "username=$USERNAME" \
	-d "password=$PASSWORD")

ACCESS_TOKEN=$(echo "$TOKEN_JSON" | jq -r '.access_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
	echo "Error: Authentication failed."
	exit 1
fi

# Iterate through videos
START=0
COUNT=100

echo "Scanning $HANDLE for non-internal videos..."

while :; do
	VIDEOS_JSON=$(curl -s -G "$BASE/api/v1/video-channels/$HANDLE/videos" \
		-H "Authorization: Bearer $ACCESS_TOKEN" \
		-d "start=$START" \
		-d "count=$COUNT")

	DATA=$(echo "$VIDEOS_JSON" | jq -c '.data[]')
	if [ -z "$DATA" ]; then
		break
	fi

	echo "$DATA" | while read -r video; do
		NAME=$(echo "$video" | jq -r '.name')
		UUID=$(echo "$video" | jq -r '.uuid')
		PRIVACY=$(echo "$video" | jq -r '.privacy.id')

		if [ "$PRIVACY" != "4" ]; then
			echo "Updating \"$NAME\" ($UUID) to internal..."
			curl -s -X PUT "$BASE/api/v1/videos/$UUID" \
				-H "Authorization: Bearer $ACCESS_TOKEN" \
				-H "Content-Type: application/json" \
				-d '{"privacy": 4}'
		fi
	done

	# Check if we should continue to the next page
	TOTAL=$(echo "$VIDEOS_JSON" | jq -r '.total')
	START=$((START + COUNT))
	if [ "$START" -ge "$TOTAL" ]; then
		break
	fi
done

echo "Done."
