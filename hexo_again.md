# hexo again

因为之前安装hexo环境的机器已经重新安装系统了，因此还需要重新安装一边hexo。

不知不觉踩了些坑。

```
sudo npm install -g hexo-cli
hexo init blog
```

 这个步骤将会非常之慢，后来实在受不了，搜了下，npm源的问题。先去切换npm的源。

## 切换npm源

```
sudo npm install -g nrm
```

nrm是一个npm的源管理器。可惜这个过程似乎一样非常缓慢。

好吧只能直接指定npm的源地址了。

```
sudo npm install --registry=https://registry.npm.taobao.org -g nrm
```

还是先手动安装nrm再说，为了之后使用方便。

安装nrm完毕后，
```
nrm use taobao
```

之后，继续回去`hexo init blog`去。

现在已经处于可用状态了。下一步再继续更新。
