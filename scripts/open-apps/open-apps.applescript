-- open-apps.applescript
-- AppleScript for opening macOS applications from whitelist
-- Part of mac-app-lifecycle-manager
--
-- This script reads from a file containing apps to open and launches them
-- with configurable delays and optional primary app preference.

on run argv
	-- Parameters passed from shell wrapper:
	-- argv[1]: Path to apps-to-open.txt file (whitelist)
	-- argv[2]: Primary app path (optional, empty string if not set)
	-- argv[3]: Stagger delay between launches (seconds)
	-- argv[4]: Post-launch delay after all apps (seconds)
	-- argv[5]: Skip running apps (true/false)
	
	if (count of argv) < 1 then
		log "ERROR: Missing required argument: whitelist file path"
		return 1
	end if
	
	set whitelistPath to item 1 of argv
	set primaryAppPath to ""
	set staggerDelay to 0.2 -- default
	set postLaunchDelay to 1.5 -- default
	set skipRunning to true -- default
	
	if (count of argv) ≥ 2 then
		set primaryAppPath to item 2 of argv
	end if
	
	if (count of argv) ≥ 3 then
		set staggerDelay to (item 3 of argv) as real
	end if
	
	if (count of argv) ≥ 4 then
		set postLaunchDelay to (item 4 of argv) as real
	end if
	
	if (count of argv) ≥ 5 then
		set skipRunningStr to item 5 of argv
		if skipRunningStr is "false" then
			set skipRunning to false
		end if
	end if
	
	-- Read and parse the whitelist file
	set appsToOpen to {}
	
	try
		set whitelistFile to read POSIX file whitelistPath
		set appLines to paragraphs of whitelistFile
		
		repeat with appLine in appLines
			set appLine to appLine as text
			
			-- Skip empty lines and comments
			if appLine is not "" and appLine does not start with "#" then
				set end of appsToOpen to appLine
			end if
		end repeat
	on error errMsg
		log "ERROR: Failed to read whitelist file: " & whitelistPath
		log "ERROR: " & errMsg
		return 2
	end try
	
	-- Get list of running apps if we need to skip them
	set runningAppPaths to {}
	if skipRunning then
		try
			tell application "System Events"
				set runningAppPaths to POSIX path of (application file of every application process whose background only is false)
			end tell
		on error errMsg
			log "WARN: Failed to get running apps list: " & errMsg
			-- Continue anyway
		end try
	end if
	
	-- Launch primary app first if specified
	if primaryAppPath is not "" and primaryAppPath is not missing value then
		log "INFO: Launching primary app: " & primaryAppPath
		try
			-- Check if already running
			set shouldLaunch to true
			if skipRunning then
				repeat with runningPath in runningAppPaths
					if runningPath contains primaryAppPath or primaryAppPath contains runningPath then
						log "INFO: Primary app already running, skipping"
						set shouldLaunch to false
						exit repeat
					end if
				end repeat
			end if
			
			if shouldLaunch then
				tell application primaryAppPath to activate
				delay staggerDelay
			end if
		on error errMsg
			log "WARN: Failed to launch primary app: " & errMsg
		end try
	end if
	
	-- Launch whitelist apps
	log "INFO: Launching whitelist apps..."
	set launchedCount to 0
	set skippedCount to 0
	
	repeat with appPath in appsToOpen
		set appPath to appPath as text
		
		-- Check if already running
		set shouldLaunch to true
		if skipRunning then
			repeat with runningPath in runningAppPaths
				if runningPath contains appPath or appPath contains runningPath then
					log "INFO: Already running, skipping: " & appPath
					set skippedCount to skippedCount + 1
					set shouldLaunch to false
					exit repeat
				end if
			end repeat
		end if
		
		if shouldLaunch then
			try
				log "INFO: Launching: " & appPath
				tell application appPath to activate
				set launchedCount to launchedCount + 1
				delay staggerDelay
			on error errMsg
				log "WARN: Failed to launch " & appPath & ": " & errMsg
			end try
		end if
	end repeat
	
	-- Wait for apps to initialize
	if postLaunchDelay > 0 then
		log "INFO: Waiting " & postLaunchDelay & "s for apps to initialize..."
		delay postLaunchDelay
	end if
	
	log "INFO: App opening complete (launched: " & launchedCount & ", skipped: " & skippedCount & ")"
	return 0
end run
