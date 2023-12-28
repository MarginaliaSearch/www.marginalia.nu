;  Small (completely unbeatable) pong clone. It is not loaded as an operating
;  system, but rather through the LOADSUB function. 
;
;  Instructions:
;  --------------
;  (1)  Assemble into pong.ternobj by running
;  'tg_assembler -o pong.ternobj pong.asm'
;
;  (2) Run 'tunguska -F pong.ternobj os.ternobj', where
;      os.ternobj is the assembled sources of the contents of
;      the memory_image subdirectory of the tunguska sources.
;
;  (3) Type 'LOADSUB'
;
;  Steer with the mouse
;
;
;  Lower this value  ---v  if it is running too slow
@EQU	computerspeed	8

; ---------------------------------------------------------
;
;
;
;  Code begins
;

@ORG	%DDD000
	; Bootstrap function
	;
	; Read page 2 from disk into page 2 in memory
	LDA	#2
	LDY	#2
	JSR	(jumpvector.fl_read_block)
        ; ... and page 3
	LDA	#3
	LDY	#3
	JSR	(jumpvector.fl_read_block)

	JMP	pongish

; These won't be copied. They are also present in the host at the same
; memory location. 

@ORG	%001000
jumpvector:
.getstring:	@DW	0
.feedscreen:	@DW	0
.putchar:	@DW	0
.putnon:	@DW	0
.puts:		@DW	0
.strcmp:	@DW	0
.strlen:	@DW	0
.index:		@DW	0
.strspn:	@DW	0
.strcspn:	@DW	0
.memset6:	@DW	0
.random:	@DW	0
.between:	@DW	0
.repaint:	@DW	0
.fl_read_block: @DW	0
.fl_write_block: @DW	0
.mouse.x       : @DW	0
.mouse.y       : @DW	0

@ORG	%002000
pongish:
		; Clear the screen
		LDX	#%DDB
		LDY	#%DDD
		LDA	#0
.clearloop:
		STA	X,Y
		INY
		JVC	.clearloop
	
		; Enable vector mode
		LDA	#%003
		STA	%DDDDDB

		; 0.0.3 bugfix
		; -- make the last vector invisible
		LDA	#%DDD
		STA	%DDBDDD+45

.loop:
		LDA	(jumpvector.mouse.y)

		LDX	#-121+paddle.height/2
		LDY	#121-paddle.height/2
		JSR	(jumpvector.between)
		STA	paddle.pos
		STA	(jumpvector.mouse.y)

		JSR	paddle.draw
		JSR	enemy.draw
		JSR	ball.draw
		JSR	ball.move
		JSR	enemy.move

		LDX	#computerspeed
.pauseloop:	DEX
		JSR	pause
		JGT	.pauseloop	

		JMP	.loop


.txt:		@DT	'PONGISH', 0

paddle:		
.pos:		@DT	0
@EQU		.vectors	%DDBDDD		; Length 4*3
@EQU		.height		27
@EQU		.width		3

.draw:
		LDA	#%DDD

		STA 	.vectors
		LDA	#%444
		STA 	.vectors+3
		STA 	.vectors+6
		STA 	.vectors+9
		STA 	.vectors+12

		LDA	#121-.width
		STA	.vectors+1
		STA	.vectors+3+1
		STA	.vectors+12+1
		LDA	#121
		STA	.vectors+6+1
		STA	.vectors+9+1

		LDA	.pos
		CLC
		ADD	#0-.height/2
		STA	.vectors+2
		STA	.vectors+9+2
		STA	.vectors+12+2
		LDA	.pos
		CLC
		ADD	#.height/2
		STA	.vectors+3+2
		STA	.vectors+6+2

		RST

enemy:
.pos:		@DT	0
@EQU		.vectors	%DDBDDD+15	; Length 4*3
@EQU		.height		27
@EQU		.width		3

