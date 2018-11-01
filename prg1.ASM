%TITLE "Ваш комментарий программы"
INCLUDE IO.ASM

MODEL	small
.286   ; FOR POPA & PUSHA
ST1 SEGMENT             ;Описали сегмент стека;
	DB 128 DUP(?)
ST1 ENDS

DATA SEGMENT
	ERR_FileNotFound	DB	'Error. Input file not found.',13,10,'$'
	file_in_name		DB	'points.txt',0
	file_handler		DW	?	; хранит идентификатор файла
    revers dw ?
    collor dB ?
	scale_buff dw ?
	count_buff db ?
	
	
	line_collor db 3 ; Цвет линии
	figure_scale dw 5; Масштаб фигуры
	line_count   db 1 ; Количество внутренних линий
	
    k      dw ?
    error  dw ?
    x0    dw ? 
    y0    dw ? 
    x1    dw ? 
    y1    dw ? 
	x2	  dw ?
	y2    dw ? 	
    
    V  dw 100
       dw 100
       
       dw 300
       dw 150
       
       dw 100
       dw 200
       
       dw 3
       
	   dw 200
	   dw 200
       
       dw 300
       dw 400
       
       dw 100
       dw 200
	
	   dw 5
    
	negative dw ?
	point_count dw 0
	char_buffer_size	EQU	1000
	char_buffer		DB	char_buffer_size DUP(?)
	char_buffer_count	DW	0	; текущее число символов в буфере
	coords dw char_buffer_size DUP(?)
	coords_buff dw char_buffer_size DUP(?)
	dimention dw 2
DATA ENDS


CODE SEGMENT            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;
VIDEO_INIT MACRO
    mov  AX,12h
    int  10h        ; видеорежим 640x480
ENDM


PUTPIXEL MACRO x , y ,color
    pusha
    
    mov ah,0Ch ; функция рисования точки
    mov al, color ; цвет точки
    mov bh,0 ; видео страница
    mov cx, x ; координата X   
    mov dx, y ; координата Y
    int 10h ; вызов прерывания BIOS
    
    popa
ENDM

ASSIGNW MACRO A,B
	push B
	pop A
ENDM
SWAP MACRO A, B, C, D
    XCHG A, B
    XCHG C, D
ENDM

VARXCHG MACRO X, Y
    push x
    push y
    pop x
    pop y
ENDM

VARMOV MACRO X,Y
	PUSH Y
	POP X
ENDM

VARLINE proc ;x0, y0, x1, y1, color
    ;LOCAL L0, L1, L2, L3, L4, L5, L6 ,L7 ,L8, next, main
    pusha

    mov dx, x1 ; dx = dx
    sub dx, x0
    
    mov cx, 1
    cmp dx, 0
        jge L000
    xor cx,cx
    neg dx
L000: ; cx = (dx >=0 )? 1 : 0 ; 
    ; dx = |dx|
    
    mov ax, y1 ; ax = dy
    sub ax, y0
    
    mov bx, 1
    cmp ax, 0
        jge L001
    xor bx, bx
    neg ax
L001:; bx = (ax >=0)? 1 : 0 ;
   ; ax = |ax| 
    
    mov k, -1
    cmp cx, bx
        jne L003
    mov k,  1
L003:; k = (cx == bx)? 1 : -1 ;

    mov revers, 0
    
    cmp ax, dx ; if (dy > dx)
        jle L004
    XCHG ax, dx
    VARXCHG x0, y0
    VARXCHG x1, y1
    mov revers, 1
L004:
    
    
    mov bx, x0
    cmp bx, x1 ; if (x0 > x1)
        jle L005
    VARXCHG x0, x1
    VARXCHG y0, y1
L005:
     mov error, 0
     mov bx, k
main00:
    mov cx, x0 ; for(;x0<=x1; ++x0)
    cmp cx, x1
        jg next00
    
    cmp revers, 0 ; if (revers)
        jne L006
    PutPixel y0, x0, collor
    jmp L007
L006:
    PutPixel x0, y0, collor
L007: 
    add error, ax ; error += dy - наименьшее прирашение
    mov cx, error
    shl cx, 1     ; bx = 2*error
    
    cmp cx, dx  ; if ( 2*error > большего приращения)
        jle L008
    
    add y0, bx ; y0 +- 1
    sub error, dx ; error -= большее приращение 
       
L008:
    inc x0
    jmp main00   
next00:    
    POPA
    RET
    
VARLINE ENDP
	
	
	
