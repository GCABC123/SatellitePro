#!/bin/bash



function radio_pass(){
    while true; do
        echo -e -n "${CP}\n[*] The "radio passes" are similar to "visual passes", the only difference being the requirement for the objects to be optically visible for observers. This function is useful mainly for predicting satellite passes to be used for radio communications. The quality of the pass depends essentially on the highest elevation value during the pass, which is one of the input parameters."
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

        echo -e -n "${CP}\n[*] Enter Minumum Elevation: "
        read min_elevation
        

        # Verify that the API key is loaded
        if [[ -z "$n2yo_key" ]]; then
            echo -e "[Error] N2YO API key is missing or not loaded. Please check your credentials." >&2
            return 1
        fi


        n2yoKey=$n2yo_key


        dest="https://api.n2yo.com/rest/v1/satellite/"
        echo -e -n "${RED}\n[ 🌐 ] [SATELLITE ID]: $id \n"

        # Fetch and store results in a variable
        results=$(curl -s "$dest/radiopasses/$id/$observer_lat/$observer_lng/$observer_alt/$days/$min_elevation?apiKey=$n2yoKey")
        echo -e -n "${RED}\n[ 🌐 ] Retrieving Satellite ($id) passes RADIO PASSES above $min_elevation degrees of elevation for next $days days. Observer is located at lat:$observer_lat, lng:$observer_lng, alt: $observer_alt \n"

        # Display parsed results using jq for each field
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [SATELLITE NAME]: $(echo "$results" | jq -r '.info.satname') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [PASSESS]       : $(echo "$results" | jq -r '.passes') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [PASSES COUNT]  : $(echo "$results" | jq -r '.info.passescount') ✔ \n"
        echo -e -n "${BLUE}\n[ 🌐 ]   ➟ [API REQUESTS ] : $(echo "$results" | jq -r '.info.transactionscount') ✔ \n"


 

        sleep 1

        # Ask user if they want to make another RADIO PASS QUERY for another Satellite
        echo -e -n "${CP}[*] Do you want to look up RADO PASSES for another Satellite? (y/n): "
        read again
        if [[ "$again" != "y" ]]; then
            break
        fi
    done

    # After exiting the loop, return to the main menu
    echo -e "${GREEN}\n[*] Returning to the Main Menu..."
}


radio_pass



