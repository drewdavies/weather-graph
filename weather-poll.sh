#!/bin/bash

# API key generated from https://developer.forecast.io/
#DARK_SKY_API_KEY=""

# Latitude/Longitude
LATITUDE="49.289248"
LONGITUDE="-123.1173364"

# InfluxDB server
INFLUXDB_SERVER="localhost"

# InfluXDB database
INFLUXDB_DATABASE="weather-graph"

# InfluxDB location tag
INFLUXDB_LOCATION="yvr"

# Temp file to contain JSON output from API query
TEMP_FILE="/tmp/yvr.json"

# Unix epoch time rounded to the minute boundary with 9 trailing zeroes for sub second accuracy
INFLUXDB_TIME=$(date -d "$(date +'%Y-%m-%d %H:%M')" +"%s000000000")

# Query data from the Dark Sky API and write to temp file
#curl -s -X GET "https://api.forecast.io/forecast/${DARK_SKY_API_KEY}/${LATITUDE},${LONGITUDE}?units=ca" > $TEMP_FILE

# Change internal field seperator to newline to create array from JSON data
IFS=$'\n'

# Create an array of all the current temperature data parsed from temp file
CURRENT_WEATHER=($(jq -r ".currently.ozone, .currently.temperature, .currently.precipProbability, .currently.precipIntensity, .currently.nearestStormBearing, .currently.nearestStormDistance, .currently.summary, .currently.apparentTemperature, .currently.dewPoint, .currently.humidity, .currently.windSpeed, .currently.windBearing, .currently.visibility, .currently.cloudCover, .currently.pressure" $TEMP_FILE))

# Convert bearings to strings
if [[ ${CURRENT_WEATHER[4]} -ge 349 ]] || [[ ${CURRENT_WEATHER[4]} -lt 11 ]]; then
  STORM_BEARING="N"
elif [[ ${CURRENT_WEATHER[4]} -ge 11 ]] || [[ ${CURRENT_WEATHER[4]} -lt 34 ]]; then
  STORM_BEARING="NNE"
elif [[ ${CURRENT_WEATHER[4]} -ge 34 ]] && [[ ${CURRENT_WEATHER[4]} -lt 56 ]]; then
  STORM_BEARING="NE"
elif [[ ${CURRENT_WEATHER[4]} -ge 56 ]] && [[ ${CURRENT_WEATHER[4]} -lt 79 ]]; then
  STORM_BEARING="ENE"
elif [[ ${CURRENT_WEATHER[4]} -ge 79 ]] && [[ ${CURRENT_WEATHER[4]} -lt 101 ]]; then
  STORM_BEARING="E"
elif [[ ${CURRENT_WEATHER[4]} -ge 101 ]] && [[ ${CURRENT_WEATHER[4]} -lt 124 ]]; then
  STORM_BEARING="ESE"
elif [[ ${CURRENT_WEATHER[4]} -ge 124 ]] && [[ ${CURRENT_WEATHER[4]} -lt 146 ]]; then
  STORM_BEARING="SE"
elif [[ ${CURRENT_WEATHER[4]} -ge 146 ]] && [[ ${CURRENT_WEATHER[4]} -lt 1695 ]]; then
  STORM_BEARING="SSE"
elif [[ ${CURRENT_WEATHER[4]} -ge 169 ]] && [[ ${CURRENT_WEATHER[4]} -lt 191 ]]; then
  STORM_BEARING="S"
elif [[ ${CURRENT_WEATHER[4]} -ge 191 ]] && [[ ${CURRENT_WEATHER[4]} -lt 214 ]]; then
  STORM_BEARING="SSW"
elif [[ ${CURRENT_WEATHER[4]} -ge 214 ]] && [[ ${CURRENT_WEATHER[4]} -lt 236 ]]; then
  STORM_BEARING="SW"
elif [[ ${CURRENT_WEATHER[4]} -ge 236 ]] && [[ ${CURRENT_WEATHER[4]} -lt 259 ]]; then
  STORM_BEARING="WSW"
elif [[ ${CURRENT_WEATHER[4]} -ge 259 ]] && [[ ${CURRENT_WEATHER[4]} -lt 281 ]]; then
  STORM_BEARING="W"
elif [[ ${CURRENT_WEATHER[4]} -ge 281 ]] && [[ ${CURRENT_WEATHER[4]} -lt 304 ]]; then
  STORM_BEARING="WNW"
elif [[ ${CURRENT_WEATHER[4]} -ge 304 ]] && [[ ${CURRENT_WEATHER[4]} -lt 326 ]]; then
  STORM_BEARING="NW"
elif [[ ${CURRENT_WEATHER[4]} -ge 326 ]] && [[ ${CURRENT_WEATHER[4]} -lt 349 ]]; then
  STORM_BEARING="NNW"
<<<<<<< HEAD
fi

# Error handling if a string is received instead of an integer/float
if [[ ${CURRENT_WEATHER[4]} -eq "null" ]]; then
  CURRENT_WEATHER[4]="999"
  STORM_BEARING=""
=======
>>>>>>> parent of cbbab3e... Added error handling for storm bearing
fi

if [[ ${CURRENT_WEATHER[5]} -eq "null" ]]; then
  CURRENT_WEATHER[5]="0"
fi

# Write the data to the InfluxDB API
curl -i -X POST "http://${INFLUXDB_SERVER}:8086/write?db=${INFLUXDB_DATABASE}" --data-binary "${INFLUXDB_LOCATION} ozone=${CURRENT_WEATHER[0]},temperature=${CURRENT_WEATHER[1]},precip_probability=${CURRENT_WEATHER[2]},precip_intensity=${CURRENT_WEATHER[3]},storm_bearing=${CURRENT_WEATHER[4]},storm_bearing_dir=\"${STORM_BEARING}\",storm_distance=${CURRENT_WEATHER[5]},summary=\"${CURRENT_WEATHER[6]}\",apparent_temp=${CURRENT_WEATHER[7]},dewpoint=${CURRENT_WEATHER[8]},humidity=${CURRENT_WEATHER[9]},wind_speed=${CURRENT_WEATHER[10]},wind_bearing=${CURRENT_WEATHER[11]},visibility=${CURRENT_WEATHER[12]},cloud_cover=${CURRENT_WEATHER[13]},pressure=${CURRENT_WEATHER[14]} $INFLUXDB_TIME"
