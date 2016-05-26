module.exports = (path, grammar, text) ->
  lines = grammar.tokenizeLines(text)

  elements = []

  nextIsSymbol = false

  for tokens, lineno in lines
    elements.push([])
    for token in tokens
      if token.scopes
        for scope in token.scopes
            elements[lineno].push(scope)
  elements
