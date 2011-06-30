from tkinter import *

class Application(Frame):
    class Dictionary:
        class Entry:
            def __init__(self, term, definition):
                self.term = term
                self.defn = definition

        def __init__(self):
            pass

        def __init__(self, stream):
            self.load(stream)

        def load(self, stream):
            def parseLine(raw):
                breakIndex = raw.find("|")
                if breakIndex == -1:
                    return None

                return self.Entry(raw[:breakIndex].strip(), raw[breakIndex + 1:].strip())

            self.entries = []

            while True:
                raw = stream.readline()

                if raw == "":
                    break

                # Remove trailing newline.
                entry = parseLine(raw[:-1])

                if entry != None:
                    self.entries.append(entry)

    def __init__(self, title = "", master = None):
        Frame.__init__(self, master)
        self.master.title(title)
        self.grid()

        self.filename = Entry(self)
        self.filename.grid()

        Button(
            self,
            text = "Load file",
            command = lambda : self.loadFile(self.filename.get())
        ).grid(row = 0, column = 1)

    def loadFile(self, filename):
        try:
            file = open(filename)
        except IOError:
            return

        self.dictionary = self.Dictionary(file)

Application("Vocab Tester").mainloop()

