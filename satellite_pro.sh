#!/bin/bash

# Satellite Pro - Main Bash Script
# Description: Main menu and handling of user selections

# Load ASCII art banners from txt directory
display_banner() {
    clear
    cat ./txt/banner.txt
    echo -e "\nWelcome to Satellite Pro - IP and Satellite OSINT Tool\n"
}

# Prompt for API Keys and credentials
get_credentials() {
    echo "Enter your API credentials (stored securely):"
    read -p "N2YO API Key: " n2yo_key
    read -p "Space-Track Username: " space_track_user
    read -s -p "Space-Track Password: " space_track_pass
    read -p "Google Earth Engine API Key: " gee_key

    echo
    # Encrypt and store keys (example using OpenSSL)
    echo "$n2yo_key" | openssl enc -aes-256-cbc -e -out ./credentials/n2yo.enc
    echo "$space_track_user:$space_track_pass" | openssl enc -aes-256-cbc -e -out ./credentials/spacetrack.enc
    echo "$gee_key" | openssl enc -aes-256-cbc -e -out ./credentials/gee.enc
    
}

# Function to decrypt and load credentials
load_credentials() {
    n2yo_key=$(openssl enc -aes-256-cbc -d -in ./credentials/n2yo.enc)
    space_track_creds=$(openssl enc -aes-256-cbc -d -in ./credentials/spacetrack.enc)
    gee_key=$(openssl enc -aes-256-cbc -d -in ./credentials/gee.enc)
    space_track_user="${space_track_creds%:*}"
    space_track_pass="${space_track_creds#*:}"
}

# Error handling function for API key issues
check_credentials() {
    if [[ -z "$n2yo_key" || -z "$space_track_user" || -z "$gee_key" ]]; then
        echo "Error: Missing API credentials. Re-enter credentials."
        get_credentials
    fi
}

# Main menu function
main_menu() {
    display_banner
    echo "Please choose an option:"
    echo "1. Satellite Intel"
    echo "2. Satellite Imagery"
    echo "3. Exit"
    read -p "Selection: " choice
    case $choice in
        1) run_satellite_intel ;;
        2) run_satellite_imagery ;;
        3) exit_script ;;
        *) echo "Invalid choice, please select 1, 2, or 3."; main_menu ;;
    esac
}

# Option 1: Satellite Intel
run_satellite_intel() {
    echo "Starting Satellite Intel..."
    bash ./osint/satellite_api.sh 
    main_menu
}

# Option 2: Satellite Imagery
run_satellite_imagery() {
    echo "Starting Satellite Imagery with Google Earth Engine..."
    python3 ./osint/google_earth_api.py #--geeKey "$gee_key"
    main_menu
}

# Option 3: Exit
exit_script() {
    echo "Exiting Satellite Pro. Goodbye!"
    exit 0
}

# Initial script execution


# Activate the virtual environment
source "$(dirname "$0")/venv/bin/activate"

# get or load/check credentials
if [[ ! -d "./credentials" ]]; then
    mkdir ./credentials
    get_credentials
else
    load_credentials
    check_credentials
fi

chmod +x ./osint/space_track.sh
 


export n2yo_key
export space_track_creds
export gee_key
export space_track_user
export space_track_pass



# Start the main menu
main_menu
