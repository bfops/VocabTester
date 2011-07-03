from tkinter import *
import random

class Application(Frame):
    # TODO: Entries can have multiple definitions.
    class Dictionary:
        class Section:
            class Entry:
                def __init__(this, term, definition):
                    this.term = term
                    this.defn = definition

            def __init__(this, title = ""):
                this.name = title
                this.entries = []

        def __init__(this, stream = None):
            this.sections = []

            if stream != None:
                this.load(stream)

        def load(this, stream):
            def parseLine(raw):
                breakIndex = raw.find("|")
                if breakIndex == -1:
                    return None

                return currentSection.Entry(raw[:breakIndex].strip(), raw[breakIndex + 1:].strip())

            def readLanguage(stream):
                # Remove trailing newline.
                raw = stream.readline()[:-1]

                if raw[:1] != "{" or raw[-1:] != "}":
                    return None

                raw = raw[1 : -1]
                splitIndex = raw.find("|")
                if splitIndex == -1:
                    return None

                return (raw[:splitIndex].strip(), raw[splitIndex + 1:].strip())

            this.language = readLanguage(stream)

            if this.language == None:
                del this.language
                return

            this.sections = [this.Section("Uncategorized")]
            currentSection = this.sections[0]

            while True:
                raw = stream.readline()

                if raw == "":
                    break

                # Remove trailing newline.
                raw = raw[:-1]

                # If it's a section header (of the form "--section").
                if raw[0 : 2] == "--":
                    currentSection = this.Section(raw[2:].strip())
                    this.sections.append(currentSection)
                # It's an actual definition.
                else:
                    # Remove trailing newline.
                    entry = parseLine(raw)

                    if entry != None:
                        currentSection.entries.append(entry)

        # Remove all empty sections.
        def prune(this):
            i = 0
            end = len(this.sections)

            while i < end:
                if len(this.sections[i].entries) == 0:
                    this.sections.pop(i)
                    end -= 1
                else:
                    i += 1

    class DictionaryInterface(Toplevel):
        def __init__(this, dictionary, title = ""):
            Toplevel.__init__(this)
            this.resizable(False, False)
            this.title(title)
            this.grid()

            this.dictionary = dictionary

            Label(this, text = "Section").grid(columnspan = 2)
            Label(this, text = "Term").grid(columnspan = 2, row = 0, column = 3)
            Label(this, text = "Definition").grid(row = 0, column = 6)

            this.sectionBox = Listbox(this, selectmode = SINGLE)
            this.sectionBox.grid(columnspan = 2)
            this.sectionScroll = Scrollbar(this, command = this.sectionBox.yview, takefocus = 0)
            this.sectionScroll.grid(row = 1, column = 2, sticky = N+S)
            this.sectionBox["yscrollcommand"] = this.sectionScroll.set

            this.entryBox = Listbox(this, selectmode = SINGLE)
            this.entryBox.grid(columnspan = 2, row = 1, column = 3)
            this.entryScroll = Scrollbar(this, command = this.entryBox.yview, takefocus = 0)
            this.entryScroll.grid(row = 1, column = 5, sticky = N+S)
            this.entryBox["yscrollcommand"] = this.entryScroll.set

            this.defnBox = Text(this, width = 20, height = 10)
            this.defnBox.grid(row = 1, column = 6)

            Button(this, text = "Add", command = lambda : this.addSection(this.sectionName.get())).grid(sticky = E+W)
            Button(this, text = "Add", command = lambda : this.addEntry(this.entryName.get())).grid(row = 2, column = 3, sticky = E+W)

            Button(this, text = "Rename", command = lambda : this.renameSelectedSection(this.sectionName.get())).grid(row = 2, column = 1, sticky = E+W)
            Button(this, text = "Rename", command = lambda : this.renameSelectedEntry(this.entryName.get())).grid(row = 2, column = 4, sticky = E+W)

            this.sectionName = Entry(this)
            this.sectionName.grid(columnspan = 2)

            this.entryName = Entry(this)
            this.entryName.grid(columnspan = 2, row = 3, column = 3)

        def populateSectionList(this):
            this.sectionBox.delete(0, END)
            this.entryBox.delete(0, END)

            for section in this.dictionary.sections:
                this.sectionBox.insert(END, section.name)

        def addSection(this, name):
            pass

        def addEntry(this, name):
            pass

        def renameSelectedSection(this, name):
            pass

        def renameSelectedEntry(this, name):
            pass

    def __init__(this, title = ""):
        def attemptFileLoad():
            if this.loadFile(this.filename.get()):
                this.dictionaryWindow.populateSectionList()
                this.defnBox.focus_set()

        Frame.__init__(this)

        this.bind_all("<KeyPress-Escape>", lambda e : this.quit())

        # Set up the window itself
        this.winfo_toplevel().title(title)
        this.winfo_toplevel().resizable(False, False)
        this.grid()

        # TODO: Closing any way window should leave the others alive.
        this.dictionary = this.Dictionary()
        this.dictionaryWindow = this.DictionaryInterface(this.dictionary, "Dictionary")

        # TODO: Allow file browser.
        this.result = Label(this, text = "Load a file...")
        this.result.grid(columnspan = 2048, sticky = W)

        Label(this, text = "Dictionary filename: ").grid()

        this.filenameString = StringVar()
        this.filenameString.trace("w", lambda *args : attemptFileLoad())
        this.filename = Entry(this, textvariable = this.filenameString, exportselection = 0)
        this.filename.grid(row = 1, column = 1)

        this.filler = Label(this)
        this.filler.grid()

        this.languageBox = Label(this)
        this.languageBox.grid(columnspan = 2048, sticky = W)
        this.languageBox["foreground"] = "#0000ff"

        this.termBox = Label(this)
        this.termBox.grid(columnspan = 2048, sticky = W)

        this.defnBox = Entry(this, width = 64)
        this.defnBox.grid(columnspan = 2048, sticky = W)

        this.answerBox = Label(this)
        this.answerBox["foreground"] = "#ff00ff"
        this.answerBox.grid(columnspan = 2048, stick = W)

        this.hideTestArea()
        this.filename.focus_set()

    def showTestArea(this):
        this.filler.grid()
        this.languageBox.grid()
        this.termBox.grid()
        this.defnBox.grid()
        this.answerBox.grid()
        this.dictionaryWindow.deiconify()

    def hideTestArea(this):
        this.filler.grid_remove()
        this.languageBox.grid_remove()
        this.termBox.grid_remove()
        this.defnBox.grid_remove()
        this.answerBox.grid_remove()
        this.dictionaryWindow.withdraw()

        # Unbind any outstanding key events.
        this.bind_all("<KeyPress-Return>")

    def test(this):
        def showAnswer(e):
            this.answerBox["text"] = entry[3 - termOrDefn]
            this.bind_all("<KeyPress-Return>", lambda e : this.test())

        # Returns a tuple of (category, term, definition)
        def getRandomEntry():
            sectionN = random.randrange(0, len(this.dictionary.sections))
            section = this.dictionary.sections[sectionN]
            sectionLength = len(section.entries)

            entryN = random.randrange(0, sectionLength)
            entry = section.entries.pop(entryN)

            if sectionLength == 1:
                this.dictionary.sections.pop(sectionN)

            return (section.name, entry.term, entry.defn)

        entry = getRandomEntry()
        # Whether to use the term or definition as the "question".
        termOrDefn = random.randint(1, 2)

        this.languageBox["text"] = this.dictionary.language[termOrDefn - 1] + " to " + this.dictionary.language[2 - termOrDefn]
        this.termBox["text"] = entry[0] + ": " + entry[termOrDefn]
        # Clear the currently entered answer.
        this.defnBox.delete(0, len(this.defnBox.get()))
        this.answerBox["text"] = ""

        this.bind_all("<KeyPress-Return>", showAnswer)

        # TODO: Fix case where dictionary runs out.

    # Returns true if the file loaded successfully.
    def loadFile(this, filename):
        try:
            file = open(filename)
        except IOError:
            this.result["text"] = "Can't find file \"" + filename + "\"."
            this.result["foreground"] = "#ff0000"

            this.hideTestArea()
            return False

        this.result["text"] = "Success!"
        this.result["foreground"] = "#00ff00"
        this.dictionary.load(file)
        this.dictionary.prune()

        this.showTestArea()
        this.test()

        return True

random.seed()
Application("Vocab Tester").mainloop()

