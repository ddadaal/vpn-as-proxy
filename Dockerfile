FROM debian:buster-slim

# Set the apt sources
COPY ./apt-sources.list /etc/apt/sources.list

# Update the sources
# Install openconnect from buster-backports
# And ssh
RUN apt update && apt install -y -t buster-backports openconnect tinyproxy ssh

# Make tinyproxy accept requests from all hosts
RUN sed -i "s/^Allow/#Allow/g" /etc/tinyproxy/tinyproxy.conf

# Make tinyproxy accept CONNECT from all ports
RUN sed -i "s/^ConnectPort/#ConnectPort/g" /etc/tinyproxy/tinyproxy.conf