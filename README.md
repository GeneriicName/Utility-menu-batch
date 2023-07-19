# Utility-menu-batch

A CLI utility menu i made in batch before porting it over to python with GUI 

The convert label is to convert None english displaynames from left to right, remove it if your users displayname is in english 
If the users displayname is in none latin languages you might need to use a none default font such as courier new in the command line or the displaynames might turn to gibbrish


## Features
**Cleans space from remote computers:**

**Get network printers from the computer:** This includes printers installed via print servers, TCP/IP, and WSD. It will retrieve the IP and tell you if it's found on any of the print servers.

**Reset print spooler.**

**Fix Internet Explorer:** Depending on your OS version, this might not work.

**Fix cockpit printers:** This deletes the appropriate registry keys. Useful only if your organization uses Jetro Cockpit.

**Fix 3 languages bug:** Fixes a bug when the same language is displayed twice.

**Delete users folders:**, Choose users to delete their folders in order to cleans up space. If the user is in your domain, it'll show their display name.

## Configuration 

**You can the paths to the print servers in line 175, also you can exclude users folders from being deleted in line 287, the current user of the remote computer should be excluded by default**

## Disclaimer

**I will not be updating this script any further, i ported it to python as with much more features, batch is somewhat limiting in some aspects**
