#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# vim:set shiftwidth=4 tabstop=4 expandtab textwidth=79:
# work with python 2.7
import re,sys,os

def main():
    '''main: Main function

    Description goes here.
    '''
    
    for i in open(sys.argv[1]):
        a=re.search("color([0-9]{1,2}):.+?#([0-9,a-f,A-F]{6})",i)
        if a:
            color_id = "%X"%int(a.group(1))
            color = a.group(2).lower()
            print 'echo -en "\e]P%s%s"  xxxxx'%(color_id,color)
    print "clear"
    print "./print.sh"
    print "exit"

if __name__ == '__main__':
    main()

