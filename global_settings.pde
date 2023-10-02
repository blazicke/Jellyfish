class GlobalInfo { //<>//

  int minJFNum, maxJFNum, minDotSize, maxDotSize, minHeadSize, maxHeadSize, minTentacleLength, maxTentacleLength, bgLines;
  float padding;
  color[] paletteJellyfish, paletteSea;

  GlobalInfo() {
    padding = 50;
    minJFNum = 20;
    maxJFNum = 40;
    minDotSize = 2;
    maxDotSize = 2;
    minHeadSize = 20;
    maxHeadSize = 80;
    minTentacleLength = 600;
    maxTentacleLength = 1000;
    bgLines = 5000;
    paletteJellyfish = createPalette(color(35, 57, 95), color(55, 47, 95), 8);
    paletteSea = createSeaPalette();
  }

  color[] createSeaPalette() {
    color[] palette = new color[6];
    palette[0] = color(239, 97, 57);
    palette[1] = color(214, 99, 70);
    palette[2] = color(201, 100, 81);
    palette[3] = color(195, 100, 88);
    palette[4] = color(190, 100, 95);
    palette[5] = color(190, 68, 99);
    return palette;
  }
  
  color[] vanGoghSunflowersPalette() {
    color[] palette = new color[6];
    palette[0] = color(50,76,93);
    palette[1] = color(47,23,96);
    palette[2] = color(44,77,89);
    palette[3] = color(53,55,98);
    palette[4] = color(55, 69, 98);
    palette[5] = color(39, 83, 89);
    return palette;
  }
  
  color[] sunPalette() {
    color[] palette = new color[5];
    palette[0] = color(48,57,93);
    palette[1] = color(37,57,97);
    palette[2] = color(21,52,88);
    palette[3] = color(4,57,97);
    palette[4] = color(218,61,96);
    return palette;
  }

  color[] createPalette(color a, color b, int n) {
    color[] palette  = new color[n];
    for (int i = 0; i<n; i++) {
      float amnt = map(i, 0, n, 0, 1);
      //float amnt = i/n;
      palette[i] = lerpColor(a, b, amnt);
    }
    return palette;
  }

  color[] createPalette2(int n) {
    color[] palette = new color[n];
    float gr = 0.618033988749895;
    for (int i = 0; i<n; i++) {
      float hue = random(1)<0.5 ? map(gr*(i+1)%1,0,1,60,90) : map(gr*(i+1)%1,0,1,300,330);
      color c = color (hue, 50, 80);
      palette[i] = c;
    }
    return palette;
  }

  color getRandomColor(color[] palette) {
    return palette[floor(random(palette.length-1))];
  }
  
  color getRandomColor2(color[] palette, color avoid) {
    int r = floor(random(palette.length-1));
    int index = palette[r] == avoid ? (r+1) % palette.length : r;
    return palette[index];
  }
}
