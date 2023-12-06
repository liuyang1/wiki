# [vim plugin] clighter8

随着VIM进入8.0时代，终于有了一系列的异步调用的支持。这些支持使得vim可以更好的处理复杂的异步操作，例如编译，建立tag等等。

而vim的语法渲染方案过去只能够给予纯文本的分析，因此只能够对例如关键词，基本的语法结构啊，比如括号之前的部分进行格式上的区分，但是因为没有语义的概念，所有就有一些限制，比如，就不能对函数和宏进行区分进行渲染。

[clighter8](https://github.com/bbchung/clighter8)就是这样的一个CS架构的vim插件。它利用了vim的`channel`的API，主要集成了[clang](http://clang.llvm.org/)用于语义分析。提供以下的特性：

- 运行时可变的，高度定制的语法高亮。

其他的特性，我没有觉得特别有用：

- 重命名重构
> 这个不是很常用，而且相比于全文替换相比，没有觉得有非常大的用处。而且我的工作代码库特别庞大，因此使用这个工具也不能保证不会引入问题。
- 自动后台运行gtags
> 这个也有缺陷，因为它只会在当前目录运行，不会在git root目录运行，因此反而会shadow掉我原本放在git root目录下面的gtags文件。
- clang-format集成
> 我在实际中采用unicurstiry而不是clang-format，因此这个特性对于我而言也没有用途。

先展示下使用clighter8前后的效果对比图。我使用的是molokai主题，本来就比较花哨。
使用clighter8之后，可以清晰的区分宏和函数，区分变量的定义和使用时的高亮。对于函数的定义，也有额外的高亮支持。

![cligher8](img/cligher8.png)

这个插件需要：

- vim8.0，并且打开job和channel的支持。
- libclang和兼容的python bindings。
- clang-format
- GNU global

这些东西都需要预先安装好。后面的clighter8的安装过程才可以保证顺利没有问题。

安装过程则非常简单,使用任意一款包管理器，我使用的是Plug

```
Plug 'bbchung/clighter8'
```

## issues

有问题的话，可以查看其文档，如果相应的功能有问题，可能是依赖没有安装，或者对应的配置选项没有进行配置。

### [clighter8] failed start engine

这个错误是因为engine.py的脚本没有启动成功。我检查下，发现它碰到一个异常，没有找到libclang.so。这是因为我没有配置

```
let g:clighter8_libclang_path="/usr/lib/llvm-3.9/lib/libclang.so"
```

这里按照你对应的clang版本进行配置。

其他问题可以尝试检查`/tmp/cligher8.log`.

### 编译选项的自定义

除了最简单的项目，我们都需要自己定义的一堆编译选项。需要配置

```
let g:clighter8_global_compile_args=['-Ipthread', ...]
```

### clighter8Expr的问题

配置完成之后，发现经常会提醒没有关于clighter8Expr的高亮配置。

```
highlight default link clighter8Expr cString
```

----

目前已经基本功能可用，后续再看需要吧。

更多我的配置，可以参考[dotfiles](https://github.com/liuyang1/dotfiles)
