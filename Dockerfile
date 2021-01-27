FROM debian:buster-slim

# Set the apt sources
COPY ./apt-sources.list /etc/apt/sources.list

# Update the sources
RUN apt update 

# Install openconnect from buster-backports
RUN apt install -y -t buster-backports openconnect tinyproxy

# Make tinyproxy accept requests from all hosts
RUN sed -i "s/^Allow/#Allow/g" /etc/tinyproxy/tinyproxy.conf
