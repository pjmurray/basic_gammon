$ -> 

  # class BoardState
    # currentPiece
    # colorDirection
    #readyToPlace
    #readyToPlace
    
  class User
    constructor: (@name, @color)->
    direction: -> 
      if @color == 'black'
        -1
      else 
        1


    
    
  class Piece
    currentPoint: undefined
      
    constructor: (@user)-> 
      
    color: -> 
      @user.color if @user?         

    render: ->
      @$el = $("<div class='piece #{@color()}'></div>")
        
    
    select: -> 
      @selected = true
      @$el.addClass('selected')

    deselect: -> 
      @selected = false
      @$el.removeClass('selected')
      
    canMoveTo: (point)->
      return true unless @currentPoint?
      (point.position - @currentPoint.position) *  @user.direction() > 0

    

    moveTo: (point)-> 
      unless @canMoveTo(point)
        alert 'wrong direction'
        return false 
      @currentPoint.removePiece(@) if @currentPoint?
            
      point.$el.append(@$el)      
      
      point.addPiece(@)
            
      @currentPoint = point
      
      @deselect() if @selected
      
    hit: (board)->
      @currentPoint.removePiece(@) if @currentPoint?
      $('.divider').append(@$el)
      @currentPoint = undefined
            
      

  # class Divider extends Point
  #   pieces:
  #   constructor
        
        

  class Point
    active: false
    pieces: []
    
    constructor: (@$el, @position, @board)->    
      @bindEvents()
      
    bindEvents: -> 
      @$el.on 'click', => 
        if @selectable
          return false if @isEmpty()
          if @selectedPiece()?
            @board.pieceDeselected(@selectedPiece())
          else
            @board.pieceSelected(@pieces[0])
                                    
        else if @placeable 
            @board.piecePlacedOn(@)
      
    setSelectable: ->
      @deactivate()
      @selectable = true
      @$el.addClass('selectable')
      
    setPlaceable: -> 
      @deactivate()
      @placeable = true
      @$el.addClass('placeable')
      
    deactivate: -> 
      @selectable = false
      @placeable = false
      @$el.removeClass('selectable')
      @$el.removeClass('placeable')
      
    selectedPiece: -> 
      _(@pieces).find (piece)-> 
        piece.selected              
                                    
    availableFor: (piece)-> 
      @isEmpty() || @currentColor() == piece.color() || @currentColor != piece.color() and @pieces.length == 1
          
    moveableFor: (die)-> 
      return false if @isEmpty()            
      _(die).chain().uniq().some (dice)=>
        
        index = @position - (dice * @currentUser().direction())
        if index >= 0 and index <= 23          
          console.log index
          @board.points[index].availableFor(@pieces[0])

      .values()
              
    inRangeFor: (piece, die)->
      diff = (@position - piece.currentPoint.position) * piece.user.direction()
      return false if diff < 0               
      _(die).some (dice)->        
        dice == diff
        
    isBlot: -> 
      @pieces.length == 1
                    
    isEmpty: ->
      @pieces.length == 0
      
    occupiedBy: (user)->
       @currentColor() is user.color
      
    currentUser: -> 
      @pieces[0].user unless @isEmpty()      
      
    currentColor: -> 
      @pieces[0].color() unless @isEmpty()
      
    addPiece: (pieceToAdd)->
      @pieces = @pieces.concat(pieceToAdd)
      
    removePiece: (pieceToRemove)->
      @pieces = _(@pieces).reject (piece)-> 
       piece == pieceToRemove
        
      
      
    
  class Board
    totalPoints: 24
    hitPieces: []
    startingPieces: {0: 2, 11: 5, 16: 3, 18: 5}
    points: []
	
    constructor: (@$el, @game)->      
       #   
    

    render: ->    
      renderOpts = ['top', -1]
      
      row1Name = renderOpts[0]
      row1 = @$el.find(".#{row1Name}").find('.point').toArray()
      row2Name = _(['top','bottom']).difference([row1Name])[0]
      row2 = @$el.find(".#{row2Name}").find('.point').toArray()
      
      row1Direction = renderOpts[1]
             
      if row1Direction == -1
        row1 = row1.reverse()
      else
        row2 = row2.reverse()
                
      @points = _(row1.concat(row2)).map (el, i)=>        
        new Point($(el),i, @)
      console.log @points
        

         
        
    pieceSelected: (piece)->
      piece.select()                   
      @game.state.currentPiece = piece
      @setPlaceable()
            
    pieceDeselected: (piece)-> 
      piece.deselect()   
      @game.state.currentPiece = undefined
      @setSelectable()
      
    piecePlacedOn: (point)->      
      distance = Math.abs(@game.state.currentPiece.currentPoint.position - point.position)
      if point.availableFor(@game.state.currentPiece)
        if point.currentUser() != @game.state.currentUser && point.isBlot()
          hitPiece = point.pieces[0]
          hitPiece.hit()
          @hitPieces.push(hitPiece)
        @game.state.currentPiece.moveTo(point)      
        
        if @game.state.availableDice.length == 1
          @game.endTurn()
        else                      
          @game.state.availableDice.splice(@game.state.availableDice.indexOf(distance), 1)
          @setSelectable()
      else
        console.log "Not valid"
        
    currentlyHit: -> 
      _(@hitPieces).some (piece)=>
        piece.user == @game.state.currentUser                  
        
    setSelectable: -> 
      if @currentlyHit() 
        
        
      else                      
      _(@points).each (point)=>
        point.deactivate()                
        if point.occupiedBy(@game.state.currentUser) and point.moveableFor(@game.state.availableDice)    
          point.setSelectable()
        
    setPlaceable: -> 
      options = @game.state.availableDice
      if options.length == 2
        options.push(options[0] +  options[1])
      else if options.length >= 3
        options.push(options[0] * 2)
        options.push(options[0] * 3)
        if @game.state.availableDice.length == 4
          options.push(options[0] * 4)        
        
          
        
      _(@game.state.availableDice.push(@game.state.availableDice))
      @state.currentPiece
      
      _(@points).each (point)=>
        point.deactivate()      
        if point.availableFor(@game.state.currentPiece) and point.inRangeFor(@game.state.currentPiece, @game.state.availableDice)                                
          point.setPlaceable() 
          
    deactivate: ->
      _(@points).each (point)=>
        point.deactivate()      

                          
    reset: ->
      _(@startingPieces).each (v,k)=>        
        _(v).times ()=>
          piece = new Piece(@game.users[0])
          piece.render()
          piece.moveTo(@points[k])

          piece = new Piece(@game.users[1])
          piece.render()
          piece.moveTo(@points[@totalPoints - k - 1])

        
  class GameState
    currentUser: undefined
    currentDice: []
    availableDice: []
    currentTurnState: undefined
    currentPiece: undefined
    autoRole: false    
    # possibleTurnStates: ['rollable', 'selectable', 'placeable']
    
  class Game
    currentUser: undefined

    users: []

    constructor: ->
      @users = [new User("PJ", "white"), new User("Ash", "black")]
      @board = new Board($('.board'), @)
      @state = new GameState
      
    render: ->     
      @board.render()      
      @bindEvents()
      
    bindEvents: -> 
      $('.roll_dice').on 'click', (e)=>
        e.preventDefault()
        @diceRolled()
      $('.auto_role input').on 'change', (e)=>
        @state.autoRole = $(e.target).is(':checked')
      # $('.quarter').on 'click' (e)->
        # if @whiteHome

    start: -> 
      @board.reset()      
      @startTurn(@users[0])

      
    diceRolled: -> 
      dice1  = Math.floor(Math.random() * 6) + 1
      dice2  = Math.floor(Math.random() * 6) + 1
      if dice1 == dice2
        die = [dice1, dice1, dice2, dice2]
      else         
        die = [dice1,dice2]
      @state.currentDice = die
      @state.availableDice = die
            
      $('.dice-1').text(dice1)
      $('.dice-2').text(dice2)       
      
      @board.setSelectable(@state)              

    endTurn: ->
      @board.deactivate()
      otherUsers =  _(@users).reject (user)=>
        user == @state.currentUser
      @startTurn(otherUsers[0])

      
    startTurn: (user)->
      @state.currentDice = []
      @state.availableDice = []
      $('.dice-1').text("")
      $('.dice-2').text("")
      $('.quarter').removeClass('home')
      if user.color == 'black'
        $('.top-left').addClass('home')
      else if user.color == 'white'
        $('.bottom-left').addClass('home')
      
      @state.currentUser = user
      $('.current-user').text(@state.currentUser.name)
      @diceRolled() if @state.autoRole

      
      

  if $('.board')
    game = new Game
    game.render()
    game.start()
     