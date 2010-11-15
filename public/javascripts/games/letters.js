var Letters = {
  characters : {
    'a' : { width: 42, height: 53 },
    'b' : { width: 35, height: 54 },
    'c' : { width: 35, height: 53 },
    'd' : { width: 39, height: 54 },
    'e' : { width: 29, height: 54 },
    'f' : { width: 28, height: 54 },
    'g' : { width: 35, height: 54 },
    'h' : { width: 42, height: 52 },
    'i' : { width: 28, height: 55 },
    'j' : { width: 43, height: 54 },
    'k' : { width: 43, height: 56 },
    'l' : { width: 32, height: 54 },
    'm' : { width: 51, height: 55 },
    'n' : { width: 42, height: 53 },
    'o' : { width: 40, height: 53 },
    'p' : { width: 32, height: 53 },
    'q' : { width: 45, height: 54 },
    'r' : { width: 37, height: 55 },
    's' : { width: 28, height: 55 },
    't' : { width: 37, height: 56 },
    'u' : { width: 41, height: 55 },
    'v' : { width: 41, height: 55 },
    'w' : { width: 60, height: 60 },
    'x' : { width: 35, height: 53 },
    'y' : { width: 41, height: 55 },
    'z' : { width: 37, height: 56 }
  },

  images : [],

  initialise : function(){
    this.paper = Raphael('paper', 958, 500);
    this.spawnCharacters();
  },

  spawnCharacters : function(){
    jQuery.each(this.characters, function(character, dimensions){
      Letters.createCharacter(character, dimensions);
      Letters.createCharacter(character, dimensions);
      Letters.createCharacter(character, dimensions);
    });
  },

  createCharacter : function(character, dimensions){
    var letter = Letters.paper.image('/images/letters/'+character+'.png', 20, 20, dimensions.width, dimensions.height);
    letter.drag(Letters.dragMove, Letters.dragStart, Letters.dragUp);
    Letters.images.push(letter);
    return letter;
  },

  dragMove : function(dx, dy){
    this.attr({x: this.x + dx, y: this.y + dy});
    this.paper.safari();
    web_socket.trigger('move', [this.id, this.attr('x'), this.attr('y')]);
  },

  dragStart : function(){
    this.x = this.attr('x');
    this.y = this.attr('y');
  },

  dragUp : function(){
  },

  updatePlayerCount: function(value){
    jQuery('#player_count').text(value);
  },

  rx: {
    update: function(image_id, x, y){
      var letter = Letters.images[image_id];
      // var path = "M"+letter.attr('x')+" "+letter.attr('y')+"L"+x+" "+y;
      letter.attr({'x': x, 'y': y});
    }
  }
};

//////////////////////////////////

jQuery(document).ready(function(){
  Letters.initialise();

  web_socket = new WebSocket("ws://markbookair.local:8081/letters/1");

  web_socket.trigger = function(event, data){
    var payload = JSON.stringify([event, data]);
    web_socket.send(payload);
  };

  web_socket.onmessage = function(evt) {
    json = JSON.parse(evt.data);

    switch(json[0]){
      case 'playerCount':
        Letters.updatePlayerCount(json[1]);
        break;
      case 'move':
        Letters.rx.update(json[1][0], json[1][1], json[1][2]);
        break;
    };
  };
});
