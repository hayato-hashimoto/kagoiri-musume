var win = false;
var textContent = 'textContent';
var filter_state = new Object;
var sort_state = '';

Event.observe(window, 'load', create_loading);
Event.observe(window, 'load', init);
Event.observe(window, 'load', focus_focus);

function create_loading() {
     var ele = document.createElement("div");
     Element.hide(ele);
     ele.id = 'loading';
     ele.innerHTML = kahua_loading_msg;
     document.body.appendChild(ele);
};

function init(){
     win = document.all?true:false;
     textContent = win?'innerText':'textContent';
     // for IE
     if (win){
          var navi = $('navigation');
          Element.remove(navi);
          document.body.appendChild(navi);
     }
}

function focus_focus(){
     var target = $('focus');
     if (target)
          target.focus();
     return false;
}


function sort_table(e){
     e = win?window.event:e;

     var target = Event.element(e);
     // var target = win?e.srcElement:e.target;

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

     rows_ = rows_.sortBy(function (v, i) { return v.cells.item(pos).getAttribute('value')});
     rows_ = rev?rows_.reverse():rows_;

     var newbody = document.createElement('tbody');

     var tbody = table.tBodies[0];

     rows_.each(function (v, i) {newbody.appendChild(rows_[i])});

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

function filter_table(select, id, all_text){

     var table = document.getElementById(id);
     var options = select.options;
     var option;

     var option_list = new Array;
     var select_text_list = new Array;

     var label = find_parent(select, 'TABLE').rows.item(0).cells.item(select.parentNode.cellIndex);
     var label_text = label[textContent];
     var thead_cells = table.tHead.rows.item(0).cells;
     var pos = 0;
     for (var i = 0; i<thead_cells.length; i++) {
          if (thead_cells.item(i)[textContent] == label_text) {
               pos = i;
               break;
          }
     }

     /* find selected text */
     for (i=0; i<options.length; i++) {
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
     var count = 0;

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
               count++;
               row.style.display = '';
          }
     }
     table.style.display=''
     /* save filterd_rows for next select */
     select.filterd_rows = filterd_rows;
     label.style.color = all?'':'red';
     $('musume_count').innerHTML = count + '/';
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

     // save searching position to table attribute
     if (table.search_pos == undefined) {
          var thead_cells = table.tHead.rows.item(0).cells;
          var pos = [];
          var name;
          for (var i = 0; i<thead_cells.length; i++) {
               name = thead_cells.item(i).getAttribute('value');
               if (name == 'no' || name == 'title') {
                    pos.push(i);
               }
          }
          table.search_pos = pos;
     }

     previous_search_key = value;
     var showall=value==""?true:false

     table.style.display='none';
     var rows = table.rows;
     var matcher = new RegExp(value,'i');
     var row, cell0, cell1;

     for (i = 1; i < rows.length; i++) {
          row = rows.item(i);
          cell0 = row.cells.item(table.search_pos[0]);
          cell1 = row.cells.item(table.search_pos[1]);
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

function search_onKeyDown(e)
{
     if(true || e.ctrlKey){
          switch (e.keyCode) {
          case 32: /* SPACE */{
                    var table = document.getElementById('musume_list');
                    var rows = table.tBodies[0].rows;
                    var pos = get_row_pos_by_value(table, 'title');
                    for (var i=0; i < rows.length; i++) {
                         if (rows[i].style.display != "none") {
                              rows[i].cells[pos].firstChild.focus();
                              return false;
                         }
                    }
               }
          }
     }
     return true;
}




function submitForm(form){
  form.submit();
  submitForm = blockIt;
  return false;
}

function blockIt(){
  return false;
}

function submitCreateUnit(form){
     var members = $A($('memberlist').getElementsByTagName("LI")).map(function (ele) {return ele.innerHTML});
     var input;
     members.map(
          function(fan){
               var input = document.createElement('input');
               input.name = 'fans';
               input.value = fan;
               input.type = 'text';
               Element.hide(input);
               form.appendChild(input);
          });
     form.submit();
     submitCreateUnit = blockIt;
     return false;
}


function update_status(elem){
     var form = document.getElementById('filtering_form');
     var target = elem[textContent];
     var options = form.status.options;
     for (var i=0; i < options.length; i++) {
          if (options[i][textContent] == target) {
               options[i].selected = true;
               break;
          }
     }
     form.status.onchange();
     return false;
}

function get_row_pos_by_value(table, value) {
     var thead_cells = table.tHead.rows.item(0).cells;
     for (var i = 0; i<thead_cells.length; i++) {
          if (thead_cells.item(i).getAttribute('value') == value) {
               return i;
          }
     }
     return -1;
}

Ajax.Responders.register(
     {onCreate: function(){
               Element.show('loading');
          },
      onComplete: function() {
               Element.hide('loading');
          }
     });



function popup_linkselect(event, unit){
     var event = {pageY:event.pageY,
                  pageX:event.pageX}
     function showResponse(req){
          var win = window.event;
          event = win?window.event:event;
          var s_x=0,s_y=0;
          if (document.all && document.getElementById && (document.compatMode == 'CSS1Compat')){
               s_x = document.documentElement.scrollLeft;
               s_y = document.documentElement.scrollTop;
          }
          else if (document.all){
               s_x = document.body.scrollLeft;
               s_y = document.body.scrollTop;
          }
          var ele = document.createElement("div");
          ele.className = 'memo';
          ele.id = 'memo';
          $('body').appendChild(ele);
          // document.body.
          var y = win?event.clientY:event.pageY;
          y = y + s_y - 20;
          ele.style.top = y + "px";
          var x = win?event.clientX:event.pageX;
          x = x + s_x - 20;
          ele.style.left = x + "px";
          ele.innerHTML = req.responseText;
     }
     var myAjax = new Ajax.Request(
          kahua_self_uri_full + 'select',
          {method: 'get', onComplete: showResponse}
          );
}

function insert_mlink(event){
     var target = Event.element(event);
     if (target.tagName.toLowerCase() == 'a'){
          var textarea = document.forms.mainedit.melody;
          textarea.focus();
          var start = textarea.selectionStart;
          textarea.value = textarea.value.substring(0, start)
               + target.target
               + textarea.value.substring(start);
          close_memo();
          return false;
     }
}

function insert_excerption(target){
  var myAjax = new Ajax.Request(
      target.href ,
      {method: 'get',
       onComplete:function(req){
	   var result = eval(req.responseText);
	   var textarea = document.forms.mainedit.melody;
	   textarea.focus();
	   var start = textarea.selectionStart;
	   textarea.value = textarea.value.substring(0, start)
             + result
	     + textarea.value.substring(start);
	   textarea.selectionEnd = start + result.length;
           new Effect.Highlight('focus');
       }
      })
       // fixme
      new Effect.Highlight(target.parentNode.parentNode.getElementsByTagName('P')[0]);
      return false;
}


function check_click(event, url){
     // var target = event.target;
     var target = Event.element(event);

     if (target.tagName.toLowerCase() == 'a'){
          target = target.parentNode;
          if (target.type == 'circle'){
               target.child.style.display = 'none';
               target.type = '';
               return false;
          }
          else {
               target.type = 'circle';
               if (target.child){
                    target.child.style.display = 'block';
                    return false;
               }
               var myAjax = new Ajax.Request(
                    kahua_self_uri_full + '/'+ url + '?unit-id=' + target.getAttribute('target'),
                    {method: 'get',
                              onComplete:function(req){
                              var ele = document.createElement("div");
                              ele.innerHTML = req.responseText;
                              target.appendChild(ele);
                              target.child = ele;
                         }
                    }
                    );
               return false;
          }
     }
}


function close_memo(){
     Element.remove('memo');
}


// function mk_elem(name) {
//      return function (childs){
//           .length)
//           var this_elem = document.createElement(name);
//           childs = childs.constructor == Array?childs:[childs];
//           childs.map(function(ele){
//                           ele = (typeof ele == 'string')?document.createTextNode(ele):ele;
//                           this_elem.appendChild(ele);
//                      });
//           return this_elem;
//      }

// var div$ = mk_elem('div');
// var dl$ = mk_elem('dl');
// var dt$ = mk_elem('dt');
// var dd$ = mk_elem('dd');

// function show_status(){
//      function handler(req)
//      {
//           function taiou (status) {
//                return div$([dt$(status.code),
//                             dd$(status.color)]);
//           }
//           var result = eval(req.responseText);
//           document.body.appendChild(dl$(result.map(taiou)));
//      }
//      new Ajax.Request('/kagoiri-musume/json-status', {onComplete: handler});
// }

function popup_help(event, keyword){
     var event = {pageY:event.pageY,
                  pageX:event.pageX}
     function showResponse(req){
          var win = window.event;
          event = win?window.event:event;
          var s_x=0,s_y=0;
          if (document.all && document.getElementById && (document.compatMode == 'CSS1Compat')){
               s_x = document.documentElement.scrollLeft;
               s_y = document.documentElement.scrollTop;
          }
          else if (document.all){
               s_x = document.body.scrollLeft;
               s_y = document.body.scrollTop;
          }
          var ele = document.createElement("div");
          ele.className = 'help';
          ele.id = 'help';
          document.body.appendChild(ele);
          var y = win?event.clientY:event.pageY;
          y = y + s_y - 20;
          ele.style.top = y + "px";
          var x = win?event.clientX:event.pageX;
          x = x + s_x - 20;
          ele.style.left = x + "px";
          ele.innerHTML = req.responseText;
     }
     var myAjax = new Ajax.Request(
          kahua_self_uri_full + '/help/' + keyword,
          {method: 'get', onComplete: showResponse}
          );
}

function close_help(){
     var help = document.getElementById('help');
     if (help)
     {
          document.body.removeChild(help, document.body);
     }
}


function filter_member(value){
     var list = $('allmemberlist');
     var nodes = $A(list.childNodes);
     var matcher = new RegExp(value,'i');
     nodes.map(function(ele){ ele.getAttribute('value').match(matcher)?Element.show(ele):Element.hide(ele)});
}


function mail_send_setting(event, unit){
     var speed = 0.4;
     function showResponse(req){
          var ele = document.createElement("div");
          ele.id = 'mail_send_setting';
          ele.style.display = 'none';
          ele.innerHTML = req.responseText;
          Event.element(event).parentNode.parentNode.appendChild(ele);
          Effect.SlideDown("mail_send_setting",{duration:speed})
     }
     var pane = $('mail_send_setting');
     if (pane){
          if (pane.style.display == 'none') {
               Effect.SlideDown("mail_send_setting",{duration:speed});
          } else {
               Effect.SlideUp("mail_send_setting",{duration:speed});
          }
     } else {
          var myAjax = new Ajax.Request(
               kahua_self_uri_full + '/mail-send-setting/' + unit,
               {method: 'get', onComplete: showResponse});
     }
}

function option_select(elem, selects){
     var selecter;
     if (typeof selects == 'boolean'){
          selector = function(o) { o.selected = selects }
     } else {
          selector = function (o) {
               if (selects.indexOf(o[textContent]) >= 0){
                    o.selected = true;
               } else {
                    o.selected = false;
               }}
     }
     var elem = $(elem);
     var options = $A(elem.options);
     new Effect.Highlight(elem, {duration:0.5});
     options.map(selector);
}

function update_height(){
     var main = $("root-box");
     $A(main.childNodes).each(function(elem){
        if (elem.tagName && elem.tagName.toUpperCase()=="DIV"){
             var c = countChild(elem);
             var height = c;
             elem.style.margin = '0 0 ' + height + 'px 0';
        }});
     Element.hide(main);
     Element.show(main);
}

function countChild(elem){
     var count = 0;
     $A(elem.childNodes).each(function(ele){
       if (ele.tagName && ele.tagName.toUpperCase()=="DIV"
           && ele.className == 'box2'){
            count = Element.getHeight(ele);
       }});
     return count;
}

function group_edit_submit(){
     var root = $("root-box");
     var gtree = '';
     gtree += '(';
     gtree += '"*TOP*" ';
     $A(root.childNodes).each(function(elem){
        if (elem.tagName && elem.tagName.toUpperCase()=="DIV"){
             gtree += collect_groups(elem);
        }});
     // temporary
     var main = $("main-box");
     if (main) {
          $A(main.childNodes).each(function(elem){
           if (elem.tagName && elem.tagName.toUpperCase()=="DIV"){
                gtree += collect_groups(elem);
           }});
     }
     gtree += ')';
     $('grouptree').value = gtree;
}

function collect_groups(ele){
     var gtree = '';
     gtree += '(';
     gtree += to_string(name_of(ele));
     var groups =  groups_of(ele);
     for (var i=0; i<groups.length;i++){
          gtree += collect_groups(groups[i]);
     }
     gtree += ')';
     return gtree;
}

function to_string(text){
     return '"' + text + '" ';
}

function name_of(group){
     return group.firstChild.nodeValue;
}


function groups_of(group){
     var children = group.childNodes;
     for (var i = 0; i< children.length; i++){
          if (children[i].className == 'box2'){
               return children[i].childNodes;
          }
     }
}

function add_group(elem){
     var name = elem.newgroup.value;
     elem.newgroup.value = '';
     if (!name){
          return;
     }
     var work = $('work-box');
     var id = Math.random() + '';
     var group = document.createElement('div');
     group.className = 'box';
     var name = document.createTextNode(name);
     group.appendChild(name);
     var dragArea = document.createElement('div');
     dragArea.className = 'box2';
     dragArea.id = id;
     group.appendChild(dragArea);
     work.appendChild(group);
     Sortable.create(id, {dropOnEmpty:true, constraint:false,tag:'div',containment:false,onChange:update_height});
     Sortable.create('work-box', {dropOnEmpty:true, constraint:false,tag:'div',containment:false});
}

function select_group(elem, is_null, pos){
     var key = elem.getAttribute('value');
     var pos = parseInt(pos);
     var nextelm = $('group-box' + pos);
     while (nextelm) {
          Element.remove(nextelm);
          nextelm = $('group-box' + ++pos);
     }
     select(elem);

     if (// is_null == '#t'
          true
          ){
          function update(req){
               var members = eval(req.responseText);
               var mlist = $('allmemberlist');
               var nodes = $A(mlist.childNodes);
               new Effect.Highlight(mlist);
               nodes.map(function(ele){
                              if (members.include(ele.getAttribute('value'))) {
                                   Element.show(ele);
                              } else {
                                   Element.hide(ele);
                              }});

          }
          new Ajax.Request(kahua_self_uri_full + '/getgroupmember/' + key,
                           {method:'get', onComplete: update});
     }
     if (is_null == '#f') {

     function update(req){
          var next = document.createElement('div');
          next.id = 'group-box' + pos;
          // var group_select = $('group-select-box');
          var group_select = $('user-tr');
          next.innerHTML = req.responseText;
          group_select.appendChild(next);

          // new Effect.Highlight(elem)
          // Effect.SlideDown(next);
     }

     new Ajax.Request(kahua_self_uri_full + '/getgroup/' + key + '/' + pos,
                      {method:'get', onComplete: update});
     }
}
