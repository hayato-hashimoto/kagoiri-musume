function sort_table(e){
     var target = e.target;
     var rev = false;
     if (target.style.backgroundColor){
          target.style.backgroundColor = null;
          rev = true;
     } else {
          var brothers = target.parentNode.childNodes;
          for (var i = 0; i < brothers.length; i++){
               brothers[i].style.backgroundColor = null;
          }
          target.style.backgroundColor = 'pink';
     }
     var table = find_parent(e.target, 'TABLE');
     var headers = table.rows.item(0).cells;

     var pos = target.cellIndex;
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

     var newbody = document.createElement('tbody');

     var tbody = table.getElementsByTagName('TBODY').item(0);

     for (var i = 0; i<rows_.length; i++) {
          newbody.appendChild(rows_[i]);
     }
     tbody.parentNode.replaceChild(newbody, tbody);
}

function filter_table(select, id, all_text, pos){

     var table = document.getElementById(id);
     var options = select.options;
     var option;

     var option_list = new Array;
     var select_text_list = new Array;

     /* find selected text */
     for (var i=0; i<options.length; i++) {
          option = options.item(i)
          if (option.selected) {
               option_list.push(option);
               select_text_list.push(option.text);
          }
     }
     /* highlight selected option */
     var prev_options = select.prev_options;
     if (prev_options != undefined)
          for (var i=0; i<prev_options.length; i++) {
               prev_options[i].style.backgroundColor = null;
          }
     for (var i=0; i<option_list.length; i++) {
          option_list[i].style.backgroundColor = 'lightblue';
     }
     select.prev_options = option_list;

     var all = has_item(select_text_list,all_text)?true:false;
     var tbody = table.getElementsByTagName('TBODY').item(0);

     var row;
     /* reset previous filter */
     if (select.filterd_rows != undefined) {
          for (var i = 0; i<select.filterd_rows.length; i++) {
               row = select.filterd_rows[i];
               row.filterd -= 1;
          }
     }
     var cell;
     var rows = table.rows;
     var filterd_rows = new Array;
     /* filter loop */
     for (var i = 1; i < rows.length; i++) {
          row = rows.item(i);
          cell = row.cells.item(pos);
          /* initialize filter count */
          if (row.filterd == undefined) {
               row.filterd = 0;
          }
          /* count up */
          if (!all && !has_item(select_text_list, cell.textContent)) {
               filterd_rows.push(row)
               row.filterd += 1;
          }

          /* check count and set visibility */
          if (!all && row.filterd > 0) {
               row.style.display = "none";
          } else if (row.filterd == 0) {
               row.style.display = null;
          }
     }
     /* save filterd_rows for next select */
     select.filterd_rows = filterd_rows;
     find_parent(select, 'TABLE').rows.item(0).cells.item(select.parentNode.cellIndex).style.color = all?null:'red';


     return true;
}

function find_parent(ele, tagname){
     while (ele.tagName != tagname) {
          ele = ele.parentNode;
          if (ele == document) {
               return false;
          }
     }
     return ele;
}


function toggle_select_mode(e){
     var target = e.target;
     if (target.className != 'clickable')
          return false
     target = find_parent(target, 'TH')
     var pos = target.cellIndex;
     var td = target.parentNode.nextSibling.cells.item(pos);
     var select = td.getElementsByTagName('SELECT').item(0);
     select.multiple = select.size>0?false:true;
     select.size = select.size>0?-1:5;

}

function has_item(array, value){
     for (var i=0; i<array.length; i++) {
          if (array[i] == value){
               return true;
          }
     }
     return false;
}
