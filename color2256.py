#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=79:
# work with python 2.7
import sys

def main():
    for i in open(sys.argv[1]):
        i = i.strip()
        l = i.split("#")
        print l[0]
        if len(l) == 2:
            ll = l[1]
            print int(ll[:2],16), int(ll[2:4],16), int(ll[4:6],16)
    '''main: Main function

    Description goes here.
    '''
    print 'main'


if __name__ == '__main__':
    main()

