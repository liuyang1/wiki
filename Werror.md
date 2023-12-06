# Werror
在C语言中,经常会碰到各种各样的错误,但是一般遇到warning,估计就会被直接忽视掉.
但是这些都隐藏着潜在的错误,说不定在什么情况下就会爆发出来.

本文总结一些常见的warning,并且分析下warn在何处,以及如何进行修改来避免这些warning.

## 指针
### 整数到指针转换
在一般机器上int类型为32bit.指针类型的长度则取决于机器为32bit或者64bit.

显然在32bit上,二者可以安全进行转换,但是在64bit上,从64bit指针转换为32bit整数,则会被截断.从32bit整数到64bit指针转换,则会补0或补1.

修改方法可以采用"intptr\_t"类型.

在C里面,可能没有定义这个类型,可以根据ctype中的宏来自己定义一个宏或者类型.

### void \*指针上的算术运算
一般指针的算术运算,会自动按照其类型的长度进行.

	assert(sizeof(int) == 4);
	int *p = NULL;
    p++;
    assert(p == 4);
    
而void \*类型的指针,因为没有类型,则无法进行这个运算.在warning状态下,其实是按照字节进行的,也就是当做char \*指针进行算数运算.

因此对于buffer的指针(最常见的不知道类型,但是有需要偏移计算的场景).
建议使用char \*类型或者unsingned char\*类型.

以上的两种问题,主要在于分类/定位不明.

- buffer/data的内存区域,使用unsigned char\*,
- 未知/不定的指针类型,void \*
- 使用整数表示指针类型,彻底的错误用法,避免.

但是,如果作为handle之类使用,可以考虑使用整数来表示.但是也应该避免,内部维护一个表,以index作为handle更好.这种方法,避免外部任意操作内部资源的可能.

### void \*\*指针
void \*的指针是通用的(generic),也就是意味着可以从/向指针类型转换,而没有warning.

有一些使用方法,就是利用指针(引用)来从函数中返回数据.结合void \*类型,就需要使用void \*\*类型的指针.

如果我们希望返回到一个int \*的指针上来.这个时候就会碰到错误
	
    void mymalloc(void **p) {
    	*p = malloc(1024);
    }
    
    int *p;
    mymalloc(&p);
    // 不兼容的指针,从int **类型到void **类型.
    
这个错误在于错误的将void \*\*类型理解为一个通用的指针的指针.实际上void \*\*类型,是指向void \*类型的,不是**通用**的.

正确的方法有两种,第一种就是在这种情况下避免使用这种将结果传出的方法.放到上面的例子,就是原始的malloc函数,直接利用返回值进行返回.

第二种就是利用一个void \*指针来间接达到目的.

    int *p;
    void *pv;
    func(&pv);
    p = pv; // key
    
这种方式的关键在于在key标示的那一行,其实进行了类型转换.
但是这一步类型转换时从 void \*类型,转换到int \*类型.
这种转换则是可以的.

## sign-compare有符号整数和无符号整数
这个错误是显然的.修改方法也是显然的.

关键是在一般表达为正整数的场合,都坚持使用size\_t类型.这个类型其实等价于unsigned long类型.

常见的例子在于数组的下标,一般应采用unsigned的类型.

另外对于这个类型的打印输出,使用"%lu"类型,而不是"%d"哦.

## const的问题

## 宏
### redefined
这个就是宏被重复定义了.

如果出现这个问题,请确保你的头文件的层次结构设计是合理的.

解决办法当然不能是简单的删除重复定义的宏.而是良好的设计和习惯.

- 头文件使用#ifdef \_HEADER #endif之类的包含.
- 使用头文件的时候,遵循一定的顺序.建议顺序是从大到小,从最基础到最顶层的顺序.
- 使用#ifndef #endif来避免这种情况.

如果你的模块化和层次设计没有问题.并且做到了第一条,就基本不会有问题的.
后面两条都是补救的办法.

## IO
### printf
打印的时候注意类型和后面的参数格式要对应.

### sprintf
缓冲区溢出.
使用snrpintf避免这类问题.

这种问题很多,类似的只是简单的列一下.
- read/fgets的返回值(检查是否成功,以及量)
- gets -> fgets

### missing termiating " char
C语言提供过一个特性,就是自动拼接相邻的字符串.

	"abc" "def"
    "abcdef"
    
上面的两个写法是等效.因此在长字符串换行的时候,可以使用这个得到更为美观的代码.同时避免原本想表示缩进的空格/tab嵌入在字面字符串中.

	"line0 string\n"
    "line1 string\n"
    
## 字面数值
### 后缀
默认情况下,C语言中直接输入的数字,也是有类型的.

- 什么修饰都没有(默认的)为10进制有符号整数
- 00前缀的为8进制整数
- 0x前缀表示16进制整数
- u后缀表示无符号整数
- l后缀表示long型

这点看上去没有什么,但是可能会碰到坑哦.
我就看到一个还不错的工程师,犯了00前缀的问题.这其实是C语言的一个特性,但是现在却仿佛成了一个bug.

其实还有很多warning,这里就挑出几个可以说说的讲讲吧.

# CONTINUE
## __builtin__memset_chk will always overflow destination buffer
void *memset(void *s, int c, size_t n)

That is mean: n > sizeof("*s")

Generally, maybe passing a pointer of pointer s, and n greater than 4(x86) or 8(x64)

## multi-char

multi-char let one store several chars in an integer. Since order in which the chars are packed into one int is not specified, portable use of multi-char constants is difficult.

use `FOURCC_GEN` like macro, could fix this kind of issue. but must ensure they have same order.

Check sample code at github: [testMultiChar.c](https://github.com/liuyang1/test/blob/master/lang/c/cleanWarning/testMultiChar.c)

## -Wcommeent

- multiline comment

## -Wdeprecated-declaration
