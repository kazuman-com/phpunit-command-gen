PhpunitCommandGenView = require './phpunit-command-gen-view'
{CompositeDisposable} = require 'atom'

module.exports = PhpunitCommandGen =
  phpunitCommandGenView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @phpunitCommandGenView = new PhpunitCommandGenView(state.phpunitCommandGenViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @phpunitCommandGenView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'phpunit-command-gen:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'phpunit-command-gen:toggle2': => @toggle2()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @phpunitCommandGenView.destroy()

  serialize: ->
    phpunitCommandGenViewState: @phpunitCommandGenView.serialize()

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()

    projectPaths = atom.project.getPaths()
    projectPath = ""
    for val in projectPaths
      if editor.getPath().indexOf(val) >= 0
        projectPath = val
        break

    path = "." + editor.getPath().replace(projectPath, "").replace(/\\/g, "/")
    atom.clipboard.write("phpunit " + path)

  toggle2: ->
    editor = atom.workspace.getActiveTextEditor()

    projectPaths = atom.project.getPaths()
    projectPath = ""
    for val in projectPaths
      if editor.getPath().indexOf(val) >= 0
        projectPath = val
        break

    path = "." + editor.getPath().replace(projectPath, "").replace(/\\/g, "/")
    pos = editor.getCursorScreenPosition()
    line = pos.row
    while line >= 0
      txt = editor.lineTextForScreenRow(line)
      if txt.indexOf("function") >= 0
        funcLine = txt.split(" ")
        for val,i in funcLine
          if val.indexOf("function") >= 0
            atom.clipboard.write("phpunit --filter='" + funcLine[i+1].replace(/\(.*/, "") + "' " + path)
            line = -1
            break

      line--
