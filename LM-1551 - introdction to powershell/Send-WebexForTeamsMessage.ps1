﻿<#

.SYNOPSIS
Send-WebexForTeamsMessage, Send a Message to a Webex for Teams Room

.DESCRIPTION
Send-WebexForTeamsMessage, Send a Message to a Webex for Teams Room

.NOTES
John McDonough, Cisco Systems, Inc. (jomcdono)

.PARAMETER apiToken
Your Webex for Teams API Token

.PARAMETER roomName
A Webex for Teams Room Name

.PARAMETER message
The Webex for Teams Message you wish to Send

.EXAMPLE
Send-WebexForTeamsMessage.ps1 -ApiToken "ZDNiZmFiOWEtN2Y3Zi00YjI3LWI3NWItYmNkNzQxOTUyYmZiNWQ0ZTY5N2ItOTlj" -RoomName "DevNet Express DCI Event Room" -Message "I have completed the Introduction to PowerShell Mission"

#>
param(
  [Parameter(Mandatory=$true,HelpMessage="Enter your API Token - put in double quotes `" please.")]
    [string] $apiToken,

  [Parameter(Mandatory=$true,HelpMessage="Enter a Room Name - put in double quotes `" please.")]
  [AllowEmptyString()]
    [string] $roomName,

  [Parameter(Mandatory=$true,HelpMessage="Enter a message - put in double quotes `" please.")]
  [AllowEmptyString()]
    [string] $message
);

# Set up the Header

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Ssl3 -bor [System.Net.SecurityProtocolType]::Tls -bor [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12

    $headers = @{"Authorization" = "Bearer $apiToken"; "Content-Type" = "application/json"; "Acccept" = "application/json"}

    try {
        # Get the Id of the Room
        if ($roomName.Length -gt 0) {
            $roomId = Invoke-RestMethod -Uri https://api.ciscospark.com/v1/rooms -Headers $headers | %{$_.items | ?{$_.title -eq $roomName} |  Select-Object id}
        } else {
            Write-Host "Please specify a Room."
            exit
        }

        # Send a Message to the Room
        if ($roomId) {
            if ($message.Length -gt 0) {
                $invokeRestResponse = Invoke-RestMethod -Uri https://api.ciscospark.com/v1/messages -Method POST -Headers $headers -Body $('{"roomId":"' + $roomId.id + '", "text": "' + $message + '"}')
                if ($invokeRestResponse.id) {
                    Write-Host "The message was successfully sent"
                }
            } else {
                Write-Host "Please specify a Message."
                exit
            }
        } else {
            Write-Host -ForegroundColor Red "Room: `"$roomName`" was not found!"
        }
    } catch {
        Write-Host "There seems to be a problem!"
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        exit
    }
