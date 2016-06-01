parse = require './element-parser'
{CompositeDisposable} = require 'atom'


module.exports =
class SymbolIndex
  constructor: (entries)->
      @entries = {}
      @markers = []
      @subscribe()

      @invalid_re = ///invalid///
      @section_re = ///entity.name.section.section///
      @title_re = ///entity.name.section.title///

      @line_markers = {}



  subscribe: () ->
    atom.workspace.onDidStopChangingActivePaneItem (editor) =>
      @update()

    atom.workspace.observeTextEditors (editor) =>
      editor_disposables = new CompositeDisposable
      # Editor events
      editor_disposables.add editor.onDidChangeGrammar =>
        @update()

      editor_disposables.add editor.onDidStopChanging =>
        @update()


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


  updateMarkers: (editor) ->
    @clearMarkers()
    if (@line_markers['invalid'])
        for lineno in @line_markers['invalid']
            @addMarker(editor, lineno)


  addMarker: (editor, lineno) ->
    marker = editor.markBufferPosition([lineno, 0], invalidate: 'never')
    editor.decorateMarker(marker, type: 'line-number', class: 'error-line')
    @markers.push(marker)




  update:() ->
    @line_markers = {}
    console.log 'update!!!'
    editor = atom.workspace.getActiveTextEditor()
    lines = @getEditorSymbols(editor)
    if (!lines)
        return
    for line,lineno in lines
        for scope in line
            console.log 'scope: ' + scope
            if @invalid_re.test(scope)
                if (!@line_markers['invalid'])
                    @line_markers['invalid'] = []
                @line_markers['invalid'].push(lineno)

            if @section_re.test(scope)
                if (!@line_markers['section'])
                    @line_markers['section'] = []
                @line_markers['section'].push(lineno)

            if @title_re.test(scope)
                if (!@line_markers['title'])
                    @line_markers['title'] = []
                @line_markers['title'].push(lineno)

    @updateMarkers(editor)
