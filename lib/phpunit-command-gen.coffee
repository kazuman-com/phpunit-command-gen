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

    com = "docker exec docker_php_1 ./vendor/bin/phpunit"
    path_prefix = "."
    if /([a-z]+)$/.exec(projectPath)[0].indexOf("******") >= 0
      com = "docker exec docker_******_1 /usr/local/******/vendor/bin/phpunit"
      path_prefix = "/usr/local/******"

    path = path_prefix + editor.getPath().replace(projectPath, "").replace(/\\/g, "/")
    atom.clipboard.write(com + " " + path)

  toggle2: ->
    editor = atom.workspace.getActiveTextEditor()

    projectPaths = atom.project.getPaths()
    projectPath = ""
    for val in projectPaths
      if editor.getPath().indexOf(val) >= 0
        projectPath = val
        break

    pos = editor.getCursorScreenPosition()
    line = pos.row
    com = "docker exec docker_php_1 ./vendor/bin/phpunit"
    path_prefix = "."
    if /([a-z]+)$/.exec(projectPath)[0].indexOf("******") >= 0
      com = "docker exec docker_******_1 /usr/local/******/vendor/bin/phpunit"
      path_prefix = "/usr/local/******"

    path = path_prefix + editor.getPath().replace(projectPath, "").replace(/\\/g, "/")

    while line >= 0
      txt = editor.lineTextForScreenRow(line)
      if txt.indexOf("function") >= 0
        funcLine = txt.split(" ")
        for val,i in funcLine
          if val.indexOf("function") >= 0
            atom.clipboard.write(com + " --filter='" + funcLine[i+1].replace(/\(.*/, "") + "' " + path)
            line = -1
            break

      line--
