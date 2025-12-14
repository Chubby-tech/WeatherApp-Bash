#!/bin/bash - 
#===============================================================================
#
#          FILE: helpers.sh
# 
#         USAGE: ./helpers.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/14/2025 15:49
#      REVISION:  ---
#===============================================================================


# Color codes
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

# -----------------------------
# Decode weather code
# -----------------------------
decode_weathercode() {
    local code="$1"
    case "$code" in
        0)  echo "Clear sky" ;;
        1|2|3) echo "Partly cloudy" ;;
        45|48) echo "Fog" ;;
        51|53|55) echo "Drizzle" ;;
        61|63|65) echo "Rain" ;;
        66|67) echo "Freezing rain" ;;
        71|73|75) echo "Snow" ;;
        77) echo "Snow grains" ;;
        80|81|82) echo "Rain showers" ;;
        85|86) echo "Snow showers" ;;
        95) echo "Thunderstorm" ;;
        96|99) echo "Thunderstorm with hail" ;;
        *) echo "Unknown condition" ;;
    esac
}

# -----------------------------
# Current Weather
# -----------------------------
print_current_weather() {
    local response="$1"

    temp=$(jq -r '.current_weather.temperature // "N/A"' <<< "$response")
    wind=$(jq -r '.current_weather.windspeed // "N/A"' <<< "$response")
    code=$(jq -r '.current_weather.weathercode // -1' <<< "$response")
    condition=$(decode_weathercode "$code")

    echo -e "${CYAN}Current Weather:${NC}"
    echo -e "${YELLOW}Temperature:${NC} ${temp}°C"
    echo -e "${YELLOW}Wind Speed:${NC} ${wind} km/h"
    echo -e "${YELLOW}Condition:${NC} ${condition}"
}

# -----------------------------
# Compare current vs last hour
# -----------------------------
print_compare_one() {
    local response="$1"

    temp_now=$(jq -r '.current_weather.temperature // 0' <<< "$response")
    hour_index=$(date +%H)
    last_hour=$((10#$hour_index - 1))
    ((last_hour<0)) && last_hour=0

    temp_last=$(jq -r ".hourly.temperature_2m[$last_hour] // 0" <<< "$response")

    temp_diff=$(awk "BEGIN { printf \"%.1f\", $temp_now - $temp_last }")

    echo -e "${CYAN}Current Temp:${YELLOW} ${temp_now}°C${NC}"
    echo -e "${CYAN}Last Hour Temp:${YELLOW} ${temp_last}°C${NC}"
    echo -e "${GREEN}Difference:${YELLOW} ${temp_diff}°C${NC}"
    echo " "
    echo " "
    echo " "
    echo " "

}

# -----------------------------
# Compare current vs yesterday same time
# -----------------------------
print_compare_two() {
    local response_today="$1"
    local response_yesterday="$2"

    hour_index=$(date +%H)
    hour_index=$((10#$hour_index))

    temp_today=$(jq -r ".hourly.temperature_2m[$hour_index] // 0" <<< "$response_today")
    temp_yesterday=$(jq -r ".hourly.temperature_2m[$hour_index] // 0" <<< "$response_yesterday")

    temp_diff=$(awk "BEGIN { printf \"%.1f\", $temp_today - $temp_yesterday }")

    echo -e "${CYAN}Today Temp:${YELLOW} ${temp_today}°C${NC}"
    echo -e "${CYAN}Yesterday Temp:${YELLOW} ${temp_yesterday}°C${NC}"
    echo -e "${GREEN}Difference:${YELLOW} ${temp_diff}°C${NC}"
    echo " "
    echo " "
    echo " "
    echo " "
}

# -----------------------------
# Forecast for a specific date
# -----------------------------
print_forecast_date() {
    local response="$1"
    local date="$2"

    if [[ "$(jq -r '.hourly // empty' <<< "$response")" == "" ]]; then
        echo -e "${RED}No forecast data available for ${date}.${NC}"
        return 1
    fi

    echo -e "${CYAN}Hourly Forecast for ${date}:${NC}"

    count=$(jq '.hourly.time | length' <<< "$response")

    for ((i=0; i<count; i++)); do
        time=$(jq -r ".hourly.time[$i]" <<< "$response")
        [[ "$time" != "$date"* ]] && continue

        temp=$(jq -r ".hourly.temperature_2m[$i] // N/A" <<< "$response")
        wind=$(jq -r ".hourly.wind_speed_10m[$i] // N/A" <<< "$response")
        humidity=$(jq -r ".hourly.relative_humidity_2m[$i] // N/A" <<< "$response")
        code=$(jq -r ".hourly.weathercode[$i] // -1" <<< "$response")
        condition=$(decode_weathercode "$code")

        echo -e "${YELLOW}${time}${NC} | Temp: ${temp}°C | Wind: ${wind} km/h | Humidity: ${humidity}% | Condition: ${condition}"
    done
    echo " "
    echo " "
    echo " "
    echo " "


}

# -----------------------------
# Full hourly forecast for today
# -----------------------------
print_full_hour() {
    local response="$1"

    echo -e "${CYAN}Full hourly forecast for today:${NC}"

    count=$(jq '.hourly.time | length' <<< "$response")
    for ((i=0; i<count; i++)); do
        time=$(jq -r ".hourly.time[$i]" <<< "$response")
        temp=$(jq -r ".hourly.temperature_2m[$i] // N/A" <<< "$response")
        wind=$(jq -r ".hourly.wind_speed_10m[$i] // N/A" <<< "$response")
        humidity=$(jq -r ".hourly.relative_humidity_2m[$i] // N/A" <<< "$response")
        code=$(jq -r ".hourly.weathercode[$i] // -1" <<< "$response")
        condition=$(decode_weathercode "$code")

        echo -e "${YELLOW}${time}${NC} | Temp: ${temp}°C | Wind: ${wind} km/h | Humidity: ${humidity}% | Condition: ${condition}"
    done
    echo " "
    echo " "
    echo " "
    echo " "


}



















