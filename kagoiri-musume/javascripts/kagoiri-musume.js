function addOnloadEvent(proc){
     if (window.addEventListener) {
          window.addEventListener("load",proc,false);
     }
     else if (window.attachEvent) {
          window.attachEvent("onload", proc);
     }
}

var win = false;
var textContent = 'textContent';
var filter_state = new Object;
var sort_state = '';

function init(){
     win = document.all?true:false;
     textContent = win?'innerText':'textContent';
}

addOnloadEvent(init);
addOnloadEvent(focus_focus);

function sort_table(e){
     e = win?window.event:e;
     var target = win?e.srcElement:e.target;

     sort_state = target.getAttribute('value')

     var rev = false;
     if (target.style.backgroundColor){
          target.style.backgroundColor = '';
          rev = true;
     } else {
          var brothers = target.parentNode.childNodes;
          for (var i = 0; i < brothers.length; i++){
               brothers[i].style.backgroundColor = '';
          }
          target.style.backgroundColor = 'pink';
     }
     var table = find_parent(target, 'TABLE');
     var headers = table.rows.item(0).cells;
     var pos = target.cellIndex;
     var rows = table.rows;
     var rows_ = new Array;
     for (i = 1; i < rows.length; i++) {
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

     for (i = 0; i<rows_.length; i++) {
          newbody.appendChild(rows_[i]);
     }
     table.replaceChild(newbody, tbody);
}


function apply_flter_state(a){
     var state = '';
     for (filter in  filter_state){
          for (f in filter_state[filter]){
               state += ('&' + filter + '=' + encodeURIComponent(filter_state[filter][f].value));
          }
     }
     if (sort_state) {
          state += '&sort_state=' + encodeURIComponent(sort_state);
     }
     if (state){
          a.href += '?'+state.slice(1);
     }
}

function copy_search(a){
     if (location.search){
          a.href += (location.search + '&search=' + encodeURIComponent(location.search.slice(1)));
     }
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

     filter_state[select.name] = option_list;

     /* highlight selected option */
     var prev_options = select.prev_options;
     if (prev_options != undefined)
          for (i=0; i<prev_options.length; i++) {
               prev_options[i].style.backgroundColor = '';
          }
     for (i=0; i<option_list.length; i++) {
          option_list[i].style.backgroundColor = 'lightblue';
     }
     select.prev_options = option_list;

     var all = has_item(select_text_list,all_text)?true:false;

     var row;
     /* reset previous filter */
     if (select.filterd_rows != undefined) {
          for (i = 0; i<select.filterd_rows.length; i++) {
               row = select.filterd_rows[i];
               row.filterd -= 1;
          }
     }
     var cell;
     var rows = table.rows;
     var filterd_rows = new Array;

     var tbody = table.getElementsByTagName('TBODY').item(0);
     var newbody = document.createElement('tbody');
     table.style.display='none';
     /* filter loop */
     for (i = 1; i < rows.length; i++) {
          row = rows.item(i);
          cell = row.cells.item(pos);
          /* initialize filter count */
          if (row.filterd == undefined) {
               row.filterd = 0;
          }
          /* count up */
          if (!all && !has_item(select_text_list, cell[textContent])) {
               filterd_rows.push(row)
               row.filterd += 1;
          }

          /* check count and set visibility */
          if (!all && row.filterd > 0) {
               row.style.display = "none";
          } else if (row.filterd == 0) {
               row.style.display = '';
          }
     }
     table.style.display=''
     /* save filterd_rows for next select */
     select.filterd_rows = filterd_rows;
     find_parent(select, 'TABLE').rows.item(0).cells.item(select.parentNode.cellIndex).style.color = all?'':'red';


     return true;
}

function filter_this(e){
     e = win?window.event:e;
     var target = win?e.srcElement:e.target;
     var target_text = target[textContent];
     var table = find_parent(target,'TABLE');
     var head = table.tHead.rows.item(0).cells.item(target.cellIndex);
     var pos = head.getAttribute('for');
     var filter = document.getElementById('table_filter');
     var select = filter.rows.item(1).cells.item(pos).getElementsByTagName('SELECT').item(0);
     var opt;
     for (var i=0; i<select.options.length; i++) {
          opt = select.options[i];
          if (opt[textContent] == target_text) {
               opt.selected = true;
          }
     }
     select.onchange()

//      var rows = table.rows;
//      var filterd_rows = new Array;
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
     e = win?window.event:e;
     var target = win?e.srcElement:e.target;
     if (target.className != 'clickable')
          return false;
     target = find_parent(target, 'TH');
     var pos = target.cellIndex;
     var td = target.parentNode.nextSibling.cells.item(pos);
     var select = td.getElementsByTagName('SELECT').item(0);
     select.multiple = select.size>1?false:true;
     select.size = select.size>1?1:5;
     return false;
}

function has_item(array, value){
     for (var i=0; i<array.length; i++) {
          if (array[i] == value){
               return true;
          }
     }
     return false;
}

function up_select(button,id){
     var select = document.getElementById(id);
     var options = select.options;
     var prev = options.item(0);
     var opt;
     for (var i=0; i<options.length; i++) {
          opt = options.item(i);
          if (opt.selected) {
               select.insertBefore(opt,prev);
          }
          else {
               prev = opt;
          }
     }
}

function down_select(button,id){
     var select = document.getElementById(id);
     var options = select.options;
     var prev = options.item(options.length-1);
     var opt;
     for (var i=options.length-1; i>=0; i--) {
          opt = options.item(i);
          if (opt.selected) {
               select.insertBefore(prev,opt);
          }
          else {
               prev = opt;
          }
     }
}

function toggle_fulllist(e){
     e = win?window.event:e;
     var target = win?e.srcElement:e.target;
     if (target.className != 'clickable')
          return false;
     target = find_parent(target, 'TH');
     var pos = target.cellIndex;
     var td = target.parentNode.nextSibling.cells.item(pos*2);
     var select = td.getElementsByTagName('SELECT').item(0);
     if (select.prev_size != undefined) {
          select.size = select.prev_size;
          select.prev_size = undefined;
     } else {
          select.prev_size = select.size;
          select.size = select.length;
     }
     return false;
}


var current_search = null;
var previous_search_key = null;

function delay_search(value){

     if (current_search) {
          // abort previous delayed search
          clearTimeout(current_search);
     }
     current_search = setTimeout(function () {
                                      search_musume(value);
                                      current_search = null;
                                 },
                                 300);
}

function search_musume(value)
{
     var table = document.getElementById('musume_list');
     if (value == previous_search_key){
          return false;
     }
     previous_search_key = value;
     var showall=value==""?true:false

     var tbody = table.getElementsByTagName('TBODY').item(0);
     var newbody = document.createElement('tbody');
     table.style.display='none';
     var rows = table.rows;
     var matcher = new RegExp(value,'i');
     var row, cell0, cell1;

     for (var i = 1; i < rows.length; i++) {
          row = rows.item(i);
          cell0 = row.cells.item(0);
          cell1 = row.cells.item(1);
          if (showall ||
              (cell0[textContent]+cell1[textContent]).match(matcher)) {
               row.style.display = '';
          }
          else {
               row.style.display = "none";
          }
     }
     table.style.display=''
     current_search = null;
     return false;
}

function focus_focus(){
     var target = document.getElementById('focus');
     if (target)
          target.focus();
     return false;
}

function submitForm(form){
  form.submit();
  submitForm = blockIt;
  return false;
}

function blockIt(){
  return false;
}

