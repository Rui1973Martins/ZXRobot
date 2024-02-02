;------------------------
; ROM/BASIC System VARS
;------------------------

; FROM: https://k1.spdns.de/Vintage/Sinclair/82/Sinclair%20ZX%20Spectrum/BASIC%20Programming%20Manual/zxmanchap25.html

; The bytes in memory from 23552 to 23733 are set aside for specific uses by the system. You can peek them to find out various things about the system, and some of them can be usefully poked. They are listed here with their uses.
;
; These are called system variables, and have names, but do not confuse them with the variables used by the BASIC. The computer will not recognize the names as referring to system variables, and they are given solely as mnemonics for we humans.
;
; The abbreviations in column 1 have the following meanings:
; X 	The variables should not be poked because the system might crash.
; N 	Poking the variable will have no lasting effect
;
;The number in column 1 is the number of bytes in the variable. For two bytes, the first one is the less significant byte the reverse of what you might expect. So to poke a value v to a two byte variable at address n, use
;
;	POKE n,v-256*1NT (v/256)
;	POKE n+1,lNT (v/256)
;
;and to peek its value, use the expression
;
;	PEEK n+256*PEEK (n+1)
;

KSTATE	EQU	23552	; N8 :	Used in reading the keyboard.
LAST_K	EQU	23560	; N1 :	Stores newly pressed key.
REPDEL	EQU	23561	;  1 :	Time (in 50ths of a second in 60ths of a second in N. America) that a key must be held down before it repeats. This starts off at 35, but you can POKE in other values.
REPPER	EQU	23562	;  1 :	Delay (in 50ths of a second in 60ths of a second in N. America) between successive repeats of a key held down: initially 5.
DEFADD	EQU	23563	; N2 :	Address of arguments of user defined function if one is being evaluated; otherwise 0.
K_DATA	EQU	23565	; Nl :	Stores 2nd byte of colour controls entered from keyboard .
TVDATA	EQU	23566	; N2 :	Stores bytes of coiour, AT and TAB controls going to television.
STRMS 	EQU	23568	; X38:	Addresses of channels attached to streams.
CHARS 	EQU	23606	;  2 :	256 less than address of character set (which starts with space and carries on to the copyright symbol). Normally in ROM, but you can set up your own in RAM and make CHARS point to it.
RASP 	EQU	23608	;  1 :	Length of warning buzz.
PIP 	EQU	23609	;  1 :	Length of keyboard click.
ERR_NR	EQU	23610	;  1 :	1 less than the report code. Starts off at 255 (for 1) so PEEK 23610 gives 255.
FLAGS 	EQU	23611	; X1 :	Various flags to control the BASIC system.
TV_FLAG	EQU	23612	; X1 :	Flags associated with the television.
ERR_SP	EQU	23613	; X2 :	Address of item on machine stack to be used as error return.
LIST_SP	EQU	23615	; N2 :	Address of return address from automatic listing.
MODE 	EQU	23617	; N1 :	Specifies K, L, C. E or G cursor.
NEWPPC	EQU	23618	;  2 :	Line to be jumped to.
NSPPC 	EQU	23620	;  1 :	Statement number in line to be jumped to. Poking first NEWPPC and then NSPPC forces a jump to a specified statement in a line.
PPC 	EQU	23621	;  2 :	Line number of statement currently being executed.
SUBPPC	EQU	23623	;  1 :	Number within line of statement being executed.
BORDCR	EQU	23624	;  1 :	Border colour * 8; also contains the attributes normally used for the lower half of the screen.
E_PPC 	EQU	23625	;  2 :	Number of current line (with program cursor).
VARS 	EQU	23627	; X2 :	Address of variables.
DEST 	EQU	23629	; N2 :	Address of variable in assignment.
CHANS 	EQU	23631	; X2 :	Address of channel data.
CURCHL	EQU	23633	; X2 :	Address of information currently being used for input and output.
PROG 	EQU	23635	; X2 :	Address of BASIC program.
NXTLIN	EQU	23637	; X2 :	Address of next line in program.
DATADD	EQU	23639	; X2 :	Address of terminator of last DATA item.
E_LINE	EQU	23641	; X2 :	Address of command being typed in.
K_CUR 	EQU	23643	;  2 :	Address of cursor.
CH_ADD	EQU	23645	; X2 :	Address of the next character to be interpreted: the character after the argument of PEEK, or the NEWLINE at the end of a POKE statement.
X_PTR 	EQU	23647	;  2 :	Address of the character after the ? marker.
WORKSP	EQU	23649	; X2 :	Address of temporary work space.
STKBOT	EQU	23651	; X2 :	Address of bottom of calculator stack.
STKEND	EQU	23653	; X2 :	Address of start of spare space.
BREG 	EQU	23655	; N1 :	Calculator's b register.
MEM 	EQU	23656	; N2 :	Address of area used for calculator's memory. (Usually MEMBOT, but not always.)
FLAGS2	EQU	23658	;  1 :	More flags.
DF_SZ 	EQU	23659	; X1 :	The number of lines (including one blank line) in the lower part of the screen.
S_TOP 	EQU	23660	;  2 :	The number of the top program line in automatic listings.
OLDPPC	EQU	23662	;  2 :	Line number to which CONTINUE jumps.
OSPCC 	EQU	23664	;  1 :	Number within line of statement to which CONTINUE jumps.
FLAGX 	EQU	23665	; N1 :	Various flags.
STRLEN	EQU	23666	; N2 :	Length of string type destination in assignment.
T_ADDR	EQU	23668	; N2 :	Address of next item in syntax table (very unlikely to be useful).
SEED 	EQU	23670	;  2 :	The seed for RND. This is the variable that is set by RANDOMIZE.
FRAMES	EQU	23672	;  3 :	3 byte (least significant first), frame counter. Incremented every 20ms. See Chapter 18.
UDG 	EQU	23675	;  2 :	Address of 1st user defined graphic You can change this for instance to save space by having fewer user defined graphics.
COORDS	EQU	23677	;  1 :	x-coordinate of last point plotted.
COORDY	EQU	23678	;  1 :	y-coordinate of last point plotted.
P_POSN	EQU	23679	;  1 :	33 column number of printer position
PR_CC 	EQU	23680	; X2 :	Full address of next position for LPRINT to print at (in ZX printer buffer). Legal values 5B00 - 5B1F. [Not used in 128K mode or when certain peripherals are attached]
ECHO_E	EQU	23682	;  2 :	33 column number and 24 line number (in lower half) of end of input buffer.
DF_CC 	EQU	23684	;  2 :	Address in display file of PRINT position.
DFCCL 	EQU	23686	;  2 :	Like DF CC for lower part of screen.
S_POSN	EQU	23688	; X1 :	33 column number for PRINT position
S_LINE	EQU	23689	; X1 :	24	line number for PRINT position.
SPOSNL	EQU	23690	; X2 :	Like S POSN for lower part
SCR_CT	EQU	23692	;  1 :	Counts scrolls: it is always 1 more than the number of scrolls that will be done before stopping with scroll? If you keep poking this with a number bigger than 1 (say 255), the screen will scroll on and on without asking you.
ATTR_P	EQU	23693	;  1 :	Permanent current colours, etc (as set up by colour statements).
MASK_P	EQU	23694	;  1 :	Used for transparent colours, etc. Any bit that is 1 shows that the corresponding attribute bit is taken not from ATTR P, but from what is already on the screen.
ATTR_T	EQU	23695	; N1 :	Temporary current colours, etc (as set up by colour items).
MASK_T	EQU	23696	; N1 :	Like MASK P, but temporary.
P_FLAG	EQU	23697	;  1 :	More flags.
MEMBOT	EQU	23698	; N30:	Calculator's memory area; used to store numbers that cannot conveniently be put on the calculator stack.
NMIADD	EQU	23728	;  2 :	This is the address of a user supplied NMI address which is read by the standard ROM when a peripheral activates the NMI. Probably intentionally disabled so that the effect is to perform a reset if both locations hold zero, but do nothing if the locations hold a non-zero value. Interface 1's with serial number greater than 87315 will initialize these locations to 0 and 80 to allow the RS232 "T" channel to use a variable line width. 23728 is the current print position and 23729 the width - default 80.
RAMTOP	EQU	23730	;  2 :	Address of last byte of BASIC system area.
P_RAMT	EQU	23732	;  2 :	Address of last byte of physical RAM.

; This program tells you the first 22 bytes of the variables area:
;
; 	10 FOR n=0 TO 21
; 	20 PRINT PEEK (PEEK 23627+256*PEEK 23628+n)
; 	30 NEXT n
;
; Try to match up the control variable n with the descriptions above. Now change line 20 to
;
;	20 PRINT PEEK (23755+n)
;
; This tells you the first 22 bytes of the program area. Match these up with the program itself.