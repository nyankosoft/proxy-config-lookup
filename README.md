# WORK IN PROGRESS

## Overview

A Windows batch file script for looking up the proxy settings and returns
the URL of the proxy which is supposed to be used for accessing the URL specified
as the command line argument.

- Input: a URL the user wants to access.
- Output: a proxy URL needed to access the input URL.
- Usage

```
get_proxy_url.bat github.com
```

## Background

Corporations sometimes deploy proxy servers in order to regulate which websites
employees are allowed access and which ones they are not.
This can be a reasonable measure for corporations to take.
However, the proxy settings can become a nuisance for employees.
Suppose the corporation has several departments and each department has its own proxy.
When an employee develops and wants to distribute an application to multiple
departments, and the installation of the application includes
some proprietary script which downloads dependencies from the internet,
the script will likely not work unless it has proxy settings in mind.
There are many other situations like this, and it seems that what we need to have
is a self-contained tool for looking up the proxy for a given URL.

## Approach and Current Status

On Windows 10, proxy configuration is stored in the registry and can be queried
via the 'reg query' command.
As such it should be possible to look up and get the proxy URL for a given URL.
This can take something more than a simple look up; these days some corporations
deploy what is called 'proxy auto-configuration script (.pac)'.
.pac file is a JavaScript-looking script and to parse them we need a JavaScript parser.
Bearing all of these in mind, I've started to write a batch file and build
a self-contained package for printing the proxy URL for the given URL.
In the meantime, there might be a completely different, better way of addressing this.
So I'll be asking a question on SO. Later I'll come back to this if this approach
is likely sound or if I don't find a better approach.

## Logic

Batch file should work like this (or at least that is the plan)

1. See if PAC script is set up

 1-yes: Download the .pac and run a JS parser (TrifleJS) to find the right proxy for the given URL

 1-no: Move on to 2.

2. See if the proxy URL is set up.

 2-yes: Move on to 3

 2-no: We think that proxy is not to be used (no output to stdout)

3. See if the given URL match any pattern in the proxy bypass list.

 3-yes: Proxy is not used for the given URL (not output to stdout)

 3-no: Print the proxy URL (host + port) to stdout.
