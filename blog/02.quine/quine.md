# Quine

[Quine](https://en.wikipedia.org/wiki/Quine_(computing)),在计算机方向，指的上一段代码。这段代码的输出就是自己的代码片段本身(self-reproduce)。

这个思路有点像是一个🐍蛇，吞食自己的感觉。

![snake](snake.jpg)

## 如何制作一个Quine程序

根据上面wiki的介绍，一个简单的quine的程序的代码分为两个部分：A和B，二者直接作为字符串拼接在一起

- A=“<B>的内容”
- B=<一段代码，可以生成A的内容> ++ 输出B的运行结果(也就是A) ++ 输出A(也就是B的内容)

以python的这段代码[quine.py](quine.py)为例：（注释并 *不是* 原始代码的一部分）

    x='y="x="+`x`+"\\n"\nprint y+x' # x=''，其中的内容，和后一段代码相等
    y="x="+`x`+"\n"                 # 这段代码的执行内容和x的内容相等
    print y+x                       # 执行输出<B>和<A>

- 这里注意第一行x所赋的字符串内容，就是第二行和第三行的内容
- 第二行y的赋值内容，当运行起来后，是第一行的内容

这里可以快速检验下这个代码是不是真的self-reproduce。

    python quine.py
    python quine.py | python
    python quine.py | python | python

在解释器的反复执行后，我们总是可以得到完全一致的结果。`diff`的结果，为空，也就是完全一致。

    python quine.py | diff quine.py -

值得注意的是这里使用的`repr`（``运算符）。

## repr, eval in Python

这里使用python的其中一个相对不常见的特性repr（或者等价的``运算符）。这个函数的特性是返回一段代码片段，这段代码可以产生你传入的内容

    >>> repr('123')
    "'123'" # 如果以这个字符串为代码，则执行结果为"123"的字符串
    >>> repr(123)
    '123'   # 如果执行这段字符串为代码，执行结果为123这个数字
    >>> repr(datetime.datetime.now())
    'datetime.datetime(2019, 3, 15, 18, 38, 28, 774931)' # 显然 这段代码的执行结果，就是2019-03-15 18:38:28.774931这个时间点
    >>> `'123'`
    "'123'"

可能有人会好奇（[我很好奇](https://zh.moegirl.org/zh-hans/%E6%88%91%E5%BE%88%E5%A5%BD%E5%A5%87)），这个效果是如何实现的。
其实首先传给repr的参数，是一个对象Object。而对象都有一个构造函数。而repr就是返回一个字符串。这个字符串的内容是调用该构造函数的代码。
那么repr如何知道呢？repr其实是调用了该Object的所属类型的`__repr__`内置函数。而显然作为这个类的函数，`__repr__`是知道具体如何构造这段代码了。

类似的，`__str__`就是显示这个类时候调用的方法，或者说将这个类转换为字符串的时候调用的方法。

下面为一个给自定义类型支持`repr`的代码[repr.py](repr.py):

    class Ridiculous:
        def __init__(self, name):
            self.name = name

        def __repr__(self):
            return "Ridiculous('%s')" % (self.name)

        def __str__(self):
            return "%s is ridiculous" % (self.name)

    god = Ridiculous('god')
    print god # god is ridiculous

    print repr(god) # Ridiculous('god')
    print eval(repr(god)) # god is rediculous

而eval函数，就是执行字符串内的代码。那么我们可以看到`x=eval(repr(x))`这是一个恒等变化的关系，或者eval是repr的逆过程。

以上还有一个微小的细节，就是Python中的[字面字符串](https://docs.python.org/2.0/ref/strings.html)。

Python的字符串有三种方式：

- 单引号（内置系统默认）
- 双引号
- 三引号

三引号的方式，和本文没有太大关系，不谈。在Python其中，单引号和双引号的效果是完全一样的。那么有为什么非要定义两种方式呢？其实是避免转义字符。在单引号括起来的字符串中，单引号需要转义，而双引号不需要。对于双引号括起来的字符串中，双引号需要转义，而单引号不需要。听起来是不是有点绕？简单看个例子。

    >>> 'hello' # 单引号括起的字符串
    'hello'
    >>> "hello" # 双引号括起的字符串
    'hello'     # 注意：字符串的默认构造函数，尽量使用单引号
    >>> '""'    # 一个字符串，内容为两个双引号，不需要转义
    '""'
    >>> "''"    # 一个字符串，内容为两个单引号，不需要转义
    "''"        # 内部字符带有单引号的字符串，系统使用双引号括起来，来避免使用转义字符
    >>> '\'\''  # 一个字符串，内容为两个单引号。因为在单引号中，需要转义
    "''"
    >>> "'\""   # 字符串内容里面同时包含单引号和双引号
    '\'"'       # 对于这样的例子，系统尽量使用单引号

思考题1，你能在手动推导出这个结果吗？

    >>> repr('\'')
    # ???

## eval in Shell

`repr`和`eval`，一般可以在脚本语言中使用。这里的构造性脚本语言，指的是内建了一个函数eval，从而可以动态的构建字符串，作为代码，从而在解释器中执行的效果。很多脚本语言，都存在这种特性。例如shell/bash里面就有eval这种函数。

下面的代码[eval.sh](eval.sh)示例shell中的eval。

    ridiculous() {
        echo "$1 is ridiculous"
    }

    s=`ridiculous god`
    echo $s

    eval "ridiculous god"

`eval`函数的负面，在于可以动态的创建任意可执行的内容。这样对于接受外部输入的代码，就是一个巨大的安全漏洞。从而被执行任意代码。对下面这段代码就是那么简单。就是打印这个脚本的第一个参数。

思考题2，你能攻击下面的程序[fragile.sh](fragile.sh)，从而执行一个新的shell或者任意代码吗？

    echo "$1"

对于在C/C++/Java这样的静态语言里面，一般较少见到这样的函数。而在动态语言，各种脚本语言，这个是一个标准流程[REPL](https://en.wikipedia.org/wiki/REPL)。所谓的REPL，就是Read–eval–print loop。而这其中`eval`就是必备的。不要觉得这个函数很神奇，其实eval就是把编译器的过程，直接纳入到这个函数里面。这样的好处，就是可以在运行时做很多magic的事情，而且可以动态改变程序的行为。属于一种黑魔法技术。

----

## quine with myrepr

可以看到上述的实现，实际上利用了`repr`的特性，那么如果不使用这个语言自带的特性，有可能实现quine程序吗？一种快捷的思路，是利用自己实现的repr。当然，我们实现的只需要支持字符串这一种就够了。

在上面的讨论中，我们可以看到对于字符串而言，代码中的字面字符串，是利用转义字符串表现的。而repr是个反转义的过程。因此我们只需要将需要转义的字符，转换为其对应的字面字符串就可以了。比如将'\n'这个回车符号，转换为字符串"\\n"（也就是斜杠和字母n的字符串）

    x='...'
    def myrepr(s):
        t = ''
        for c in s:
            if c == '\n':
                nc = '\\n'
            elif c == '\t':
                nc = '\\t'
            elif c == '\\':
                nc = '\\\\'
            elif c == '\'':
                nc = '\\\''
            else:
                nc = c
            t += nc
        return "'" + t + "'"
    y="x="+myrepr(x)+"\n"
    print y+x

注意：以上实现了一个myrepr的函数。这个函数的作用就对于字符串这种类型，进行反转义处理。

在这个基础上，我们只需要手动将整个后面的代码全部手动反转义为x被赋值的字面字符串内容就好了。这个过程，看起来就是人肉将myrepr做一遍，然后在最开始写一段`x='...'`就可以了。

虽然说起来很容易，可以一点点做人肉翻译机，还是挺痛苦的。当然了，作为程序员我们怎么可以这么笨拙呢？很简单，我们可以写一个辅助程序`callRepr.py`，直接调用repr或者我们写的myrepr将上述代码作为文本转为其对应的反转义字符串。

    import sys
    with open(sys.argv[1]) as fp:
        print repr(fp.read())

这样我们就可以得到最终完整版的[myquine.py](myquine.py)了。

## 总结

看到这里就可以领会到，所谓的quine的关键，就是在于`repr`的过程。一般而言，编译器的过程，就是一个`eval`的构成。而我们要实现的quine，其实就是经过一次eval变换之后，不变的代码`eval(x)=x`.而在*求解*这个的方程的时候，自然就需要求助于eval的逆过程。也就是类似于反编译器的过程，这里就是`repr`。从而可以得到`repr(eval(x))=repr(x)`。

从数学的角度而言，`eval`是一种映射。`repr`是其逆。而所谓的quine程序，就是这种映射的不动点。具体关于不动点，就是一个更为宏大而深远的话题。这里不展开了。

而我们可以根据每个编程语言的字符串->字面字符串的过程，写出自己的repr函数。从而可以在几乎任何语言里面，实现quine的代码。思考题3，可以使用自己顺手的编程语言完成一个。