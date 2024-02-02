; RS232 Driver Main

include "_REF_/rom_vars.asm"
include "_REF_/zx.asm"

BASE_ADDR	EQU #FC00	; = 64512	; #FD00	; = 64768


; UART (Ti16c752c) Registers
R_RHR	EQU	(0)*2 +1	; (R/_) RHR = Receive Holding Register
R_THR	EQU	(0)*2 +1	; (_/W) THR = Transmit Holding Register
R_IER	EQU	(1)*2 +1	; (R/W) IER = 
R_IIR	EQU (2)*2 +1	; (R/_) IIR =
R_FCR	EQU (2)*2 +1	; (_/W) FCR =
R_LCR	EQU (3)*2 +1	; (R/W) LCR =
R_MCR	EQU (4)*2 +1	; (R/W) MCR = 	
R_LSR	EQU (5)*2 +1	; (R/_) LSR = Line Status Register	
R_MSR	EQU (6)*2 +1	; (R/_) MSR = 
R_SPR	EQU (7)*2 +1	; (R/W) SPR = 

; Special Access: LCR[7]=1 
 R_DLL  	EQU	(0)*2 +1	; (_/W) DLL = DivsorLatch Low
 R_DLH  	EQU	(1)*2 +1	; (_/W) DLH = DivsorLatch High

; Special Access: LCR[7:5]=100
 R_AFR  	EQU (2)*2 +1	; (R/W) AFR = 
 
; Special Access: LCR[7:0]=10111111
 R_EFR  	EQU	(2)*2 +1
 R_XON1 	EQU (4)*2 +1	; (R/W) XON1  = TranXmit ON 1  (Flow Control Char 1)
 R_XON2 	EQU (5)*2 +1	; (R/W) XON2  = TranXmit ON 2  (Flow Control Char 2)
 R_XOFF1	EQU (6)*2 +1	; (R/W) XOFF1 = TranXmit OFF 1 (Flow Control Char 1)
 R_XOFF2	EQU (7)*2 +1	; (R/W) XOFF2 = TranXmit OFF 2 (Flow Control Char 2)
 
 



T_COM_UART_ADDR_IDX           EQU 0 
T_COM_UART_ADDR_SIZE          EQU 2

T_COM_NAME_IDX                EQU T_COM_UART_ADDR_IDX + T_COM_UART_ADDR_SIZE
T_COM_NAME_SIZE               EQU 1		; 1 or 2

T_COM_BAUDRATE_IDX            EQU T_COM_NAME_IDX + T_COM_NAME_SIZE
T_COM_BAUDRATE_SIZE           EQU	6		; "115200"

T_COM_BIT_PARITY_STOP_IDX     EQU T_COM_BAUDRATE_IDX + T_COM_BAUDRATE_SIZE
T_COM_BIT_PARITY_STOP_SIZE    EQU 3	; Example "8N1"

T_COM_XON_XOFF				EQU	T_COM_BIT_PARITY_STOP_IDX + T_COM_BIT_PARITY_STOP_SIZE


ORG BASE_ADDR

	; Driver Jump Table64768
	JP	InitComDrivers
	swallowChar DEFB	0x00	; If different from ZERO (0x00) swallow this char
	
	JP	OpenCOM1_11
	NOP

	JP	CloseCOM1_11
	NOP
	
	JP	COM1_Write
	NOP

	JP	COM1_Read
	NOP
	
	JP	OpenCOM2_12
	NOP

	JP	CloseCOM2_12
	NOP
	
	JP	COM2_Write
	NOP

	JP	COM2_Read
	NOP
	

Obj_COM1:
	DB	#0000	; bits [15:0] => addr (0..15)
	DB	'1'		; COM1 Channel ID
	DB  "9600"	; BaudRate
	DB  "8N1"	; DataBits Parity StopBits
	
Obj_COM2:
	DB	#0010	; bits [15:0] => addr (16..31)
	DB	'2'		; COM2 Channel ID
	DB  "9600"	; BaudRate
	DB  "8N1"	; DataBits Parity StopBits


Obj_DEF:
		Obj_Def_NAME      DB	'1'
		Obj_Def_BAUDRATE  DB	"9600"
		Obj_Def_BPS		  DB	"8N1"


