#!/bin/bash

# Satellite Pro - Main Menu Script
# Manages N2YO, SPACE-TRACK options, OSINT submenus, map generation, and exit controls

# Function to return to main menu
return_to_menu() {
    echo -e "\nReturning to main menu..."
    sleep 1
    main_menu
}



# Function for N2YO Satellite Tracking (stub for calling an actual script)
n2yo_option() {

    echo "=== SPACE-TRACK OSINT Options ==="
    echo "Select an OSINT option:"
    echo "1. GET SATELLITE TLE"
    echo "2. GET SATELLITE FUTURE POSITION"
    echo "3. VISUAL PASS"
    echo "4. RADIO PASS"
    echo "5. SEARCH RADIUS"
    echo "6. Return to Main Menu"
    
    read -rp "Choose an option [1-6]: " space_track_choice
    
    case $space_track_choice in
        1)
            bash ./osint/tle.sh
            ;;
        2)
            bash ./osint/future_positions.sh
            ;;
        3)
            bash ./osint/visual_pass.sh
            ;;
        4)
            bash ./osint/radio_pass.sh
            ;;
        5)
            bash ./osint/search_radius.sh
            ;;
        6)
            return_to_menu
            ;;
        *)
            echo "Invalid option. Please try again."
            space_track_option
            ;;
    esac
}


function space_track_login() {
    echo "Logging in to Space-Track..."
    wget --save-cookies "$COOKIE_FILE" --keep-session-cookies \
        --post-data "identity=$space_track_user&password=$space_track_pass" \
        "$LOGIN_URL" -O /dev/null
    
    if [[ $? -ne 0 ]]; then
        echo "Login failed. Please check your credentials or connectivity."
        exit 1
    fi
    
    # Validate login by checking if the cookie file contains authentication data
    if ! grep -q "space-track.org" "$COOKIE_FILE"; then
        echo "Login failed. Please verify your Space-Track credentials."
        exit 1
    fi
    
    echo "Login successful."
}

# Function to handle SPACE-TRACK API options
space_track_option() {
    while true; do
        echo "=== SPACE-TRACK OSINT Menu ==="
        echo "1. Satellite Catalog Data"
        echo "2. Launch Data by Country"
        echo "3. Decayed Satellites Data"
        echo "4. Satellite Debris Data"
        echo "5. Re-Entry Predictions for Satellites"
        echo "6. Country of Origin (Satellite Ownership)"
        echo "7. Orbital Parameters"
        echo "8. Return to Satellite API Menu"
        
        read -rp "Choose an option [1-8]: " choice
        
        case $choice in
            1)
                echo "Fetching Satellite Catalog Data..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/satcat/format/json" -O satellite_catalog.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Satellite Catalog Data. Please check your connection or credentials."
                    return
                fi
                jq '.' satellite_catalog.json
                ;;
            2)
                echo -n "Enter the country code (e.g., USA, RUS, CHN): "
                read country
                echo "Fetching Launch Data for $country..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/launch_country/Country/$country/format/json" -O launch_data.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Satellite Launch Data. Please check your connection or credentials."
                    return
                fi
                jq '.' launch_data.json
                ;;
            3)
                echo "Fetching Decayed Satellites Data..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/decayed/format/json" -O decayed_satellites.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Decayed Satellites Data. Please check your connection or credentials."
                    return
                fi
                jq '.' decayed_satellites.json
                ;;
            4)
                echo "Fetching Satellite Debris Data..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/debris/format/json" -O satellite_debris.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Satellite Debris Data. Please check your connection or credentials."
                    return
                fi
                jq '.' satellite_debris.json
                ;;
            5)
                echo "Fetching Re-Entry Predictions for Satellites..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/prediction/format/json" -O reentry_predictions.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Re-entry Prediction Data for Satellites. Please check your connection or credentials."
                    return
                fi
                jq '.' reentry_predictions.json
                ;;
            6)
                echo -n "Enter NORAD Catalog Number (unique satellite ID): "
                read norad_id
                echo "Fetching Country of Origin for Satellite with NORAD ID $norad_id..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/satcat/NORAD_CAT_ID/$norad_id/format/json" -O country_of_origin.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Country of Origin for Satellite with NORAD ID $norad_id. Please check your connection or credentials."
                    return
                fi
                jq '.' country_of_origin.json
                ;;
            7)
                echo -n "Enter NORAD Catalog Number (unique satellite ID) for Orbital Parameters: "
                read norad_id
                echo "Fetching Orbital Parameters for Satellite with NORAD ID $norad_id..."
                wget --load-cookies "$COOKIE_FILE" "$BASE_URL/class/omm/NORAD_CAT_ID/$norad_id/orderby/EPOCH%20desc/format/json" -O orbital_parameters.json
                if [[ $? -ne 0 ]]; then
                    echo "Failed to fetch Orbital Parameters for Satellite with NORAD ID $norad_id. Please check your connection or credentials."
                    return
                fi
                jq '.' orbital_parameters.json
                ;;
            8) break ;;
            *) echo "Invalid option. Please select a valid option [1-8]." ;;
        esac
    done
}





# Main menu function
main_menu() {
    clear
    echo "=== Satellite Pro Main Menu ==="
    echo "1. N2YO Satellite Tracking"
    echo "2. SPACE-TRACK OSINT Options"
    echo "3. Generate Map (Folium)"
    echo "4. Exit"
    
    read -rp "Choose an option [1-4]: " choice
    
    case $choice in
        1)
            n2yo_option
            ;;
        2)
            space_track_option
            ;;
        3)
            generate_map
            ;;
        4)
            echo "Exiting Satellite Pro. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            main_menu
            ;;
    esac
}

# Function to generate and display map using Folium
generate_map() {
    echo "Generating map using Folium..."
    python3 generate_map.py
    echo "Map has been generated and displayed in your browser."
    echo "Press Enter to return to the main menu."
    read -r
    return_to_menu
}

# script execution starts here

# Ensure Space-Track credentials are set in environment variables
if [[ -z "$space_track_user" || -z "$space_track_pass" ]]; then
    echo "Please set your Space-Track credentials as environment variables:"
    echo "export space_track_user='your_username'"
    echo "export space_track_pass='your_password'"
    exit 1
fi

BASE_URL="https://www.space-track.org/basicspacedata/query"
LOGIN_URL="https://www.space-track.org/ajaxauth/login"

# Cookie file for session management
COOKIE_FILE="cookies.txt"



space_track_login




# Start the main menu
main_menu





