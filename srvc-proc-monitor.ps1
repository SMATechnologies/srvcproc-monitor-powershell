	<#
	.SYNOPSIS
        This script checks if a service or a process is running or is stopped on the local system.
        Can run on Single mode (1 check) or Timed mode (several checkes during a period of time).

	.DESCRIPTION
        This script gives the ability to check if a process or a service is running/stopped on the local machine,
        based on parameters.
        The script finishes ok if there is match between the request (parameters) and the result.
        The script fails with Exit Code 200 if there is not a match between the request and the results.

    .PARAMETERS
        -Mode (String) - Identifies if it is a single check or if the script is going to run 
        for a specified period of time.
        Expected values are:
        ---> "single" (default) if one time execution (1 check).
        ---> "timed" if the script will run for a specified period of time. See other parameters for more details.

        -Type (String: Default = "Service") - Identifies a service or a process is going to be monitored.
        Expected values are:
        ---> "service" (default) if monitoring a service.
        ---> "process" if monitoring a process/application.

        -Name [REQUIRED] (String) - It is the name of the service or process to be monitored.
        ---> If looking for a service, check the name (not the description) of the service within Windows Service Manager.
        --- ---> Example: SMA OpCon Service Manager (Description) = SMA_ServMan (Name)
        ---> If looking for a process, first check how Windows names the process.
        --- ---> Example: Microsoft Word (winword.exe) = winword

        -Status (String) - The status you want to check.
        Expected values are:
        ---> "Running" (default)
        ---> "Stopped"
        
        -StartDate (String) - Only used if -Mode "Timed". Defines the Date to start looking for the service/process.
        ---> Format: MM/dd/yyyy
        ---> Default is current date.

        -EndDate (String) - Only used if -Mode "Timed". Defines the Date to stop looking for the service/process.
        ---> Format: MM/dd/yyyy
        ---> Default is current date.

        -StartTime (String) - Only used if -Mode "Timed". Defines the Time to start looking for the service/process.
        ---> Format: HH:mm:ss (24 hour)
        ---> Default is "00:00:00"

        -EndTime (String) - Only used if -Mode "Timed". Defines the End Time to stop looking for the service/process.
        ---> Format: HHmmss (24 hour)
        ---> Default is "23:59:55"

        -Interval (Integer) - Only used if -Mode "Timed". Defines the ammount of SECONDS 
        the script will sleep until the next check.
        ---> Format: n
        ---> Default: 5

	.PARAMETERS VALUES EXAMPLES
        1 - Single Execution Service Running
        This will perform 1 check.
        ---> If the service 'SMA_ServMan" is running, the script ends with exit code 0.
        ---> If the service 'SMA_ServMan" is NOT running, the script ends with exit code 200.
        -Mode "Single" -Type "Service" -Name "SMA_ServMan" -Status "Running"
        
        2 - Single Execution Service Stopped
        This will perform 1 check.
        ---> If the service 'SMA_ServMan" is NOT running, the script ends with exit code 0.
        ---> If the service 'SMA_ServMan" is running, the script ends with exit code 200.
        -Mode "Single" -Type "Service" -Name "SMA_ServMan" -Status "Stopped"
        
        3 - Single Execution Process Running
        This will perform 1 check.
        ---> If the process 'SMAServMan.exe" is running, the script ends with exit code 0.
        ---> If the process 'SMAServMan.exe" is NOT running, the script ends with exit code 200.
        -Mode "Single" -Type "Process" -Name "SMAServMan" -Status "Running"
        
        4 - Single Execution Process Stopped
        This will perform 1 check.
        ---> If the process 'SMAServMan.exe" is NOT running, the script ends with exit code 0.
        ---> If the process 'SMAServMan.exe" is running, the script ends with exit code 200.
        -Mode "Single" -Type "Process" -Name "SMAServMan" -Status "Stopped"

        5 - Timed Execution Service Running Default values
        This will perform check every 5 seconds on the current date starting at 00:00:00 or immediately.
        ---> If the service 'SMA_ServMan" is running by the time the script stats, the script ends with exit code 0.
        ---> If the service 'SMA_ServMan" is NOT running by the time the script stats, the script ends with exit code 200.
        ---> If the status of the service changes to stop during the execution (before EndTime) the script ends with exit code 200.
        -Mode "Timed" -Name "SMA_ServMan"
        ---> Default values:
        --- ---> -Type "Service" -StartDate "<current date>" -EndDate "<current date>" -StartTime "00:00:00" -EndTime "23:59:55" 

        6 - Timed Execution Service Running Specific Date/Time Period
        This will perform check every 5 seconds on a specif date/time.
        ---> If the service 'SMA_ServMan" is running by the time the script stats, the script ends with exit code 0.
        ---> If the service 'SMA_ServMan" is NOT running by the time the script stats, the script ends with exit code 200.
        ---> If the status of the service changes to stop during the execution (before EndTime) the script ends with exit code 200.
        -Mode "Timed" -Name "SMA_ServMan" -StartDate "08/13/2020>" -EndDate "08/13/2020" -StartTime "08:00:00" -EndTime "23:59:55" 
        ---> If the script starts before 8:00 AM, it will wait until 8:00:00 to start monitoring for the service

    .VERSION HISTORY
        8/13/2020 - Version 1.2.200813
        ---> Rewrote the script to have a better logic.
        --- ---> Using functions and re-using code.
        --- ---> Improved Timed mode (wait for a specific time to start monitoring)
        --- ---> Added additional output information

        8/09/2020 - Version 1.1.200809
        ---> Added basic "Timed" mode.
        ---> Only single execution was avaialable

        8/06/2020 - Version 1.0.200806
        ---> Finished first version of the script.
        ---> Only single execution was avaialable
    #>