BAUD_RATE_TABLE:
	DB	    "5", "0" + 0x80
	DB	   	"7", "5" + 0x80
	DB	   "11", "0" + 0x80
	DB	   "15", "0" + 0x80
	DB	   "30", "0" + 0x80
	DB	   "60", "0" + 0x80
	DB	  "120", "0" + 0x80
	DB	  "180", "0" + 0x80
	DB	  "200", "0" + 0x80
	DB	  "240", "0" + 0x80
	DB	  "360", "0" + 0x80
	DB	  "480", "0" + 0x80
	DB	  "720", "0" + 0x80
	DB	  "960", "0" + 0x80
	DB	 "1920", "0" + 0x80
	DB	 "3840", "0" + 0x80
	DB	 "7680", "0" + 0x80
	DB	"11520", "0" + 0x80


UART_DATA_BITS   DB "5678"

UART_PARITY      DB "NOESM"	; None, Odd, Even, Space, Mark

STOP_BITS        DB "12"	; 1 or 2


InitComDrivers:
	DI
	PUSH IX

		LD	IX, COM1_DATA
		CALL	RegisterChannel

		LD	IX, COM2_DATA
		CALL	RegisterChannel

	POP IX
	EI
	
	RET


OpenCOM1_11:
	LD	A, 11

OpenCOM1:
; INPUT:
; A = Channel/Stream

	DI
	PUSH IX
	
		LD	IX, COM1_DATA
		PUSH AF
		
			CALL	SetupCOM
			
		POP AF
		
		CALL	OpenStream

	POP IX
	EI
	
	RET


OpenCOM2_12:
	LD	A, 12

OpenCOM2:
; INPUT:
; A = Channel/Stream

	DI
	PUSH IX
	
		LD	IX, COM2_DATA
		PUSH AF
		
			CALL	SetupCOM
			
		POP AF

		CALL	OpenStream

	POP IX
	EI
	
	RET


CloseCOM1_11:
	LD	A, 11

CloseCOM1:
; INPUT:
; A = Channel/Stream

	DI
	PUSH IX

		LD	IX, COM1_DATA
		CALL	CloseChannelStream

	POP IX
	EI
	
	RET


CloseCOM2_12:
	LD	A, 12

CloseCOM2:
; INPUT:
; A = Channel/Stream

	DI
	PUSH IX
	
		LD	IX, COM2_DATA
		CALL	CloseChannelStream

	POP IX
	EI
	
	RET
	

COM1_Read:
	DI
	PUSH IX

		LD	IX, COM1_DATA
		CALL	RS_Read

	POP IX
	EI
	
	RET


COM2_Read:
	DI
	PUSH IX
	
		LD	IX, COM2_DATA
		CALL	RS_Read

	POP IX
	EI
	
	RET



COM1_Write:
	EI	
	PUSH IX

		LD	IX, COM1_DATA
		CALL	RS_Write

	POP IX
	EI
	
	RET

COM2_Write:
	DI
	PUSH IX

		LD	IX, COM2_DATA
		CALL	RS_Write

	POP IX
	EI
	
	RET
	

; COM_DATA DEFINITION
COM_DATA_WRITE	EQU 0	
COM_DATA_READ	EQU 2
COM_DATA_NAME	EQU 4
COM_DATA_IO		EQU 5


COM_DATA_R_RHR_			EQU COM_DATA_IO + 0
COM_DATA_R_THR_			EQU COM_DATA_IO + 0
COM_DATA_R_DLL_			EQU COM_DATA_IO + 0

COM_DATA_R_IER_			EQU COM_DATA_IO + 1
COM_DATA_R_DLH_			EQU COM_DATA_IO + 1

COM_DATA_R_IIR_			EQU COM_DATA_IO + 2
COM_DATA_R_FCR_			EQU COM_DATA_IO + 2
COM_DATA_R_AFR_			EQU COM_DATA_IO + 2
COM_DATA_R_EFR_			EQU COM_DATA_IO + 2

COM_DATA_R_LCR_			EQU COM_DATA_IO + 3

COM_DATA_R_MCR_			EQU COM_DATA_IO + 4
COM_DATA_R_XON1_		EQU COM_DATA_IO + 4

COM_DATA_R_LSR_			EQU COM_DATA_IO + 5
COM_DATA_R_XON2_		EQU COM_DATA_IO + 5

COM_DATA_R_MSR_			EQU COM_DATA_IO + 6
COM_DATA_R_XOFF1_		EQU COM_DATA_IO + 6
COM_DATA_R_TCR_			EQU COM_DATA_IO + 6

