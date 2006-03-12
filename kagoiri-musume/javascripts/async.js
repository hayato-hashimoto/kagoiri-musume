//------------------------------------------------------------
// AJAX functions
//
function async_get(e,id,pagename)
{
     new Ajax.Updater(id, pagename, {method: 'get'});
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
     var element = $(id);
/*      element.style.backgroundColor = "#dedede"; */
     element.style.backgroundColor = "#7b96ac";
}

function unhighlight(id)
{
     var element = $(id);
     element.style.backgroundColor = null;
}


function select_worker(e)
{
     async_get(e, 'eval', pagename)
}


function toggle_show(id)
{
     var ele = $(id);
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