# Params for the script
param (
    $mode="Single",
    $type="Service",
    $name,
    $status="Running",
    $startDate=(Get-Date -Format ("MM/dd/yyyy")),
    $endDate=(Get-Date -Format ("MM/dd/yyyy")),
    $startTime="00:00:00",
    $endTime="23:59:55",
    $interval=5
)
function listParams {
    param(
        $mode,
        $type,
        $name,
        $status,
        $startDate,
        $endDate,
        $startTime,
        $endTime,
        $interval
    )
    $tmp = Get-Date -Format ("MM/dd/yyyy HH:mm:ss")
    Write-Host $tmp `t " **** Version 1.2.200813 ****`r"
    Write-Host $tmp `t " List of Parameters and Values `r"
    Write-Host $tmp `t " Variable  " `t `t "Value `r"
    Write-Host $tmp `t " ==========" `t `t "===== `r"
    Write-Host $tmp `t " -Mode     " `t `t $mode `r
    Write-Host $tmp `t " -Type     " `t `t $type `r
    Write-Host $tmp `t " -Name     " `t `t $name `r

    if ($status -eq "Running"){
        Write-Host $tmp `t " -Status   "  `t `t "$status (Default) `r" }
    else{
        Write-Host $tmp `t " -Status   "  `t `t "$status `r" }

    if($startDate -eq (Get-Date -Format ("MM/dd/yyyy"))){
        Write-Host $tmp `t " -StartDate"  `t `t "$startDate (Default: Today) `r" 
    }
    else{
        Write-Host $tmp `t " -StartDate"  `t `t $startDate `r
    }
    if($startTime -eq "00:00:00"){
        Write-Host $tmp `t " -StartTime" `t `t "$startTime (Default) `r"
    }
    else{
        Write-Host $tmp `t " -StartTime" `t `t $startTime `r
    }
    if($endDate -eq (Get-Date -Format ("MM/dd/yyyy"))){
        Write-Host $tmp `t " -EndDate  "  `t `t "$endDate (Default: Today) `r"
    }
    else{
        Write-Host $tmp `t " -EndDate  "  `t `t $endDate `r
    }
    if($endTime -eq "23:59:59"){
    Write-Host $tmp `t " -EndTime  " `t `t "$endTime (Default) `r"
    }
    else{
        Write-Host $tmp `t " -EndTime  " `t `t $endTime `r
    }
    if($interval -eq 5){
        Write-Host $tmp `t " -Interval " `t `t "5 seconds (Default) `r"
    }
    else{
        Write-Host $tmp `t " -Interval" `t `t $endinterval "seconds `r"
    }
    Write-Host `r
    $exitCode = 0
    return $exitCode
}

function paramValidation {
    param (
        $mode,
        $type,
        $name,
        $status,
        $startDate,
        $endDate,
        $startTime,
        $endTime,
        $interval
    )
    $tmp = Get-Date -Format ("MM/dd/yyyy HH:mm:ss")
    if ($mode -ne "Single" -and ($mode -ne "Timed")){
        $exitCode = 100
        Write-Host $tmp `t 'Parameter "-Mode" must be "Single" or "Timed"' `r
    }
    else {
        $exitCode = 0
    }
    if ($exitCode -eq 0) {
        if ($type -ne "Service" -and ($type -ne "Process")){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-Type" must be "Service" or "Process"' `r
        }
        else {
            $exitCode = 0
        }
    }
    if ($exitCode -eq 0){
        if ($status -ne "Running" -and ($status -ne "Stopped")){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-Status" must be "Running" or "Stopped"' `r
        }
        else {
            $exitCode = 0
        }
    }
    if ($exitCode -eq 0){
        if ($name -eq ""){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-Name" cannot be null' `r
        }
        else {
            $exitCode = 0
        }
    }
    if ($exitCode -eq 0){
        if (-not ($interval -match "^[\d]*$")){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-Interval" must be an integer' `r
        }
        else {
            $exitCode = 0
        }
    }
    # Dates validation
    if ($exitCode -eq 0){
        try {
            Get-Date -Date $startDate -Format "MM/dd/yyyy" | Out-Null
            $exitCode = 0
        }
        catch{
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-StartDate" must be in "MM/dd/yyyy" format.' `r
        }
    }
    if ($exitCode -eq 0){
        try {
            Get-Date -Date $endDate -Format "MM/dd/yyyy" | Out-Null
            $exitCode = 0
        }
        catch{
            $exitCode = 100
            Write-Host $tmp `t 'Parameter "-EndDate" must be in "MM/dd/yyyy" format.' `r
        }
    }
    $tmpStartDateTime = (Get-Date -Date $startDate -Format ("MM/dd/yyyy")) + " " + (Get-Date -Date $startTime -Format ("HH:mm:ss"))
    $tmpEndDateTime = (Get-Date -Date $endDate -Format ("MM/dd/yyyy")) + " " + (Get-Date -Date $endTime -Format ("HH:mm:ss"))
    if ($exitCode -eq 0){
        $tmpDif = New-TimeSpan -Start $tmpStartDateTime -End $tmpEndDateTime
        if($tmpDif -le 0){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter mismatch. End Date/Time (-EndDate & -EndTime) cannot be prior to Start Date/Time (-StartDate & -StartTime).' `r
        }
        else{
            $exitCode =0
        }
    }
    if ($exitCode -eq 0){
        if($startDate -lt (Get-Date -Format ("MM/dd/yyyy")) -or ($endDate -lt (Get-Date -Format ("MM/dd/yyyy")))){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter mismatch. The lowest value for Start Date (-StartDate) or End Date (-EndDate) is Today.' `r
        }
        else{
            $exitCode =0
        }
    }
    if ($exitCode -eq 0){
        $tmpDif = New-TimeSpan -End $tmpEndDateTime
        if($tmpDif -lt 0){
            $exitCode = 100
            Write-Host $tmp `t 'Parameter mismatch. End Date/Time (-EndDate & -EndTime) cannot be prior to current Date/Time' `r
        }
        else{
            $exitCode =0
        }
    }
    return $exitCode
}

