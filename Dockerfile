# The openwhisk/dockerskeleton is the image that has a predefined openwhisk server
# implemented in python/flask. All open whisk action messages are sent to this 
# server and the server sends them to /action/exec. If another image is used as
# the base you will have to place commands to load and implement the server.
FROM openwhisk/dockerskeleton
 
ENV FLASK_PROXY_PORT 8080

### Add source file(s)

RUN apk add --no-cache --virtual .build-deps \
        ncurses5-libs

# need glibc environment because the standard libc environment that comes
# with alpine does not have __strcat_chk and other functions needed by
# JSoftware's J language

# The following comes from the docker source: frol/docker-alpine-glibc
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

ENV LANG=C.UTF-8

# These commented out lines are used to compile a C language based action and replace exec
# executable the openwhisk flask server front end is expecting to send messages to. 
### Compile source file(s)
## && cd /action; gcc -o exec example.c \
## && apk del .build-deps


# the following adapted from docker source at joebo/tinycore-jhs. Added to this are 
# commands for addon libraries to be preloaded from their tar files at the JSoftware 
# site.
COPY ./convert_json_1.0.9_linux.tar.gz /home/
COPY ./convert_misc_1.3.5_linux.tar.gz /home/

RUN ln -s /usr/lib/libncurses.so.5 /usr/lib/libtinfo.so.5 \
    && cd /home \
    && wget http://www.jsoftware.com/download/j805/install/j805_linux64.tar.gz \
    && tar -xf j805_linux64.tar.gz \
    && rm -rf j805_linux64.tar.gz \
    && ln -s /home/j64-805 /home/j805 \
    && cd /home/j64-805/addons \
    && tar -xf /home/convert_json_1.0.9_linux.tar.gz \
    && rm -rf /home/convert_json_1.0.9_linux.tar.gz \
    && tar -xf /home/convert_misc_1.3.5_linux.tar.gz \
    && rm -rf /home/convert_misc_1.3.5_linux.tar.gz \
    && rm -f /action/exec 

# The library path is needed so jconsole will load the proper libraries
ENV LD_LIBRARY_PATH /lib64:/usr/lib:/lib

# User script file that will ultimately be run
# right now the script handles ARGV from the action script
# Likely the final version will handle already parsed JSON
# and return parsed JSON. The action script will need to 
# change accordingly to set that all up.
# '~temp/' in J defaults to the /tmp directory
ADD main.ijs /tmp/main.ijs

# dockerSkeleton expects an executable file
ADD action.sh /action/exec

CMD ["/bin/bash", "-c", "cd actionProxy && python -u actionproxy.py"]
