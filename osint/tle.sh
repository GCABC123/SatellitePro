#!/bin/bash



function tle_query(){
    while true; do

        echo -e -n "${CP}\n[*] Retrieve the Two Line Elements (TLE) for a Satellite identified by NORAD id. "

        echo -e -n "${CP}\n[*] NOTE: API REQUESTS limit is 1000 transactions/hour "

        echo -e -n "${CP}\n[*] Enter Satellite ID: "
        read id

        # Verify that the API key is loaded
        if [[ -z "$n2yo_key" ]]; then
            echo -e "[Error] N2YO API key is missing or not loaded. Please check your credentials." >&2
            return 1
        fi



        n2yoKey=$n2yo_key

        dest="https://api.n2yo.com/rest/v1/satellite/"
        echo -e -n "${RED}\n[ 🌐 ] [SATELLITE ID]: $id \n"

        # Fetch and store results in a variable
        results=$(curl -s "$dest/tle/$id?apiKey=$n2yoKey")

        # Display parsed results using jq for each field
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITE NAME]: $(echo "$results" | jq -r '.info.satname') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITE TLE] : $(echo "$results" | jq -r '.tle') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [API REQUESTS ] : $(echo "$results" | jq -r '.info.transactionscount') ✔ \n"


 

        sleep 1

        # Ask user if they want to make another satellite ID TLE request
        echo -e -n "${CP}[*] Do you want to look up the TLE for another Satellite? (y/n): "
        read again
        if [[ "$again" != "y" ]]; then
            break
        fi
    done

    # After exiting the loop, return to the main menu
    echo -e "${GREEN}\n[*] Returning to the Main Menu..."
}


tle_query

