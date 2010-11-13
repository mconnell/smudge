// Copyright smudge.it
// All rights reserved.

Sketchpad = {
  initialise: function(){
    Sketchpad.paper  = Raphael('paper', 960, 450);
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

    jQuery('#paper').mouseup(function (event) {
      moving = false;
    });
  },

  rx: {
    clear: function(){
      paper.clear();
      return true;
    },
    draw: function(){
      var shape = Sketchpad.canvas.path(obj.paths);
      shape.attr({'stroke-width' : 2, 'opacity': 0.8});
      return shape;
    }
  }
};

//////////////////////////////////

jQuery(document).ready(function(){
  Sketchpad.initialise();
});
