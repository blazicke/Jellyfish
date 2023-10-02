void saveFrame() {
if (keyPressed && key == ('p')) {
    saveFrame("frames/exp_" + year() + "_" + month() + "_" + day() + "_" + hour() +  "" + minute() + "" + second() + ".png");
  }
}
