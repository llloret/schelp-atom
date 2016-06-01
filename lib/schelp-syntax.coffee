'use babel';

SchelpSyntaxView = require './schelp-syntax-view'
ElementIndex = require('./element-index')

{CompositeDisposable} = require 'atom'

module.exports = schelpSyntax =
    schelpSyntaxView: null
    modalPanel: null
    subscriptions: null

    activate: (state) ->
        @index = new ElementIndex(state?.entries)
        @schelpSyntaxView = new SchelpSyntaxView(state.schelpSyntaxViewState)
        @modalPanel = atom.workspace.addModalPanel(item: @schelpSyntaxView.getElement(), visible: false)

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace',
            'schelp-syntax:toggle': => @toggle()

    deactivate: ->
        @modalPanel.destroy()
        @subscriptions.dispose()
        @schelpSyntaxView.destroy()

    serialize: ->
        schelpSyntaxViewState: @schelpSyntaxView.serialize()
        entries: @index.entries

    toggle: ->
        console.log 'SchelpSyntax was toggled!'
