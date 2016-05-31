parse = require './element-parser'
{CompositeDisposable} = require 'atom'


module.exports =
class SymbolIndex
  constructor: (entries)->
      @entries = {}
      @markers = []
      @subscribe()



  subscribe: () ->
    atom.workspace.onDidStopChangingActivePaneItem (editor) =>
      @updateGutter()

    atom.workspace.observeTextEditors (editor) =>
      editor_disposables = new CompositeDisposable
      # Editor events
      editor_disposables.add editor.onDidChangeGrammar =>
        @updateGutter()

      editor_disposables.add editor.onDidStopChanging =>
        @updateGutter()


      editor_disposables.add editor.onDidDestroy ->
        editor_disposables.dispose()

  getEditorSymbols: (editor) ->
    # Return the symbols for the given editor, rescanning the file if necessary.
    if (editor)
        fqn = editor.getPath()
#    if not @entries[fqn]
        @entries[fqn] = parse(fqn, editor.getGrammar(), editor.getText())
        return @entries[fqn]

  clearMarkers: () ->
    for marker in @markers
        marker.destroy()

  addMarker: (editor, lineno) ->
    marker = editor.markBufferPosition([lineno, 0], invalidate: 'never')
    editor.decorateMarker(marker, type: 'line-number', class: 'error-line')
    @markers.push(marker)




  updateGutter:() ->
    @clearMarkers()
    invalid_re = ///invalid///
    console.log 'updateGutter!!!'
    editor = atom.workspace.getActiveTextEditor()
    lines = @getEditorSymbols(editor)
    if (!lines)
        return
    for line,lineno in lines
        for scope in line
            console.log 'scope: ' + scope
            if invalid_re.test(scope)
                @addMarker(editor, lineno)
