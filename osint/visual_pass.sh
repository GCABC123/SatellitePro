#!/bin/bash



function visual_pass(){
    while true; do
        echo -e -n "${CP}\n[*] Get predicted visual passes for any satellite relative to a location on Earth. A "visual pass" is a pass that should be optically visible on the entire (or partial) duration of crossing the sky. For that to happen, the satellite must be above the horizon, illumintaed by Sun (not in Earth shadow), and the sky dark enough to allow visual satellite observation. "
        echo -e -n "${CP}\n[*] NOTE: API REQUESTS limit is 1000 transactions/hour "

        echo -e -n "${CP}\n[*] Enter Satellite ID: "
        read id

        echo -e -n "${CP}\n[*] Enter Observer Latitude: "
        read observer_lat

        echo -e -n "${CP}\n[*] Enter Observer Longitude: "
        read observer_lng

        echo -e -n "${CP}\n[*] Enter Observer Altitude: "
        read observer_alt

        echo -e -n "${CP}\n[*] Enter Number of Days: "
        read days

        echo -e -n "${CP}\n[*] Enter Minumum Visibility (seconds): "
        read min_visibility
        

        # Verify that the API key is loaded
        if [[ -z "$n2yo_key" ]]; then
            echo -e "[Error] N2YO API key is missing or not loaded. Please check your credentials." >&2
            return 1
        fi


        n2yoKey=$n2yo_key


        dest="https://api.n2yo.com/rest/v1/satellite/"
        echo -e -n "${RED}\n[ 🌐 ] [SATELLITE ID]: $id \n"

        # Fetch and store results in a variable
        results=$(curl -s "$dest/visualpasses/$id/$observer_lat/$observer_lng/$observer_alt/$days/$min_visibility?apiKey=$n2yoKey")
        echo -e -n "${RED}\n[ 🌐 ] Retrieving Satellite ($id) passes optically visible at least $min_visibility seconds for next $days days. Observer is located at lat:$observer_lat, lng:$observer_lng, alt: $observer_alt \n"

        # Display parsed results using jq for each field
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITE NAME]: $(echo "$results" | jq -r '.info.satname') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [PASSESS]       : $(echo "$results" | jq -r '.passes') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [PASSES COUNT]  : $(echo "$results" | jq -r '.info.passescount') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [API REQUESTS ] : $(echo "$results" | jq -r '.info.transactionscount') ✔ \n"


 

        sleep 1

        # Ask user if they want to make another QUERY for another satellite.
        echo -e -n "${CP}[*] Do you want to look up VISUAL PASSES for another Satellite? (y/n): "
        read again
        if [[ "$again" != "y" ]]; then
            break
        fi
    done

    # After exiting the loop, return to the main menu
    echo -e "${GREEN}\n[*] Returning to the Main Menu..."
}


visual_pass



