# alpine-j-whisk
Docker source for image that runs J language under the IBM OpenWhisk dockerskeleton/alpine distro

This was inspired by the docker image that github user: joebo created to run J under the tinycore distro:
https://github.com/joebo/docker-tinycore-jhs

To run this image for OpenWhisk purposes use the following command:
docker run -p 127.0.0.1:8080:8080 -d --name testing porteverglades/alpine-j-whisk
