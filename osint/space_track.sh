#!/bin/bash



BASE_URL="https://www.space-track.org/basicspacedata/query"

# Login credentials for wget
#CREDENTIALS="--user=$space_track_user --password=$space_track_pass"

# Function to prompt user and perform Space-Track API queries
function fetch_data() {
    case $1 in
        1)  # Satellite Catalog Data
            echo "Fetching Satellite Catalog Data..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/satcat/format/json" -O satellite_catalog.json
            jq '.' satellite_catalog.json
            ;;

        2)  # Launch Data by Country
            echo -n "Enter the country code (e.g., USA, RUS, CHN): "
            read COUNTRY
            echo "Fetching Launch Data for $COUNTRY..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/launch_country/Country/$COUNTRY/format/json" -O launch_data.json
            jq '.' launch_data.json
            ;;

        3)  # Decayed Satellites Data
            echo "Fetching Decayed Satellites Data..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/decayed/format/json" -O decayed_satellites.json
            jq '.' decayed_satellites.json
            ;;

        4)  # Satellite Debris Data
            echo "Fetching Satellite Debris Data..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/debris/format/json" -O satellite_debris.json
            jq '.' satellite_debris.json
            ;;

        5)  # Re-Entry Predictions for Satellites
            echo "Fetching Re-Entry Predictions for Satellites..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/prediction/format/json" -O reentry_predictions.json
            jq '.' reentry_predictions.json
            ;;
        
        6)  # Country of Origin (Satellite Ownership)
            echo -n "Enter NORAD Catalog Number (unique satellite ID): "
            read NORAD_CAT_ID
            echo "Fetching Country of Origin for Satellite with NORAD ID $NORAD_CAT_ID..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/satcat/NORAD_CAT_ID/$NORAD_CAT_ID/format/json" -O country_of_origin.json
            jq '.' country_of_origin.json
            ;;

        7)  # Orbital Parameters
            echo -n "Enter NORAD Catalog Number (unique satellite ID) for Orbital Parameters: "
            read NORAD_CAT_ID
            echo "Fetching Orbital Parameters for Satellite with NORAD ID $NORAD_CAT_ID..."
            wget --keep-session-cookies --load-cookies=cookies.txt "$BASE_URL/class/omm/NORAD_CAT_ID/$NORAD_CAT_ID/orderby/EPOCH%20desc/format/json" -O orbital_parameters.json
            jq '.' orbital_parameters.json
            ;;

        *)  
            echo "Invalid option. Please select a number from 1 to 7."
            ;;
    esac
}

# Main menu loop

# obtain a session cookie good for ~2 hours 
wget  --post-data='identity=space_track_user&password=space_track_pass!' --cookies=on --keep-session-cookies --save-cookies=cookies.txt 'https://www.space-track.org/ajaxauth/login' -olog


while true; do
    echo "Select a query to fetch data from Space-Track:"
    echo "1. Satellite Catalog Data"
    echo "2. Launch Data by Country"
    echo "3. Decayed Satellites Data"
    echo "4. Satellite Debris Data"
    echo "5. Re-Entry Predictions for Satellites"
    echo "6. Country of Origin (Satellite Ownership)"
    echo "7. Orbital Parameters"
    echo "8. Exit"
    echo -n "Enter your choice [1-8]: "
    read CHOICE

    if [[ $CHOICE -eq 8 ]]; then
        echo "Exiting..."
        break
    fi

    fetch_data $CHOICE
done
