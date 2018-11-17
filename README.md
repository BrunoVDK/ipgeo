Crude app ; reads a text file, extracts IPs with regexes and checks which IPs match with the database of country ranges to filter out IPs from a given country. Matches are finally shown in a pop-up.

The text file should be dragged and then dropped onto the app's icon.

The country name used for filtering can be changed in the `AppDelegate.m` file.

Database taken from [here](https://dev.maxmind.com/geoip/legacy/geolite/#IP_Geolocation), saved as 'geo.csv' within the bundle.