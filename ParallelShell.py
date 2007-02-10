#!/usr/bin/env python

# ParallelShell.py
# J. Jacobsen, for UW-IceCube
# February, 2007

import thread
from time import sleep
from os import popen
import re

class PCmd:
    "Class for handling individual commands to be executed in parallel"
    def __init__(self, cmd, doParallel=False, dryRun=False):
        self.cmd        = cmd
        self.done       = False
        self.result     = None
        self.doParallel = doParallel
        self.dryRun     = dryRun

    def __str__(self): return self.cmd
    
    def run_thread(self):
        "Thread to execute the command; notify main thread when done"
        if self.dryRun:
            self.result = ""
            self.done   = True
        else:
            px = popen("%s 2>&1" % self.cmd, "r")
            self.result = px.read()
            self.done = True

    def go(self):
        "Execute one command"
        if self.doParallel:
            self.runThread = thread.start_new_thread(self.run_thread, ())
        else:
            self.run_thread()
        
class ParallelShell:
    "Class to implement multiple shell operations in parallel"
    def __init__(self, doParallel = True, dryRun = False):
        self.pcmds      = []
        self.doParallel = doParallel
        self.dryRun     = dryRun

    def start(self):
        "Start all pending commands"
        for c in self.pcmds: c.go()
            
    def wait(self):
        "Wait for running commands to complete"
        while True:
            done = True
            for c in self.pcmds:
                if not c.done:
                    done = False
                    break
            if done: return
            sleep(0.25)
            
    def add(self, name):
        "Add command to list of pending operations"
        self.pcmds.append(PCmd(name, self.doParallel, self.dryRun))
    
    def showAll(self):
        "Show output of completed commands, or commands themselves if still pending"
        for c in self.pcmds:
            if not c.done:
                print "PENDING: "+ str(c)
            elif re.search(r"\S+", c.result):
                print c.result
