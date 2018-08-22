# Interesting Travel among Compiler's Option

Recently, I have a task to upgrade GCC to new version. 

Our build system is complex. It have multiple levels, and tons of build flags.
So I just replace the tool chain with PATH and prefix name of tool chain.
I think this is general way for tool chain upgrade.

However, new GCC stuck sometimes. I don't know the reason. Let's check it.

1. check by `ps -A | grep -i gcc`, we could see the gcc process just wait there.
2. `pstree | grep -i gcc`. I find gcc try to execute the `as` command.
3. `strace -p [PID of as]`. The `as` process is waiting for `read` system call.

Looks like `as` is waiting for input, I guess.

4. check the `/proc/[PID of as]/exe`, the program is
    `/usr/bin/x86_64-linux-gnu-as`.

The `as` program don't belong to new GCC tool chain, but is part of `binutils`.

I try to `gdb -p [PID of as]`, but the `as` program is stripped.
(Of course, Damn it!). I need the debug verison of `as`.
so download and build it.

5.1 under root directory of `binutils`'s source code:

    mkdir /tmp/4as
    ./configure --prefix=/tmp/4as
    make && make install
    export PATH=/tmp/4as:$PATH

so we get debug version of `as` under `/tmp/4as` now.
And our debug version will shadow the system one.
With this way, we could debug this issue and keep our system clean.

5.2 just run the build command again. This time, we could get the call stack now.

    main -> perform_an_assembly_pass -> read_a_source_file ->
    input_scrub_new_file -> input_file_open

6. check code of `binutils/gas`.
https://github.com/bminor/binutils-gdb/blob/master/gas/input-file.c#L117-L146

summary to one line: it fallback to `STDIN` when filename is empty string.

But we build code from local source code file to object file. I don't think
we need touch `STDIN`.

7. check the `as` command.

        cat /proc/[PID of as]/cmdline | tr '\000' ' '
        as --64  -o hello.o /tmp/[user]/xxxxx.s %

The key of this command is replace '\0' to space character.
As we know, the arguments of command is stored by C raw string which is end of '\0'.
If directly show it, the non-printable character '\0' will be truncated by terminal.

    cat /proc/[PID of as]/cmdline
    as--64-ohello.o/tmp/[user]/xxxx.s%

With same reason, the end '%' is not part of cmdline,
    and it means the string have no newline character.

If we try to run the command manually, it don't stuck.

    as --64 -o hello.o /tmp/[user]/xxxxx.s

The key clue already show up!
I don't know do you find the key clue of this issue or not. :)

I insert code to show arguments in `as`'s `main` function. It show the `as` have one extra argument.

    ['as', '--64', '', '-o', 'hello.o', '/tmp/[user]/xxx.s']

The extra arguments is ''. Ahab!

The `as` program consider the '' is input file. And it fallback to STDIN.
Obviously, we don't have any input to `as`. so it just stuck and wait for input.

8. return back to check gcc command. It's too long and have many flags.
    I just remove half part of flags, and retry.
    With binary searching, I locate the suspicious option:

        -Wa,

https://gcc.gnu.org/onlinedocs/gcc/Assembler-Options.html

The gcc's `-Wa,[option]`, means pass option to the assembler (`as` program).
If option contains commas, it is split into multiple options as the commas.

But we actually have empty option for assembler, as it just pass useless `-Wa,` option.
And we remove the option, the build PASS now. 🎈

9. check the gcc's code, https://github.com/gcc-mirror/gcc/blob/master/gcc/gcc.c#L4001-L4019
    
        case OPT_Wa_:
        {
            int prev, j;
            /* Pass the rest of this option to the assembler.  */

            /* Split the argument at commas.  */
            prev = 0;
            for (j = 0; arg[j]; j++)
                if (arg[j] == ',')
                {
                    add_assembler_option (arg + prev, j - prev);
                    prev = j + 1;
                }

            /* Record the part after the last comma.  */
            add_assembler_option (arg + prev, j - prev);
        }
        do_save = false;
        break;

It record the part after last comma in line 4016.
But we have no option after last comma.
That's why gcc try to pass '' option as empty string to `as`.

And let's check the command of `as` again:

    as --64  -o hello.o /tmp/[user]/xxxxx.s %

Do you find the double spaces after "--64"? It's empty string.
The raw command is:

    as\0--64\0\0-o\0hello.o\0\/tmp/[user]/xxxxx.s\0

The gcc run `as` command by `execv` system call.
This function use arguments array to call program.
It could use empty string as argument.
However, if we execute the command in shell, shell will split the command by space first.
We have no way to use empty string as argument. That's how gcc make this issue.
It's reasonable that why we cannot reproduce this issue with same command in shell.

Let's review this issue again:

- gcc pass '-Wa,option' to `as`. It record the part after the last comma, but record empty string with '-Wa,' option.
- `as` fallback to STDIN when input file name is empty string.
- `as` stuck as waiting input from STDIN.

How to resolve this issue?

Just remove the dumb '-Wa,' option.

I study this issue several hours, and just remove 5 characters. :)
