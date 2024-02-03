# Microsoft Network Monitor

Since Windows needs admin access for capturing packets there is a problem of that software being vulnerable 

so we can use netmon which can be used for capturing the network packets then and store it in a log file

### Capturing the Packets
```cmd
nmcap /start /network * /capture all
```
### Storing logs
```cmd
nmcap /file C:\Logs\network_capture.cap
```
### Stoping the service
nmcap /stop