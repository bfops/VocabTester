import sys
from tkinter import *

class Application(Frame):
    def __init__(self, title = "", master = None):
        Frame.__init__(self, master)
        self.master.title(title)
        self.grid()

Application("Vocab Tester").mainloop()

