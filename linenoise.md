
# readline和linenoise

------
# readline和背景
相比于GUI，在CLI混战的人也有user-friendly interface的需求。这方面有非常成熟的库**GNU readline**，shell很多都是使用它来支持丰富多彩的输入/交互特性。很多编程语言的解释器都支持使用readline。支持着异常丰富的特性。

- line edit（移动光标，编辑已经输入的内容）
- tab completion（自动补全功能）
- history
- vi-mode/emacs-mode（按键绑定方式，两种风格）

以上的很多功能，已经是大家对于shell的默认选项。
试想一个不支持编辑功能的shell，估计是有多难用啊。
本文不是介绍这部分，因此不再此处深入。

但是学习过C语言编程的人都知道，C默认支持的输入方式并不支持上述的任何一个特性。
C的输入，必须以newline，eof之类结束，才可以输入一个整行。
这是C的默认的行缓冲模式。而且在输入过程中backspace是可用的，
但是其他按键，例如delete，方向键都是不行的。
按着方向键输出都是^[[A, ^[[B

这样看上去像是混乱语句的东西。
这样就无法进行编辑功能。

如何支持上述特性呢？

- line edit
    
    需要行的缓存，以及虚拟终端的控制。
- tab completion
    
    同样需要虚拟终端控制，这些才可以进行立即方式输入，而不是默认的行缓冲模式。
- history
    
    这个感觉相对没有那么复杂，需要保存历史文件（就像所有的shell里面一样），然后支持各种历史的接口。
- vi-mode，emacs-mode
    
    在tab completion的基础上，可以立即响应各种按键，因此也会是可以支持的。

对于上面的分析，可以看到问题基本集中在一个背景知识，虚拟终端控制，和一个技术实现，行缓存。
- [GNU readline](http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html)

## ANSI escape code
### 历史
回到刚刚的C语言的例子，输出的^[[A之类的到底是什么。这应该就是问题的关键点（之一）。因为shell中这个向上按键，会向上翻命令历史，但是在这里却是^[[A。

这是一种特殊的格式[ANSI escape code](http://en.wikipedia.org/wiki/ANSI_escape_code)。

这种格式是一种带内in-band传输格式的一种方式。所谓的in-band，就是数据信息和控制信息一起传输。对于终端而言，控制信息控制着格式（普通字体，粗体，斜体，颜色，反色，闪烁，下划线）以及光标的位置，终端的刷新等。而数据信息就是纯字符或者说可打印可显示的字符。而终端则起到翻译或者解释的作用，对于这种混合的字节流进行解释，最终输出呈现效果。

如果有喜欢配置炫酷的终端prompt的同学，肯定对此多少有一定了解。

注意：
Windows的控制台不是采用这种方式。
终端的颜色输出，和各种特性，已经另一个方面的库libncursor也是基于这个特性衍生出来的。这个以后有机会再介绍。
关于console，terminal，tty，virtual terminal，terminal emulator之类的区别可以参考这个吧。[csdn](http://blog.csdn.net/on_1y/article/details/20203963)

作为一个带内控制的方法，最初是有很多各自自定义的一套。这是时候为了兼容就需要一个接口，一般可以配置在termcap或者terminfo中，就是终端的capability或者information。后来出现了本节的ANSI escape sequence.作为一个标准。支持标准的一个流行的terminal，VT100.这个在有些软件比如putty，SecureCRT中还是可以看到，设置终端格式为VT100方式。

而终端模拟器（今天所使用的几乎所有跑在GUI下的所谓终端），也同时支持。Linux控制器(Ctrl+Alt+F1出来的）也同样支持。而Unix/Linux下的众多程序都靠这个来在命令行下得到丰富多彩的输出。

这一段似乎扯的太远了。readline之类的库，也是通过ANSI escape code也是通过这个支持的。

中间的escape是什么意思呢？如果你在C程序中，会发现按下Esc，对应的是^[，也就是这些控制串都是以Esc对应的控制串开始的，因此这么叫。

### 标准


## linenoise
GNU readline 是 GPL 协议的，因此会存在“污染”的问题。在英文wiki上就记载这样的故事，CLISP因为链接了readline，被要求按照GPL协议重新发布。
GNU readline还是一个非常庞大而复杂的库，这不利于实际的工程应用。

最近看到一个开源的库linenoise，这个库比较短小，核心代码仅仅1k+-行，非常的短小精悍，而且支持上述的前三个特性。keybinding的支持目前正在进行中。本身采用BSD协议，可以相对自由的使用它。

目前在redis，MongoDB和Android中用到。

前面感觉闲扯的有点多，现在飞速进入正题中。

### completion

#### external interface
    typedef struct linenoiseCompletions {
      size_t len;
      char **cvec;
    } linenoiseCompletions;

linenoiseCompletions 这个类型的作用就像它的名字一样。

这里的cvec是一个二级指针，用于指向待匹配的字符串序列。而len就是长度了。
对于初学者而言，这里需要注意，cvec指向一个数组，这个数组的长度为len。这个数据中的每个元素为一个字符串数据指针。

例如，我们已经有了字符串“ab”，然后想匹配“abc”，“abd”，等等。这里的cvec就是用于指向后面的“abc”，“abd”的。
这个时候对应的len就是2。

那么这个序列是如何工作的呢？

    typedef void(linenoiseCompletionCallback)(const char *, linenoiseCompletions *);
    void linenoiseSetCompletionCallback(linenoiseCompletionCallback *);
    void linenoiseAddCompletion(linenoiseCompletions *, const char *);

就是通过这个函数类型和这两个函数作用的。

linenoiseSetCompletionCallback这个函数就是设置了回调函数。

回调函数有2个参数，第一个字符串，表示当前的字符串内容。第二个为linenoiseCompletions类型指针。
结合example.c可以看到，回调函数可以根据当前的字符串内容，通过linenoiseAddCompletion函数添加新的补全字符串到lc中。结合当才的linenoiseCompletions的数据类型分析，这个逻辑必然是简单的添加到数据指针的后面。需要特别考虑的就是cvec这个数据可能的长度不够的问题。

检查linenoiseAddCompletion这个函数的逻辑，果然是这样的。

做的不那么好的地方就是，每次需要每次都调用realloc函数，来扩张cvec的大小。我认为相对较好的方法是初始化一定的大小，然后可以容纳数据，然后阶梯上涨。不过这样需要额外的属性存储存储空间的大小。逻辑略微复杂一点。好处是减低了内存空间调整的频率。

realloc函数，这个用的不多。
用于改变指针指向的存储空间的大小。从开始位置到min（new size， old size）之间的内容得以保持不变。

存储区域扩张的画，新增内存空间是未初始化的。

如果参数ptr是NULL，那么等同于malloc的效果。

如果参数size是0，而ptr不是NULL，那么等同于free的效果。

使用realloc，可以进行内存分配的动态增长，对于一些不限定大小的需求非常有用。

字符串的复制这里其实可以直接调用C标准库中的strdup就可以了。

#### internal process
以上是关于自动补全的外部接口，内部还需要怎样处理呢。

这完全集中在一个函数completeLine中。

completeLine的参数是linenoiseState类型。

这个类型存储了当前的命令行的状态。

    struct linenoiseState {
        int ifd;            /* Terminal stdin file descriptor. */
        int ofd;            /* Terminal stdout file descriptor. */
        char *buf;          /* Edited line buffer. */
        size_t buflen;      /* Edited line buffer size. */
        const char *prompt; /* Prompt to display. */
        size_t plen;        /* Prompt length. */
        size_t pos;         /* Current cursor position. */
        size_t oldpos;      /* Previous refresh cursor position. */
        size_t len;         /* Current edited line length. */
        size_t cols;        /* Number of columns in terminal. */
        size_t maxrows;     /* Maximum num of rows used so far (multiline mode) */
        int history_index;  /* The history index we are currently editing. */
    };

上面的注释都非常清楚。用处也很明确。

这个函数初始化了一个linenoiseCompletions lc，然后调用上面所讲的回调函数来初始化它。从ls中的buf就可以得到当前的字符串的内容是什么。

这个时候我们就知道,外部认为匹配的自动补全的内容。

completeLine的过程。

输入“ab” -> 按键tab -> 如果没有匹配内容，则没有什么变化或者warning。

如果有按键内容，那么显示第一个内容 -> 按键Tab，轮替显示 -> Esc 则退出。其他键，认为输入其他键退出。

// copy from src

返回最后一个的输入字符，这样可以进行插入处理。

### 显示和编辑命令缓冲区

上面的显示和刷新显示命令行的方式来自于refreshLine这个函数。
结合上面的linenoiseState的类型，也可以简单估计，就是通过prompt和buf组合了显示的字符串，pos决定了光标的位置，ifd，ofd则用于输入和输出。

refreshLine分为两种模式，MultiLine模式和SingleLine模式。

    void linenoiseSetMultiLine(int ml);

就是用于设置这个全局选项的。

显示refreshSingleLine，单行模式，首先就是光标的位置不可以超过单行的长度，不然存在问题。其次是字符串的长度不可以超过单行的长度。

然后就是制造一个ab序列就可以了，根据内容填充进去。

- \r        回到行首
- prompt    添加命令行头部
- buf       添加命令行的内容
- \x1b[0K   清除之后的一行的内容
- \r\x1b[%dC    先回到行首，然后则折返回光标位置

abuf 的类型比上面的cvec还要简单，就是一个字符串空间，要注意的就是append的时候，同样使用realloc增长，然后把字符串复制进去就行了。

那么MultiLine模式呢，显然也是类似构造的。这里是没有趣味的就省略了。

那么添加一个字符在当前位置呢，同样的步骤一样是可以完成的。
对于单行模式，并且并未超过行宽的时候，可以直接写入下一个字符的，这种特别处理一下（因为简单，又不想重新搞一遍控制字符）

对于单行模式其他情况和多行模式，那么必要要调用刚刚的刷新函数了。

对于在中间插入的情况，那么将后半段的内容向后移一个字符，这里使用memmove，不能用memcpy哦。
然后把插入的字符补进来就行了。

从这里可以看到基于Ansi Escape的编码序列，控制term的显示逻辑就是这里的关键思想。其他部分，并不重要。

### 历史

History的部分其实和自动补全有些相似，其实不再由回调函数提供待匹配的字符串数据，而是由历史文件确定的。而命令行的显示原理是一样的。

    char *linenoise(const char *prompt);
    int linenoiseHistoryAdd(const char *line);
    int linenoiseHistorySetMaxLen(int len);
    int linenoiseHistorySave(const char *filename);
    int linenoiseHistoryLoad(const char *filename);
    void linenoiseClearScreen(void);
    void linenoisePrintKeyCodes(void);

### 扩展

#### 层级命令
对于一个控制/debug根据而言，其实可以想shell的控制终端一样，提供一个层级的方式。

例如：

    git log

然后在这个上下文下，自动对命令进行的上下文进行补全。例如在这个状态下，执行HEAD
命令，那么就相当于git log HEAD 命令。这样的好处是我在层级之间切换的时候，
不需要输入冗长的前缀。因此它的菜单可以任意扩展。支持异常丰富的命令，同时
对于使用者没有那么大的压力。
