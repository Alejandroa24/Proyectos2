import processing.serial.*; //Se incluye la libreria para utilizar el serial

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Serial puerto;  //Se crea el objeto de clase serial
IntList info, info1;  //Arreglo que almacena los datos de la senial
float x1,x2,y1,y2;  //Puntos para pintar la senal
boolean sinc = false;  //Variable para determinar si el buffer se lee sincronizadamente
int state = 0;  //Variable para la maquina de estados
byte aux1, aux2, aux3, aux4, aux5, aux6; //Variables auxiliares para pasar los datos necesarios a la funcion de conversion
int result1;  //Resultado final de la conversion del primer analogico
int result2, result3, result4;  //Resultado final de la conversion del segundo analogico
int i,i1, j;
float A=0.1;
int k=0;
int num = 4;

/////////////////////////////juego///////////////////////////////
float veloz;
float Angle;

int IncomingDistance;
//float Pas; //pour deplacements X

float BirdX;
float BirdY;
float balaX=250;

////////////////////////////////////////////////////////////////
int DistanceUltra;
float [] CloudX = new float[6];
float [] CloudY = new float[6];

float Hauteur; //en Y
//vitesse constante hein


PImage Cloud;
PImage Bird;
PImage bala;


void serialEvent(Serial puerto){
  byte[] dato = new byte[6];  // Se crea una varibale tipo byte para guardar el dato del buffer
  dato = puerto.readBytes();  // Se lee y se guardan los datos
  for(int i = 0; i<6; i++){  // Bucle para leer los datos que vienen del buffer
    if(dato[i] == -14){  // Si se lee la cabecera (etiqueta)
      sinc = true;  //Entonces se esta sincronizado
    }
    if(sinc){
      switch(state){
        case 0:
          state = 1;
          break;
        case 1:
          aux1 = dato[i];  //Se guarda el segundo byte recibido
          state = 2;
          break;
        case 2:
          aux2 = dato[i];  //Se guarda el tercer byte recibido
          state = 3;
          break;
        case 3:
          aux3 = dato[i];  //Se guarda el cuarto byte recibido
          state = 4;
          break;
        case 4:
          aux4 = dato[i];  //Se guarda el quinto byte recibido
          state = 5;
          break;
        case 5:
          aux5 = dato[i];  //Se guarda el sexto byte recibido
          state = 6;
          break;
          case 6:
          aux6 = dato[i];  //Se guarda el sexto byte recibido
          state = 7;
          break;
        case 7:
          result1 = analogconvertion(aux1, aux2);  //Se convierte
          result2 = analogconvertion(aux3,aux4);
          result1 = (int) map(result1, 0, 4095,0, 150);//Se mapea para que se encuentre entre los valores de la pantalla
          result2 = (int) map(result2, 0, 4095,0, 100);//Se mapea para que se encuentre entre los valores de la pantalla
          result3 = aux5;
          result4 = aux6;
          info1.append(result1);  //Se almacenan los datos en el arreglo
          info.append(result2);  //Se almacenan los datos en el arreglo
          state = 0;
          sinc = false;
          break;
    
      }
    }
  }
    if(info.size() == 20){
    println(info);
  }
   if(info1.size() == 20){
    println(info1);
  }

 // println(result1); //checks....
   println(result3); //checks....
 //println(result2); //checks....  
  println(result4); //checks....  
  if (result2>1  && result2< 100) {
        DistanceUltra = result2; //save the value only if its in the range 1 to 100     }
    }
 if(result1<30){
 veloz=0;
 } 
 if(result1<45 & result1>30 ){
 veloz=10;
 }
 if(result1<55 & result1>45){
 veloz=20;
 }
 if(result1<75 & result1>55){
 veloz=40;
 } 
 if(result1>75){
 veloz=60;
 }  

  if (result3<1)
          if (looping)  noLoop();
    else          loop();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int analogconvertion(byte auxi1, byte auxi2){
  int r;
  int b,c;
  int auxi3, auxi4;
  b = (auxi1 & 0x1F); //Elimino los tres primeros bits, que corresponden al cero y los dos digitales
  c = (auxi2 << 1);  //Elimino el cero del principio y queda al final
  auxi3 = (b << 8);  //Para concatenar, se shiftea 8 veces a la izquierda, y quedan ocho ceros a la derecha
  auxi4 = c & 0x00FF; //Paso de 11111111c a 00000000c para concatenar
 
 
  auxi4 = (auxi3 | auxi4);  //Se concatenan
  r = (auxi4 >> 1);  //Se elimina el ultimo cero
 
  return r;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup(){
 
  //noStroke();

 
  puerto = new Serial(this, Serial.list()[0], 115200);
  puerto.buffer(6);  //Se almacenaran 6 bytes en el buffer, PENDIENTE QUE ERAN 4
  info = new IntList();
  info1 = new IntList();
  x1 = 0;  //Se inicializan las coordenadas
  x2 = 1;
  y1 = 600;
  frameRate(30); 

    size(800, 600);
    rectMode(CORNERS) ; //we give the corners coordinates 
    noCursor(); //why not ?
    textSize(16);

    Hauteur = 300; //initial plane value


    Cloud = loadImage("cloud.png");  //load a picture
    Bird = loadImage("bird.png");  
    bala = loadImage("bala.png");  


    //int clouds position
    for  (int i = 1; i <= 5; i = i+1) {
        CloudX[i]=random(1000);
        CloudY[i]=random(400);
    }

}
////////////////////////////////////////////////////////////////////////////
void draw() 
{
    background(0, 0, 0);
    Ciel();
    fill(5, 72, 0); 

    rect(0, 580, 800, 600); //some grass

    text(Angle, 10, 30); //debug things...
    text(Hauteur, 10, 60); 


    //Angle = mouseY-300; //uncomment this line and comment the next one if you want to play with the mouse
    Angle = (18- DistanceUltra)*2;  // you can increase the 4 value...

    Hauteur = Hauteur + sin(radians(Angle))*40; //calculates the vertical position

    //check the height range to keep the plane on the screen 
    if (Hauteur < 0) {
        Hauteur=0;
    }

   
    if (Hauteur > 600) {
        Hauteur=600;
    }

    TraceAvion(Hauteur, Angle);

    BirdX =   BirdX -  10 - veloz;// cos(radians(Angle))*10;
    
 
    
    if (BirdX < -30) {
        BirdX=900;
        BirdY = random(600);
    }

    //draw and move the clouds
    for  (int i = 1; i <= 5; i = i+1) {
        CloudX[i] =   CloudX[i] -  cos(radians(Angle))*(10+2*i)-veloz;

        image(Cloud, CloudX[i], CloudY[i], 300, 200);

        if (CloudX[i] < -300) {
            CloudX[i]=1000;
            CloudY[i] = random(400);
        }
    }
      int t;
   //if (key == 'P') {

   // image(bala, balaX, Hauteur, 32, 32);
    //for(t=200;t>800;t=+10){
    //balaX=balaX+10;
    
 // }
    /*if(key=='P'){
  for (balaX=200;balaX>800;balaX= +10){
    image(bala, balaX, Hauteur, 32, 32);
    }
    }*/
    

image(Bird, BirdX, BirdY, 59, 38); //displays the useless bird. 59 and 38 are the size in pixels of the picture

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void keyPressed() {
  int keyIndex = -1;
  int t, contador;
  if (result4>0) {
    //balaX=200;
    //image(bala, balaX, Hauteur, 32, 32);
    contador=0;
    
    for(t = 0 ; t < 800 ; t = t + 1){
     
      for(contador=0 ; contador<10000 ; contador++){
         t=t; 
      
    }
      //balaX=+10;
       //strokeWeight(5);
   //  fill(#FF0900, #FF0900, #FF0900) ;
    //line (300, Hauteur, balaX, Hauteur);
   image(bala, balaX+t, Hauteur, 32, 32);
  }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void laser(float altura, float BalaX){

    
    image(bala, BalaX, altura, 32, 32);
    
    strokeWeight(5);
   //  fill(#FF0900, #FF0900, #FF0900) ;
    line (300, altura, 780, altura);      //Linea horizontal que simula el rayo láser   
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Ciel() {
    //draw the sky

    noStroke();
    rectMode(CORNERS);

    for  (int i = 1; i < 600; i = i+10) {
        fill( 49    +i*0.165, 118   +i*0.118, 181  + i*0.075   );
        rect(0, i, 800, i+10);
    }
}


void TraceAvion(float Y, float AngleInclinaison) {
    //draw the plane at given position and angle

    noStroke();
    pushMatrix();
    translate(100, Y);
    rotate(radians(AngleInclinaison)); //in degres  ! 


    /*
    Drawing concept :  ;-)
     
     |\___o__
     ________>     
     
     */

    scale(0.5);  //0.2 pas mal
    fill(255, 0, 0);
    stroke(0, 0, 0);
    strokeWeight(2);
    ellipse(292-228, 151-85, 45, 45); //roue

    line(373-228, 145-85, 373-228, 20-85); //helice


    strokeWeight(1); //main thickness


    beginShape();
    //poorly drawn plane

    vertex(214, 120);
    vertex(32, 82);
    vertex(32, 76 );
    vertex(15, 71);
    vertex(35, 69);
    vertex(35, 21);
    vertex(49, 21);
    vertex(57, 24);
    vertex(70, 30);
    vertex(79, 43);
    vertex(81, 58);
    vertex(95, 68);
    vertex(161, 62);
    vertex(187, 59);
    vertex(239, 59);
    vertex(242, 42);
    vertex(296, 40);
    vertex(297, 58);
    vertex(351, 59);
    vertex(365, 67);
    vertex(373, 82);
    vertex(364, 98);
    vertex(339, 109);
    vertex(305, 118);
    vertex(273, 133);

    translate(-228, -85); //centering...

    endShape(CLOSE);

    fill(0, 0, 0);

    fill(255, 128, 0);

    popMatrix();
}

//file end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*void draw(){
  for(i=0; i<info.size(); i=+1){  //Si ya se tienen los datos suficientes
  paint(info.remove(0));  //Se pintan
  }
  frameRate(1000);
  println(mouseX + " : " + mouseY);
  // escalas del osciloscopio
  //height=height-100;
  k=0;
  for (int i = 0; i <= width; i += 50) {
    //fill(0, 0, 0);               // Letras negras
    //text((i/2)-200, i-10, height-15);  // Texto, coord X, Coord Y
    k=k+1;
    if(k>=6){ 
           if(k<15){
    stroke(0);                     // Lineas verticales negras
    strokeWeight (1);               // grosor del trazo
    line(i, height-100, i, 100);
    //line(i+50, height-100, i+50, 0);
           }
    }
  }
  
 k=0;
 for (int j = 0; j <height*2; j += 50) {
  
   
   

   
   
     k=k+1; 
     if(k>2){
     if(k<=11){
    strokeWeight (1);     // grosor del trazo
    stroke(0);                     // Lineas horizontales negras
    line(250, j, width-240, j);
    //line(245, j+50, width, j+50);
       if(num>=-4){
       fill(0);                 // Letras negras
       text(num, 238, j+4);     // Texto, coord X, Coord Y
       num = num-1;
       } 
       
      }
    }
 }
  
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void keyPressed() {
  int keyIndex = -1;
  if (key == 'A') {
    A=A-0.1;
  }
  if ( key == 'Z') {
    A=A+0.1;
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void paint(int punto ){
  y2 = punto;  //Se pinta por lineas
  if(x1 == 0){
    stroke(255);  //La primera linea se pinta de blanco, para que no se vea
  }
  else{
    stroke(0);
  }
 
  line(x1,y1,x2,y2);
  x1 = x2;
  x2 = x2 +A;
  y1 = y2;
  if(x2 > 840){  //Si se supera el tamano de la pantalla
    background(255);  //Se pinta de blanco
    x1 = 0;  //Se empezara a pintar desde el principio de la pantalla otra vez
    x2 = 1;
    info.clear();  //Se limpian los datos capturados, para obtener nuevos
  }
    if(key=='C'){  //Si se supera el tamano de la pantalla
    background(255);  //Se pinta de blanco
    x1 = 0;  //Se empezara a pintar desde el principio de la pantalla otra vez
    x2 = 1;
    info.clear();  //Se limpian los datos capturados, para obtener nuevos
    }
    
}

*/
