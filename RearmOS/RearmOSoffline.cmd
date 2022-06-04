:: reset  windows licens after the the tree rearms
:: Boot using a live and work on the registry offline
:: Useful when you have a develope VM and sysprep it again and again, rearm, sysprep...
reg load HKLM\MY_SYSTEM "c:\Windows\System32\config\system"
reg delete HKLM\MY_SYSTEM\WPA /f
reg unload HKLM\MY_SYSTEM