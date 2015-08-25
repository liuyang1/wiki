# bitfield in ctypes @Python

在C语言中,解析二进制数据常使用位域.可以直接从二进制数据映射到C语言中的结构提.

在Python中,如果要解析二进制数据的话,可以使用struct模块.

struct模块中定义了unpack方法可以用作这个用途.但是unpack其中内涵了一个小的描述语言,掌握其中的细节比较麻烦,而且谁能够记住这些东西呢.这个必然是write once, read never的代码,除非加上几倍的注释在附近.

而利用Python的ctypes模块中的Structure的功能,我们也可以写出类似于C语言位域的代码,同时结合Python的特点,可以写出更为简明易懂的代码.

闲话不说了,直接上例子.

VP8是Google出品的一种视频编码方式,VP8视频流可以存储在一种IVF的文件格式中.这种文件格式本身非常简单.

- 32字节的文件头
- 12字节的帧头,帧头的前4个字节为帧数据的长度.

据此我们可以完成一个简单的IVF文件的probe代码.

{{{
    Put code here
}}}

其中__str__函数,是Python对象的默认转换为字符串的函数. 重载这个函数,可以直接简单的调用print来打印对象的信息.

原始代码::
- ![github](https://github.com/liuyang1/test/blob/master/lang/python/ivf.py)