.draw:
		LDA	#%DDD

		STA 	.vectors
		LDA	#%444
		STA 	.vectors+3
		STA 	.vectors+6
		STA 	.vectors+9
		STA 	.vectors+12

		LDA	#-121+.width
		STA	.vectors+1
		STA	.vectors+3+1
		STA	.vectors+12+1
		LDA	#-121
		STA	.vectors+6+1
		STA	.vectors+9+1

		LDA	.pos
		CLC
		ADD	#0-.height/2
		STA	.vectors+2
		STA	.vectors+9+2
		STA	.vectors+12+2
		LDA	.pos
		CLC
		ADD	#.height/2
		STA	.vectors+3+2
		STA	.vectors+6+2

		RST
.move:
		LDA	.pos
		LDX	#-120+.height/2
		LDY	#120-.height/2
		JSR	(jumpvector.between)
		STA	.pos

		LDA	.pos
		CMP	ball.y
		JLT	.inc
		JGT	.dec
		RST
.inc:		
		INC	.pos
		RST
.dec:
		DEC	.pos
		RST
	
ball:
.x:		@DT	0
.y:		@DT	0
.vx:		@DT	2
.vy:		@DT	1
		@EQU	.width 4
		@EQU	.height 4
		@EQU	.vectors	%DDBDDD+30	; Length 4*3
.draw:
		LDA	#%DDD

		STA 	.vectors
		LDA	#%444
		STA 	.vectors+3
		STA 	.vectors+6
		STA 	.vectors+9
		STA 	.vectors+12

		LDA	.x
		CLC
		ADD	#0-.width/2
		STA	.vectors+1
		STA	.vectors+3+1
		STA	.vectors+12+1
		LDA	.x
		CLC
		ADD	#0+.width/2
		STA	.vectors+6+1
		STA	.vectors+9+1

		LDA	.y
		CLC
		ADD	#0-.height/2
		STA	.vectors+2
		STA	.vectors+9+2
		STA	.vectors+12+2

		LDA	.y
		CLC
		ADD	#.height/2
		STA	.vectors+3+2
		STA	.vectors+6+2

		RST
.move:
		LDA	.x
		ADD	.vx
		STA	.x

		LDA	.y
		ADD	.vy
		STA	.y

	
		; Flip y if floor/ceiling collision
		LDA	.y
		CMP	#121-.height/2
		JGT	.flipy
		CMP	#{.height/2 - 121}
		JLT	.flipy

		; Don't perform collision detection if not close to
		; user paddle, x-wise
		LDA	.x
		CMP	#121-paddle.width/2
		JLT	.enemytest

		; If paddle position - height/2 > y, reset
		LDA	paddle.pos
		ADD	#0-paddle.height/2
		CMP	.y
		JGT	.reset


		LDA	paddle.pos
		ADD	#paddle.height/2
		CMP	.y
		JLT	.reset

		JMP	.flipx

.enemytest:
		LDA	.x
		CMP	#-121+paddle.width/2
		JGT	.mdone

		; If paddle position - height/2 > y, reset
		LDA	enemy.pos
		ADD	#0-enemy.height/2
		CMP	.y
		JGT	.reset

		LDA	enemy.pos
		ADD	#enemy.height/2
		CMP	.y
		JLT	.reset

		JMP	.flipx

		LDA	.x
		CMP	#121-.width/2
		JGT	.flipx
		CMP	#-121 + .width/2
		JLT	.flipx

.mdone:		 RST
.reset:
		LDA	#0
		STA	.x
		STA	.y
		RST
.flipy:
		LDA	.vy
		EOR	#%444
		STA	.vy

		LDA	.y
		LDX	#-121+.height/2
		LDY	#121-.height/2
		JSR	(jumpvector.between)
		STA	.y
		RST
.flipx:
		LDA	.vx
		EOR	#%444
		STA	.vx

		LDA	.x
		LDX	#-121+.width/2
		LDY	#121-.width/2
		JSR	(jumpvector.between)
		STA	.x

		RST

pause:
		PHX
		LDX	#%DDD
.loop:		INX
		JVC	.loop
		PLX
		RST
		
