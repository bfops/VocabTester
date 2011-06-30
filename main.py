from tkinter import *

class Application(Frame):
    class Dictionary:
        class Section:
            class Entry:
                def __init__(self, term, definition):
                    self.term = term
                    self.defn = definition

            def __init__(self, title = ""):
                self.name = title
                self.entries = []

        def __init__(self):
            pass

        def __init__(self, stream):
            self.load(stream)

        def load(self, stream):
            def parseLine(raw):
                breakIndex = raw.find("|")
                if breakIndex == -1:
                    return None

                return currentSection.Entry(raw[:breakIndex].strip(), raw[breakIndex + 1:].strip())

            self.sections = [self.Section()]
            currentSection = self.sections[0]

            while True:
                raw = stream.readline()

                if raw == "":
                    break

                if raw[0 : 2] == "--":
                    # Remove trailing newline.
                    currentSection = self.Section(raw[2 : -1].strip())
                    self.sections.append(currentSection)
                else:
                    # Remove trailing newline.
                    entry = parseLine(raw[:-1])

                    if entry != None:
                        currentSection.entries.append(entry)

    def __init__(self, title = "", master = None):
        Frame.__init__(self, master)
        self.master.title(title)
        self.grid()

        self.filename = Entry(self)
        self.filename.grid()
        self.result = Label(self, text = "Load a file...")
        self.result.grid()

        Button(
            self,
            text = "Load file",
            command = lambda : self.loadFile(self.filename.get())
        ).grid(row = 0, column = 1)

    def loadFile(self, filename):
        try:
            file = open(filename)
        except IOError:
            self.result["text"] = "Can't find file \"" + filename + "\"."
            self.result["foreground"] = "#ff0000"
            return

        self.result["text"] = "Success!"
        self.result["foreground"] = "#00ff00"
        self.dictionary = self.Dictionary(file)

Application("Vocab Tester").mainloop()

