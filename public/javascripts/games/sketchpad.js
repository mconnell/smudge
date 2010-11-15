// Copyright smudge.it
// All rights reserved.

Sketchpad = {
  initialise: function(){
    Sketchpad.paper = Raphael('paper', 960, 450);
    Sketchpad.bindDrawingTool();
  },

  bindDrawingTool: function(){
    var offset = jQuery('#paper').offset();
    var start_x, start_y, shape, path, moving;

    jQuery('#paper').mousedown(function (event) {
      moving  = true;
      start_x = event.pageX - offset.left;
      start_y = event.pageY - offset.top;
      path    = [["M", start_x, start_y],["L", start_x, start_y]];
      shape   = Sketchpad.paper.path(path);
      shape.attr({'stroke-width' : 2, 'opacity': 0.2});
    });

    jQuery('#paper').mousemove(function(event){
      if(moving){
        path[path.length] = ['L', (event.pageX-offset.left), (event.pageY-offset.top)];
        shape.attr({path: path});
      };
    });

    jQuery(document).mouseup(function(event){
      if(moving){
        web_socket.trigger('draw', shape.attrs['path']);
        moving = false;
      };
    });
  },

  rx: {
    clear: function(){
      Sketchpad.paper.clear();
      Sketchpad.countdown.count = 180;
      return true;
    },
    draw: function(obj){
      var shape = Sketchpad.paper.path(obj);
      shape.attr({'stroke-width' : 2, 'opacity': 0.2});
      return shape;
    }
  },

  countdown: {
    count: 180,
    start: function(count){
      if(count > 0){ Sketchpad.countdown.count = count };
      setInterval("Sketchpad.countdown.decrement()", 1000);
    },
    decrement: function(){
      if(Sketchpad.countdown.count > 0){
        Sketchpad.countdown.count -= 1;
        Sketchpad.countdown.display();
      };
    },
    display: function(){
      var minutes = Math.floor(Sketchpad.countdown.count/60);
      var seconds = Sketchpad.countdown.count % 60;
      if(seconds < 10){ seconds = '0'+seconds }
      jQuery('#countdown').text(minutes+':'+seconds);
    }
  }
};

//////////////////////////////////

jQuery(document).ready(function(){
  Sketchpad.initialise();

  web_socket = new WebSocket("ws://markbookair.local:8080/sketchpad/1");

  web_socket.trigger = function(event, data){
    var payload = JSON.stringify([event, data]);
    web_socket.send(payload);
  };

  web_socket.onmessage = function(evt) {
    json = JSON.parse(evt.data);

    switch(json[0]){
      case 'draw':
        Sketchpad.rx.draw(json[1]);
        break;
      case 'clear':
        Sketchpad.rx.clear();
        break;
      case 'startTimer':
        Sketchpad.countdown.start(json[1]);
        break;
    };
  };

});
