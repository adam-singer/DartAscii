import 'dart:html';
import '../lib/ascii_canvas.dart';
void main() {
  AsciiCanvas ascii = new AsciiCanvas();
  ascii.asciifyImageLoad(query("#dart"));
}