COM_DATA_R_SPR_			EQU COM_DATA_IO + 7
COM_DATA_R_XOFF2_		EQU COM_DATA_IO + 7
COM_DATA_R_TLR_			EQU COM_DATA_IO + 7
COM_DATA_R_FIFORdy_		EQU COM_DATA_IO + 7


COM1_DATA:
	DW	COM1_Write	;2548	;COM1_Write
	DW	COM1_Read	;4264	;COM1_Read
	DB	"1"
	;DW	0000	; BASE I/O Addr
	; COM1 UART (Ti16c752c) Registers
	DB	R_THR	; (R/W) *HR Holding Register
	DB	R_IER	; (R/W) IER = 
	DB	R_FCR	; (R/W) IIR/FCR =
	DB	R_LCR	; (R/W) LCR =
	DB	R_MCR	; (R/W) MCR = 	
	DB	R_LSR	; (R/_) LSR = Line Status Register	
	DB	R_MSR	; (R/_) MSR = 
	DB	R_SPR	; (R/W) SPR = 


COM2_DATA:

	DW	COM2_Write
	DW	COM2_Read
	DB	"2"
	;DW	0000	; BASE I/O Addr
	; COM2 UART (Ti16c752c) Registers
	DB	16+R_THR	; (R/W) *HR Holding Register
	DB	16+R_IER	; (R/W) IER = 
	DB	16+R_FCR	; (R/W) IIR/FCR =
	DB	16+R_LCR	; (R/W) LCR =
	DB	16+R_MCR	; (R/W) MCR = 	
	DB	16+R_LSR	; (R/_) LSR = Line Status Register	
	DB	16+R_MSR	; (R/_) MSR = 
	DB	16+R_SPR	; (R/W) SPR = 



RegisterChannel:
; IX = Pointer to COMx_DATA (either COM1_DATA or COM2_DATA)

	; MAke sure we are not already registered.
	LD	HL, (CHANS)
	LD	BC, 4
	
RegisterChannel_LOOP:

	ADD	HL, BC
	LD	A, (HL)
	CP	(IX+4)		; Channel Name
	RET Z
	
	INC	HL			; Next Record

	LD	A, (HL)		; Check CHANS Table End Marker (0x80)
	CP	0x80
	JP	NZ, RegisterChannel_LOOP
	
RegisterChannel_data:

	;LD	HL, (PROG)	; A new channel starts below PROG
	;DEC	HL			; Step down once to CHANS End-Marker (0x80)

	LD	BC, 0x0005	; Require this much space
	CALL	0x1655	; ROM MAKE-ROOM Subroutine

	INC	HL			; point HL to 1st byte of new channel data
	
	LD	A, (IX+0)	; LSB of output routine
	LD (HL), A		;

	INC	HL			;
	LD	A, (IX+1)	; MSB of output routine
	LD	(HL), A		;

	INC	HL			;
	LD	A, (IX+2)	; LSB of COM input routine
	LD	(HL), A     ;

	INC	HL			;
	LD	A, (IX+3)	; MSB of COM input routine
	LD	(HL), A		;

	INC	HL			;
	LD	A, (IX+4)	; Channel name COM x
	LD	(HL), A		;

	RET


OpenChannelStream:
;INPUT:
; A = Stream to open.
; B = Stream Name ('1' or '2')


OpenStream:
;INPUT:
; A = Stream to open.
; IX = Pointer to COMx_DATA (either COM1_DATA or COM2_DATA)

	PUSH AF		; Save Channel Number
	
		LD	A, (IX+4)
		
		CP '1'
		JP Z, OpenStream_findChannel
		
		CP '2'
		JP Z, OpenStream_findChannel

	POP AF	; Restore Channel number

	; TODO: Return Error
RET	

	
OpenStream_findChannel:

	LD	B, (IX+4)	; Keep Channel Name : Could use	LD B, A
	
	LD	HL, (CHANS)	; Channels Table Addr

OpenStream_findChannel_LOOP:

	LD	A, (HL)
	CP	0x80		; End Marker
	
	JP Z, OpenStream_errorExit 			; TODO Should Return an Error
	
	EX	DE, HL

		LD	IXl, E
		LD 	IXh, D
		
		LD	A, (IX + 4)
		CP	B

		JP	Z, OpenStream_createStream	; Found Channel
		
	LD	HL, 0x0005	; Next Channel
	ADD	HL, DE

	JP	OpenStream_findChannel_LOOP	

