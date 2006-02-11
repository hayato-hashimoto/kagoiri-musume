//------------------------------------------------------------
// AJAX functions
//
var xmlhttp=false;


/*@cc_on @*/
/*@if (@_jscript_version >= 5)
// JScript gives us Conditional compilation, we can cope with old IE versions.
// and security blocked creation of the objects.
 try {
  xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
 } catch (e) {
  try {
   xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
  } catch (E) {
   xmlhttp = false;
  }
 }
@else
 xmlhttp=false
@end @*/
if (!xmlhttp && typeof XMLHttpRequest!='undefined') {
    try {
         xmlhttp = new XMLHttpRequest();
         xmlhttp.overrideMimeType("text/xml");
    } catch (e) {
         xmlhttp=false;
    }
    /* debug.print (xmlhttp); */
}

var ele = document.createElement("div");
ele.style.position = 'absolute';
ele.style.border = "1px solid black";
ele.style.backgroundColor = "rgb(170, 221, 187)";
ele.appendChild(document.createTextNode("Processing¡Ä"));

function async_get(e,id,pagename)
{
     if (!document.getElementById) return true;

     ele.style.top = e.pageY - 10;
     ele.style.left = e.pageX - 10;
     document.body.appendChild(ele);
     var element = document.getElementById(id);

     xmlhttp.open("GET", pagename , true);

     xmlhttp.onreadystatechange = function()
          {
               if (xmlhttp.readyState == 4 && xmlhttp.status == 200)
               {
                    element.innerHTML = xmlhttp.responseText;
                    document.body.removeChild(ele, document.body)
               }
          }
     xmlhttp.send(null);
     return false;
}

function async_post(e,id)
{
     if (!document.getElementById) return true;
     var form = e.target;
     var eles = form.elements;
     var post = "";
     var elem;
     for (var i=0;i< eles.length; i++)
     {
          elem = eles[i];
          if ((elem.type == 'checkbox' || elem.type == 'radio')
              && !elem.checked)
          {
               continue;
          }
          post += "&" + elem.name + "=" + encodeURIComponent(elem.value);
     }

     ele.style.top = e.pageY - 10;
     ele.style.left = e.pageX - 10;
     document.body.appendChild(ele);
     var element = document.getElementById(id);

     xmlhttp.open("POST", form.action , true);

     xmlhttp.onreadystatechange = function()
          {
               if (xmlhttp.readyState == 4 && xmlhttp.status == 200)
               {
                    element.innerHTML = xmlhttp.responseText;
                    document.body.removeChild(ele, document.body)
               }
          }
     xmlhttp.send(post);
     return false;
}

function highlight(id)
{
     var element = document.getElementById(id);
/*      element.style.backgroundColor = "#dedede"; */
     element.style.backgroundColor = "#f0f0f0";
}

function unhighlight(id)
{
     var element = document.getElementById(id);
     element.style.backgroundColor = null;
}


function select_worker(e)
{
     async_get(e, 'eval', pagename)
}


function toggle_show(id)
{
     var ele = document.getElementById(id);
     current = ele.style.display;
     ele.style.display = (current=='block')?'none':'block';
}

function select(ele)
{
     var nodes = ele.parentNode.childNodes;
     for (i=0;i < nodes.length; i++)
     {
          nodes[i].style.backgroundColor = null;
     }
     ele.style.backgroundColor = "rgb(194, 243, 182)";
}
