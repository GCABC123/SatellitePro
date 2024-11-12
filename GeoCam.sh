#!/bin/bash

# Function to query Shodan API for webcams by geo location using Shodan CLI
function search_webcams() {
    # Prompt user for geo location (latitude and longitude)
    read -p "Enter latitude: " latitude
    read -p "Enter longitude: " longitude
    read -p "Enter search radius (km): " radius

    # Define the search query
    query="webcam geo:$latitude,$longitude,$radius"

    # Make the API request with Shodan CLI
    echo "Searching for webcams near ($latitude, $longitude) with a $radius km radius..."
    shodan search "$query"
}

# Main menu function
function main_menu() {
    while true; do
        echo ""
        echo "===== Shodan Webcam Search ====="
        echo "1) Enter Geo Location Data"
        echo "2) Exit"
        echo "================================"
        read -p "Select an option (1 or 2): " choice

        case $choice in
            1)
                search_webcams
                ;;
            2)
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

# Run the main menu
main_menu
