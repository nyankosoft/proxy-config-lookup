:: Prints the Proxy URL to be used for accessing the URL specified as the first command line argument

:: Requirements
:: - TrifleJS (confirmed with v0.4)
:: - curl

:: Usage:
::
:: get_proxy_url.bat nyankosoft.space
:: -> Prints out the URL of the proxy to be used to access nyankosoft.space to stdout
::
:: To call this batch file in your batch file and store the proxy URL printed to stdout to a variable,
:: copy and paste the line below:
::
:: for /f "delims=" %%A in ('get_proxy_url.bat github.com') do set "var=%%A"
::

@echo off

setlocal EnableExtensions EnableDelayedExpansion

set triflejs_path="%~dp0\TrifleJS_v0.4\TrifleJS.exe"
set curl_path="%~dp0\curl-7.59.0\src\curl.exe"

set target_url=%1

:: echo host: %target_url%

:: These are not necessary unless PAC is enabled, but writing these lines in the else block causes
:: some obscure errors so it's done here.
:: TODO: add definitions of other functions.
echo function shExpMatch(url, pattern) {pattern = pattern.replace(/\./g, '\\.'); pattern = pattern.replace(/\*/g, '.*'); pattern = pattern.replace(/\?/g, '.'); var newRe = new RegExp('^'+pattern+'$'); return newRe.test(url);} > pac.js
echo console.log(FindProxyForURL('', >> pac.js
echo '%target_url%' >> pac.js
echo ));phantom.exit(); >> pac.js

set reg_internet_settings="HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

:: 1. Check if proxy auto-configuration is set up

:: 1.1 Get the URL of the proxy auto-config script
:: 1.1.1 Look up the registry key that has autoconfig URL and save the key and the value it to a text file.
reg query %reg_internet_settings% /v AutoConfigURL > pac_script_url.txt 2>&1

:: 1.1.2 Extract the third line from the text file.
::     The third line has the proxy URL and it typically looks like this:
::     "    AutoConfigURL    REG_SZ    http://www.mycompany.com/pac/intranet.pac"
:: Note that 'more +2' ensures that the more command prints up to the third line of the text file.
for /f "usebackq delims=" %%a in (`more +2 pac_script_url.txt`) DO (
  set auto_config_url_line=%%a
  break
)

if "%auto_config_url_line:~4,13%"=="AutoConfigURL" (
REM echo PAC script detected

REM echo %auto_config_url_line:~31%

    set pac_url=!auto_config_url_line:~31!
REM echo pac_url is !pac_url!
    %curl_path% -s -o script.pac !pac_url!

REM 1.2. Create a JS script from the PAC script
REM 1.2.1 Define the pac script function(s)

REM 1.2.2 Append the PAC script
    type script.pac >> pac.js

REM 1.2.3 Append the main function call.

REM Print the proxy URL to stdout
    echo "TODO: Print nothing if the output is DIRECT and trim 'PROXY' if the output is 'PROXY (proxy URL)'"
    %triflejs_path% pac.js
)

if not "%auto_config_url_line:~4,13%"=="AutoConfigURL" (
REM echo PAC script not detected

    set is_proxy_enabled=
    reg query %reg_internet_settings% /v ProxyEnable > proxy_enable.txt 2>&1
    for /f "usebackq delims=" %%a in (`more +2 proxy_enable.txt`) do set is_proxy_enabled=%%a

REM echo "!is_proxy_enabled:~32!"
	set is_enabled=!is_proxy_enabled:~32!
REM reg query %reg_internet_settings% | find /i "proxyserver"
)

if "!is_enabled!"=="0x0" (
REM echo Proxy is likely NOT enabled
	exit /b
)

if "!is_enabled!"=="0x1" (
REM echo Proxy is likely enabled

REM TODO: See if the given URL matches any of the patterns in the proxy bypass list

    reg query %reg_internet_settings% /v ProxyServer > proxy_servers.txt 2>&1
    for /f "usebackq delims=" %%a in (`more +2 proxy_servers.txt`) do set proxy_url_line=%%a
	set proxy_urls=!proxy_url_line:~29!
	echo "TODO: split the string below by ';' and pick up the right proxy for the requested URL"
	echo !proxy_urls!
)



REM Clean up; delete temporary files.
:: del script.pac
:: del pac_script_url.txt
:: del pac.js

