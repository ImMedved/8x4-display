	.org 0x00
	rjmp setup


	.org 0x50
setup:
	ser r16
	out ddrd, r16
	out portd, r16

	out ddrb, r16
	out portb, r16

	out portc, r16

	clr r16

	out ddrc, r16
	

	//temp

	ldi r16, 0b00000000
	mov r0, r16

	ldi r16, 0b00000000
	mov r1, r16

	ldi r16, 0b00000000
	mov r2, r16

	ldi r16, 0b00000000
	mov r3, r16

	ldi r22, 0b00000010		//pos
	ldi r23, 0b00000011		//num

	ser r21					//flags

	jmp loop


//////////////////////////

timer:
	clr r25
	clr r24

timer_loop:
	inc r24

	cpi r24, 0xff
	breq timer_r25_inc
timer_after_comparison:

	cpi r25, 0x20
	breq timer_end

	rjmp timer_loop

timer_r25_inc:
	inc r25
	rjmp timer_after_comparison

timer_end:
	ret

//////////////////////////


draw:
	cbi portb, 2
	mov r16, r0
	call draw_digit
	call timer
	sbi portb, 2

	cbi portb, 3
	mov r16, r1
	call draw_digit
	call timer
	sbi portb, 3

	cbi portb, 4
	mov r16, r2
	call draw_digit
	call timer
	sbi portb, 4
	
	cbi portb, 5
	mov r16, r3
	call draw_digit
	call timer
	sbi portb, 5

	ret

draw_digit:
	out portd, r16
	andi r16, 0b00000011
	in r17, portb
	andi r17, 0b11111100
	add r17, r16
	out portb, r17
	ret

//////////////////////////

update_table:
	ldi r16, 0b11111011
	and r0, r16
	and r1, r16
	and r2, r16
	and r3, r16
	ldi r16, 4

	sbrc r22, 0
	rjmp update_digit_0

	sbrc r22, 1
	rjmp update_digit_1

	sbrc r22, 2
	rjmp update_digit_2

	sbrc r22, 3
	rjmp update_digit_3

	ret

update_digit_0:
	ldi r31, 0x03
	mov r30, r23

	lsl r30
	rol r31

	lpm r0, Z
	
	or r0, r16

	ret

update_digit_1:
	ldi r31, 0x03
	mov r30, r23

	lsl r30
	rol r31

	lpm r1, Z
	
	or r1, r16

	ret
	
update_digit_2:
	ldi r31, 0x03
	mov r30, r23

	lsl r30
	rol r31

	lpm r2, Z
	
	or r2, r16

	ret

update_digit_3:
	ldi r31, 0x03
	mov r30, r23

	lsl r30
	rol r31

	lpm r3, Z
	
	or r3, r16

	ret

//////////////////////////

detect_input:
	sbic pinc, 0
	call left
	sbic pinc, 1
	call right
	sbic pinc, 2
	call up
	sbic pinc, 3
	call down

	sbis pinc, 0
	ori r21, 0b00000001
	sbis pinc, 1
	ori r21, 0b00000010 
	sbis pinc, 2
	ori r21, 0b00000100
	sbis pinc, 3
	ori r21, 0b00001000

	ret

left:
	sbrs r21, 0
	ret
	ror r22
	andi r21, 0b11111110

	cpi r22, 0x00
	breq pos_bottom_bound

	ret

pos_bottom_bound:
	ldi r22, 0b00000001
	ret

right:
	sbrs r21, 1
	ret
	rol r22
	andi r21, 0b11111101

	sbrc r22, 4
	ldi r22, 0b00001000

	ret

up:
	sbrs r21, 2
	ret
	inc r23
	andi r21, 0b11111011

	cpi r23, 10
	breq num_upper_bound

	ret

num_upper_bound:
	ldi r23, 0b00001001
	ret

down:
	sbrs r21, 3
	ret
	dec r23
	andi r21, 0b11110111

	sbrc r23, 7
	ldi r23, 0b00000000

	ret

//////////////////////////

loop:
	call update_table
	
	call draw

	call detect_input

	rjmp loop


end:
	rjmp end


.org 0x0300
.db 0b11101011,0
.db 0b00101000,0
.db 0b10110011,0
.db 0b10111010,0
.db 0b01111000,0
.db 0b11011010,0
.db 0b11011011,0
.db 0b10101000,0
.db 0b11111011,0
.db 0b11111010,0