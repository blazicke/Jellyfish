void noise() {
  loadPixels();
  for (int i=0; i<width; i++) {
    for (int j=0; j<height; j++) {
      int r = floor(random(3));
      colorMode(HSB, 255, 255, 255);
      int p = i + j*width;
      float h = hue(pixels[p]);
      float s = saturation(pixels[p]);
      float b = brightness(pixels[p]);
      color c = color(h, s, b-(5*r));
      pixels[p] = c;
    }
  }
  updatePixels();
}
