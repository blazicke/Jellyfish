void drawOneString(int maxLength, float segmentLength, PGraphics canvas, String type, color c) {
  ArrayList<PVector> points = new ArrayList<PVector>();

  PVector startPoint = new PVector(random(8, width-8), random(8, height-8));

  while (!pointCheckMask(startPoint.x, startPoint.y, globalHeadMask)) {
    startPoint = new PVector(random(width), random(height));
  }
  points.add(0, startPoint);


  String direction = "down";
  for (int i = 0; i < maxLength; i++) {
    if (direction == "down") {
      PVector point = points.get(i);
      float angle = FF.lookup(point.x, point.y).heading()+HALF_PI;
      PVector segment = PVector.fromAngle(angle).setMag(segmentLength);
      PVector newPoint = PVector.add(point, segment);
      if (pointCheckMask(newPoint.x, newPoint.y, globalHeadMask)) {
        points.add(newPoint);
      } else {
        if (points.size()>2) {
          points.remove(points.size()-1);
          points.remove(points.size()-1);
        }
        direction = "up";
      }
    }
    if (direction == "up") {
      PVector prevPoint = points.get(0);
      float prevAngle = FF.lookup(prevPoint.x, prevPoint.y).heading()-HALF_PI;
      PVector prevSegment = PVector.fromAngle(prevAngle).setMag(segmentLength);
      PVector prevNewPoint = PVector.add(prevPoint, prevSegment);
      if (pointCheckMask(prevNewPoint.x, prevNewPoint.y, globalHeadMask)) {
        points.add(0, prevNewPoint);
      } else {
        if (points.size()>2) {
          points.remove(0);
          points.remove(0);
        }

        break;
      }
    }
  }

  if (type == "dots") {
    for (PVector p : points) {
      drawBlob(makeBlob(p.x, p.y, floor(random(GI.minDotSize, GI.maxDotSize)), 8), canvas, color(c));
    }
  } else if (type == "lines") {
    float l = points.size();
    float tentacleWeight = 10;
    float diff = tentacleWeight/l;
    canvas.beginDraw();
    canvas.stroke(c, 10);
    canvas.noFill();
    canvas.strokeWeight(300);
    canvas.strokeCap(ROUND);
    canvas.beginShape();
    for (int i = 0; i < points.size()-2; i++) {
      PVector p1 = points.get(i);
      PVector p2 = points.get(i+1);
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



boolean pointCheckMask(float x, float y, PGraphics mask) {
  if (x>=0 && x<width && y>=0 && y<height) {
    mask.beginDraw();
    mask.loadPixels();
    int index = floor(x) + floor(y) * mask.width;

    boolean response = brightness(mask.pixels[index]) > 2 ? false : true;

    mask.updatePixels();
    mask.endDraw();
    return response;
  }
  return false;
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

  color cTest = color(0);
  for (int i = 0; i<blob.size(); i++) {
    PVector p = blob.get(i);
    if (p.x>=0 && p.x<width && p.y>=0 && p.y<height) {

      if (i == 0) {
        cTest = canvas.pixels[floor(blob.get(0).x) + floor(blob.get(0).y) * width];
      }
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
