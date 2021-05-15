## Octolapse rendering
### Purpose

As I'm using OctoPi on a RPi 3, it takes some time 
to render the timelapse (convert photos into a video).  
I decided to make the timelapse with my computer so I 
can shutdown my printer earlier (my RPi is powered by the printer).

Even better, I can easly output them using x265 !


### Explanation

Basically doing a timelapse with `ffmpeg` is just a simple command :
```bash
ffmpeg -pattern_type glob -i "*.jpg" -c:v libx265 -crf 18 -vf "format=yuv420p" -tag:v hvc1 my_timelapse.mp4
```

As I want my video to got the same name as the GCODE file, 
I find it annoying to specify it on every time I run the command.

The main part of this script it to deduce the file name based on 
the common part of the photos names.  
To do so, I use the metadata file to get the files list, get 
the common part and trim the remaining "0".

As I'm using the metadata file, this script also check if all 
photos are really here.


### Prerequisite

In order to use this, you'll need `ffmpeg` installed.
```bash
sudo apt install ffmpeg
```

### Using the script

This script need to be run where the photos are located. 
So, unzip the archive and navigate to the directory 
where the photos are located and call the script from there.

*My way of using it by putting the script in `~/bin` 
(as this path is in my `PATH`) so I can call it from anywhere.*