LINE_ITERATOR MACRO 
	pusha
	
	push k
	push revers
	push error
	
	
	mov ax, x1  ; first pair of points
	mov bx, y1
	
	mov cx, x0
	mov dx, y0
	
	
	;mov x1, x2   ; second pair of points
	;mov y1, y2
	push x2
	pop  x1
	push y2
	pop  y1
	
	
	call VARLINE
	
	mov x1, ax ; return value
	mov y1, bx
	
	mov x0, cx
	mov y0, dx
	
	pop error
	pop revers
	pop k
	
	popa
ENDM

VARTRANGLE proc ;x0, y0, x1, y1, x2, y2, color
	; x2, y2 - вершина 
    ;LOCAL L0, L1, L2, L3, L4, L5, L6 ,L7 ,L8, next, main
    pusha

    mov dx, x1 ; dx = dx
    sub dx, x0
    
    mov cx, 1
    cmp dx, 0
        jge L100
    xor cx,cx
    neg dx
L100: ; cx = (dx >=0 )? 1 : 0 ; 
    ; dx = |dx|
    
    mov ax, y1 ; ax = dy
    sub ax, y0
    
    mov bx, 1
    cmp ax, 0
        jge L101
    xor bx, bx
    neg ax
L101:; bx = (ax >=0)? 1 : 0 ;
   ; ax = |ax| 
    
    mov k, -1
    cmp cx, bx
        jne L103
    mov k,  1
L103:; k = (cx == bx)? 1 : -1 ;

    mov revers, 0
    
    cmp ax, dx ; if (dy > dx)
        jle L104
    XCHG ax, dx
    VARXCHG x0, y0
    VARXCHG x1, y1
    mov revers, 1
L104:
    
    
    mov bx, x0
    cmp bx, x1 ; if (x0 > x1)
        jle L105
    VARXCHG x0, x1
    VARXCHG y0, y1
L105:
     mov error, 0
     mov bx, k
	 
main10:
    mov cx, x0 ; for(;x0<=x1; ++x0)
    cmp cx, x1

;=========================================
		jg next100
	jmp forLonJump
	
next100:
	jmp next10	
forLonJump:    

;==========================================
    cmp revers, 0 ; if (revers)
        je L106 ;; ISPRAVIL
	;==comit==========================================	
    
	;PutPixel y0, x0, collor ;before
	;comment *
	VARXCHG x0, y0 ; change pair
	
	LINE_ITERATOR

	VARXCHG x0, y0
	;*
    
	;=======================================================
	jmp L107
L106:
	;==comit============================================	
    
	;PutPixel x0, y0, collor ;before
	
	LINE_ITERATOR
	
	;=================================================
L107: 
	
    add error, ax ; error += dy - наименьшее прирашение
    mov cx, error
    shl cx, 1     ; bx = 2*error
    
    cmp cx, dx  ; if ( 2*error > большего приращения)
        jle L108
    
    add y0, bx ; y0 +- 1
    sub error, dx ; error -= большее приращение 
       
L108:
    inc x0
    jmp main10   
next10:    
    POPA
    RET
    
VARTRANGLE ENDP

TRANGLE_COOL_FILL MACRO  x_0, y_0, x_1, y_1, x_2, y_2, color
	mov x0, x_0
    mov y0, y_0
    mov x1, x_1
    mov y1, y_1
	mov x2, x_2
    mov y2, y_2
    mov collor, color 
	call VARTRANGLE
ENDM

TRANGLE_FILLED  MACRO x_0, y_0, x_1, y_1, x_2, y_2, color
	TRANGLE_COOL_FILL x_0 y_0, x_1 y_1, x_2 y_2 color
	TRANGLE_COOL_FILL x_2 y_2, x_0 y_0, x_1 y_1 color
	TRANGLE_COOL_FILL x_1 y_1, x_2 y_2, x_0 y_0 color
ENDM

LINE MACRO x_0, y_0, x_1, y_1, color
    mov x0, x_0
    mov y0, y_0
    mov x1, x_1
    mov y1, y_1
    mov collor, color
    call VARLINE
ENDM

RECTANGLE MACRO x_0, y_0, x_1, y_1, color
    line x_0 y_0 x_0 y_1 color
    line x_0 y_1 x_1 y_1 color
    line x_1 y_1 x_1 y_0 color
    line x_1 y_0 x_0 y_0 color
ENDM

;VECTOR ТИПА DW
LINELOOP MACRO VECTOR, LEN, COLOR ; reverve x&y
    LOCAL L0
    pusha
    
	mov bx, 2
	xor dx,dx 
	mov ax, len
	div bx

	
    mov cx, ax
    dec cx
    xor bx, bx
