# alpine-j-whisk
Docker source for image that runs J language under the IBM Bluemix and OpenWhisk openwhisk/dockerskeleton distro

The dockerfile expects J addons: convert/json and convert/misc to have been downloaded to the build 
directory. Since they are subject to revision I did not include them here. Go to the J software website:

http://www.jsoftware.com

To obtain any addons as compressed files and place them in your build directory. See the COPY command
in the Docker file for how to get them into the image. Also look at the RUN command following the COPY 
it has tar commands to expand the addons and place them in their proper location and clean up the directories
afterward

This was inspired by the docker image that github user: joebo created to run J under the tinycore distro:
https://github.com/joebo/docker-tinycore-jhs

For J to run under the openwhisk/dockerskeleton distro which is based on Alpine you need the GNU libc installed
in the image. The image commands for this are lifted from user frol:
https://github.com/frol/docker-alpine-glibc

Since this the idea of this image was to run in conjunction with OpenWhisk. The design decision was to 
keep the base image from openwhisk/dockerskeleton and modify it based on docker-alpine-glibc and docker-tinycore-jhs
to get the J language environment operational.

## Build and Run
To build this image issue the following command from the source directory:
docker build --no-cache=true -t porteverglades/alpine-j-whisk .

To run this image for OpenWhisk purposes use the following command:
docker run -p 127.0.0.1:8080:8080 -d --name testing porteverglades/alpine-j-whisk

## OpenWhisk
Under IBM Bluemix follow the directions for downloading the Whisk CLI
Under the 'wsk' environment, login into to your bluemix account

Then the following CLI commands will test the docker action using whisk

wsk action create --docker dkecho porteverglades/alpine-j-whisk:v01

wsk action invoke --blocking --result dkecho --param msg "hello world"

NOTE: don't forget the tag of the docker image. It's important otherwise OpenWhisk
will not be able to load the image.

## Debugging the Docker image
When debugging the image it is nice to be able to open a shell running on the image.
An internet search found: 

https://askubuntu.com/questions/505506/how-to-get-bash-or-ssh-into-a-running-container-in-background-mode

Author Adam Kalnas suggests: docker run -i -t --entrypoint /bin/bash <imageID>
or Agusti Sanchez command: docker exec -t -i container_name /bin/bash

This will open a bash command line that is running within the image. Very helpful when things aren't working
as they should. 

Finally should you need a shell and can't find bash on an image the following comand should work:
laktak provided: docker exec -it CONTAINER /bin/sh
