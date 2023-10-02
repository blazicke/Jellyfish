class FlowField {
  PVector[][] field;
  int cols, rows, resolution;
  float xoff, yoff;
  String type;
  float data;

  FlowField(int resolution_, String _type, float _data) {
    resolution = resolution_;
    cols = width/resolution;
    rows = height/resolution;
    field = new PVector[cols][rows];
    type = _type;
    data = _data;
    init();
  }

  // initial setup function
  void init() {
    if (type == "noise")
    {
      xoff = 0;
      for (int i = 0; i<cols; i++) {
        yoff = 0;
        for (int j = 0; j<rows; j++) {
          float theta = map(noise(xoff, yoff), 0, 1, 0, TWO_PI);
          field[i][j] = new PVector(cos(theta), sin(theta));
          stroke(255, 0, 0);
          pushMatrix();
          translate(i* resolution, j * resolution);
          rotate(theta);
          line(0, 0, 0, 10);
          popMatrix();

          yoff+= 0.01;
        }
        xoff+= 0.01;
      }
    } else if (type == "angle") {
      for (int i = 0; i<cols; i++) {
        float incJ = 0;
        for (int j = 0; j<rows; j++) {
          float theta = data + sin(incJ)*map(j,0,height,0,1);
          field[i][j] = new PVector(cos(theta), sin(theta));
          incJ+=0.05;
        }
      }
    } else if (type == "fromCenter") {
      for (int i = 0; i<cols; i++) {
        for (int j = 0; j<rows; j++) {
      PVector center = new PVector(width/2,height/2);
      PVector cell = new PVector(i*resolution,j*resolution);
      float theta = PVector.sub(center,cell).heading();
      field[i][j] = new PVector(cos(theta), sin(theta));
        }
      }
    }
  }

  // returns cell vector
  PVector lookup(float x, float y) {
    PVector lookup = new PVector(x, y);
    int column = int(constrain(lookup.x/resolution, 0, cols-1));
    int row = int(constrain(lookup.y/resolution, 0, rows-1));
    return field[column][row].get();
  }
}
