## Hugo related scripts
### Convert images to WebP
#### Purpose

As [v0.83.0](https://github.com/gohugoio/hugo/releases/tag/v0.83.0) 
of [Hugo](https://gohugo.io/) framework bring support to WebP format, 
I scripted a tool to automatically convert images and update posts.


#### Prerequisite

Without modification, this script will only work if your content 
are in the `content` folder and your images in the static folder.

In order to use this, you'll need `webp` installed.
```bash
sudo apt install webp
```
*The script will use `gif2webp` for GIF file and 
`cwebp` for the others.*


You also need a file (in the same folder as the script) named `list.txt` 
containing the image path as it is specified in the post preceded by the 
post path.

For exemple :
`content/posts/2021/05-05-my-awsome-post/index.en.md` contain :
```
{{< image src="/path/to/images/un.png" caption="Azerty" title=" " >}}
{{< image src="/path/to/images/one.jpg" caption="Qwerty" title=" " >}}
```

and
`content/posts/2020/04-17-hello/index.en.md` contain :
```
{{< image src="/2020/04-17/hello/1.gif" caption="Hi" title=" " >}}
{{< image src="/2020/04-17/hello/2.gif" caption="Hello" title=" " >}}
```

This mean the images paths are :
```
static/path/to/images/un.png
static/path/to/images/one.jpg
static/2020/04-17/hello/1.gif
static/2020/04-17/hello/2.gif
```

My `list.txt` file must contain thoses lines :
```
content/posts/2021/05-05-my-awsome-post/index.en.md /path/to/images/un.png
content/posts/2021/05-05-my-awsome-post/index.en.md /path/to/images/one.jpg
content/posts/2020/04-17-hello/index.en.md /2020/04-17/hello/1.gif
content/posts/2020/04-17-hello/index.en.md /2020/04-17/hello/2.gif
```

Here is my dirty command to achieve that :
```
find content -type f -name "*.md" -print | xargs grep "image src" | sed 's/{{< image src="//g' | awk '{print $1}' | tr -d '"' | sed 's/:/ /g' | grep -e ".jpg" -e ".png" -e ".gif" | sort -u > list.txt
```
If this command work for you, dont forget to manually remove external images links.


#### Using the script

Update the variable `HUGO_ROOT` on line 12 to hugo site folder 
(ex : `HUGO_ROOT="/home/anup92k/git/HugoBlog"`).  
*With so, you don't need to place the script inside the Hugo folder.*

You may also want to change the conversion parameters (see line 15).  
Make shure to specify something that will work with `cwebp` and `gif2webp`.


Run the script !

`error.txt` file will contain paths of non found images.  
`failed.txt` file will contain a list of non converted file.  
`toberemove.txt` file will contain the list of the removed images.  
Keep in mind that thoses files are cleared on every run.
