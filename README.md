# HealthCheck for Sites and Services - Monitoring Script:

## Introduction
This shell script is designed to oversee the health of web services or websites and send notifications if they are experiencing slowness or are non-operational. It can be set to run as a cronjob, continuously checking the status of servers or services and alerting via email whenever there is a change in their operational state. The script utilizes general websites and webservices running on WSO2 servers for monitoring services showcasing its compatibility with WSO2.

## Basic feature list:  
Monitors any HTTP or HTTPS URL, checking for “200” status returned  
Monitors Web-services based on codes in xml response (for checking Admin service of WSO2 server, it checks for RUNNING code in xml response) 
Can be applied to monitor multiple sites/services  
Checks request fulfillment time for slow responses, not just UP/DOWN  
Sends email notification on state change (UP, SLOW, or DOWN)  
Customizable To/From notification settings  
Customizable SLOW latency threshold  
Tracks previous state change and last update to avoid multiple notifications  
Uses single text file for data storage, no DB necessary (configurable to have separate status files for Services and Sites)  
No agents or special software to install

## Monitoring categories 
1. Sites :  Monitor carbon consoles or any http/https sites, checking for “200” status returned  
2. Services :  Monitor Admin service for WSO2 server status, checking for xml response codes  

## Sample Email Response (for status changes)  

Time: 2018-06-28 00:07:56  
Site: https://localhost:9543/console/  
Status: DOWN  
Latency: 0 sec  
Previous status: UP  
Previous change: 2018-06-28 00:06:01  

Time: 2018-06-28 00:07:56  
Service: https://localhost:9443/services/ServerAdmin  
Status: SLOW  
Latency: 15 sec  
Previous status: UP  
Previous change: 2018-06-28 00:06:02  


## Sample Cronjob Definition  
*/5 * * * * root /home/username/HealthCheck.sh 

## Environment
This script (HealthCheck.sh) is tested on MacOS, changes may be required for other unix environments
