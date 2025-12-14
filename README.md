# WeatherApp Bash

A terminal-based weather application written in Bash. Fetches weather data for cities using OpenStreetMap geocoding and the Open-Meteo API. The app supports current weather, comparisons, forecasts, and hourly details.

## Features

- **City Geocoding**: Converts city names to latitude and longitude using OpenStreetMap.
- **Current Weather**: Displays temperature, wind speed, and weather conditions.
- **Hourly Comparison**: Compare current temperature with last hour.
- **Daily Comparison**: Compare today's temperature with the same time yesterday.
- **Forecast**: Get hourly forecast for a specific date.
- **Full Hourly Forecast**: Shows full hourly weather for today.
- **Caching**: Saves city coordinates and weather data in JSON to reduce API calls.

## Requirements

- Bash 5+
- `curl`
- `jq` (for JSON parsing)

## Directory Structure

```

WeatherApp/
│
├── data/                  # Cached city and weather data
│   ├── cities.txt
│   └── history.json
│
├── utils/                 # Utility scripts
│   ├── geocoding.sh
│   ├── weatherapi.sh
│   └── helpers.sh
│
└── main.sh                # Main application entry point

````

## Usage

```bash
# Make sure scripts are executable
chmod +x main.sh utils/*.sh

# Run the app
./main.sh
````

Follow the menu to enter a city name and choose which weather information to display.

## Contribution

Feel free to fork the project, add features, and submit pull requests.

## Author

Chibuike / chubby-tech

```

