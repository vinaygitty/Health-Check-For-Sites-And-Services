#Add Sites to monitor here
SITES=( \
    "https://aws.amazon.com" \
    "https://www.facebook.com" \
    "https://www.google.com/" \
    "https://localhost:9443/console/" \
    "https://localhost:9543/console/"\        
    )
SITES_STATUS_FILE="/tmp/wso2SiteMonitor.status"

#Add Admin Services to monitor server status here
SERVICES=( \
    "https://localhost:9443/services/ServerAdmin" \
    "https://localhost:9543/services/ServerAdmin" \
    )
SERVICES_STATUS_FILE="/tmp/wso2ServiceMonitor.status"


SLOW_THRESHOLD_SERVICE=4 # Slow threshold for services in Seconds
SLOW_THRESHOLD_SITE=10 # Slow threshold for consoles in Seconds
CURL_TIMEOUT=15 # Curl timeout in seconds

SITE_OK_STATUS=( "200" )
SERCVICE_OK_XML_RESPONSE='<ns:return>RUNNING</ns:return>'

#Base64 encoded string for wso2 user:pwd
AUTH_HEADER="Authorization: Basic YWRtaW46YWRtaW4="


#Note: Configure mail commands in lines 102 and 182 as per your environments mail server configuration
#Email users 
#NOTIFY_FROM_EMAIL='monitoring@xyz.com'
#NOTIFY_TO_EMAIL='mymail@xyz.com'

######### NO USER MOD BELOW THIS LINE ############

echo "* * * Start of Health Check * * *"
echo " "

#--------- Begin: Sites Health Check ------------

for SITE in "${SITES[@]}"
do
    START=$(date +%s)

    RESPONSE=`wget $SITE --no-check-certificate -S -q -O - 2>&1 | \
                  awk '/^  HTTP/{print \$2}'`
    
    END=$(date +%s)
    DIFF=$(( $END - $START ))
    
    if [ -z "$RESPONSE" ]; then
        RESPONSE="0"
    fi


	
    if [[ $RESPONSE = *$SITE_OK_STATUS* ]] 
	then
	    RESPONSE="200"
        if [ "$DIFF" -lt "$SLOW_THRESHOLD_SITE" ]; then
            STATUS="UP"
        else
            STATUS="SLOW"
        fi
    else
        STATUS="DOWN"
    fi

	echo "Site: $SITE is $STATUS"
	echo "Latency is $DIFF seconds"
		
	echo " "

    touch $SITES_STATUS_FILE
    STATUS_LINE=`grep $SITE $SITES_STATUS_FILE`
    STATUS_PARTS=($(echo $STATUS_LINE | tr " " "\n"))
    CHANGED=${STATUS_PARTS[2]}
    if [ "$STATUS" != "${STATUS_PARTS[5]}" ]; then
        #if [ -e "${STATUS_PARTS[5]}" ] || [ "$STATUS" != "UP" ]; then
            if [ -z "${STATUS_PARTS[5]}" ]; then
                STATUS_PARTS[5]="No record"
            fi
            #TIME=`date -d @$END` # Linux format
            TIME=`date -r "$END" "+%Y-%m-%d %H:%M:%S"` #Mac Format
			
            echo "Time: $TIME" > /tmp/SiteMonitor.email.tmp
            echo "Site: $SITE" >> /tmp/SiteMonitor.email.tmp
            echo "Status: $STATUS" >> /tmp/SiteMonitor.email.tmp
            echo "Latency: $DIFF sec" >> /tmp/SiteMonitor.email.tmp
            echo "Previous status: ${STATUS_PARTS[5]}" >> /tmp/SiteMonitor.email.tmp
            if [ -z "${STATUS_PARTS[2]}" ]; then
                TIME="No record"
            else
                #TIME=`date -d @${STATUS_PARTS[2]}` - Linux format
				TIME=`date -r ${STATUS_PARTS[2]} "+%Y-%m-%d %H:%M:%S"` # Mac Format
            fi
            echo "Previous change: $TIME" >> /tmp/SiteMonitor.email.tmp
						
			# Replace below email snippet with your Script for Email notification
            echo "-----Begin: Sending Email Content for Site status--------"
			cat /tmp/SiteMonitor.email.tmp
           # `mail -a "From: $NOTIFY_FROM_EMAIL" \
           #       -s "SiteMonitor Notification: $HOST is $STATUS" \
           #       "$NOTIFY_TO_EMAIL" < /tmp/SiteMonitor.email.tmp`            
			echo "----- End:  Sending Email Content for Site status--------"
		   
            rm -f /tmp/SiteMonitor.email.tmp
        #else
             # first report, but host is up, so no need to notify
        #fi
        CHANGED="$END"
    fi
    echo $SITE $RESPONSE $CHANGED $END $DIFF $STATUS  >> /tmp/SiteMonitor.status.tmp	
	