function checkSrvcProc {
    param (
        $mode,
        $type,
        $name,
        $status,
        $startDate,
        $endDate,
        $startTime,
        $endTime,
        $interval
    )
    $exitCode = 0
    $count = 0
    $endLoop = $false
    Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t " Request ==> $mode "Execution to check if" $type $name is $status" `r
    do {
        if ($type -eq "Service"){
            try{
                $result = Get-Service -Name $name -ErrorAction Stop`
                $count++
                $result = $result.Status
                Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t " --- Result ==> $type $name is $result" `r
            }
            catch{
                $exitCode = 100
                Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t " Could not find a service called $name" `r
                $endLoop = $true
            }
        }
        elseif($type -eq "Process"){
            $result = "Running"
            try{
                Get-Process $name -ErrorAction Stop | Out-Null
                $count++
            }
            catch{
                $result = "Stopped"
            }
            if ($result -eq $status){
                $exitCode = 0
            }
            else{
                $exitCode = 200
                $endLoop = $true
            }
        }
        if ($mode -eq "Single"){
            $endLoop = $true
        }
        elseif($mode -eq "Timed"){
            $tmpEndDateTime = (Get-Date -Date $endDate -Format ("MM/dd/yyyy")) + " " + (Get-Date -Date $endTime -Format ("HH:mm:ss"))
            $tmpDif = New-TimeSpan -End $tmpEndDateTime
            if($tmpDif -gt 0){
                Start-Sleep -Seconds $interval
            }
            else {
                $endLoop = $true
            }
            if($result -ne $status){
                $endLoop = $true
            }
        }
    } until ($endloop)
    Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t " $mode execution ending" `r
    Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t " --- $count check(s) performed" `r
    if($result -eq $status){
        $exitCode = 0
    }
    else {
        if ($exitCode -ne 100){
            $exitCode = 200
        }
    }
    return $exitCode
}

##### Main Logic #####
# List parameters in log
listParams -mode $mode -type $type -name $name -status $status -StartDate $startDate -startTime $startTime -endDate $endDate -endTime $endTime -interval $interval |Out-Null

# Parameters validation
$exitCode = paramValidation -mode $mode -type $type -name $name -status $status -startDate $startDate -startTime $startTime -endDate $endDate -endTime $endTime -interval $interval

# If timed, wait until it is time to start
if ($exitCode -eq 0){
    $tmpStartDateTime = (Get-Date -Date $startDate -Format ("MM/dd/yyyy")) + " " + (Get-Date -Date $startTime -Format ("HH:mm:ss"))
    $tmpDif = New-TimeSpan -End $tmpStartDateTime
    $tmpDifSec = $tmpDif.TotalSeconds
    if($tmpDifSec -gt 0){
        Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t "Monitoring of $name is set to start in $tmpDif ($tmpDifSec seconds)" `r
        Start-Sleep -Seconds $tmpDifSec
    }
    Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t "Starting Monitoring of $name" `r
    # Calling the function to check the service or the process
    $exitCode = checkSrvcProc -mode $mode -type $type -name $name -status $status -endDate $endDate -endTime $endTime -interval $interval
}

Write-Host (Get-Date -Format ("MM/dd/yyyy HH:mm:ss")) `t "End of the script: Exit Code --> $exitCode" `r`n
exit $exitCode
