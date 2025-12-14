#!/bin/bash - 
#===============================================================================
#
#          FILE: weatherapi.sh
# 
#         USAGE: ./weatherapi.sh 
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



source /home/chubby/Weatherapp/utils/helpers.sh


#!/bin/bash
set -o nounset

source /home/chubby/Weatherapp/utils/helpers.sh

current_weather() {
    local lat="$1"
    local lon="$2"
    local cityname="$3"

    local history_file="/home/chubby/Weatherapp/data/history.json"
    local today
    today=$(date +%Y-%m-%d)

    mkdir -p /home/chubby/Weatherapp/data
    [[ ! -f "$history_file" ]] && echo '{}' > "$history_file"

    # Check cache
    if jq -e --arg city "$cityname" --arg date "$today" \
        '.[$city][$date]' "$history_file" >/dev/null 2>&1; then

        echo -e "\033[0;32mUsing cached weather for $cityname\033[0m"
        response=$(jq -c --arg city "$cityname" --arg date "$today" \
            '.[$city][$date]' "$history_file")

    else
        echo -e "\033[0;36mFetching new weather data for $cityname...\033[0m"

        response=$(curl -s \
            "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode&start_date=$today&end_date=$today")

        # Validate JSON
        if ! echo "$response" | jq empty >/dev/null 2>&1; then
            echo -e "\033[0;31mInvalid JSON from API\033[0m"
            return 1
        fi

        # 🔥 FIX: read JSON via STDIN, NOT --argjson "$response"
      jq --arg city "$cityname" --arg date "$today" \
   --argjson data "$(echo "$response")" \
   '
   .[$city] = (.[$city] // {}) |
   .[$city][$date] = $data
   ' "$history_file" > /tmp/weather_tmp.json && mv /tmp/weather_tmp.json "$history_file"

    fi

    print_current_weather "$response"
}


compare_one(){
    local lat="$1"
    local lon="$2"
    local cityname="$3"
    local history_file="/home/chubby/Weatherapp/data/history.json"
    local today=$(date +%Y-%m-%d)

  # Ensure history.json exists
    [[ ! -f "$history_file" ]] && echo "{}" > "$history_file"

    # Check if today's data exists in cache
    exists=$(jq -e --arg city "$cityname" --arg date "$today" '.[$city][$date]' "$history_file" 2>/dev/null)

    if [ "$exists" != "" ]; then
        echo -e "\033[0;32mUsing cached weather for $cityname today.\033[0m"
        response=$(jq --arg city "$cityname" --arg date "$today" '.[$city][$date]' "$history_file")
    else
        echo -e "\033[0;36mFetching new weather data for $cityname...\033[0m"
        response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode&start_date=$today&end_date=$today")

        # Validate JSON before using
        if [ -z "$response" ] || ! echo "$response" | jq empty >/dev/null 2>&1; then
            echo -e "\033[0;31mError: API returned invalid or empty JSON.\033[0m"
            return 1
        fi

        # Merge new data into history.json safely
        jq --arg city "$cityname" --arg date "$today" --argjson data "$response" \
           '.[$city][$date] = $data' "$history_file" > tmp.json && mv tmp.json "$history_file"
    fi

     print_compare_one "$response"


}

 compare_two(){
    local lat="$1"
    local lon="$2"
    local cityname="$3"
    local history_file="/home/chubby/Weatherapp/data/history.json"
    local today=$(date +%Y-%m-%d)
    local yesterday=$(date -d "yesterday" +%Y-%m-%d)

    # Ensure history.json exists
    [[ ! -f "$history_file" ]] && echo "{}" > "$history_file"

    # Check if yesterday's data exists
    exists=$(jq -e --arg city "$cityname" --arg date "$yesterday" '.[$city][$date]' "$history_file" 2>/dev/null)

    if [ "$exists" != "" ]; then
        echo -e "\033[0;32mUsing cached weather for $cityname yesterday.\033[0m"
        yesterday_response=$(jq --arg city "$cityname" --arg date "$yesterday" '.[$city][$date]' "$history_file")
    else
        echo -e "\033[0;36mFetching weather data for $cityname yesterday...\033[0m"
        yesterday_response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode&start_date=$yesterday&end_date=$yesterday")

        if [ -z "$yesterday_response" ] || ! echo "$yesterday_response" | jq empty >/dev/null 2>&1; then
            echo -e "\033[0;31mError: API returned invalid or empty JSON.\033[0m"
            return 1
        fi

        # Merge under yesterday key
        jq --arg city "$cityname" --arg date "$yesterday" --argjson data "$yesterday_response" \
           '.[$city][$date] = $data' "$history_file" > tmp.json && mv tmp.json "$history_file"
    fi

    # Also get today's data (current weather)
    today_response=$(jq --arg city "$cityname" --arg date "$today" '.[$city][$date]' "$history_file")

    # Call helper to compare today vs yesterday
    print_compare_two "$today_response" "$yesterday_response"
}


forecast_date(){
    local lat="$1"
    local lon="$2"
    local cityname="$3"
    local history_file="/home/chubby/Weatherapp/data/history.json"

    read -rp "Enter date (YYYY-MM-DD): " target_date

    # Check if date exists in cache
    exists=$(jq -e --arg city "$cityname" --arg date "$target_date" '.[$city][$date]' "$history_file" 2>/dev/null)

    if [ "$exists" != "" ]; then
        echo -e "\033[0;32mUsing cached forecast for $cityname on $target_date.\033[0m"
        response=$(jq --arg city "$cityname" --arg date "$target_date" '.[$city][$date]' "$history_file")
    else
        echo -e "\033[0;36mFetching forecast for $cityname on $target_date...\033[0m"
        response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode&start_date=$target_date&end_date=$target_date")

        if [ -z "$response" ] || ! echo "$response" | jq empty >/dev/null 2>&1; then
            echo -e "\033[0;31mError: API returned invalid or empty JSON.\033[0m"
            return 1
        fi

        jq --arg city "$cityname" --arg date "$target_date" --argjson data "$response" \
           '.[$city][$date] = $data' "$history_file" > tmp.json && mv tmp.json "$history_file"
    fi

    # Call helper to print forecast for the specific date
    print_forecast_date "$response" "$target_date"
}


full_hour(){
    local lat="$1"
    local lon="$2"
    local cityname="$3"
    local history_file="/home/chubby/Weatherapp/data/history.json"
    local today=$(date +%Y-%m-%d)

    # Check if today's data exists
    exists=$(jq -e --arg city "$cityname" --arg date "$today" '.[$city][$date]' "$history_file" 2>/dev/null)

    if [ "$exists" != "" ]; then
        echo -e "\033[0;32mUsing cached hourly forecast for $cityname today.\033[0m"
        response=$(jq --arg city "$cityname" --arg date "$today" '.[$city][$date]' "$history_file")
    else
        echo -e "\033[0;36mFetching hourly forecast for $cityname today...\033[0m"
        response=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weathercode&start_date=$today&end_date=$today")

        if [ -z "$response" ] || ! echo "$response" | jq empty >/dev/null 2>&1; then
            echo -e "\033[0;31mError: API returned invalid or empty JSON.\033[0m"
            return 1
        fi

        jq --arg city "$cityname" --arg date "$today" --argjson data "$response" \
           '.[$city][$date] = $data' "$history_file" > tmp.json && mv tmp.json "$history_file"
    fi

    # Call helper to print full hourly forecast
    print_full_hour "$response"
}






















