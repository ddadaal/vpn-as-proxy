# Docker image to use PKU VPN as a proxy server

# Motivation



# How to use?

1. Create a `.env` file under the cloned repository with its ID and password in the following format:

```env
STUID=student id
PWD=password
```

2. Run `docker-compose up`
3. A proxy is listening at port `8888`. Any traffic to the proxy will be tunneled by VPN.

You may also modify the docker-compose file to change the VPN host and other parameters.


