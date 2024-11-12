#!/bin/bash



function future_positions(){
    while true; do

        echo -e -n "${CP}\n[*] Retrieve the future positions of any satellite as groundtrack (latitude, longitude) to display orbits on maps. Also return the satellite's azimuth and elevation with respect to the observer location. Each element in the response array is one second of calculation. First element is calculated for current UTC time."

        echo -e -n "${CP}\n[*] NOTE: API REQUESTS limit is 1000 transactions/hour "

        echo -e -n "${CP}\n[*] Enter Satellite ID: "
        read id

        echo -e -n "${CP}\n[*] Enter Observer Latitude: "
        read observer_lat

        echo -e -n "${CP}\n[*] Enter Observer Longitude: "
        read observer_lng

        echo -e -n "${CP}\n[*] Enter Observer Altitude: "
        read observer_alt

        echo -e -n "${CP}\n[*] Enter Number of Seconds: "
        read seconds



        # Verify that the API key is loaded
        if [[ -z "$n2yo_key" ]]; then
            echo -e "[Error] N2YO API key is missing or not loaded. Please check your credentials." >&2
            return 1
        fi



        n2yoKey=$n2yo_key

        dest="https://api.n2yo.com/rest/v1/satellite/"
        echo -e -n "${RED}\n[ 🌐 ] [SATELLITE ID]: $id \n"

        # Fetch and store results in a variable
        results=$(curl -s "$dest/positions/$id/$observer_lat/$observer_lng/$observer_alt/$seconds?apiKey=$n2yoKey")

        # Display parsed results using jq for each field
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITE NAME]: $(echo "$results" | jq -r '.info.satname') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [FUTURE POSITIONS] : $(echo "$results" | jq -r '.positions') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [API REQUESTS ] : $(echo "$results" | jq -r '.info.transactionscount') ✔ \n"


 

        sleep 1

        # Ask user if they want to make another satellite ID TLE request
        echo -e -n "${CP}[*] Do you want to find the future positions for another Satellite? (y/n): "
        read again
        if [[ "$again" != "y" ]]; then
            break
        fi
    done

    # After exiting the loop, return to the main menu
    echo -e "${GREEN}\n[*] Returning to the Main Menu..."
}


future_positions


