#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

fahrenheit=$1
location=$2
fixedlocation=$3

display_location()
{
  if [[ "$location" == "true" && -n "$fixedlocation" ]]; then
    echo " $fixedlocation"
  elif [[ "$location" == "true" ]]; then
    city=$(curl -s --connect-timeout 2 --max-time 3 https://ipinfo.io/city 2> /dev/null)
    region=$(curl -s --connect-timeout 2 --max-time 3 https://ipinfo.io/region 2> /dev/null)
    if [[ -n "$city" || -n "$region" ]]; then
      echo " $city, $region"
    else
      echo ''
    fi
  else
    echo ''
  fi
}

fetch_weather_information()
{
  display_weather=$1
  # it gets the weather condition textual name (%C), and the temperature (%t)
   curl -sL --connect-timeout 2 --max-time 3 "wttr.in/${fixedlocation// /%20}?format=%C+%t$display_weather"
}

#get weather display
display_weather()
{
  if [[ "$fahrenheit" == "true" ]]; then
    display_weather='&u' # for USA system
  else
    display_weather='&m' # for metric system
  fi
  weather_information=$(fetch_weather_information "$display_weather")

  weather_condition=$(echo "$weather_information" | rev | cut -d ' ' -f2- | rev) # Sunny, Snow, etc
  temperature=$(echo "$weather_information" | rev | cut -d ' ' -f 1 | rev) # +31°C, -3°F, etc
  unicode=$(forecast_unicode "$weather_condition")

  echo "$unicode${temperature/+/}" # remove the plus sign to the temperature
}

forecast_unicode()
{
  weather_condition=$(echo $weather_condition | awk '{print tolower($0)}')

  if [[ $weather_condition =~ 'snow' ]]; then
    echo '❄ '
  elif [[ (($weather_condition =~ 'rain') || ($weather_condition =~ 'shower')) ]]; then
    echo '☂ '
  elif [[ (($weather_condition =~ 'overcast') || ($weather_condition =~ 'cloud')) ]]; then
    echo '☁ '
  elif [[ $weather_condition = 'NA' ]]; then
    echo ''
  else
    echo '☀ '
  fi
}

main()
{
  weather_output="$(display_weather)" || weather_output=""

  location_output=""
  if [[ "$location" == "true" ]]; then
    location_output="$(display_location)" || location_output=""
  fi

  if [[ -n "$weather_output$location_output" ]]; then
    echo "$weather_output$location_output"
  else
    echo "Weather Unavailable"
  fi
}

#run main driver program
main
