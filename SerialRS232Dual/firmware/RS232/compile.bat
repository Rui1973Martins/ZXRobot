@cls
@echo:
@echo: ##### Compile Driver #####
pasmo -d --alocal --tap driver.asm RS232 > asm.txt

@echo:
@echo ===== Generate Files =====
copy /b /y RS232 driver.tap

copy /b /y driver.tap d.tap