L0:    
    mov ax, VECTOR[bx+2]
    mov x0,  ax
    mov ax, VECTOR[bx]
    mov y0, ax
    mov ax, VECTOR[bx+6]
    mov x1, ax
    mov ax, VECTOR[bx+4]
    mov y1, ax
	mov al, COLOR
    mov collor, al
    CALL VARLINE
    add bx , 4
    loop L0
    
    popa 
ENDM

CLOSED_LINELOOP MACRO VECTOR, LEN, COLOR
LOCAL L0, L1
    pusha
    
    mov collor, COLOR
    mov cx, len
    
    mov dx, cx
    shl dx, 2; dx = длинна массива - 4
    sub dx, 4
    
    xor bx, bx
L0:    
    mov ax, VECTOR[bx]
    mov x0, ax
    mov ax, VECTOR[bx+2]
    mov y0, ax
    cmp bx, dx
        jne L1
    mov bx, -4
L1:
    mov ax, VECTOR[bx+4]
    mov x1, ax
    mov ax, VECTOR[bx+6]
    mov y1, ax
    CALL VARLINE
    add bx, 4
    loop L0

    popa 
ENDM
TRANGLE_FILLED_VECT MACRO V, LEN
LOCAL L0
	PUSHA
	mov cx, LEN
	xor bx, bx
L0:
	ASSIGNW X0 V[bx]
    ASSIGNW y0, v[bx+2]
    ASSIGNW x1, v[bx+4]
    ASSIGNW y1, v[bx+6]
	ASSIGNW x2, v[bx+8]
    ASSIGNW y2, v[bx+10]
 
	MOV ax , V[bx+12]
	mov collor, al

	
	call VARTRANGLE
	add bx, 14
	LOOP L0
	POPA
ENDM

ascii_to_dw MACRO INP, OUTP
LOCAL L0, L1, next
	pusha
	mov collor, 10
	mov revers, 0
	mov negative, 0
	mov cx, char_buffer_size
	xor si,si
	xor bx,bx
L0:
	cmp INP[bx] , '0'
		jl L1
	cmp INP[bx], '9'
		jg L1
	
	mov revers, 1
	pusha
	;from ascii to int
	xor cx,cx
	mov cl, INP[bx]
	sub cx, '0'
	
	xor ax,ax
	mov ax, OUTP[si]
	mul collor ; ax = dx*10
	
	mov OUTP[si] , ax
	add OUTP[si] , cx 
	
	popa
		jmp next
L1:
	cmp revers,1 
		jne next
	;Увеличиваем глобальную переменную 	
	inc point_count
	mov revers,0
	cmp negative, 1
		jne L2
	NEG OUTP[SI]
	MOV negative,0
L2:
		
	add si, 2
next:
	cmp INP[bx], '-'
		jne L3
	mov negative, 1	
L3:
	inc bx
	loop L0
	
	popa
ENDM

SCALE MACRO vect, ratio, len
LOCAL L0
pusha
	mov si, ratio
	mov cx, len
	xor bx,bx
L0:
	mov ax, vect[bx]
	mul si
	add ax, 200
	
	; разворот
	push dx
	mov dx, 400
	sub dx, ax
	
	mov vect[bx], dx
	
	pop dx
	
	
	add bx, 2
	loop L0
popa
ENDM

SCALE_In_BUFF MACRO vect, buff_vect, ratio, len
LOCAL L0
pusha
	mov si, ratio
	mov cx, len
	xor bx,bx
L0:
	mov ax, vect[bx]
	mul si
	add ax, 200
	
	; разворот
	push dx
	mov dx, 350
	sub dx, ax
	
	mov buff_vect[bx], dx
	
	pop dx
	
	
	add bx, 2
	loop L0
popa
ENDM

DRAW_CYCLE_LINELOOP MACRO coords_p, coords_buff_p, point_count_p, color_p, scale_p, count_p
	pusha
	VARMOV coords coords_p
	VARMOV coords_buff coords_buff_p
	VARMOV point_count point_count_p
	mov al, color_p
	mov collor, al
	
	VARMOV scale_buff, scale_p
	

	
	mov al, count_p
	mov count_buff, al
	
	call PROC_DRAW_CYCLE_LINELOOP
	popa
ENDM

;Отрисовка 20 контуров разной велечины
;Если передать в color cl, контур будет разноцветный 
PROC PROC_DRAW_CYCLE_LINELOOP;  coords, coords_buff, point_count, color
LOCAL 
	pusha
	
	xor cx, cx
	mov cl, count_buff
	
L3000:	
	;scale coords 10 point_count
	SCALE_In_BUFF coords coords_buff scale_buff point_count
	LINELOOP coords_buff point_count collor
	dec scale_buff
	loop L3000
	
	popa
	RET
