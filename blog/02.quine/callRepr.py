import sys


with open(sys.argv[1]) as fp:
    print repr(fp.read())