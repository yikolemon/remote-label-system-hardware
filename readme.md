# 硬件准备





# 1、环境搭建

Mqtt测试服务器：

```shell
sudo docker run -d --name emqx -p 1883:1883 -p 8081:8081 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083 emqx/emqx:4.3.10
```

端口号：18083进入后台

默认账号：admin
默认密码：public