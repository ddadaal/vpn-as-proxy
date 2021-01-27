# Use VPN as a HTTP proxy server

# Motivation

VPN is used to access internal resources that can only be obtained in the internal network of your corporation. However, connecting to VPN in your devices makes all network traffic forwarded to VPN, which adds network latency and affect speed for requests that can be accessed without VPN. 

Most applications now support proxy. A proxy forwards incoming traffic to the upstream server. Therefore, if a proxy is connected to VPN, only the requests that are forwarded to the proxy will go the VPN, which addresses the original issue.

This project creates a docker container that is exactly the proxy mentioned above. This container does 2 things:

- connects to your VPN
- listens a port, from which the container receives incoming HTTP requests and "re-sends" them

Set the proxy of your application to `http://localhost:{port}`, and all the HTTP requests from the app will be forwarded to the container. The container just simply resends the requests without any modification. Since the container is connected to a VPN, any network traffic coming from the container is tunneled to VPN, and as a result, the application is now able to access internal resource.

# How to use?

1. Create a `.env` file under the cloned repository with its ID and password in the following format:

```env
USER=username
PWD=password
SERVER=VPN server
PROTOCOL=VPN protocol, see `openconnect -h`
PORT=the listening port in your host
```

File `example.env` is provided using PKU VPN as an example.

2. Run `docker-compose up`
3. A proxy is listening at the specified port. Set the proxy server of your apps to `http://localhost:{PORT}`
4. The container should keep running to be able to function. Press `Ctrl-C` to stop the container.

# Implementation

- Base image: `debian:buster-slim`
- VPN client: `openconnect`
- Proxy: `tinyproxy`

