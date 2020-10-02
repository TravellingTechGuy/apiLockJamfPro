#!/bin/bash

# Variables
jamfURL="$4"
apiUser="$5"
apiPassword="$6"

deviceLockPasscode="$7"

credentials=$(printf "$apiUser:$apiPassword" | iconv -t ISO-8859-1 | base64 -i -)
echo $credentials
decodedCredentials=$(echo $credentials | base64 --decode)
echo $decodedCredentials

serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
echo $serialNumber

#adding a Jamf Inventory update before locking the device
jamf recon

# Lock the Mac
/usr/bin/curl -X POST \
		$jamfURL/JSSResource/computercommands/command/DeviceLock \
		--header "authorization: Basic $credentials" \
		--header "content-type: application/xml" \
		--data "<computer_command>
			<general>
				<command>DeviceLock</command>
				<passcode>$deviceLockPasscode</passcode>
			</general>
			<computers>
				<computer>
					<serial_number>$serialNumber</serial_number>
				</computer>
			</computers>
		</computer_command>"