PROC_DRAW_CYCLE_LINELOOP ENDP
; axis :      direction:
;    0 - x    0 - direct  
;	 1 - y	  1 - reverse
SHIFT MACRO vector, axis, direction,value , point_count
LOCAL L0, L1, L2
	pusha
	
	; si = value
	mov si, value
	
	xor bx, bx
	
	;If axis = y, then begin from 1 elem 
	mov ax, axis
	cmp ax, 1
		je L0
	add bx, dimention
L0:
	; if direction <0 then value = - value
	mov ax, direction
	cmp ax, 0
		je L1
	
	neg si
L1:
	mov cx, point_count
	shr cx, 1
	; cx = point_count div 2
L2:
	;go throught 2
	add vector[bx] , si
	add bx, dimention
	add bx, dimention
	
	loop L2
	
	
	popa
ENDM
; Обработка нажатия кнопок
; В AL лежит считанный символ
PROC BUTTON_PROCESSING
	pusha
	cmp al, 'w'
		jne L5000
	;Слон идет вверх
	SHIFT coords, 0,0,5,point_count
L5000:
	cmp al, 'a'
		jne L5001
	;Слон идет вево
	SHIFT coords, 1,0,5,point_count
L5001:
	cmp al, 's'
		jne L5002
	;Слон идет вниз	
	SHIFT coords, 0,1,5,point_count
L5002:
	cmp al, 'd'
		jne L5003
	;Слон идет вправо
	SHIFT coords, 1,1,5,point_count
L5003:
	; if ( al in [0,9] ) change color
	cmp al, '0'
		jl L5004
	cmp al, '9'
		jg L5004
	mov line_collor, al
L5004:		
	cmp al, '='
		jne L5005
	;Увеличиваем масштаб
	inc figure_scale
L5005:
	cmp al, '-'
		jne L5006
	;Уменьшаем масштаб
	dec figure_scale
L5006:	
	cmp al, ']'
		jne L5007
	;Увеличиваем кол-во линий
	inc line_count
L5007:
	cmp al, '['
		jne L5008
	cmp line_count, 1
		je L5008
	;Уменьшаем кол-во линий
	dec line_count
		
L5008:
	popa
	ret
BUTTON_PROCESSING ENDP
Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
    VIDEO_INIT
    
	
; открытие существующего файла
	mov	ah,3dh
	mov	al,0	; режим доступа: 0 чтение, 1 запись, 2 чтение-запись
	mov	dx,offset file_in_name	; задание адреса имени файла
	int	21h
	mov	file_handler,ax		; сохранение идентификатора файла

	jnc	SkipErrNotFound		; переход если файл существует

	; обработка ошибки: вывод ERR_FileNotFound на экран
	mov	ax,@data
	mov	dx,offset ERR_FileNotFound
	mov	ah,09h
	int	21h
	jmp	exitin

SkipErrNotFound:

; чтение из файла
	mov	ah,3fh			; 3fh для чтения, 40h для записи
	mov	bx,file_handler		; задание идентификатора файла
	mov	cx,char_buffer_size	; число считываемых байтов
	mov	dx,offset char_buffer	; задание адреса буфера ввода-вывода
	int	21h
	; ax - число фактически считанных(или записаннных) байтов

	mov	char_buffer_count,ax

; закрытие файла(иначе данные будут потеряны)
	mov  ah,3eh
	mov  bx,file_handler	; задание идентификатора закрываемого файла
	int  21h

	;TRANGLE_FILLED 100 100 300 150 100 200 3
	;TRANGLE_FILLED v[cx] v[cx+2] v[cx+4] v[cx+6] v[cx+8] v[cx+10] V_COLOR
	ascii_to_dw char_buffer, coords
	comment *
	mov bx, 2
	xor dx,dx 
	mov ax, point_count
	div bx
	mov point_count, ax
	*
	
	;оьтрисовываем первый раз
	DRAW_CYCLE_LINELOOP coords, coords_buff, point_count, line_collor, figure_scale, line_count
	
Knopk:	
	mov	ah,	1
	int	21h                                   
	; ждем нажатия кнопки
	;Зарисовываем предыдущий рисунок

	DRAW_CYCLE_LINELOOP coords, coords_buff , point_count, 0 ,figure_scale, line_count
	
	call BUTTON_PROCESSING
	
	cmp	al,	1bh  ; ascii code of input character ; Если это Escape , то выходим в меню
		je	exitin
	
	DRAW_CYCLE_LINELOOP coords, coords_buff, point_count, line_collor,figure_scale, line_count
	
	jmp	Knopk	
	
	;TRANGLE_FILLED_VECT coords  point_count
exitin:
;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish
ENDS

END	Start
