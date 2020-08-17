# Service and Process Monitor
A PowerShell script that checks if a service or a process is running or is stopped.

The script ends with exit code 0 if the condition matches.
For example:
	Request: Check if Service SMA_ServMan is Running.
	
	Result: Service SMA_ServMan is Running.

The script ends with exit code 200 if the condition does not match.
For example:
	Request: Check if Service SMA_ServMan is Running.
	
	Result: Service SMA_ServMan is Stopped.

It also allows an execution for a single check (checks if the service/process is running/stopped once) or an execution for a timed check (using start/end date/time using a specific interval).
For example:
	Request: Every 5 seconds Check if Service SMA_ServMan is Running between 08/13/2020 00:00:00 and 08/13/2020 23:59:55.
	Results:
		If the service is Running, the script keeps running until it reaches the end date/time (exit code 0 at the end).
		If the service is Running or stops running during the date/time window, the script ends with exit code 200.

# Prerequisites
* Powershell 7.0+ (https://github.com/PowerShell/PowerShell)

# Optional (Desirable)
* OpCon Scripts repository (Multi-instance is strongly recommended)

# Instructions
## Steps for Script and Job Setup

Paste or import the script into the OpCon Scripts Repository and add a job into a Schedule.

The script has several different parameters, allowing the user to use it without having to make too many changes.
Check the documentation within the script for a better understanding of the parameters.

Check the OpCon documentation for more information on how to setup Multi-Instance jobs.

The following lines show 2 examples on how to specify some arguments (Single and Timed executions):

```
        -Mode "Single" -Type "Service" -Name "SMA_SQLAGENTNET" -Status "Running"
```

```
        -Mode "Timed" -Type "Service" -Name "SMA_SQLAGENTNET" -Status "Running" -Interval 5 
```
This last execution uses default values for StartDate, EndDate, StartTime and EndTime.

Add an On Request frequency.

# Disclaimer
No Support and No Warranty are provided by SMA Technologies for this project and related material. The use of this project's files is on your own risk.

SMA Technologies assumes no liability for damage caused by the usage of any of the files offered here via this Github repository.

# License
Copyright 2020 SMA Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Contributing
We love contributions, please read our [Contribution Guide](CONTRIBUTING.md) to get started!

# Code of Conduct
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code-of-conduct.md)
SMA Technologies has adopted the [Contributor Covenant](CODE_OF_CONDUCT.md) as its Code of Conduct, and we expect project participants to adhere to it. Please read the [full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.
