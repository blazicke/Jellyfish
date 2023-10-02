class JF extends PVector {

  float x, y, w, h, theta;
  int tentaclesN;
  int[] singleTentacleLengths;
  ArrayList<PVector> shape;
  ArrayList< ArrayList<PVector>> tentacles;
  PVector location;
  color c;

  JF(float _x, float _y, float _w, float _h, float _theta, color _c, int[] _singleTentacleLengths) {
    super(_x, _y);
    w = _w;
    h = _h;
    x = _x;
    y = _y;
    theta = _theta;
    location = new PVector(x, y);
    c = _c;
    singleTentacleLengths = _singleTentacleLengths;
    tentaclesN = singleTentacleLengths.length;
    tentacles = new ArrayList< ArrayList<PVector>>();
  }

  // checks coordinates in mask
  boolean pointCheckMask(float x, float y, PGraphics mask) {
    if (x>=0 && x<width && y>=0 && y<height) {
      mask.beginDraw();
      mask.loadPixels();
      int index = floor(x) + floor(y) * mask.width;

      boolean response = brightness(mask.pixels[index]) > 5 ? false : true;

      mask.updatePixels();
      mask.endDraw();
      return response;
    }
    return false;
  }

  // creates head shape
  ArrayList<PVector> createHeadShape(float scale) {
    shape = new ArrayList<PVector>();
    float step = PI/20;
    float localX = 0;
    float localY = 0;
    float bottomBorderHelper = 0;
    for (float i = PI; i<PI*3+0.001; i+= step) {
      if (i<TWO_PI) {
        float noise = map(noise(abs(PI-i)), 0, 1, 1, 1.2)* scale;
        localX = cos(i)*w * noise;
        localY = sin(i)*h * noise;
      } else {
        localX = cos(i)*w;
        localY = sin(bottomBorderHelper)*4;
        bottomBorderHelper+=0.5;
      }
      PVector p = new PVector(localX, localY).rotate(theta);
      p.x+=x;
      p.y+=y;
      shape.add(p);
    }

    return shape;
  }

  // checks head shape in mask
  boolean checkHeadMask(PGraphics mask) {
    for (PVector v : shape) {
      if (!pointCheckMask(v.x, v.y, mask)) {
        return false;
      }
    }
    return true;
  }

  // draws head shape in mask
  void drawHeadShape(ArrayList<PVector> shape, PGraphics mask, color c, boolean withBorder) {
    mask.beginDraw();
    mask.fill(c);
    if (withBorder) {
      mask.stroke(c);
      mask.strokeWeight(2);
    }
    mask.beginShape();
    for (int i = 0;i<shape.size();i++) {
      PVector v = shape.get(i);
      mask.curveVertex(v.x, v.y);
     
      if(i ==shape.size()-1) {
        mask.curveVertex(v.x, v.y);
      }
     }
    mask.endShape(CLOSE);
    if (withBorder) {
      mask.noStroke();
    }
    mask.endDraw();
  }

  // draws head
  void drawHead(PGraphics canvas) {

    float minx = width;
    float maxx = 0;
    float miny = height;
    float maxy = 0;

    for (PVector p : shape) {
      minx = p.x <= minx ? p.x : minx;
      maxx = p.x >= maxx ? p.x : maxx;
      miny = p.y <= miny ? p.y : miny;
      maxy = p.y >= maxy ? p.y : maxy;
    }

    PGraphics headBuffer = createGraphics(width, height);
    headBuffer.beginDraw();
    headBuffer.colorMode(HSB, 360, 100, 100, 100);
    headBuffer.background(0, 0, 0);
    headBuffer.fill(0, 0, 100);
    headBuffer.endDraw();
    drawHeadShape(shape, headBuffer, c, false);

    float w = maxx-minx;
    float h = maxy-miny;

    int area = int(w*h* 0.03);

    for (int i = 0; i< area; i++) {
      float x = random(minx, maxx);
      float y = random(miny, maxy);

      float blobColorA = map(y, miny, maxy, 60, 10);
      color blobColor = color(0, 0, 100, blobColorA);


      if (!pointCheckMask(x, y, headBuffer)) {
        drawBlob(makeBlob(x, y, floor(random(2, 3)), 8), canvas, blobColor);
      }
    }
  }




  // draws head 2
  void drawHead2(PGraphics canvas) {

    PGraphics fill = createGraphics(canvas.width, canvas.height);
    PGraphics fillMask = createGraphics(canvas.width, canvas.height);
    drawHeadShape(shape, fillMask, c, false);
    fill.beginDraw();
    fill.colorMode(HSB, 360, 100, 100, 100);
    fill.noStroke();
    fill.endDraw();
    for (float i = 1; i>0; i-=0.2) {
      drawHeadShape(createHeadShape(i), fill, GI.getRandomColor2(GI.sunPalette(),c), false);
      if (i==1 || i==0.8) {
        ArrayList<PVector> shape = createHeadShape(i+0.1);
        for (PVector p : shape) {
          drawBlob(makeBlob(p.x, p.y, floor(random(4, 6)), 8), fill, color(360, 0, 100));
        }
      }
    }
    fill.mask(fillMask);
    canvas.beginDraw();
    canvas.image(fill, 0, 0);
    canvas.endDraw();
  }








  // finds starting points for tentacles
  void getTentaclesStartingPoint() {
    float distBetweenTentacles = w/tentaclesN * 0.75;
    PVector distVector = PVector.fromAngle(theta);
    distVector.setMag(distBetweenTentacles);

    for (int i = 0; i < tentaclesN; i++) {
      int mult = i%2 == 0 ? 1 : -1;
      PVector tentacleStartingPoint = new PVector(location.x + (distVector.x*mult * i), location.y + (distVector.y*mult * i));
      float angle = FF.lookup(tentacleStartingPoint.x, tentacleStartingPoint.y).heading()+HALF_PI;
      PVector segment = PVector.fromAngle(angle).setMag(6);
      tentacleStartingPoint.add(segment);
      tentacles.add(new ArrayList<PVector>());
      tentacles.get(i).add(tentacleStartingPoint);
    }
  }


  // draw the mask for one tentacle

  void drawOneTentacleMask(int tentacleIndex, int segmentN, float segmentLength, PGraphics canvas) {
    ArrayList<PVector> tentacle = tentacles.get(tentacleIndex);
    for (int i = 0; i< segmentN; i++) {
      PVector point = tentacle.get(i);
      float angle = FF.lookup(point.x, point.y).heading()+HALF_PI;
      PVector segment = PVector.fromAngle(angle).setMag(segmentLength);
      PVector newPoint = PVector.add(point, segment);
      if (pointCheckMask(newPoint.x, newPoint.y, globalHeadMask)) {
        tentacle.add(newPoint);
      } else {
        if (tentacle.size()>2) {
          tentacle.remove(tentacle.size()-1);
          tentacle.remove(tentacle.size()-1);
        }
        break;
      }
    }

    float tentacleWeight = 8;
    canvas.beginDraw();
    canvas.stroke(0, 0, 100);
    canvas.noFill();
    canvas.strokeWeight(tentacleWeight);
    canvas.strokeCap(ROUND);
    canvas.beginShape();
    for (int i = 0; i < tentacle.size()-2; i++) {
      PVector p1 = tentacle.get(i);
      PVector p2 = tentacle.get(i+1);
      canvas.line(p1.x, p1.y, p2.x, p2.y);
    }
    canvas.endShape();
    canvas.noStroke();
    canvas.fill(c);
    canvas.endDraw();
  }


  // draws a tentacle
  void drawOneTentacle(int tentacleIndex, int segmentN, float segmentLength, PGraphics canvas, String type) {
    ArrayList<PVector> tentacle = tentacles.get(tentacleIndex);
    for (int i = 0; i< segmentN; i++) {
      PVector point = tentacle.get(i);
      float angle = FF.lookup(point.x, point.y).heading()+HALF_PI;
      PVector segment = PVector.fromAngle(angle).setMag(segmentLength);
      PVector newPoint = PVector.add(point, segment);
      if (pointCheckMask(newPoint.x, newPoint.y, globalHeadMask)) {
        tentacle.add(newPoint);
      } else {
        if (tentacle.size()>2) {
          tentacle.remove(tentacle.size()-1);
          tentacle.remove(tentacle.size()-1);
        }
        break;
      }
    }
    if (type == "dots") {
      for (int i = 0; i< tentacle.size(); i++) {
        drawBlob(makeBlob(tentacle.get(i).x, tentacle.get(i).y, floor(random(GI.minDotSize, GI.maxDotSize)), 8), canvas, color(c, 80));
      }
    } else if (type == "lines") {

      float l = tentacle.size();
      float tentacleWeight = 2;
      float diff = tentacleWeight/l;
      canvas.beginDraw();
      canvas.stroke(c);
      canvas.noFill();
      canvas.strokeWeight(tentacleWeight);
      canvas.strokeCap(ROUND);
      canvas.beginShape();
      for (int i = 0; i < tentacle.size()-2; i++) {
        PVector p1 = tentacle.get(i);
        PVector p2 = tentacle.get(i+1);
        canvas.line(p1.x, p1.y, p2.x, p2.y);
        tentacleWeight = tentacleWeight - diff;
        canvas.strokeWeight(tentacleWeight);
      }
      canvas.endShape();
      canvas.noStroke();
      canvas.fill(c);
      canvas.endDraw();
    }
  }


  // returns a blob shape
  ArrayList<PVector> makeBlob(float centerX, float centerY, float size, int numOfVertices) {
    ArrayList<PVector> vertices = new ArrayList<PVector>();
    float n1 = random(1);
    for (float j = 0; j < numOfVertices+4; j++) {
      float n2 = j < (numOfVertices+4)/2 ? map(j, 0, numOfVertices+4, 0.8, 1) : map(j, 0, numOfVertices+4, 1, 0.8);
      float cx = sin(j * TWO_PI/numOfVertices) * (size * n2 * map(noise(n1), 0, 1, 0.6, 1));
      float cy = cos(j * TWO_PI/numOfVertices) * (size * n2 * map(noise(n1), 0, 1, 0.6, 1));
      if (j< (numOfVertices+4)/2) {
        n1+= 0.2;
      } else {
        n1-= 0.2;
      }
      vertices.add(new PVector(cx + centerX, cy + centerY));
    }
    return vertices;
  }

  //draws a blob shape
  void drawBlob(ArrayList<PVector> blob, PGraphics canvas, color blobColor) {

    canvas.beginDraw();
    canvas.beginShape();
    canvas.fill(blobColor);


    for (PVector p : blob) {
      if (p.x>=0 && p.x<width && p.y>=0 && p.y<height) {
        color cTest = canvas.pixels[floor(blob.get(0).x) + floor(blob.get(0).y) * width];
        if (canvas.pixels[floor(p.x) + floor(p.y) * width] != cTest) {
          return;
        }
      }
    }

    for (PVector p : blob) {
      canvas.curveVertex(p.x, p.y);
    }
    canvas.endShape();
    canvas.endDraw();
  }
}
