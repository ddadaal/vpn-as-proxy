# Use VPN as a HTTP proxy server

# Motivation

VPN is used to access internal resources that can only be obtained in the internal network of your corporation. However, connecting to VPN in your device makes all network traffic forwarded to the VPN, which adds network latency and affects speed for requests that can be accessed without VPN. 

Most applications now support proxy. A proxy forwards incoming traffic to a upstream server. Therefore, if a proxy is connected to VPN, only the requests that are forwarded to the proxy will go the VPN, which addresses the original issue.

This project creates a docker container that does exactly what is mentioned above. This container does 2 things:

- connects to your VPN
- listens to a port, from which the container receives incoming HTTP requests and "re-sends" them

Set the proxy of your application to `http://localhost:{port}`, and all the HTTP requests from the app will go to the container. The container just simply resends the requests without any modifications. Since the container is connected to a VPN, any network traffic coming from the container is tunneled to your VPN, and as a result, the application is now able to access internal resource.

# How to use?

## Configuration

1. Clone the repo
2. Create a copy of `.env.example` file and name the new file to exactly **`.env`** under the cloned folder 
3. Modify the `.env` file as follows:

```env
PORT=the listening port in your host, for example 8888
CMD=the command to connect to your VPN using openconnect
```

Example CMD values of several universities are under the `configs` file. 

If your organization is included:

1. Read the comments of the config file and modify the command accordingly
2. Append the last uncommented line after `CMD=` in your `.env` file

If not, you can do the followings to experiment and find the command to connect to VPN:

1. Run `docker-compose build` to build the image
2. Run `docker run -it --cap-add=NET_ADMIN vpnproxy` to start a container
3. Try connecting to your VPN with `openconnect` **in one line**
4. Append the command after `CMD=` in your `.env` file
5. Submit a pull request to add your organization's config in the repo!

Note: 

- The command itself should be able to your VPN without any intervention (like inputting credentials), so all your configs, including credentials, should be included in the command
- If `openconnect` does not exit, the connection is already successful. Some errors can be ignored in this case.
- The CMD will be wrapped inside a pair of single quotes to run, so escape your command if necessary

## Run

After the `.env` file is configured, you can run the proxy:

1. Run `docker-compose up` (add `-d` to run in the background) to start the container
2. Set the proxy server of your apps to `http://localhost:{PORT}` (the PORT you set in the `.env` file)
3. The container should keep running for the proxy to work.
4. Press `Ctrl-C` or use `docker kill {container id}`(container id can be obtained by `docker ps -a`) to stop the container.

It is tested that the VPN connected in one container are isolated with other containers, i.e. the other containers are not connected to the VPN connected by one container.

# Implementation

- Base image: `debian:buster-slim`
- VPN client: `openconnect`
- Proxy: `tinyproxy`

