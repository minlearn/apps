
function getTextFromNode(nodeidx, addSpaces) {
    var i, result, text, child;
    result = '';

    node = document.querySelectorAll("#qssrc")[(nodeidx -= 1)];

   // for (i = 0; i < node.childNodes.length; i++) {
   //     child = node.childNodes[i];
   //     text = null;
   //     if (child.nodeType === 1) {
   //         text = getTextFromNode(child, addSpaces);
   //     } else if (child.nodeType === 3) {
   //         text = child.nodeValue;
   //     }
   //     if (text) {
   //         if (addSpaces && /\S$/.test(result) && /^\S/.test(text)) text = ' ' + text;
   //         result += text;
   //     }
   // }
   result = node.childNodes[0].textContent.substring(0, 50);
   console.log(result);

   return result;
}


function insertAtCaret(areaId,text) {
  var txtarea = document.getElementById(areaId);
  var scrollPos = txtarea.scrollTop;
  var strPos = 0;
  var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? 
    "ff" : (document.selection ? "ie" : false ) );
  if (br == "ie") { 
    txtarea.focus();
    var range = document.selection.createRange();
    range.moveStart ('character', -txtarea.value.length);
    strPos = range.text.length;
  }
  else if (br == "ff") strPos = txtarea.selectionStart;
	
  var front = (txtarea.value).substring(0,strPos);  
  var back = (txtarea.value).substring(strPos,txtarea.value.length); 

  if ( txtarea.value != "" ) text="\n\n> "+text; else text="> "+text;

  txtarea.value=front+text+back;


  strPos = strPos + text.length;
  if (br == "ie") { 
    txtarea.focus();
    var range = document.selection.createRange();
    range.moveStart ('character', -txtarea.value.length);
    range.moveStart ('character', strPos);
    range.moveEnd ('character', 0);
    range.select();
  }
  else if (br == "ff") {
    txtarea.selectionStart = strPos;
    txtarea.selectionEnd = strPos;
    txtarea.focus();
  }
  txtarea.scrollTop = scrollPos;
}


