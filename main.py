from tkinter import *

class Application(Frame):
    class Dictionary:
        class Section:
            class Entry:
                def __init__(this, term, definition):
                    this.term = term
                    this.defn = definition

            def __init__(this, title = ""):
                this.name = title
                this.entries = []

        def __init__(this):
            pass

        def __init__(this, stream):
            this.load(stream)

        def load(this, stream):
            def parseLine(raw):
                breakIndex = raw.find("|")
                if breakIndex == -1:
                    return None

                return currentSection.Entry(raw[:breakIndex].strip(), raw[breakIndex + 1:].strip())

            this.sections = []
            currentSection = None

            while True:
                raw = stream.readline()

                if raw == "":
                    break

                if raw[0 : 2] == "--":
                    # Remove trailing newline.
                    currentSection = this.Section(raw[2 : -1].strip())
                    this.sections.append(currentSection)
                else:
                    if currentSection == None:
                        currentSection = this.Section("Uncategorized")
                        this.sections.append(currentSection)

                    # Remove trailing newline.
                    entry = parseLine(raw[:-1])

                    if entry != None:
                        currentSection.entries.append(entry)

    def __init__(this, title = "", master = None):
        Frame.__init__(this, master)
        this.master.title(title)
        this.grid()

        this.result = Label(this, text = "Load a file...")
        this.result.grid(columnspan = 2048, sticky = W)
        Label(this, text = "Dictionary filename: ").grid()
        this.filename = Entry(this)
        this.filename.grid(row = 1, column = 1)

        Button(
            this,
            text = "Load file",
            command = lambda : this.loadFile(this.filename.get())
        ).grid(row = 1, column = 2)

        this.filler = Label(this)
        this.filler.grid()

        this.termBox = Label(this)
        this.termBox.grid(columnspan = 2048)

        this.defnBox = Entry(this, width = 64)
        this.defnBox.grid(columnspan = 2048)

        this.hideTestArea()

    def showTestArea(this):
        this.filler.grid()
        this.termBox.grid()
        this.defnBox.grid()

    def hideTestArea(this):
        this.filler.grid_remove()
        this.termBox.grid_remove()
        this.defnBox.grid_remove()

    def loadFile(this, filename):
        try:
            file = open(filename)
        except IOError:
            this.result["text"] = "Can't find file \"" + filename + "\"."
            this.result["foreground"] = "#ff0000"

            this.hideTestArea()
            return

        this.result["text"] = "Success!"
        this.result["foreground"] = "#00ff00"
        this.dictionary = this.Dictionary(file)

        this.showTestArea()

Application("Vocab Tester").mainloop()