done
mv /tmp/SiteMonitor.status.tmp $SITES_STATUS_FILE


#--------- End: Sites Health Check ------------


#--------- Begin: Services Health Check ------------

for SERVICE in "${SERVICES[@]}"
do
    START=$(date +%s)
	RAW=`curl -k -sL -H "Content-Type: application/soap+xml;charset=UTF-8;" -H "$AUTH_HEADER" -H "SOAPAction:urn:getServerStatus" --data @getServerStatus.xml --connect-timeout $CURL_TIMEOUT  $SERVICE`
    END=$(date +%s)
    DIFF=$(( $END - $START ))

    if [ -z "$RAW" ]; then
        RESPONSE="NULL"
	else
		RESPONSE="NOT_NULL"
    fi


    if [[ $RAW = *$SERCVICE_OK_XML_RESPONSE* ]] 
	then
        if [ "$DIFF" -lt "$SLOW_THRESHOLD_SERVICE" ]; then
            STATUS="UP"
        else
            STATUS="SLOW"
        fi
    else
        STATUS="DOWN"
    fi	

	echo "Service: $SERVICE is $STATUS"
	echo "Latency is $DIFF seconds"

	echo " "

    touch $SERVICES_STATUS_FILE
    STATUS_LINE=`grep $SERVICE $SERVICES_STATUS_FILE`
    STATUS_PARTS=($(echo $STATUS_LINE | tr " " "\n"))
    CHANGED=${STATUS_PARTS[2]}
    if [ "$STATUS" != "${STATUS_PARTS[5]}" ]; then
        #if [ -e "${STATUS_PARTS[5]}" ] || [ "$STATUS" != "UP" ]; then
            if [ -z "${STATUS_PARTS[5]}" ]; then
                STATUS_PARTS[5]="No record"
            fi
            #TIME=`date -d @$END` # Linux format
            TIME=`date -r "$END" "+%Y-%m-%d %H:%M:%S"` #Mac Format
			
            echo "Time: $TIME" > /tmp/ServiceMonitor.email.tmp
            echo "Service: $SERVICE" >> /tmp/ServiceMonitor.email.tmp
            echo "Status: $STATUS" >> /tmp/ServiceMonitor.email.tmp
            echo "Latency: $DIFF sec" >> /tmp/ServiceMonitor.email.tmp
            echo "Previous status: ${STATUS_PARTS[5]}" >> /tmp/ServiceMonitor.email.tmp
            if [ -z "${STATUS_PARTS[2]}" ]; then
                TIME="No record"
            else
                #TIME=`date -d @${STATUS_PARTS[2]}` - Linux format
				TIME=`date -r ${STATUS_PARTS[2]} "+%Y-%m-%d %H:%M:%S"` # Mac Format
            fi
            echo "Previous change: $TIME" >> /tmp/ServiceMonitor.email.tmp
						
			# Replace below email snippet with your Script for Email notification
            echo "-----Begin: Sending Email Content for Service status--------"
			cat /tmp/ServiceMonitor.email.tmp
           # `mail -a "From: $NOTIFY_FROM_EMAIL" \
           #       -s "ServiceMonitor Notification: $HOST is $STATUS" \
           #       "$NOTIFY_TO_EMAIL" < /tmp/ServiceMonitor.email.tmp`
            
			echo "----- End:  Sending Email Content for Service status--------"
		   
            rm -f /tmp/ServiceMonitor.email.tmp
        #else
             # first report, but host is up, so no need to notify
        #fi
        CHANGED="$END"
    fi
    echo $SERVICE $RESPONSE $CHANGED $END $DIFF $STATUS  >> /tmp/ServiceMonitor.status.tmp	
	
done
mv /tmp/ServiceMonitor.status.tmp $SERVICES_STATUS_FILE

#--------- End: Services Health Check ------------


echo "* * * End of Health Check * * *"



