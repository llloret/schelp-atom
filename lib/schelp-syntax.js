'use babel';

import SchelpSyntaxView from './schelp-syntax-view';
import { CompositeDisposable } from 'atom';

export default {

  schelpSyntaxView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.schelpSyntaxView = new SchelpSyntaxView(state.schelpSyntaxViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.schelpSyntaxView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'schelp-syntax:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.schelpSyntaxView.destroy();
  },

  serialize() {
    return {
      schelpSyntaxViewState: this.schelpSyntaxView.serialize()
    };
  },

  toggle() {
    console.log('SchelpSyntax was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
