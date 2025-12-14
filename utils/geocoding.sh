#!/bin/bash - 
#===============================================================================
#
#          FILE: geocoding.sh
# 
#         USAGE: ./geocoding.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/14/2025 15:48
#      REVISION:  ---
#===============================================================================

                           # Treat unset variables as an error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'  # No Color

cities=/home/chubby/Weatherapp/data/cities.txt

geocoding(){

    local city="$1"

    if grep -i "^$city," /home/chubby/Weatherapp/data/cities.txt >/dev/null; then
        echo -e "${GREEN}$city found in cache${NC}"

        coords=$(grep -i "^$city," /home/chubby/Weatherapp/data/cities.txt)
        lat=$(echo "$coords" | cut -d',' -f2)
        lon=$(echo "$coords" | cut -d',' -f3)

        echo -e "${CYAN}Latitude: ${YELLOW}$lat${NC}, Longitude: ${YELLOW}$lon${NC}"
        echo -e "${CYAN}Connecting to weatherbase${NC}"

    else
        echo -e "${CYAN}Heading to geocoding...${NC}"
        city_encoded=$(echo "$city" | sed 's/ /%20/g')
        response=$(curl -s "https://nominatim.openstreetmap.org/search?q=$city_encoded&format=json&limit=1")

        lat=$(echo "$response" | jq -r '.[0].lat')
        lon=$(echo "$response" | jq -r '.[0].lon')

        if [ "$lat" == "null" ] || [ -z "$lat" ]; then
            echo -e "${RED}City not found via API${NC}"
            return 1
        fi

        echo -e "${CYAN}Latitude: ${YELLOW}$lat${NC}, Longitude: ${YELLOW}$lon${NC}"

        echo "$city,$lat,$lon" >> "$cities"
    fi
}
