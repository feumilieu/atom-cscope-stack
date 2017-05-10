module.exports =
class Navigation

  constructor: (size) ->
    @historyPrev = []
    @historyCurr = null
    @historyNext = []
    @historyMax = size

  save: (model) ->

    if not model.functionName?
      console.log "no functionName in model (?)"

    if not @historyCurr?
      @pushCurrentToHistoryPrev()
    else
      # There should not exist two consecutive "from" locations in the stack,
      # it is pointless.  If keyword is set, then the current location is a "to"
      # location and it should be saved.
      if @historyCurr.keyword?
        # Check for the case when the cscope panel is still opened and we choose
        # another search result from it.  In this case we should not remember
        # the choice we made before.
        if @historyCurr.keyword isnt model.functionName
          @historyPrevPush @historyCurr
          @pushCurrentToHistoryPrev()
      else
        @pushCurrentToHistoryPrev()

    @historyCurr =
      path: model.projectDir
      pos:
        column: 0
        row: model.lineNumber - 1
      keyword: model.functionName

    @historyNext = []

  pushCurrentToHistoryPrev: ->
    editor = atom.workspace.getActiveTextEditor()
    pos = editor?.getCursorBufferPosition()
    file = editor?.buffer.file
    filePath = file?.path
    if pos? and filePath?
      @historyPrevPush
        path: filePath
        pos: pos
        keyword: null

  historyPrevPush: (item) ->
    @historyPrev.push item
    if @historyPrev.length > @historyMax
      @historyPrev.shift()

  openHistoryCurr: ->
    console.log "openHistoryCurr"
    atom.workspace.open(@historyCurr.path, {initialLine: @historyCurr.pos.row, initialColumn: @historyCurr.pos.column, pending: true})

  openNext: ->
    next = @historyNext.pop()
    return if not next?
    @historyPrev.push @historyCurr if @historyCurr?
    @historyCurr = next
    @openHistoryCurr()

  openPrev: ->
    prev = @historyPrev.pop()
    return if not prev?
    @historyNext.push @historyCurr if @historyCurr?
    @historyCurr = prev
    @openHistoryCurr()
