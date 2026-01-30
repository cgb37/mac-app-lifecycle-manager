-- close-apps.applescript
-- AppleScript for closing macOS applications
-- Part of mac-app-lifecycle-manager
--
-- This script reads from a file containing apps to close and handles three types:
-- 1. Standard apps (close by name)
-- 2. Apps with problematic process names (close by path)
-- 3. Stubborn apps (force quit by bundle ID pattern)

on run argv
	-- Parameters passed from shell wrapper:
	-- argv[1]: Path to apps-to-close.txt file
	-- argv[2]: Quit timeout (seconds)
	-- argv[3]: Close delay (seconds)
	
	if (count of argv) < 1 then
		log "ERROR: Missing required argument: apps list file path"
		return 1
	end if
	
	set appListPath to item 1 of argv
	set quitTimeout to 3 -- default
	set closeDelay to 0.1 -- default
	
	if (count of argv) ≥ 2 then
		set quitTimeout to (item 2 of argv) as integer
	end if
	
	if (count of argv) ≥ 3 then
		set closeDelay to (item 3 of argv) as real
	end if
	
	-- Read and parse the app list file
	set appsToCloseByName to {}
	set appsToCloseByPath to {}
	set appsToForceQuit to {}
	
	try
		set appListFile to read POSIX file appListPath
		set appLines to paragraphs of appListFile
		
		repeat with appLine in appLines
			set appLine to appLine as text
			
			-- Skip empty lines and comments
			if appLine is not "" and appLine does not start with "#" then
				if appLine starts with "PATH:" then
					-- Extract path and add to path list
					set appPath to text 6 thru -1 of appLine
					set end of appsToCloseByPath to appPath
				else if appLine starts with "FORCE:" then
					-- Extract bundle ID pattern and add to force list
					set bundlePattern to text 7 thru -1 of appLine
					set end of appsToForceQuit to bundlePattern
				else
					-- Standard app name
					set end of appsToCloseByName to appLine
				end if
			end if
		end repeat
	on error errMsg
		log "ERROR: Failed to read app list file: " & appListPath
		log "ERROR: " & errMsg
		return 2
	end try
	
	-- Get list of running apps for name-based closing
	set runningApps to {}
	try
		tell application "System Events"
			set runningApps to name of every application process whose background only is false
		end tell
	on error errMsg
		log "ERROR: Failed to get running apps list"
		log "ERROR: " & errMsg
		return 1
	end try
	
	-- Close apps by name
	log "INFO: Closing apps by name..."
	repeat with appName in appsToCloseByName
		set appName to appName as text
		if appName is in runningApps then
			try
				log "INFO: Closing " & appName
				with timeout of quitTimeout seconds
					tell application appName to quit
				end timeout
				delay closeDelay
			on error errMsg
				log "WARN: Failed to close " & appName & ": " & errMsg
			end try
		else
			log "DEBUG: " & appName & " not running"
		end if
	end repeat
	
	-- Close apps by path
	log "INFO: Closing apps by path..."
	repeat with appPath in appsToCloseByPath
		set appPath to appPath as text
		try
			log "INFO: Closing " & appPath
			with timeout of quitTimeout seconds
				tell application appPath to quit
			end timeout
			delay closeDelay
		on error errMsg
			log "WARN: Failed to close " & appPath & ": " & errMsg
		end try
	end repeat
	
	-- Force quit stubborn apps
	if (count of appsToForceQuit) > 0 then
		log "INFO: Force quitting stubborn apps..."
		repeat with bundlePattern in appsToForceQuit
			set bundlePattern to bundlePattern as text
			try
				log "INFO: Force quitting process matching: " & bundlePattern
				do shell script "pkill -f '" & bundlePattern & "'"
				delay closeDelay
			on error errMsg
				-- pkill returns non-zero if no processes match (not an error)
				log "DEBUG: pkill for " & bundlePattern & ": " & errMsg
			end try
		end repeat
	end if
	
	log "INFO: App closing complete"
	return 0
end run
