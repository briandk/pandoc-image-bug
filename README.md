# Overview
This project is a [Docker image](https://registry.hub.docker.com/u/danielak/pandoc-image-bug/) to try and replicate an image bug I've been having in Pandoc. Namely, pandoc throws a 'could not find image' error during document conversion, even though visiting the URL image in the browser confirms the image is there. The reason I created a Docker image was so I could isolate as many dependencies as I could, trying to insure this bug replicates on any system that runs Docker.

## Expected Behavior

When running my docker image, Given this Markdown input (in the file `test.md`):

```markdown
Here is my image. ![my image][1]

[1]: https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png
```

And this pandoc command:

```
pandoc test.md --from=markdown --to=latex --output=test.pdf --standalone
```

Pandoc will produce a PDF that looks like this:

![image of PDF page including a "Shifts in CLASS" graphic](http://f.cl.ly/items/323J132r130m171S1D3V/Napkin%2007-06-15,%205.41.06%20PM.png)

## Actual Behavior

Running my docker image produces the following output:

    $ docker run danielak/pandoc-image-bug
    pandoc: Could not find image `https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png', skipping...
    ! Package pdftex.def Error: File `https://www.physport.org/physport/images/tiny
    /CLASS\%20Plot\%20GPER.png' not found.

    See the pdftex.def package documentation for explanation.
    Type  H <return>  for immediate help.
     ...

    l.75 ...ort/images/tiny/CLASS\%20Plot\%20GPER.png}

    pandoc: Error producing PDF from TeX source


## Steps to Reproduce (Internet Connection Required)

1. Install Docker on your system:
	1. Ubuntu Linux: <http://docs.docker.com/linux/started/>
	2. Mac OS X: <http://docs.docker.com/mac/step_one/>
	3. Windows: <http://docs.docker.com/windows/step_one/>
2. If you're on Windows or Mac, start Boot2docker. If you're on Linux, skip this step.
3. **Make sure you have root access** or the windows equivalent, because [Docker requires root access](https://docs.docker.com/articles/security/#docker-daemon-attack-surface). Then, at the terminal, type

		# make sure you have root access when you execute this:
		docker run danielak/pandoc-image-bug

4. Confirm that you receive this output:

        pandoc: Could not find image `https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png',     skipping...
        ! Package pdftex.def Error: File `https://www.physport.org/physport/images/tiny
        /CLASS\%20Plot\%20GPER.png' not found.

        See the pdftex.def package documentation for explanation.
        Type  H <return>  for immediate help.
         ...

        l.75 ...ort/images/tiny/CLASS\%20Plot\%20GPER.png}

        pandoc: Error producing PDF from TeX source
        
 ### What to do if you want to access the Docker container itself
 
Right now if you run my image, it executes one pandoc command and then quits. You might be wondering, "what if I want to poke around your docker image and try commands for myself?" No problem. Below is a command that will allow you shell access to my docker image. From there, you can try pandoc commands yourself. I haven't tested this on Windows, but it should work on *nix-like systems (Ubuntu and Mac OS X, among others).

```bash
# Make sure you run this with root access
docker run -i -t --entrypoint /bin/bash danielak/pandoc-image-bug
```
