:: Force joined clients to sync with PDC 
w32tm /config /syncfromflags:DOMHIER /update
w32tm /config /Update
w32tm /resync /nowait /rediscover
SC stop w32time & ping 127.0.0.1 -n 6  &sc start w32time 