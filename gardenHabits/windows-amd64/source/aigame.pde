import processing.sound.*;
SoundFile file;
int growth = 0;
int maxGrowth = 100;
Button[] buttons;
PFont font;
HashMap<String, String> lastLog = new HashMap<String, String>();
PImage[] stages;
ArrayList<PVector> flowers = new ArrayList<PVector>();

void setup() {
  fullScreen();
  file = new SoundFile(this, "animalcrossing.mp3");
  file.loop();
  font = createFont("Nunito", 32);
  textFont(font);
  loadLastLog();

  stages = new PImage[5];
  for (int i = 0; i < stages.length; i++) {
    stages[i] = createStageGraphic(i);
  }

  buttons = new Button[] {
    new Button("💧 drink water", 50, height - 360, color(173, 216, 230), "water", false),
    new Button("🏃 move body", 50, height - 270, color(144, 238, 144), "exercise", false),
    new Button("🌞 get sunlight", 50, height - 180, color(255, 250, 160), "sunlight", false),
    new Button("🚶 take a walk", 50, height - 90,  color(255, 204, 229), "walk", false)
  };
}

void draw() {
  background(#F4F1DE);
  drawPlantStage();

  for (PVector f : flowers) {
    drawFullFlower(f.x, f.y);
  }

  for (Button b : buttons) b.display();

  fill(80);
  textAlign(LEFT);
  textSize(36);
  text("growth: " + growth + (growth >= maxGrowth ? " (max)" : ""), 50, 60);
}

void mousePressed() {
  if (growth >= maxGrowth) return;

  String today = getToday();
  for (Button b : buttons) {
    if (b.isPressed(mouseX, mouseY)) {
      if (b.oncePerDay) {
        String last = lastLog.get(b.habit);
        if (last == null || !last.equals(today)) {
          addGrowth();
          lastLog.put(b.habit, today);
          saveLastLog();
        }
      } else {
        addGrowth();
      }
    }
  }
}

void addGrowth() {
  if (growth < maxGrowth) {
    growth++;
    if (growth % 5 == 0) {
      float x = random(width * 0.2, width * 0.8);
      float y = random(height * 0.5, height * 0.9);
      flowers.add(new PVector(x, y));
    }
  }
}

void drawPlantStage() {
  int stage = min(growth / 3, stages.length - 1);
  imageMode(CENTER);
  image(stages[stage], width / 2, height / 2);
}

void drawFullFlower(float x, float y) {
  pushMatrix();
  translate(x, y);
  stroke(88, 129, 87);
  strokeWeight(4);
  line(0, 0, 0, 80); // stem

  fill(163, 201, 168);
  noStroke();
  ellipse(-10, 40, 20, 10); // left leaf
  ellipse(10, 55, 20, 10);  // right leaf

  translate(0, 0); // flower on top
  noStroke();
  fill(255, 182, 193);
  for (int a = 0; a < 360; a += 60) {
    float px = cos(radians(a)) * 20;
    float py = sin(radians(a)) * 20;
    ellipse(px, py, 24, 14);
  }
  fill(255, 105, 180);
  ellipse(0, 0, 30, 30);
  popMatrix();
}

PImage createStageGraphic(int stage) {
  PGraphics g = createGraphics(200, 300);
  g.beginDraw();
  g.background(255, 0);
  g.stroke(88, 129, 87);
  g.strokeWeight(6);

  switch(stage) {
    case 0:
      g.fill(139, 94, 60);
      g.ellipse(100, 280, 20, 20);
      break;
    case 1:
      g.fill(163, 201, 168);
      g.line(100, 280, 100, 220);
      g.ellipse(90, 230, 20, 10);
      g.ellipse(110, 230, 20, 10);
      break;
    case 2:
      g.fill(163, 201, 168);
      g.line(100, 280, 100, 180);
      g.ellipse(90, 200, 20, 10);
      g.ellipse(110, 200, 20, 10);
      break;
    case 3:
      g.fill(163, 201, 168);
      g.line(100, 280, 100, 140);
      g.ellipse(90, 200, 20, 10);
      g.ellipse(110, 200, 20, 10);
      g.ellipse(90, 160, 20, 10);
      g.ellipse(110, 160, 20, 10);
      break;
    case 4:
      g.fill(163, 201, 168);
      g.line(100, 280, 100, 100);
      g.ellipse(90, 160, 20, 10);
      g.ellipse(110, 160, 20, 10);
      g.fill(255, 182, 193);
      for (int a = 0; a < 360; a += 60) {
        float px = 100 + cos(radians(a)) * 20;
        float py = 90 + sin(radians(a)) * 20;
        g.ellipse(px, py, 24, 14);
      }
      g.fill(255, 105, 180);
      g.ellipse(100, 90, 30, 30);
      break;
  }

  g.endDraw();
  return g;
}

class Button {
  String label;
  float x, y, w = 320, h = 70;
  color bg;
  String habit;
  boolean oncePerDay;

  Button(String label, float x, float y, color bg, String habit, boolean oncePerDay) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.bg = bg;
    this.habit = habit;
    this.oncePerDay = oncePerDay;
  }

  void display() {
    fill(0, 20);
    rect(x + 4, y + 4, w, h, 20);
    fill(bg);
    rect(x, y, w, h, 20);
    fill(50);
    textAlign(CENTER, CENTER);
    textSize(28);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isPressed(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}

String getToday() {
  return nf(year(), 4) + "-" + nf(month(), 2) + "-" + nf(day(), 2);
}

void loadLastLog() {
  String[] lines = loadStrings("log.txt");
  if (lines == null) return;
  for (String line : lines) {
    String[] parts = split(line, ':');
    if (parts.length == 2) {
      lastLog.put(parts[0], parts[1]);
    }
  }
}

void saveLastLog() {
  String[] out = new String[lastLog.size()];
  int i = 0;
  for (String key : lastLog.keySet()) {
    out[i++] = key + ":" + lastLog.get(key);
  }
  saveStrings("log.txt", out);
}
