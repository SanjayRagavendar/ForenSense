# ForenSense
A Digital forensics tool which can be used by both techies and non techies. Its supports both platform windows and linux. It shows the finding in the simple web application. It analyses the 

## Architecture

### Windows
For the windows `main.ps1` is the major which does the digital forensics process like write protection and sends the register to the web app and computer stats at the time when a usb drive or external hard drive is connected to the system using ftk imager a image is made and using autopsy it creates the output file and data from image

The `main.ps1` can be called normally or a ioc which is setup can also call when a anomoly detected.

### Linux 
For the linux `script.sh` is the major which does the digital forensics process like `main.ps1` In this script it utilizes command line ftk to generate the images of the file and it is checked by using autopsy_cli to get the output_files.

As similar to the windows a `ioc.sh` will be running at the background when a ioc is  triggered then `script.sh` is executed

## Steps
* Cloning the repo
```cmd
git clone 'https://github.com/SanjayRagavendar/ForenSense.git'
```

* Getting into web interface, install prerequsites and  running the web app
  ```
  cd AdminInterface
  pip install -r requirements.txt
  python3 app.py
  ```
  
