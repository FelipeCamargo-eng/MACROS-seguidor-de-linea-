; ************************
;                                                                        *
;   ________  _  ___________  ___   ___                                  *
;  / __/ __ \/ |/ /  _/ ___/ |_  | / _ \                                 * 
; _\ \/ /_/ /    // // /__  / __/_/ // /                                 *
;/___/\____/_/|_/___/\___/ /____(_)___/                                  *
;                                                                        *
;                                                                        *
; Description *                                                          *
; *                                                                      *
; Nombre de archivo: Seguidor de linea Sonic_2.0                         *
;                                                                        *
; Versión de archivo: XC, PIC-as 2.31 *                                  *
; *                                                                      *
; Autor: Alejandro Tuberquia 2420182022 y Felipe Camargo 2420182012 *    *
; Universidad de Ibagué                                                  *
; *                                                                      *
; FDISPOSITIVO: P16F877A *                                               *
; ************************
PROCESSOR 16F877A
#include <xc.inc>
CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS
;ENTREDAS
    #define SEN1_IZQ     PORTB,0 ;SENSOR_IZQUIERDA 
    #define SEN2_CEN     PORTB,1 ;SENSOR_CENTRO
    #define SEN3_DER     PORTB,2 ;SENSOR_DERECHO
;SALIDAS    
    #define MOT1_D_A     PORTC,0 ;MOTOR1_AVANZAR
    #define MOT1_D_R     PORTC,1 ;MOTOR1_REVERSA
    #define MOT2_I_A     PORTC,2 ;MOTOR2_AVANZAR 
    #define MOT2_I_R     PORTC,3 ;MOTOR2_REVERSA
    #define LED1_IZQ     PORTC,4 ;LED_INDICADOR_IZQUIERDA
    #define LED2_STOP    PORTC,5 ;LED_INDICADOR_STOP
    #define LED3_DER     PORTC,6 ;LED_INDICADOR_DERECHA
    
PSECT code

AVANZAR: 
    
    BSF MOT1_D_A 
    BCF MOT1_D_R
    BSF MOT2_I_A 
    BCF MOT2_I_R
    BCF LED1_IZQ
    BCF LED2_STOP
    BCF LED3_DER
    GOTO MAIN
 
GIRO_DERECHA:
    
     BCF MOT1_D_A 
     BCF MOT1_D_R
     BSF MOT2_I_A 
     BCF MOT2_I_R
     BCF LED1_IZQ
     BCF LED2_STOP
     BSF LED3_DER
    GOTO MAIN
 
GIRO_IZQUIERDA:
    
    BSF MOT1_D_A 
    BCF MOT1_D_R
    BCF MOT2_I_A 
    BCF MOT2_I_R
    BSF LED1_IZQ
    BCF LED2_STOP
    BCF LED3_DER
    GOTO MAIN
    
 
STOP:
    
    BCF MOT1_D_A 
    BCF MOT1_D_R
    BCF MOT2_I_A 
    BCF MOT2_I_R
    BCF LED1_IZQ
    BSF LED2_STOP
    BCF LED3_DER
    GOTO MAIN

INISYS:
    
    BCF STATUS, 6       ;BANCO_1
    BSF STATUS, 5  
   
    ;ENTRADAS
    
    BSF TRISB, 0        ;PORT B0 SEN_S1     ENTRADA
    BSF TRISB, 1        ;PORT B1 SEN_S2     ENTRADA  
    BSF TRISB, 2        ;PORT B2 SEN_S3     ENTRADA  
    
    ;SALIDAS
    
    BCF TRISC, 0        ;PORT C0 MOT1_D_A   SALIDA  
    BCF TRISC, 1        ;PORT C1 MOT1_D_R   SALIDA 
    BCF TRISC, 2        ;PORT C2 MOT2_I_A   SALIDA
    BCF TRISC, 3        ;PORT C3 MOT2_I_R   SALIDA
    BCF TRISC, 4        ;PORT C4 LED1_IZQ   SALIDA 
    BCF TRISC, 5        ;PORT C5 LED2_STOP  SALIDA
    BCF TRISC, 6        ;PORT C6 LED3_DER   SALIDA 
 
    BCF STATUS, 5         ; BANCO_0
    
MAIN:
   
   
   BTFSS SEN1_IZQ 
   GOTO ORDEN1 
   GOTO ORDEN2 
    
   ORDEN1:
    
   BTFSS SEN3_DER
   GOTO ORDEN3 
   GOTO ORDEN4 
   
   ORDEN2:
    
    BTFSS SEN3_DER
    GOTO ORDEN5 
    GOTO ORDEN6 
    
   ORDEN3: 
    
   BTFSS SEN2_CEN
   CALL STOP
   CALL GIRO_DERECHA
   
   ORDEN4:
    
   BTFSS SEN2_CEN
   CALL AVANZAR
   CALL GIRO_DERECHA
   
   ORDEN5:
    
    BTFSS SEN2_CEN
    CALL GIRO_IZQUIERDA
    GOTO MAIN
    
   ORDEN6:
    
   BTFSS SEN2_CEN
   CALL GIRO_IZQUIERDA
   CALL STOP
   
   end resetVec
 