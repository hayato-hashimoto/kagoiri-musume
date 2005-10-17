function sort_table(e){
     var target = e.target;
     var rev = false;
     if (target.style.backgroundColor){
          target.style.backgroundColor = null;
          rev = true;
     }
     else {
          var brothers = target.parentNode.childNodes;
          for (var i = 0; i < brothers.length; i++){
               brothers[i].style.backgroundColor = null;
          }
          target.style.backgroundColor = 'pink';
     }
     var table = e.target.parentNode.parentNode.parentNode;
     var headers = table.rows.item(0).cells;

     var pos = 0;
     for (var i = 0; i < headers.length; i++) {
          if (target == headers[i]) {
               pos = i;
               break
          }
     }
     var rows = table.rows;
     var rows_ = new Array;
     for (var i = 1; i < rows.length; i++) {
          rows_[i-1] = rows.item(i);
     }

     rows_ = rows_.sort(function(x,y){
                             var x_var = x.cells.item(pos).getAttribute('value');
                             var y_var = y.cells.item(pos).getAttribute('value');
                             if (x_var == y_var)
                                  return 0;
                             else if (x_var > y_var)
                                  return rev?1:-1;
                             else
                                  return rev?-1:1;
                        });

     tbody = table.getElementsByTagName('TBODY').item(0)
     for (var i = 0; i<rows_.length; i++){
          tbody.appendChild(rows_[i]);
     }
}
