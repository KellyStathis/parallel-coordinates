// Data
Table table;
String path = "lab2.csv";
int[][] tableData;
int numRows, numCols;
String[] rowNames, colNames;
int[] colMins, colMaxes;

// Window dimensions
int leftOffset = 40;
int rightOffset = 40;
int topOffset = 50;
int bottomOffset = 60;
int distanceBetweenAxes;

// PGraphics (layers)
PGraphics axes;

// Highlighted lines
int[] highlightedRows;

// Axis orientations
boolean[] positiveAxis;

void setup() {
  // Open the data file
  table = loadTable(path);
  numRows = table.getRowCount() - 1;
  numCols = table.getColumnCount() - 1;
  tableData = new int[numRows][numCols];
  rowNames = new String[numRows];
  colNames = new String[numCols];
  colMins = new int[numCols];
  colMaxes = new int[numCols];
  highlightedRows = new int[numRows];
  positiveAxis = new boolean[numCols];
 
  println("numCols: " + numCols);
  
  // Get column headers and initialize column min/max and orientation arrays
  for (int j = 0; j < numCols; j++) {
    colNames[j] = table.getString(0, j+1);
    colMins[j] = Integer.MAX_VALUE;
    colMaxes[j] = Integer.MIN_VALUE;
    positiveAxis[j] = false; // maximum at top
  }
  
  // Initialize highlighted rows array to 0s
  for (int i = 0; i < numRows; i++) {
    highlightedRows[i] = 0;
  }
  
  // Get numerical (integer) data
  for (int i = 0; i < numRows; i++) {
    // Get row names
    rowNames[i] = table.getString(i+1, 0);
    // Get table data
    for (int j = 0;  j < numCols; j++) {
      tableData[i][j] = table.getInt(i+1, j+1); 
      // Update column mins and maxes
      if (tableData[i][j] < colMins[j]) {
        colMins[j] = tableData[i][j];
      }
      if (tableData[i][j] > colMaxes[j]) {
        colMaxes[j] = tableData[i][j];
      }
    }
  }
 
  // Configure surface
  size(1200,600);
  surface.setResizable(true); // allows you to resize the canvas
}

void draw() {
  background(255, 255, 255);
  drawAxes();
  drawLines();
}

void drawAxes() {
  // FIXME Use PGraphics
  distanceBetweenAxes = (width - leftOffset - rightOffset) / (numCols-1);
  int axisX = leftOffset;
  int tickLeftEdge = axisX - 5;
  int tickRightEdge = axisX + 5;
  strokeWeight(1);
 
  for (int j = 0; j < numCols; j++) {
    // Draw axis
    line(axisX, topOffset, axisX, height-bottomOffset);
    
    /*
    // Calculate increment
    int increment = colMaxes[j] / 10;
    if (increment > 10) {
      increment = increment - increment % 10;
    }
    if (increment == 0 && (colMaxes[j] - colMins[j] > 1)) {
      increment = 1;
    }*/
    
    /*
    // Draw tick marks
    int tickValue = 0;
    int i = 0;
    float tickDistance = (((float)increment) / colMaxes[j]) * (height - bottomOffset - topOffset);
    if (increment != 0) {
      while (tickValue <= colMaxes[j]) {
        float tickHeight = (i*tickDistance) + topOffset;
        line(tickLeftEdge, tickHeight, tickRightEdge, tickHeight);
        tickValue += increment;
        i++;
      }
      if (tickValue > colMaxes[j]) {
        float tickHeight = height - bottomOffset;
        line(tickLeftEdge, tickHeight, tickRightEdge, tickHeight);
      }
    }
    */
    //else {
      line(tickLeftEdge, height - bottomOffset, tickRightEdge, height - bottomOffset);
      line(tickLeftEdge, topOffset, tickRightEdge, topOffset);
    //}
    
    // Label axis with name
    textAlign(CENTER);
    textSize(10);
    fill(0,0,0);
    text(colNames[j], axisX, height-bottomOffset+30);
    
    // Label axis with max and min
    if (positiveAxis[j]) {
      text(colMins[j], axisX, topOffset-5);
      text(colMaxes[j], axisX, height-bottomOffset+15);
    }
    else {
      text(colMaxes[j], axisX, topOffset-5);
      text(colMins[j], axisX, height-bottomOffset+15);
    }
    
    // Draw +/- button
    rectMode(CENTER);
    fill(255,255,255);
    rect(axisX, height-bottomOffset+40, 12, 12, 5);
    String buttonText;
    if (positiveAxis[j]) {
      buttonText = "+";
    }
    else {
      buttonText = "-";
    }
    textAlign(CENTER);
    fill(0,0,0);
    text(buttonText, axisX, height-bottomOffset+43);
    
    // Move forward to next column
    axisX += distanceBetweenAxes;
    tickLeftEdge += distanceBetweenAxes;
    tickRightEdge += distanceBetweenAxes;
  }
}

