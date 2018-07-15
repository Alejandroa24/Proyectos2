#include "PE_Types.h"
#include "Cpu.h"
#include "Events.h"
#include "AD1.h"
#include "AS1.h"
#include "TI1.h"
#include "Cap1.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"
/* User includes (#include below this line is not maintained by Processor Expert) */

//unsigned char estado = ESPERAR;
unsigned char CodError;			//Defino un tipo de dato llamado CodError de tamaño 1byte (char)
unsigned int Enviados = 2;		// Esta variable no aporta nada más sino el número de elementos del arreglo a enviar.
unsigned int error;				//Defino un tipo de dato llamado error de tamaño 1byte (char)
bool primero = FALSE;
unsigned int periodo;
unsigned int time;


int i;

typedef union{
unsigned char u8[2];
unsigned int u16;
}AMPLITUD;

volatile AMPLITUD iADC,iADC1;
volatile AMPLITUD b,c,b1,c1,dig1,dig2;
unsigned char cTrama[7]={0xF2,0x00,0x00,0x00,0x00,0x00,0x00}; 	// Esta es una primera trama que yo hice de ejemplo.
unsigned char dTrama[2]={0x00,0x00};					// Esta es la trama que declaré para rellenarla con la medición del ADC.	

void main(void)
{
  /* Write your local variable definition here */

	
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
    
  /* For example: for(;;) { } */

  while (1){

	  
	  if (estado==2){
		  	 
		  
  		
  			CodError = AD1_MeasureChan(TRUE,0);
  			CodError = AD1_GetChanValue16(0,&iADC.u16);
  			CodError = AD1_MeasureChan(TRUE,3);
  			CodError = AD1_GetChanValue16(3,&iADC1.u16);
  			
  			CodError = AD1_MeasureChan(TRUE,1);
  			CodError = AD1_GetChanValue16(1,&dig1.u16);
  			CodError = AD1_MeasureChan(TRUE,2);
  			CodError = AD1_GetChanValue16(2,&dig2.u16);
  			  			
  			  			
  			//primer canal Analogico
  					iADC.u16 = iADC.u16 >> 4;
  					c.u16 =iADC.u16 & 0x007F;
  					b.u16 =iADC.u16 >> 7;
  					b.u16 = b.u16 & 0x1F; 
			cTrama[1] = b.u16;
			cTrama[2] = c.u16;
			//segundo canal
			  	  	 iADC1.u16 = time;// >> 4;
			  	  	 c1.u16 =iADC1.u16 & 0x007F;
			  	  	 b1.u16 =iADC1.u16 >> 7;
			  	  	 b1.u16 = b1.u16 & 0x1F; 
			 cTrama[3] = b1.u16;
			 cTrama[4] = c1.u16;
			 
  			//segundo canal (Digital)
			dig1.u16 = dig1.u16 >> 4;
			dig2.u16 = dig2.u16 >> 4;
			
			if(dig1.u16 >= 1){
			  				cTrama[6] = cTrama[6] | 0x01;
			  			}
			  			else if(dig1.u16 <= 0){
			  				cTrama[6] = cTrama[6] & 0xFE;
			  			}
			  					
			  if(dig2.u16 >= 2000){
			  				cTrama[5] = cTrama[5] | 0x01;
			  			}
			  			else if(dig2.u16 < 2000){
			  				cTrama[5] = cTrama[6] & 0xFE;
			  			}
  						
  			 //El arreglo con la medición está en iADC.u8 (notar que es un apuntador)
  		
			for(i = 0; i < 7; i++){
						do{
							CodError = AS1_SendChar(cTrama[i]);
						} while (CodError != ERR_OK);
			}
  			
  			
  			
	/*cTrama[1]=0;
	cTrama[2]=0; 
  	b.u16=0;
  	c.u16=0;*/
  	estado = 0;

  	}
  }
  
  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END ProcessorExpert */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.08]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
