import processing.serial.*; //Se incluye la libreria para utilizar el serial

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Serial puerto;  //Se crea el objeto de clase serial
IntList info;  //Arreglo que almacena los datos de la senial
float x1,x2,y1,y2;  //Puntos para pintar la senal
boolean sinc = false;  //Variable para determinar si el buffer se lee sincronizadamente
int state = 0;  //Variable para la maquina de estados
byte aux1, aux2, aux3, aux4, aux5; //Variables auxiliares para pasar los datos necesarios a la funcion de conversion
int result1;  //Resultado final de la conversion del primer analogico
int result2;  //Resultado final de la conversion del segundo analogico
int i, j;
float A=0.1;
int k=0;
int num = 4;



void serialEvent(Serial puerto){
  byte[] dato = new byte[5];  // Se crea una varibale tipo byte para guardar el dato del buffer
  dato = puerto.readBytes();  // Se lee y se guardan los datos
  for(int i = 0; i<4; i++){  // Bucle para leer los datos que vienen del buffer
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
          result1 = analogconvertion(aux1, aux2);  //Se convierte
          result2 = analogconvertion(aux3,aux4);
          result1 = (int) map(result1, 0, 4095, 300, 150);//Se mapea para que se encuentre entre los valores de la pantalla
          info.append(result1);  //Se almacenan los datos en el arreglo
          state = 0;
          sinc = false;
          break;
    
      }
    }
  }
    if(info.size() == 20){
    println(info);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup(){
  size(890,600);  //Se ajusta el tamano de la pantalla
  background(255);  //Se pinta la pantalla de blanco
 
  noStroke();
  rectMode(CENTER);
 
  puerto = new Serial(this, Serial.list()[0], 115200);
  puerto.buffer(4);  //Se almacenaran 4 bytes en el buffer, PENDIENTE QUE ERAN 4
  info = new IntList();
  x1 = 0;  //Se inicializan las coordenadas
  x2 = 1;
  y1 = 600;
  

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw(){
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
