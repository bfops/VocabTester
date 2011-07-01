from tkinter import *
import random

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

            this.sections = []
            currentSection = None

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
                    if currentSection == None:
                        currentSection = this.Section("Uncategorized")
                        this.sections.append(currentSection)

                    # Remove trailing newline.
                    entry = parseLine(raw)

                    if entry != None:
                        currentSection.entries.append(entry)

    def __init__(this, title = "", master = None):
        def attemptFileLoad():
            if this.loadFile(this.filename.get()):
                this.defnBox.focus_set()

        Frame.__init__(this, master)

        this.bind_all("<KeyPress-Escape>", lambda e : this.quit())

        # Set up the window itself
        this.master.title(title)
        this.grid()

        # TODO: Allow file browser.
        this.result = Label(this, text = "Load a file...")
        this.result.grid(columnspan = 2048, sticky = W)

        Label(this, text = "Dictionary filename: ").grid()

        this.filename = Entry(this, exportselection = 0)
        this.filename.grid(row = 1, column = 1)
        # TODO: Try loading as they type.
        this.filename.bind("<KeyPress-Return>", lambda e : attemptFileLoad())

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

    def hideTestArea(this):
        this.filler.grid_remove()
        this.languageBox.grid_remove()
        this.termBox.grid_remove()
        this.defnBox.grid_remove()
        this.answerBox.grid_remove()

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

            if sectionLength == 1:
                dictionaries.sections.pop(sectionN)

            entryN = random.randrange(0, sectionLength)
            entry = section.entries.pop(entryN)

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
        this.dictionary = this.Dictionary(file)

        this.showTestArea()
        this.test()

        return True

random.seed()
root = Tk()
root.resizable(False, False)
Application("Vocab Tester", root).mainloop()

