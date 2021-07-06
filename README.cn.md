# 连接到VPN的HTTP代理

还支持SSH！

- [连接到VPN的HTTP代理](#连接到vpn的http代理)
- [如何使用？](#如何使用)
	- [1. 配置](#1-配置)
	- [2. 运行代理](#2-运行代理)
	- [3. 设置代理服务器](#3-设置代理服务器)
		- [git](#git)
		- [大多数命令行程序](#大多数命令行程序)
		- [浏览器](#浏览器)
		- [SSH](#ssh)
- [原理](#原理)
- [实现](#实现)

# 如何使用？

## 1. 配置

1. Clone这个repo
2. 在repo的目录下，创建一个`.env.example`文件的副本，并将副本命名为`.env`
3. 按以下格式修改`.env`文件

```env
PORT=监听的端口，默认为8888
CMD=在容器内连接VPN的命令
```

`configs`文件夹下放了一些大学的`CMD`值的示例。

如果`configs`目录下有您的大学/组织，按照以下步骤操作：

1. 阅读对应文件的开头的注释部分，并按您的情况修改文件最后一行的命令
2. 复制文件最后一行，粘贴到`.env`文件的`CMD=`之后

如果`configs`目录下没有您的组织，您可以按照以下步骤尝试找到连接您的VPN的命令：

1. 运行`docker-compose build`构建镜像
2. 运行`docker run -it --cap-add=NET_ADMIN vpnproxy`启动一个容器
3. 在容器中，借助`openconnect`程序，尝试使用**一行**命令连接到您的VPN
4. 把这个命令添加到`.env`文件的`CMD=`之后
5. （可选）提交一个PR，把您的组织的配置文件提交到`configs`目录下！

注意：

- 只使用这一条命令就能连接到VPN，运行命令后不能再有任何输入（比如输入用户名密码）。所以，您的所有配置（包括用户名密码）都需要被包含在这个命令中
- 命令中请尽量使用双引号包裹命令中的字符串。命令执行的时候会被包括在**一对单引号**中，所以如果您发现您的命令不能正常使用，尝试加点转义符。
- 如果`openconnect`运行起来之后没有自己退出，VPN连接应该就成功了，可以无视之后的报错

## 2. 运行代理

在`.env`文件配置好之后，按以下方式运行代理：

1. 运行`docker-compose up` （加`-d`后台运行）
2. 把需要走VPN的程序的代理设置为`http://localhost:{PORT}`（{PORT}和`.env`文件里设置的PORT值一致）
3. 容器需要保持运行
4. 使用`Ctrl-C`或者使用`docker kill {container id}`(container id可以通过`docker ps -a`获得)来关闭代理
q
经测试，在一个容器里连接的VPN不会影响其他容器和主机的网络连接。

## 3. 设置代理服务器

代理服务器跑起来之后，给需要走内网的应用设置HTTP和HTTPS代理到`http://localhost:{PORT}`（`{PORT}`为`.env`中设置的值，默认为8888）。

一些常见设置（下面均使用8888为端口，如果为其他端口请自行更改）.

### git

```bash
# 只修改当前repo
git config http.proxy http://localhost:8888
git config https.proxy http://localhost:8888
```

### 大多数命令行程序

```powershell
# Windows PowerShell
$env:HTTP_PROXY="http://localhost:8888"
$env:HTTPS_PROXY=$env:HTTP_PROXY
```

```bash
# Linux/macOS
export HTTP_PROXY=http://localhost:8888
export HTTPS_PROXY=$HTTP_PROXY
```

### 浏览器

使用**Proxy SwitchyOmega**（[Chrome Web Store](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif)）扩展，然后按照以下操作：

1. 设定页中，选择**新建情景模式**，名字任意，类型为代理服务器

![新建情景模式](docs/switchyomega/cn/1.png)

2. 左边选择新建的情景模式，右侧**代理协议**为HTTP，**代理服务器**填写为`localhost`，**代理端口**填写为**8888**，然后点击左侧**应用选项**

![设置情景模式](docs/switchyomega/cn/2.png)

3. 左边选择auto switch，在右边给需要代理的URL设置情景模式为之前自己创建的情景模式，默认情景模式设置为`system proxy`（系统代理），然后点击左侧应用选项

![设置代理规则](docs/switchyomega/cn/3.png)

4. 在浏览器菜单栏中找到这个扩展的菜单，选择`auto switch`

![应用auto switch](docs/switchyomega/cn/4.png)

完成。之后访问第三步中设置的URL时将会自动走HTTP代理，其他的将会走系统代理。

### SSH

镜像中默认安装了SSH，接下来只需要进入容器的`bash`中，即可通过SSH链接到内网机器了。在容器启动时将主机的`~/.ssh`目录映射到了容器的`/root/.ssh`目录，主机和容器共享SSH密钥对。所以主机能免密登录的机器，容器也可以。

另外，容器的所有流量将会走VPN，所以也可以在容器中使用必须走VPN的程序。

```bash
# 1. 进入容器
# Windows PowerShell
pwsh bash.sh

# Linux/macOS
./bash.sh

# 2. 连接ssh
ssh username@ip
```

# 原理

![使用本方案的网络请求流向](docs/arch/cn.png)

VPN可以被用来在外网访问内网资源。但是，一旦连接VPN，系统里的所有流量都会被转发到VPN，对于不需要走VPN的流量，这会带来一些不必要的网络延迟，影响网络速度。

现在的大多数应用程序都支持**代理**(proxy)功能。如果一个应用程序被设置了代理，程序的流量将会被发到代理服务器上，由代理服务器发送到真正的目的地。

所以，如果我们有一个连接到VPN的代理服务器，那么，设置了代理的应用程序的流量就会走VPN，而没有设置这个代理的程序发出的流量就不会经过VPN。

这个项目就是创建docker镜像，它的功能就是上文提到的这个**连接到VPN的代理服务器**。这个容器有两个功能：

1. 连接到VPN
2. 启动一个代理服务器进程，它监听一个端口，并直接转发这些流量

由于这个容器整体连接到了VPN，所以由这个容器发出的流量都会走VPN。所以，我们只需要设置我们需要走VPN的程序的代理程序为`http://localhost:{PORT}`，这样这些程序的流量就会走这个代理，然后走VPN，这样就可以访问内部资源了。

请查看[我博客上的相关文章](https://ddadaal.me/articles/vpn-as-http-proxy)，对VPN、代理以及本方案进行了更详细的介绍。



# 实现

- Docker base image: `debian:buster-slim`
- VPN client: `openconnect`
- Proxy: `tinyproxy`

