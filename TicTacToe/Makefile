CC=pasmo.exe

all: TicTacToe.tap

clean:
	del TicTacToe.tap main.tap code.tap *.bin *.symbol



data.bin: _DATA_/data.asm _DATA_/*.asm
	$(CC) -d --alocal --bin $< $(@F) data.symbol


%.bin::_DATA_/%.asm
	$(CC) -d --alocal --bin $< $(@F) $(*F).symbol


#  _REF_/*.asm _LIB_/*.asm _DATA_/Font_Tiles_T00.asm  _SFX_/*.asm data.bin

code.tap: main.asm
	$(CC) --alocal --tap $< $@ code.symbol

#	$(CC) -d --alocal --tap $< $@ code.symbol


udg udg.tap: udg.asm _DATA_/BoardParts.asm
	$(CC) --alocal --tap $< udg
	copy /b /y udg udg.tap


# main.tap: ttt.tap code.tap udg
#	copy /b /y ttt.tap+code.tap+udg $@

main.tap: ttt.tap udg
	copy /b /y ttt.tap+udg $@

main: main.tap


tictactoe.tap: main.tap
	copy /b /y $< $@


run: tictactoe.tap
	copy code.symbol "C:\Users\tekday\_DEV_\ZX\Emulator\Zero\code.symbol"
	start /B "C:\Users\tekday\_DEV_\ZX\Emulator\Zero\Zero.exe " tictactoe.tap

debug: tictactoe.tap
	copy code.symbol "C:\Users\tekday\_DEV_\ZX\Emulator\Zero\code.symbol"
	echo %PATH%
	symbol.bat
	start /B "C:\Users\tekday\_DEV_\ZX\Emulator\Zero\Zero.exe " tictactoe.tap