void drawLines() {
  // FIXME Use PGraphics
  
  // Initialize highlighted rows array to 0s
  for (int i = 0; i < numRows; i++) {
    highlightedRows[i] = 0;
  }

  // Draw lines
  for (int i = 0; i < numRows; i++) {
    float Px = leftOffset;
    float Qx = leftOffset + distanceBetweenAxes;
    float Py, Qy = 0;
    for (int j = 0; j < numCols-1; j++) {
      // FIXME What if max and min are the same? Dividing by 0
      if (j == 0) {
        float Pfrac = ((float)tableData[i][j] - colMins[j]) / (colMaxes[j]- colMins[j]);
        if (positiveAxis[j]) {
          Py = Pfrac * (height - bottomOffset - topOffset) + topOffset;
        }
        else {
          Py = height - bottomOffset - (Pfrac * (height - bottomOffset - topOffset));
        }
      }
      else {
        Py = Qy;
      }
      float Qfrac = ((float)tableData[i][j+1] - colMins[j+1]) / (colMaxes[j+1] - colMins[j+1]);
      if (positiveAxis[j+1]) {
        Qy = Qfrac * (height - bottomOffset - topOffset) + topOffset;
      }
      else {
        Qy = height - bottomOffset -(Qfrac * (height - bottomOffset - topOffset));
      }
      if (highlightedRows[i] == 1) {
        strokeWeight(3);
      }
      else {
        strokeWeight(1);
      }
      line(Px, Py, Qx, Qy);
      
      // Hovering
      float m = (float)(Py-Qy)/(Px-Qx);
      float b = Py-m*Px;
      if ((Math.abs(mouseY - ((m*mouseX)+b)) < 3) && ((Qy <= Py && mouseY <= Py && mouseY >= Qy) || (Py <= Qy && mouseY <= Qy && mouseY >= Py)) && 
        ((Qx <= Px && mouseX <= Px && mouseX >= Qx) || (Px <= Qx && mouseX <= Qx && mouseX >= Px))) {
        highlightedRows[i] = 1;
        drawHighlightedLinesSubset(i, 0, j-1);
        strokeWeight(3);
        fill(255, 0, 0); // FIXME Why doesn't fill color work?
        line(Px, Py, Qx, Qy);
      }
      
      // Move forward to next column
      Px = Qx;
      Qx += distanceBetweenAxes;
    }
  }
}

void drawHighlightedLinesSubset(int i, int first, int last) {
  float Py, Qy = 0;
  for (int j = first; j < last+1; j++) {
      float Px = leftOffset + j*distanceBetweenAxes;
      float Qx = Px + distanceBetweenAxes;
      // FIXME What if max and min are the same? Dividing by 0
      if (j == 0) {
        float Pfrac = ((float)tableData[i][j] - colMins[j]) / (colMaxes[j]- colMins[j]);
        if (positiveAxis[j]) {
          Py = Pfrac * (height - bottomOffset - topOffset) + topOffset;
        }
        else {
          Py = height - bottomOffset - (Pfrac * (height - bottomOffset - topOffset));
        }
      }
      else {
        Py = Qy;
      }
      float Qfrac = ((float)tableData[i][j+1] - colMins[j+1]) / (colMaxes[j+1] - colMins[j+1]);
      if (positiveAxis[j+1]) {
        Qy = Qfrac * (height - bottomOffset - topOffset) + topOffset;
      }
      else {
        Qy = height - bottomOffset -(Qfrac * (height - bottomOffset - topOffset));
      }
      strokeWeight(3);
      line(Px, Py, Qx, Qy);
  }
}

void mouseClicked() {
  if (Math.abs(mouseY - (height-bottomOffset+40)) <= 12/2) {
    for (int j = 0; j < numCols; j++) {
      int axisX = leftOffset + j*distanceBetweenAxes;
      if (Math.abs(mouseX - axisX) <= 12/2) {
        positiveAxis[j] = !positiveAxis[j];
      }
    }
  }  
}