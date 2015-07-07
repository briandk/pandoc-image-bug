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

## My best guess at the cause of the bug

I think what's happening is that there's security certificate issue with the host, `physport.org`. My guess is based on the following evidence of command results in the terminal:

```bash
# To make sure you have the latest image version
$ docker run danielak/pandoc-image-bug:latest

# Remember to run this with root-level access
# It'll then drop you to shell access inside the container
$ docker run -i -t --entrypoint /bin/bash danielak/pandoc-image-bug

# In your prompt, the hash following @ might be different
root@6ef180c258d1:/src# wget https://www.physport.org/physport/

# Which produces this output
images/tiny/CLASS%20Plot%20GPER.png
--2015-07-07 04:04:35--  https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png
Resolving www.physport.org (www.physport.org)... 149.28.119.173
Connecting to www.physport.org (www.physport.org)|149.28.119.173|:443... connected.
ERROR: cannot verify www.physport.org's certificate, issued by '/C=GB/ST=Greater Manchester/L=Salford/O=COMODO CA Limited/CN=COMODO RSA Domain Validation Secure Server CA':
  Unable to locally verify the issuer's authority.
To connect to www.physport.org insecurely, use `--no-check-certificate'.

# Trying again with the no-check-certificate option
root@6ef180c258d1:/src# wget https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png --no-check-certificate

# The download works
--2015-07-07 04:14:43--  https://www.physport.org/physport/images/tiny/CLASS%20Plot%20GPER.png
Resolving www.physport.org (www.physport.org)... 149.28.119.173
Connecting to www.physport.org (www.physport.org)|149.28.119.173|:443... connected.
WARNING: cannot verify www.physport.org's certificate, issued by '/C=GB/ST=Greater Manchester/L=Salford/O=COMODO CA Limited/CN=COMODO RSA Domain Validation Secure Server CA':
  Unable to locally verify the issuer's authority.
HTTP request sent, awaiting response... 200 OK
Length: 83194 (81K) [image/png]
Saving to: 'CLASS Plot GPER.png'

100%[===============================================================================================================================>] 83,194       480KB/s   in 0.2s
```


