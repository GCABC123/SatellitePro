#!/bin/bash



function search_radius(){
    while true; do
        echo -e -n "${CP}\n[*] The function will return altitude, latitude and longitude of satellites footprints to be displayed on a map, and some minimal information to identify the object."
        echo -e -n "${CP}\n[*] NOTE: API REQUESTS limit is 1000 transactions/hour "

   
        echo -e -n "${CP}\n[*] Enter Observer Latitude: "
        read observer_lat

        echo -e -n "${CP}\n[*] Enter Observer Longitude: "
        read observer_lng

        echo -e -n "${CP}\n[*] Enter Observer Altitude: "
        read observer_alt

        echo -e -n "${CP}\n[*] Enter Search Radius (0-90 degreesl 0 - above; 90 -horizon): "
        read search_radius



        echo -e -n "${CP}\n[*] Amateur radio - 18; Celestis - 45; Chinese Space Station	- 54"
        echo -e -n "${CP}\n[*] Beidou Navigation System	35; CubeSats - 32; Disaster monitoring - 8 "
        echo -e -n "${CP}\n[*] Brightest - 1; Earth resources - 6; Education - 29; Engineering - 28"
        echo -e -n "${CP}\n[*] Experimental	- 19; Flock	- 48; Galileo - 22; Geodetic - 27"
        echo -e -n "${CP}\n[*] Geostationary - 10; Global Positioning System (GPS) Constellation - 50; Global Positioning System (GPS) Operational - 20; Globalstar	- 17"
        echo -e -n "${CP}\n[*] Glonass Constellation - 51; Glonass Operational - 21; GOES - 5; Gonets - 40"
        echo -e -n "${CP}\n[*] Gorizont	- 12; Intelsat	- 11; Iridium	- 15; IRNSS	- 46"
        echo -e -n "${CP}\n[*] ISS	- 2; Lemur	- 49; Military	- 30; Molniya	- 14"
        echo -e -n "${CP}\n[*] Navy Navigation Satellite System	- 24; NOAA	- 4; O3B Networks	43; OneWeb	- 53"
        echo -e -n "${CP}\n[*] Orbcomm	- 16; Parus	- 38; QZSS	- 47; Radar Calibration	- 31"
        echo -e -n "${CP}\n[*] Raduga	- 13; Russian LEO Navigation	- 25; Satellite-Based Augmentation System - 23; Search & rescue	- 7"
        echo -e -n "${CP}\n[*] Space & Earth Science	- 26; Starlink	- 52; Strela	- 39; Tracking and Data Relay Satellite System	- 9"
        echo -e -n "${CP}\n[*] Tselina	- 44; Tsikada	- 42 Education - 29; Engineering - 28"
        echo -e -n "${CP}\n[*] Weather	- 3; Westford Needles	- 37; Tsiklon	- 41; TV	- 34"
        echo -e -n "${CP}\n[*] XM and Sirius	- 33; Yaogan	- 36"


        echo -e -n "${CP}\n[*] Enter Category ID  (see abvove): "
        read category_id
        

        # Verify that the API key is loaded
        if [[ -z "$n2yo_key" ]]; then
            echo -e "[Error] N2YO API key is missing or not loaded. Please check your credentials." >&2
            return 1
        fi


        n2yoKey=$n2yo_key


        dest="https://api.n2yo.com/rest/v1/satellite/"

        # Fetch and store results in a variable
        results=$(curl -s "$dest/above/$observer_lat/$observer_lng/$observer_alt/$search_radius/$category_id?apiKey=$n2yoKey")
        echo -e -n "${RED}\n[ 🌐 ] Retrieving Category ($category_id) located within a search radius of $search_radius degrees. Observer is located at lat:$observer_lat, lng:$observer_lng, alt: $observer_alt \n"

        # Display parsed results using jq for each field
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [CATEGORY]: $(echo "$results" | jq -r '.info.category') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITER COUNT]  : $(echo "$results" | jq -r '.info.satcount') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITES]       : $(echo "$results" | jq -r '.above') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [API REQUESTS ] : $(echo "$results" | jq -r '.info.transactionscount') ✔ \n"


 

        sleep 1

        # Ask user if they want to make another RADIO PASS QUERY for another Satellite
        echo -e -n "${CP}[*] Do you want to look up more Satellites within a specified search radius? (y/n): "
        read again
        if [[ "$again" != "y" ]]; then
            break
        fi
    done

    # After exiting the loop, return to the main menu
    echo -e "${GREEN}\n[*] Returning to the Main Menu..."
}


search_radius