OpenStream_errorExit

	POP AF	; Restore Channel number
	
	; TODO Return an Error
	; 	RST $08 	; Call the error handling routine.
	; 	DEFB $17	; Invalid Stream
RET


OpenStream_createStream:

	EX	DE, HL		; Recover Found Channel Addr
	
	;PUSH HL			; Save Channel Addr
		; CALL SetupCOM


	LD	DE, (CHANS)	; Calculate the offset to the channel data

	AND	A			; and store it in DE
	SBC	HL, DE		;
	

	EX	DE, HL      ; DE = Found - (CHANS)
	INC DE			; Adjust for STRMS Table Offset by 1

	POP	AF			; Recover Channel Number/Stream to open (4 .. #15).

	ADD	A, 0x03		; Calculate the offset (due to 3 negative Channels) and store it in BC
	ADD	A, A		; x2 (for Words)
	LD	B, 0x00     ;
	LD	C, A        ; STRMS table offset (in words)

	LD	HL, STRMS	; STRMS Table Addr
	ADD	HL, BC		; Final Addr to STRMS table entry
	
	LD	(HL), E		; Offset LSB of 2nd byte of new channel data
	INC	HL			;
	LD	(HL), D		; Offset MSB of 2nd byte of new channel data

	; POP HL			; restore Channel Addr
	
	RET	


CloseChannelStream:
;INPUT:
; A = Stream number to close.

	ADD	A, 3		; Adjust Zero Offset
	ADD	A, A		; x2 (Word Offsets)

	LD	HL, STRMS	; Streams Offset Table

	LD	D, 0
	LD	E, A
	
	ADD	HL, DE		; Stream offset addr

		
	LD	E, (HL)		; Stream Offset LOW
	INC	HL			; Advance
	LD	D, (HL)		; Stream Offset High
					; DE = Offset

	; is Stream Open ?
	LD	A, D		; Open -> != 0
	OR	E
	JP	Z, CloseChannelStream_errorExit	; It's an Error to close an already closed Stream

	PUSH HL			; Save Stream offset Addr
	
		; We need to confirm this is a Stream that this driver/Channel can handle
		LD	HL, 4-1	; Channel Name Offset (Zero adjusted)
		ADD HL, DE	; HL = Adjusted name offset

		LD	DE, (CHANS)
		ADD	HL, DE
		LD	A, (HL)	; A = Channel Type
	
	POP HL
	
	DEC	HL			; Back to Stream Offset Low byte
	
	CP	'1'
	JP	Z, CloseStream
	
	CP	'2'
	JP	Z, CloseStream

CloseChannelStream_errorExit:

	; TODO Return an Error
	; 	RST $08 	; Call the error handling routine.
	; 	DEFB $17	; Invalid Stream

RET	


CloseStream:
;INPUT:
; HL = Stream entry to close.

	; Clear Stream data ( set Offset to zero )
	XOR A		
	LD	(HL), A
	INC	HL
	LD	(HL), A

	; TODO: Disable COM PORT
RET


Setup
;INPUT:
; BC = Pointer to Setup string
;
;	Expects: a string with the following format, where all parameters are optional.
;	[Com_port],[Baud_rate],[Data_format],[Flow_control],[XOn_byte],[XOff_byte]

;	- [Com_port]: Either '1' or '2' which selects COM1 or COM2, respectively

;	- [Baud_rate]: Any string from BAUD_RATE_TABLE

;	- [Data_format]: Composed of 3 items: Data_Bits, Parity and Stop_bits
;		

;	- [Flow_control]; NONE, SOFT (XON/XOFF), HARD (RTS/CTS)
;	- 
;	- [XOn_byte]	= 19
;	. [XOff_byte]	= 17

;	Defaults params are equivalent to the following String:
;	"1,9600,8N1,AUTO,19,17"

	Setup_UART
		LD	E, C	; Save String ptr
		LD	D, B
		
	Setup_UART_loop
	
		CALL ParseDecimal

		PUSH DE
		; Use Decimal
		;...
		
		POP DE
		;CALL SwallowWhitespace nextParam
		
		LD	A, (DE)
		CP	' '
		CP	','
		;RET S, Setup_BaudRate
		
	Setup_UART_
	
		
	Setup_BaudRate

	Setup_Flow_Control

	Setup_XOn

	Setup_XOff

	RET


SetupCOM
;INPUT:
;	IX = Base Addr of COM data structure (T_COM)
;

	; Setup UART
			
	; BaudRate
	
	LD	B, 0
	
	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 128	; Setup Special Access ( LCR[7] = 1 )
	OUT (C), A

	; Set 9600 Baud
	
		LD	C, (IX + COM_DATA_R_DLH_)	; Divisor Latch High
		LD	A, 0	; 9600 -> DLH = 0
		OUT (C), A
	

		LD	C, (IX + COM_DATA_R_DLL_)	; Divisor Latch Low
		LD	A, 104	; 9600 -> DLL = 104
		OUT (C), A

	; Set Bits, Parity and Stop Bit
	
	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 3	; 8 Data bits, No Parity, 1 Stop Bit
	OUT (C), A

	; Modem Control
	
	LD	C, (IX + COM_DATA_R_MCR_)	; Modem Control Register = 9
	LD	A, 0	; Disable: loopBack, IRQ, FIFORdy, RTS e DTR
	OUT (C), A

	; Setup XOn/XOff
	
	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 0xBF	; BF: XRegs
	OUT (C), A

	; Setup_XOn

		LD	C, (IX + COM_DATA_R_XON1_)	; XOn1 = 9
		LD	A, 17	; Standard XON char
		OUT (C), A

		LD	C, (IX + COM_DATA_R_XON2_)	; XOn2 = 11
		LD	A, 17	; Standard XON char
		OUT (C), A

	; Setup_XOff

		LD	C, (IX + COM_DATA_R_XOFF1_)	; XOff1 = 13
		LD	A, 19	; Standard XOFF char
		OUT (C), A

		LD	C, (IX + COM_DATA_R_XOFF2_)	; XOff2 = 15
		LD	A, 19	; Standard XOFF char
		OUT (C), A

	; Recover Bits, Parity and Stop Bit
	
	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 3	; 8 Data bits, No Parity, 1 Stop Bit
	OUT (C), A
	
	; Flow Control
	
	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 0xBF	; BF: XRegs
	OUT (C), A

	LD	C, (IX + COM_DATA_R_EFR_)	; Enhanced Functions Register = 5
	LD	A, 0	; SW Flow Control Off
	OUT (C), A

	LD	C, (IX + COM_DATA_R_EFR_)	; Enhanced Functions Register = 5
	LD	A, 128+64+16	; Enable AutoCTS, AutoRTS, Enhanced Func On
	OUT (C), A

	; Recover Bits, Parity and Stop Bit

	LD	C, (IX + COM_DATA_R_LCR_)	; Line Control Register = 7
	LD	A, 3	; 8 Data bits, No Parity, 1 Stop Bit
	OUT (C), A


	; Modem Control Register
	
	LD	C, (IX + COM_DATA_R_MCR_)	; Modem Control Register = 9
	LD	A, 64	; TCR On
	OUT (C), A


		LD	C, (IX + COM_DATA_R_TCR_)	; Transmission Control Register = 13
		LD	A, 0 + ((48/4) + (32/4*16))	; TCR, Fifo Trigger Levels
		OUT (C), A


	; FIFOs

	LD	C, (IX + COM_DATA_R_FCR_)	; FIFO Control Register = 5
	LD	A, 7	; Reset TX, Reset RX, Enable FIFO
	OUT (C), A
	
	RET	


RS_Read:
;INPUT:
;	IX = Base Addr of COM data structure (COM_DATA)
;
;OUTPUT:
;	Carry = 1 if there is data available
;	Carry = 0 and Zero flag = 0 if no data available in A register
;	A = input stream Char (if carry = 1)

	LD	B, 0
	LD	C, (IX + COM_DATA_R_LSR_) ; LSR = Line Status Register
	IN	A, (C)		; Read Status. Uses BC
	
	AND %00011111	; keep only interesting bits (Errors and Char available) and clears Carry
	JR Z, RS_Read_empty_OK

IF 1
	BIT	0, A		; Char available ?	(Does not affect Carry)
	JR	Z, RS_Read_error
ELSE
	RRA				; Set Carry = Char available
	JR	NC, RS_Read_error
ENDIF


RS_Read_char:
	EX	AF, AF'		;' Save status

		; LD B, 0
		LD	C, (IX + COM_DATA_R_RHR_)	; RHR = Receive Holding Register

IF 0
		; NOTE: IN instruction affects Flags (Except Carry)
		IN	B, (C)		; Read CHAR. Uses BC

	EX	AF, AF'		;' Recover status

	LD	A, B		; Get Data Byte
	;SCF				; Set Carry = 1; Data Available
ELSE
		; NOTE: IN instruction affects Flags (Except Carry)
		IN	A, (C)	; Read CHAR. Uses BC
		
	; NOTE: Keeps and returns Status in AF'

	; DEBUG
		;EX AF, AF'	;'
		;	LD	C, (IX + COM_DATA_R_THR_)	; RHR = Receive Holding Register
		;	OUT (C), A
		;EX AF, AF'	;'
		;	OUT (C), A
		
	;SCF				; Set Carry = 1; Data Available
ENDIF
	EX AF, AF'	;'
	
		LD A,(swallowChar)
		AND A	
		JP Z, RS_Read_noSwallow
		
		LD	C, A	; Copy to C
		
	EX AF, AF'	;'
	CP C	; Compare with swallowChar
	JP Z, RS_Read	; Swallow

	SCF				; Set Carry = 1; Data Available
	RET				; Exit with: Carry = 1 ;(TODO?: and Z = 1 if error)
	
RS_Read_noSwallow:

	EX AF, AF'	;'

	SCF				; Set Carry = 1; Data Available
	RET				; Exit with: Carry = 1 ;(TODO?: and Z = 1 if error)


RS_Read_error:
	AND %00011101	; keep only Error character related bits [4:2] and 0 (Ignore Overrun Error (bit 1))
	RRA				; Rotate twice to match border color bits
	RRA				; Place Received  Error bit into A[7]

	LD	C, ULA		; DEBUG Change Border to an error color, formed by 3 error bits
	OUT	(C), A

	; TODO: We must Read RHR, to be able to update the Status in LSR (Line Status Register)
	EX	AF, AF'		;' Save status
	
		LD	A, R_RHR	; RHR = Receive Holding Register
		ADD A, D
		LD	C, A

	XOR A			; Clear Carry = 0 (no Data Available), Clear Z Flag = 0 (no Data Available)
	RET

RS_Read_empty_OK:
	
	;LD	C, ULA		; DEBUG Change Border to BLACK (since A = 0)
	;OUT	(C), A		; Make sure we use BC, to use the full 16 bits address

	;CP	-1			; Exit with: Carry = 0 and Z Flag = 0 (and Sign = 0)
	XOR A			; Exit with: Carry = 0 and Z Flag = 0 (and Sign = 0)
	
	RET
	
	

RS_Write:
; INPUT:
;	A = Char to Transmit
	
	; TODO: Should check if we can write, i.e. if the TX FIFO is FULL or not.

	LD	B, 0
	LD	C, (IX + COM_DATA_R_THR_)	; Transmit Holding Register	
	OUT	(C), A		; Write CHAR in TX FIFO, Uses BC
		
	RET


ParseDecimal
;INPUT:
;	DE: ptr to String
;	A:	String length
;
;OUTPUT:
;	HL: Number
;	DE: First Char not used.
;	B: 0, if every char used, > 0 if some char was not a digit
;
; TRASHES:	A, B, 
	LD HL, #0000	; 10 T

	AND	A	; Exit on Empty string
	RET	Z
	
	LD B, A	; Keep counter
	
ParseDecimal_loop

	LD	A, (DE)	; Read Char

	; Validate if in range ['0'..'9']
	SUB	'0'		; Test and convert to number
	RET	M		; Char is less than '0', exit with value in HL
	
	CP	9
	RET P		; Char is above digit '9' exit with value in HL 
	
	PUSH DE

		; multiply by 10
		LD	E, L	; DE = HL, to use in x5
		LD	D, H
		
		ADD	HL, HL	; x2
		ADD	HL, HL	; x4
		ADD HL, DE	; x5
		ADD	HL, HL	; x10
		
		; Add extra digit
		LD	E, A
		LD	D, 0
		ADD HL, DE
		
	POP DE

	INC	DE	; Advance, since we used this char
	
	DJNZ ParseDecimal_loop

	RET
