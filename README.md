## About

A Docker image with Suricata based on jsonwilder Docker Suricata image with ELK stack 
See: - git clone https://github.com/jasonish/docker-suricata-elk.git

## NOTE

Unlike most Docker containers, this one uses host networking.  

This is to allow Suricata access to your physical interfaces while
running inside the container. 

## Running

As this is a Docker container you need to be running Docker on Linux.
Please refer to the Docker documentation at https://docs.docker.com/
for installation help.  Note that if running in a virtual machine you
should allocate at least 2GB of memory.

 - ./launcher start [-i INTERFACE]

The container is completely stateless with all persistent data stored
in ./data.  

To get a shell into the running container (may require sudo):

 - ./launcher enter

## Building

If you wish to rebuild the image yourself simply run:

 - ./launcher build
