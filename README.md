# alpine-j-whisk
Docker source for image that runs J language under the IBM OpenWhisk dockerskeleton/alpine distro

This was inspired by the docker image that github user: joebo created to run J under the tinycore distro:
https://github.com/joebo/docker-tinycore-jhs

To run this image for OpenWhisk purposes use the following command:
docker run -p 127.0.0.1:8080:8080 -d --name testing porteverglades/alpine-j-whisk

When debugging the image it is nice to be able to open a shell running on the image.
An internet search found: 

https://askubuntu.com/questions/505506/how-to-get-bash-or-ssh-into-a-running-container-in-background-mode

Author Adam Kalnas suggests: docker run -i -t --entrypoint /bin/bash <imageID>
or Agusti Sanchez command: docker exec -t -i container_name /bin/bash

This will open a bash command line that is running within the image. Very helpful when things aren't working
as they should. 

Finally should you need a shell and can't find bash on an image the following comand should work:
laktak provided: docker exec -it CONTAINER /bin/sh
