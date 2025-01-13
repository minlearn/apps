

function loadjscssfile(filename, filetype){
 if (filetype=="js"){ //if filename is a external JavaScript file
  var fileref=document.createElement('script')
  fileref.setAttribute("type","text/javascript");
  fileref.setAttribute("src", filename);
 }
 else if (filetype=="css"){ //if filename is an external CSS file
  var fileref=document.createElement("link")
  fileref.setAttribute("rel", "stylesheet");
  fileref.setAttribute("type", "text/css");
  fileref.setAttribute("href", filename);
 }
 if (typeof fileref!="undefined")
  document.getElementsByTagName("head")[0].appendChild(fileref)
}

var filesadded="" //list of files already added

function checkloadjscssfile(filename, filetype){
 if (filesadded.indexOf("["+filename+"]")==-1){
  loadjscssfile(filename, filetype)
  filesadded+="["+filename+"]" //add to list of files already added, in the form of "[filename1],[filename2],etc"
 }
 else
  alert("file already added!")
}

function removejscssfile(filename, filetype){
 var removedelements=0
 var targetelement=(filetype=="js")? "script" : (filetype=="css")? "link" : "none" //determine element type to create nodelist using
 var targetattr=(filetype=="js")? "src" : (filetype=="css")? "href" : "none" //determine corresponding attribute to test for
 var allsuspects=document.getElementsByTagName(targetelement)
 for (var i=allsuspects.length; i>=0; i--){ //search backwards within nodelist for matching elements to remove
  if (allsuspects[i] && allsuspects[i].getAttribute(targetattr)!=null && allsuspects[i].getAttribute(targetattr).indexOf(filename)!=-1){
   allsuspects[i].parentNode.removeChild(allsuspects[i]) //remove element by calling parentNode.removeChild()
   removedelements+=1
  }
 }
 //if (removedelements>0)
  //alert("Removed "+removedelements+" instances of "+filename)
}

function createjscssfile(filename, filetype){
 if (filetype=="js"){ //if filename is a external JavaScript file
  var fileref=document.createElement('script')
  fileref.setAttribute("type","text/javascript")
  fileref.setAttribute("src", filename)
 }
 else if (filetype=="css"){ //if filename is an external CSS file
  fileref=document.createElement("link")
  fileref.setAttribute("rel", "stylesheet")
  fileref.setAttribute("type", "text/css")
  fileref.setAttribute("href", filename)
 }
 return fileref
}

function replacejscssfile(oldfilename, newfilename, filetype){
 var replacedelements=0
 var targetelement=(filetype=="js")? "script" : (filetype=="css")? "link" : "none" //determine element type to create nodelist using
 var targetattr=(filetype=="js")? "src" : (filetype=="css")? "href" : "none" //determine corresponding attribute to test for
 var allsuspects=document.getElementsByTagName(targetelement)
 for (var i=allsuspects.length; i>=0; i--){ //search backwards within nodelist for matching elements to remove
  if (allsuspects[i] && allsuspects[i].getAttribute(targetattr)!=null && allsuspects[i].getAttribute(targetattr).indexOf(oldfilename)!=-1){
   var newelement=createjscssfile(newfilename, filetype)
   allsuspects[i].parentNode.replaceChild(newelement, allsuspects[i])
   replacedelements+=1
  }
 }
 //if (replacedelements>0)
  //alert("Replaced "+replacedelements+" instances of "+oldfilename+" with "+newfilename)
}


// function to set a given theme/color-scheme
function setThemestore(themeName) {
    localStorage.setItem('theme', themeName);
    //document.documentElement.className = themeName;
}
// function to toggle between light and dark theme
function toggleTheme() {



  let curtheme = getComputedStyle(document.documentElement).getPropertyValue("--neutral-shade-0").trim(); // || "";
  if ( curtheme === "black" ) {
			console.log("need light theme");
			removejscssfile("/css/dark.css", "css");
                        setThemestore('theme-light');
  } else {
			console.log("need dark theme");
			loadjscssfile("/css/dark.css", "css");
                        setThemestore('theme-dark');
  }


}


// inital
(function () {
  if (localStorage.getItem('theme') === 'theme-dark') {
			loadjscssfile("/css/dark.css", "css");
                        //setThemestore('theme-dark');
  } else {
			removejscssfile("/css/dark.css", "css");
                        setThemestore('theme-light');
  }
})()




