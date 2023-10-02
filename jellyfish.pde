PGraphics globalHeadMask, buffer, bgBuffer;
ArrayList<JF> jellyfish;
FlowField FF;
GlobalInfo GI;
int trackingJellyfish, trackingBG;



void setup() {

  // globa setup
  size(1000, 1000);
  colorMode(HSB, 360, 100, 100, 100);
  background(0, 0, 0);
  fill(0, 0, 100);
  noStroke();

  // global info
  GI = new GlobalInfo();
  trackingJellyfish = 0;

  // FlowField
  FF = new FlowField(2, "noise", HALF_PI*0.5);

  // buffers
  globalHeadMask = createGraphics(width, height);
  buffer = createGraphics(width, height);
  bgBuffer = createGraphics(width, height);

  globalHeadMask.beginDraw();
  globalHeadMask.colorMode(HSB, 360, 100, 100, 100);
  globalHeadMask.background(0, 0, 0);
  globalHeadMask.noStroke();
  globalHeadMask.fill(0, 0, 100);
  globalHeadMask.endDraw();

  buffer.beginDraw();
  buffer.colorMode(HSB, 360, 100, 100, 100);
  buffer.noStroke();
  buffer.fill(0, 0, 100);
  buffer.endDraw();

  bgBuffer.beginDraw();
  bgBuffer.colorMode(HSB, 360, 100, 100, 100);
  bgBuffer.background(239, 50, 40);
  bgBuffer.noStroke();
  bgBuffer.fill(0, 0, 100);
  bgBuffer.endDraw();




  //  *****************************************
  //  init
  //  *****************************************


  jellyfish = new ArrayList<JF>();
  int JFnum = floor(random(GI.minJFNum, GI.maxJFNum));
  for (int i = 0; i< JFnum; i++) {

    // coordinates
    float x = random(GI.padding, width-GI.padding);
    float y = map(i, 0, JFnum, height-GI.padding, GI.padding);


    // head size
    float distFromCenter = dist(x, y, width/2, height/2);
    float headWidth = map(distFromCenter, 0, width*.5, GI.maxHeadSize, GI.minHeadSize);
    headWidth = constrain(headWidth, GI.minHeadSize, GI.maxHeadSize);
    float headHeight = headWidth;


    // Jellyfish angle
    float theta = FF.lookup(x, y).heading();


    // Jellyfish tentacles
    int tentaclesN = floor(headWidth / 3);
    int[] singleTentacleLength = new int[tentaclesN];


    // setting lengths for each tentacle
    for (int j = 0; j<tentaclesN; j++) {
      int tentacleLength = floor(random(GI.minTentacleLength, GI.maxTentacleLength));
      singleTentacleLength[j] = tentacleLength;
    }


    // creating the Jellyfish object
    JF oneJellyfish = new JF(x, y, headWidth, headHeight, theta, GI.getRandomColor(GI.sunPalette()), singleTentacleLength);


    // checking the coordinates of the JF in the mask canvas
    if (oneJellyfish.pointCheckMask(x, y, globalHeadMask)) {
      oneJellyfish.createHeadShape(1);

      // checking the coordinates of the JF head shape in the mask canvas
      if (oneJellyfish.checkHeadMask(globalHeadMask)) {
        oneJellyfish.drawHeadShape(oneJellyfish.shape, globalHeadMask, color(360, 0, 100), true);
        oneJellyfish.getTentaclesStartingPoint();
        jellyfish.add(oneJellyfish);
      }
    }
  }


  // actually drawing in the buffer
  for (JF oneJellyfish : jellyfish) {
    oneJellyfish.drawHeadShape(oneJellyfish.shape, buffer, oneJellyfish.c, false);
    oneJellyfish.drawHead2(buffer);
    for (int j = 0; j<oneJellyfish.tentaclesN; j++) {
      oneJellyfish.drawOneTentacle(j, oneJellyfish.singleTentacleLengths[j], 5, buffer, "dots");
    }
    trackingJellyfish++;
    println(trackingJellyfish + " of " + JFnum);
  }

  println("Jellyfish drawn");
  trackingBG = 0;

  // backgrund
  for (int j = 0; j<GI.bgLines; j++) {
    trackingBG++;
    drawOneString(1200, 5, bgBuffer, "dots", color (GI.getRandomColor(GI.paletteSea)));
    println(trackingBG + " of " + GI.bgLines);
  }

  bgBuffer.beginDraw();
  bgBuffer.filter(BLUR, 1);
  bgBuffer.endDraw();


  // adding jellyfish and background to the main canvas
  image(bgBuffer, 0, 0);
  image(buffer, 0, 0);

  // adding some noise
  noise();
}


void draw() {
  // saves if p is pressed
  saveFrame();
}
