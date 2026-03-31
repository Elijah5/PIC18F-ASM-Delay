;*******************************************************************************************************
;   File: CylonDelay.s
;   Date: JANUARY 29, 2026
;   Author: ELIJAH BURTNER
;   Description: THIS PROGRAM PRODUCES A CYLON EFFECT ACROSS 8 LEDs to demonstrate an ASM delay loop.
;*******************************************************************************************************

PROCESSOR 18F57Q43  ;SET PIC PROCESSOR
#include <xc.inc>


; PIC18F57Q43 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FEXTOSC = OFF         ; External Oscillator Selection (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_1MHZ; Reset Oscillator Selection (HFINTOSC with HFFRQ = 4 MHz and CDIV = 4:1)

; CONFIG2
  CONFIG  CLKOUTEN = OFF        ; Clock out Enable bit (CLKOUT function is disabled)
  CONFIG  PR1WAY = ON           ; PRLOCKED One-Way Set Enable bit (PRLOCKED bit can be cleared and set only once)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)

; CONFIG3
  CONFIG  MCLRE = EXTMCLR       ; MCLR Enable bit (If LVP = 0, MCLR pin is MCLR; If LVP = 1, RE3 pin function is MCLR )
  CONFIG  PWRTS = PWRT_OFF      ; Power-up timer selection bits (PWRT is disabled)
  CONFIG  MVECEN = ON           ; Multi-vector enable bit (Multi-vector enabled, Vector table used for interrupts)
  CONFIG  IVT1WAY = ON          ; IVTLOCK bit One-way set enable bit (IVTLOCKED bit can be cleared and set only once)
  CONFIG  LPBOREN = OFF         ; Low Power BOR Enable bit (Low-Power BOR disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled , SBOREN bit is ignored)

; CONFIG4
  CONFIG  BORV = VBOR_1P9       ; Brown-out Reset Voltage Selection bits (Brown-out Reset Voltage (VBOR) set to 1.9V)
  CONFIG  ZCD = OFF             ; ZCD Disable bit (ZCD module is disabled. ZCD can be enabled by setting the ZCDSEN bit of ZCDCON)
  CONFIG  PPS1WAY = ON          ; PPSLOCK bit One-Way Set Enable bit (PPSLOCKED bit can be cleared and set only once; PPS registers remain locked after one clear/set cycle)
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low voltage programming enabled. MCLR/VPP pin function is MCLR. MCLRE configuration bit is ignored)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Extended Instruction Set and Indexed Addressing Mode disabled)

; CONFIG5
  CONFIG  WDTCPS = WDTCPS_31    ; WDT Period selection bits (Divider ratio 1:65536; software control of WDTPS)
  CONFIG  WDTE = OFF            ; WDT operating mode (WDT Disabled; SWDTEN is ignored)

; CONFIG6
  CONFIG  WDTCWS = WDTCWS_7     ; WDT Window Select bits (window always open (100%); software control; keyed access not required)
  CONFIG  WDTCCS = SC           ; WDT input clock selector (Software Control)

; CONFIG7
  CONFIG  BBSIZE = BBSIZE_512   ; Boot Block Size selection bits (Boot Block size is 512 words)
  CONFIG  BBEN = OFF            ; Boot Block enable bit (Boot block disabled)
  CONFIG  SAFEN = OFF           ; Storage Area Flash enable bit (SAF disabled)
  CONFIG  DEBUG = OFF           ; Background Debugger (Background Debugger disabled)

; CONFIG8
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block not Write protected)
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers not Write protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not Write protected)
  CONFIG  WRTSAF = OFF          ; SAF Write protection bit (SAF not Write Protected)
  CONFIG  WRTAPP = OFF          ; Application Block write protection bit (Application Block not write protected)

; CONFIG10
  CONFIG  CP = OFF              ; PFM and Data EEPROM Code Protection bit (PFM and Data EEPROM code protection disabled)
  
;   -----------END CONFIG--------------
  
 PSECT udata_acs	; Access RAM GPRs are available 0x00 to 0x5F

 ;Setup counter globals
 global innerCount
 global outerCount

innerCount: 	DS 1
outerCount: 	DS 1

  PSECT resetVec, class=CODE, reloc=2
resetVec:
    GOTO main
    
    PSECT code
main:					;PROGRAM STARTS HERE
						;SETUP
						
    BSF TRISB4			;MAKE RB4 AN INPUT	
    CLRF PORTC, A		;CLEAR PORT C BEFORE MAKING INPUT	
    CLRF TRISC, A		;MAKE PORTC AN OUTPUT
    
    CLRF    PORTF, A	;CLEARING PORT F
						;ENABLE DIGITAL DRIVERS
    BANKSEL ANSELC		;SELECT PORT C
    CLRF ANSELC, B		;CLEAR TO SET DIGITAL
    
						;SETUP WEAK PULLUP RESISTORS
    BANKSEL WPUB		;SELECT BANK
    BSF	WPUB4			;TURN ON WEAK PULLUPS
    BSF RC0				;SET PORTC BIT 0 TO HAVE AN LED / BIT TO ROTATE
    
mainLoop:
    CALL runLeft		;ROTATE ACTIVE LED TO THE LEFT
    CALL runRight		;ROTATE ACTIVE LED TO THE RIGHT
    GOTO mainLoop		;KEEP RUNNING MAIN LOOP
    
runLeft:
    RLNCF PORTC, A		;ROTATE PORTC (ACTIVE LED) LEFT WITH NO CARRY
    CALL delay			;ADD A DELAY INBETWEEN
    BTFSC RC7			;CHECK IF BIT / LED IN POSITION 7 IS CLEAR
    RETURN				;IF THE BIT IS SET, BREAK THIS LOOP AND GOTO MAIN LOOP (RIGHT DIRECTION LOOP RUNS NEXT)
    GOTO runLeft		;STAY IN THIS LOOP OTHERWISE
    
runRight:
    RRNCF PORTC, A		;ROTATE PORTC (ACTIVE LED) RIGHT WITH NO CARRY
    CALL delay			;ADD A DELAY INBETWEEN
    BTFSC RC0			;CHECK IF BIT / LED IN POSITION 0 IS CLEAR
    RETURN				;IF THE BIT IS SET, BREAK THIS LOOP AND GOTO MAIN LOOP (LEFT DIRECTION LOOP RUNS NEXT)
    GOTO runRight		;STAY IN THIS LOOP OTHERWISE
        
 delay:
    MOVLW 20				;MOVE LITERAL TO W
    MOVWF outerCount, C		;STORE IT IN OUTERCOUNT (DELAY MULT)
    MOVLW 180
    MOVWF innerCount, C

delayOuter:
delayInner:
    DECFSZ  innerCount, F, A	;1 CYCLE IF NOT 0, 3 CYCLES IF SKIP | DECREMENT F, SKIP IF ZERO
    GOTO    delayInner			;2 CYCLES | RESET PC @ DELAY INNER
    DECFSZ  outerCount, F, A
    GOTO    delayOuter			;RUN AGAIN
    NOP							;1 CLOCK CYCLE
    NOP							;1 CLOCK CYCLE
    RETURN						;RETURN TO MAIN LOOP / PC
    NOP
    
    end resetVec




