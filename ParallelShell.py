#!/usr/bin/env python

import thread
from time import sleep
from os import popen
import re

class PCmd:
    def __init__(self, cmd, doParallel=False, dryRun=False):
        self.cmd        = cmd
        self.done       = False
        self.result     = None
        self.doParallel = doParallel
        self.dryRun     = dryRun

    def __str__(self): return self.cmd
    
    def run_thread(self):
        if self.dryRun:
            self.result = "OK"
            self.done   = True
        else:
            px = popen("%s 2>&1" % self.cmd, "r")
            self.result = px.read()
            self.done = True

    def go(self):
        if self.doParallel:
            self.runThread = thread.start_new_thread(self.run_thread, ())
        else:
            self.run_thread()
        
class ParallelShell:
    def __init__(self, doParallel = False, dryRun = False):
        self.pcmds      = []
        self.doParallel = doParallel
        self.dryRun     = dryRun

    def start(self):
        for c in self.pcmds: c.go()
            
    def wait(self):
        while True:
            done = True
            for c in self.pcmds:
                if not c.done:
                    done = False
                    break
            if done: return
            sleep(0.25)
            
    def add(self, name): self.pcmds.append(PCmd(name, self.doParallel, self.dryRun))
    
    def showAll(self):
        for c in self.pcmds:
            if not c.done:
                print "NOT DONE: "+ str(c)
            elif re.search(r"\S+", c.result):
                print c.result
