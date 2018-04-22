:: Prints the Proxy URL to be used for accessing the URL specified as the first command line argument

:: Requirements
:: - TrifleJS (confirmed with v0.4)
:: - curl

:: Usage
:: To call this batch file in your batch file and store the proxy URL printed to stdout to a variable,
:: copy and paste the line below:
::
:: for /f "delims=" %%A in ('get_proxy_url.bat') do set "var=%%A"
::

@echo off

set triflejs_path="%~dp0\TrifleJS_v0.4\TrifleJS.exe"
set curl_path="%~dp0\curl-7.59.0\src\curl.exe"

set target_url=%1

:: echo host: %target_url%

:: These are not necessary unless PAC is enabled, but writing these lines in the else block causes
:: some obscure errors so it's done here.
:: TODO: add definitions of other functions.
echo function shExpMatch(url, pattern) {pattern = pattern.replace(/\./g, '\\.'); pattern = pattern.replace(/\*/g, $
echo console.log(FindProxyForURL('', >> pac.js
echo '%target_url%' >> pac.js
echo ));phantom.exit(); >> pac.js


:: 1. Check if proxy auto-configuration is set up

:: 1.1 Get the URL of the proxy auto-config script
:: 1.1.1 Look up the registry key that has autoconfig URL and save the key and the value it to a text file.
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL > pac_s$

:: 1.1.2 Extract the third line from the text file.
::     The third line has the proxy URL and it typically looks like this:
::     "    AutoConfigURL    REG_SZ    http://www.mycompany.com/pac/intranet.pac"
set "lineNr=3"
set /a lineNr-=1
for /f "usebackq delims=" %%a in (`more +%lineNr% pac_script_url.txt`) DO (
  set auto_config_url_line=%%a
  break
)

if "%auto_config_url_line:~0,5%" == "ERROR" (
    echo PAC script not detected

    reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings" | find /i "proxyserv$
) else (
echo PAC script detected

set ac_url=%auto_config_url_line:~31%
%curl_path% -s -o script.pac %ac_url%

REM 1.2. Create a JS script from the PAC script
REM 1.2.1 Define the pac script function(s)

REM 1.2.2 Append the PAC script
type script.pac >> pac.js

REM 1.2.3 Append the main function call.

REM Print the proxy URL to stdout
%triflejs_path% pac.js
)

REM Clean up; delete temporary files.
del script.pac
del pac_script_url.txt
del pac.js

