#!/bin/bash - 
#===============================================================================
#
#          FILE: main.sh
# 
#         USAGE: ./main.sh 
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

                        

#source ~/Weatherapp/utils/geocoding.sh
source /home/chubby/Weatherapp/utils/geocoding.sh
source /home/chubby/Weatherapp/utils/weatherapi.sh



#colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color

#cities=cities.txt
#link to geocoding.sh
#link to weatherapi.sh




while true; do
    clear
echo -e "${CYAN}==============================${NC}"
echo -e "${MAGENTA}    THE WEATHER APP           ${NC}"
echo -e "${CYAN}==============================${NC}"

read -rp  "$(echo -e ${YELLOW}Please enter a city name: ${NC})" cityname

if ! geocoding "$cityname"; then
    echo -e "${RED}Cannot continue without valid city coordinates.${NC}"
    main  # re-prompt the user
    return
fi

geocoding "$cityname"



while true; do
    echo " "
    echo " "
    echo " "
    echo " "

echo -e "${GREEN}What would you like to see today?${NC} "
echo -e "${BLUE}1) Current Weather${NC}"
echo -e "${BLUE}2) Compare current vs last hour${NC}"
echo -e "${BLUE}3) Compare current vs yesterday same time${NC}"
echo -e "${BLUE}4) Forecast for a specific date${NC}"
echo -e "${BLUE}5) Full hourly forecast for today${NC}"
echo -e "${BLUE}6) Back to main menu${NC}"
echo -e "${RED}7) Exit${NC}"

read -rp "$(echo -e ${YELLOW}Choose an option[1-7]: ${NC})" option

if !  [[ "$option" =~ ^[0-9]$ ]]; then
        echo -e "${RED}Please enter a valid number${NC}"
        continue
    fi

    if [[ "$option" == 7 ]]; then
        echo -e "${RED}EXITING${NC}"
        exit
    fi

case $option in

    1)
        clear
        echo -e "${CYAN}Printing Current Weather${NC}"
        current_weather "$lat" "$lon" "$cityname"
        ;;
    2)
        clear   
        echo -e "${CYAN}Printing Comparison${NC}"
        compare_one "$lat" "$lon" "$cityname"
        ;;
    3)
        clear
        echo -e "${CYAN}Printing Comparison Two${NC}"
        compare_two "$lat" "$lon" "$cityname"
        ;;
    4)
        clear
        echo -e "${CYAN}Specific Forecast${NC}"
        forecast_date "$lat" "$lon" "$cityname"
        ;;
    5)
        clear
        echo -e "${CYAN}Full Hourly Forecast${NC}"
        full_hour "$lat" "$lon" "$cityname"
        ;;
    6)
        echo "Going back to main menu"
        break
        ;;

    *)
        clear
        echo -e "${RED}Please choose numbers from 1-6${NC}"
        ;;

esac
done
done
