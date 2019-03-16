x='def myrepr(s):\n    t = \'\'\n    for c in s:\n        if c == \'\\n\':\n            nc = \'\\\\n\'\n        elif c == \'\\t\':\n            nc = \'\\\\t\'\n        elif c == \'\\\\\':\n            nc = \'\\\\\\\\\'\n        elif c == \'\\\'\':\n            nc = \'\\\\\\\'\'\n        else:\n            nc = c\n        t += nc\n    return "\'" + t + "\'"\ny="x="+myrepr(x)+"\\n"\nprint y+x'
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
