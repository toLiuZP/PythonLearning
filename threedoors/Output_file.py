#!/usr/bin/env python3
#coding:utf-8

class File(object):
    def __init__(self,file):
        self.file = file
    def openFile(self):
        self.file = open("/Users/liuzp/Code/Output_Test/3Doors", 'w+')
    def writeFile(self, context):
        self.file.write(context)
