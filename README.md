# Use VPN as a HTTP proxy server

# Motivation

VPN is used to access internal resources that can only be obtained in the internal network of your corporation. However, connecting to VPN in your device makes all network traffic forwarded to the VPN, which adds network latency and affects speed for requests that can be accessed without VPN. 

Most applications now support proxy. A proxy forwards incoming traffic to a upstream server. Therefore, if a proxy is connected to VPN, only the requests that are forwarded to the proxy will go the VPN, which addresses the original issue.

This project creates a docker container that does exactly what is mentioned above. This container does 2 things:

- connects to your VPN
- listens to a port, from which the container receives incoming HTTP requests and "re-sends" them

Set the proxy of your application to `http://localhost:{port}`, and all the HTTP requests from the app will go to the container. The container just simply resends the requests without any modifications. Since the container is connected to a VPN, any network traffic coming from the container is tunneled to your VPN, and as a result, the application is now able to access internal resource.

# How to use?

1. Clone the repo
2. Create a file **named exactly `.env`** under the cloned folder with the following configurations:

```env
USER=username
PWD=password
SERVER=VPN server
PROTOCOL=VPN protocol. Passed to openconnect. See below
PORT=the listening port in your host
```

Protocol help from `openconnect`
```
Set VPN protocol:
      --protocol=anyconnect       Compatible with Cisco AnyConnect SSL VPN, as well as ocserv (default)
      --protocol=nc               Compatible with Juniper Network Connect
      --protocol=gp               Compatible with Palo Alto Networks (PAN) GlobalProtect SSL VPN
      --protocol=pulse            Compatible with Pulse Connect Secure SSL VP
```

File `.env.example` is provided using PKU VPN as an example.

3. Run `docker-compose up` (add `-d` to run in the background)
4. A proxy is now listening at the specified port. Set the proxy server of your apps to `http://localhost:{PORT}`
5. The container should keep running for the proxy to work.
6. Press `Ctrl-C` or use `docker kill {container id}`(container id can be obtained by `docker ps -a`) to stop the container.

It is tested that the VPN connected in one container are isolated with other containers, i.e. the other containers are not connected to the VPN connected by one container.

# Implementation

- Base image: `debian:buster-slim`
- VPN client: `openconnect`
- Proxy: `tinyproxy`

