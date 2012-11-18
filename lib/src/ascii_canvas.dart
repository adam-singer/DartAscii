/*
 * jsAscii 0.1
 * Copyright (c) 2008 Jacob Seidelin, jseidelin@nihilogic.dk, http://blog.nihilogic.dk/
 * MIT License [http://www.nihilogic.dk/licenses/mit-license.txt]
 * 
 * Ported to dart by Adam Singer <financeCoding@gmail.com>
 */
part of ascii_canvas;

class AsciiCanvas {
  List<String> aDefaultCharList; // = (" .,:;i1tfLCG08@").split("");
  List<String> aDefaultColorCharList; // = (" CGO08@").split("");
  String strFont = "courier new";
  
  AsciiCanvas() {
    aDefaultCharList = " .,:;i1tfLCG08@".split("");
    aDefaultColorCharList = " CGO08@".split("");
  }
  
  /**
   * convert img element to ascii
   */
  asciifyImage(ImageElement oImg, ImageElement oCanvasImg) {
    var oCanvas = new CanvasElement();
    CanvasRenderingContext2D oCtx = oCanvas.getContext("2d");
    var iScale = oImg.attributes.containsKey("asciiscale") ? int.parse(oImg.attributes["asciiscale"]) : 1;
    var bColor = oImg.attributes.containsKey("asciicolor");
    var bAlpha = oImg.attributes.containsKey("asciialpha");
    var bBlock = oImg.attributes.containsKey("asciiblock");
    var bInvert = oImg.attributes.containsKey("asciiinvert");
    var strResolution = oImg.attributes.containsKey("asciiresolution") ? oImg.attributes["asciiresolution"] : "medium";
    var aCharList = oImg.attributes.containsKey("asciichars") ? 
        oImg.attributes["asciichars"] : (bColor ? aDefaultColorCharList : aDefaultCharList);
    var fResolution = 0.5;
    
    switch (strResolution) {
      case "low": fResolution = 0.25; break;
      case "medium": fResolution = 0.5; break;
      case "high": fResolution = 1; break;
    }
    
    var iWidth = (oImg.offsetWidth * fResolution).round().toInt();
    var iHeight = (oImg.offsetHeight * fResolution).round().toInt();
    
    oCanvas.width = iWidth;
    oCanvas.height = iHeight;
    oCanvas.style.display = "none";
    oCanvas.style.width = "$iWidth";
    oCanvas.style.height = "$iHeight";
    
    oCtx.drawImage(oCanvasImg, 0, 0, iWidth, iHeight);
    var oImgData = oCtx.getImageData(0, 0, iWidth, iHeight).data;
    var strChars = new StringBuffer();
    
    for (var y = 0; y < iHeight; y += 2) {
      for (var x = 0; x < iWidth; x++) {
        var iOffset = (y * iWidth + x) * 4;
        var iRed = oImgData[iOffset];
        var iGreen = oImgData[iOffset + 1];
        var iBlue = oImgData[iOffset + 2];
        var iAlpha = oImgData[iOffset + 3];
        
        int iCharIdx = 0;
        if (iAlpha != 0) {
          var fBrightness = (0.3*iRed + 0.59*iGreen + 0.11*iBlue) / 255;
          iCharIdx = (aCharList.length-1) - (fBrightness * (aCharList.length-1)).round().toInt();
        }
        
        if (bInvert) {
          iCharIdx = (aCharList.length-1) - iCharIdx;
        }
        
        var strThisChar = aCharList[iCharIdx];
        if (strThisChar == " ") {
          strThisChar = "&nbsp;";
        }
        
        if (bColor) {
          strChars.add("<span style='");
          strChars.add("color:rgb($iRed, $iGreen, $iBlue);");
          if (bBlock) {
            strChars.add("background-color:rgb($iRed, $iGreen, $iBlue);");
          }
          
          if (bAlpha) {
            strChars.add("opacity: ${iAlpha/255};");
          }
          
          strChars.add("'>$strThisChar</span>");
        } else {
          strChars.add(strThisChar);
        }  
      }
      strChars.add("<br/>");
    }
    
    var fFontSize = (2/fResolution)*iScale;
    var fLineHeight = (2/fResolution)*iScale;
    
    // adjust letter-spacing for all combinations 
    // of scale and resolution to get it to fit the image width.
    var fLetterSpacing = 0;
    switch (strResolution) {
      case "low": 
        switch (iScale) {
          case 1 : fLetterSpacing = -1; break;
          case 2 : 
          case 3 : fLetterSpacing = -2.1; break;
          case 4 : fLetterSpacing = -3.1; break;
          case 5 : fLetterSpacing = -4.15; break;
        }
        break;
      case "medium":
        switch (iScale) {
          case 1 : fLetterSpacing = 0; break;
          case 2 : fLetterSpacing = -1; break;
          case 3 : fLetterSpacing = -1.04; break;
          case 4 : 
          case 5 : fLetterSpacing = -2.1; break;
        }
        break;
      case "high": 
        switch (iScale) {
          case 1 : 
          case 2 : fLetterSpacing = 0; break;
          case 3 : 
          case 4 : 
          case 5 : fLetterSpacing = -1; break;
        }
        break;
    }
    
    var oAscii = new TableElement();
    oAscii.innerHTML ="<tr><td>$strChars</td></tr>";
    if (!oImg.style.backgroundColor.isEmpty) {
      oAscii.rows[0].cells[0].style.backgroundColor = oImg.style.backgroundColor;
      oAscii.rows[0].cells[0].style.color = oImg.style.color;
    }
    
    oAscii.cellSpacing = "0";
    oAscii.cellPadding = "0";
    
    var oStyle = oAscii.style;
    oStyle.display = "inline";
    oStyle.width = "${(iWidth/fResolution*iScale).round().toInt()}px";
    oStyle.height = "${(iHeight/fResolution*iScale).round().toInt()}px";
    oStyle.whiteSpace = "pre";
    oStyle.margin = "0px";
    oStyle.padding = "0px";
    oStyle.letterSpacing = "${fLetterSpacing}px";
    oStyle.fontFamily = strFont;
    oStyle.fontSize = "${fFontSize}px";
    oStyle.lineHeight = "${fLineHeight}px";
    oStyle.textAlign = "left";
    oStyle.textDecoration = "none";
    
    oImg.replaceWith(oAscii);
  }
  
  /**
   * load the image file
   */
  asciifyImageLoad(ImageElement oImg) {
    var oCanvasImg = new ImageElement();
    oCanvasImg.src = oImg.src;
    oCanvasImg.on.load.add((event) {
      asciifyImage(oImg, oCanvasImg);
    });
  }
}
