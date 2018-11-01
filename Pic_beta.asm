%TITLE "Ваш комментарий программы" 
.286
INCLUDE IO.ASM

MODEL	small

ST1 SEGMENT             ;Описали сегмент стека;
	DB 1280 DUP(?)
ST1 ENDS

DATA SEGMENT
x0 dw ?
y0 dw ?
x1 dw ?
y1 dw ?
x2 dw ?
y2 dw ?


color dw ?
;переменные макроса Parallelogram


xparal dw ?
yparal dw ?


;переменные процедуры lineto
xline dw ?
yline dw ?
x1line dw ?
y1line dw ?
x2line dw ?
y2line dw ?
iline  dw ?
mnline dw ?
znakxline dw ?
znakyline dw ?
kolvoline dw ?
Kolvo1lineto dw ? 

two dw 2

;== dr ==
    xl dw 0
    yl dw 0
    xc dw 0
    yc dw 0
    xc2 dw 0
    yc2 dw 0
    
;==

;==== files ==
    file_in_name	DB	'file_in.txt',0
    file_handler	DW	?	; хранит идентификатор файла
    
    char_buffer_size	EQU	10 ;                    размер массива
    char_buffer		DB	char_buffer_size DUP(?)
    char_buffer_count	DW	0
    
    ten dw 10
    negative dw ?
    revers dw ?
    point_count dw 0;
    
    OUTP DW char_buffer_size DUP(-1)

DATA ENDS

CODE SEGMENT            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;

LineX PROC FAR

	push	bp
	mov	bp,sp

	mov ax, [bp+6]
	mov color,ax
	mov ax, [bp+8]
	mov y2line,ax
	mov ax, [bp+10]
	mov x2line,ax
	mov ax, [bp+12]
	mov y1line,ax
	mov ax, [bp+14]
	mov x1line,ax
	
	PUSHA
	mov bx,x1line
	cmp bx,x2line
	jle linexZ1
	
	mov ax, x2line
	mov x2line, bx
	mov x1line, ax
	mov ax, y2line
	mov bx, y1line
	mov y2line, bx
	mov y1line, ax
	
	mov znakyline,1
	
linexZ1:
	
	mov bx,x1line		
	mov xline,bx
	mov cx,x2line		;если x2 координата больше
	sub cx,x1line
	add cx,1
	mov iline,cx
	mov kolvoline, cx
	mov mnline,0		; строимая точка
	
	
	mov cx,iline
linexZ2:
	jcxz linexend
	mov iline, cx
	mov ax,y2line
	sub ax,y1line
	cmp ax,0
	jge linexL1
	neg ax
	mov znakyline,-1
linexL1:
	mul mnline
	xor dx,dx
	div kolvoline
	cmp znakyline,-1
	jne linexL2
	neg ax
linexL2:
	add ax,y1line
	mov dx,ax
	mov cx,xline
	add cx,mnline
	add mnline,1
	mov ax, color
	mov ah,0Ch			; Функция рисования точки	
	mov bx,0			; видеостраница
	int 10h 			; вызов прерывания BIOS
	mov cx, iline
	Loop linexZ2
linexend:	
	POPA
	pop 	bp
	ret	10
 linex Endp
 
LineY PROC FAR

	push	bp
	mov	bp,sp

	mov ax, [bp+6]
	mov color,ax
	mov ax, [bp+8]
	mov y2line,ax
	mov ax, [bp+10]
	mov x2line,ax
	mov ax, [bp+12]
	mov y1line,ax
	mov ax, [bp+14]
	mov x1line,ax
	
	PUSHA
	
	mov bx,y1line
	cmp bx,y2line
	jle LineYZ1
	
	mov ax, y2line
	mov y2line, bx
	mov y1line, ax
	mov ax, x2line
	mov bx, x1line
	mov x2line, bx
	mov x1line, ax
	
	mov znakxline,1
	
LineYZ1:
	
	mov bx,y1line		
	mov yline,bx
	mov cx,y2line		;если x2 координата больше
	sub cx,y1line
	add cx,1
	mov iline,cx
	mov kolvoline, cx
	mov mnline,0		; строимая точка
	
	
	mov cx,iline
LineYZ2:
	jcxz LineYend
	mov iline, cx
	mov ax,x2line
	sub ax,x1line
	cmp ax,0
	jge LineYL1
	neg ax
	mov znakxline,-1
LineYL1:
	mul mnline
	xor dx,dx
	div kolvoline
	cmp znakxline,-1
	jne LineYL2
	neg ax
LineYL2:
	add ax,x1line
	mov cx,ax
	mov dx,yline
	add dx,mnline
	add mnline,1
	mov ax, color
	mov ah,0Ch			; Функция рисования точки	
	mov bx,0			; видеостраница
	int 10h 			; вызов прерывания BIOS
	mov cx, iline
	Loop LineYZ2
LineYend:	
	POPA
	pop 	bp
	ret	10
 liney Endp

cls     macro  color                                                        
    PUSHA                                                   
		mov     ax,0600h        ; Номер функции "скроллинг"            
        mov     bx,color           ; Атрибут экрана
		shl		bx,8
        mov     cx,0000         ; Левая верхняя позиция курсора        
        mov     dx,184Fh        ; Правая нижняя                        
        int     10h                                                    
	Popa                                                   
endm    cls  

LineTo Macro X1, Y1, X2, Y2, color
LOCAL L1, L2, L3, L4, endmacros
	PUSHA
	mov ax, x2
	sub ax, x1
	cmp ax, 0
	jge L1
	neg ax
L1:
	mov Kolvo1lineto, ax
	
	mov ax,y2
	sub ax,y1
	cmp ax,0
	jge L2
	neg ax
L2: 
	cmp Kolvo1lineto, ax
	jle L3
	jmp L4
L3:
	push x1
	push y1
	push x2
	push y2
	push color
	Call LineY 
	jmp endmacros
L4:
	push x1
	push y1
	push x2
	push y2
	push color
	Call LineX 
endmacros:	
	POPA
	Endm
	
rectangle Macro X1, Y1, X2, Y2, color
PUSHA
LineTo x1 y2 x2 y2 color
LineTo x2 y2 x2 y1 color
LineTo x2 y1 x1 y1 color
LineTo x1 y1 x1 y2 color
POPA
Endm



treygol Macro X1, Y1, X2, Y2, X3, Y3, color
PUSHA
LineTo x1 y1 x2 y2 color
LineTo x2 y2 x3 y3 color
LineTo x1 y1 x3 y3 color
POPA
Endm

parallelogram Macro X1, Y1, X2, Y2, X3, Y3, color
PUSHA
LineTo x1 y1 x2 y2 color
LineTo x2 y2 x3 y3 color
mov ax,x1
add ax,x3
sub ax,x2
mov xparal,ax
mov ax,y1
add ax,y3
sub ax,y2
mov yparal,ax
LineTo x1 y1 xparal yparal color
LineTo xparal yparal x3 y3 color
POPA
Endm

;===== files ====
file_reading proc
    pusha
                ; открытие существующего файла
        mov	ah,3dh
        mov	al,0	; режим доступа: 0 чтение, 1 запись, 2 чтение-запись
        mov	dx,offset file_in_name	; задание адреса имени файла
        int	21h
        mov	file_handler,ax		; сохранение идентификатора файла

        jc	proc_end		; переход если файл существует

        ; обработка ошибки: вывод ERR_FileNotFound на экран
    

    

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
  proc_end:      
    popa
    ret
file_reading endp
;--------------------


proc_ascii_to_dw PROC ;char_buffer, OUTP

  pusha
        mov ten, 10
        mov revers, 0
        mov negative, 0
        mov cx, char_buffer_size
        xor si,si
        xor bx,bx
        L0:
        cmp char_buffer[bx] , '0'
            jl L1
        cmp char_buffer[bx], '9'
            jg L1
        
        mov revers, 1
        pusha
        ;from ascii to int
        xor cx,cx
        mov cl, char_buffer[bx]
        sub cx, '0'
        
        xor ax,ax
        mov ax, OUTP[si]
        mul ten ; ax = dx*10
        
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
        cmp char_buffer[bx], '-'
            jne L3
        mov negative, 1  
        L3:
        inc bx
        loop L0
    
  popa
  
  ret
proc_ascii_to_dw endp;



;--------- MA $$ --------------------------------------
filled_rectangle Macro x0, y0, x1, y1, color     ;****
local ex, internal
PUSHA
;mov bx, y0

;Drw:
;    LineTo x0, bx, x1, bx, color
;    inc bx
;    cmp bx, y1
;        jle Drw

; точка
	mov	ah,0ch		; тип прерывания
	mov	al, byte ptr color		; цвет (0..127)
	
	mov cx, x0
	mov dx, y0
	
	
ex:
    mov cx, x0; сначала
    internal: int 10h
                inc cx
                cmp cx, x1
                    jle internal;
                
    inc dx
    cmp dx, y1
        jle ex;
        
POPA
endm;
;-----------------------------------------------------
draw_left_quater Proc 
    pusha
     ; xl yl
     
     mov ax, xl ;     red
     add ax, 11
     mov xc, ax
     
     mov ax, yl
     add ax, 3
     mov yc, ax
     
     mov ax, xl
     add ax, 20
     mov xc2, ax
     
     mov ax, yl
     add ax, 14
     mov yc2, ax
     
     filled_rectangle xc, yc, xc2, yc2, color; через регистры - не работает
     


     sub xc, 6
     add yc, 12
     sub xc2, 11
     sub yc2, 10
    
    mov cx, 2
ll:
     LineTo xc, yc, xc2, yc2, color
     inc xc
     inc xc2
Loop ll;

    dec yc
    ;dec yc2
    mov cx, 4
lll:
     LineTo xc, yc, xc2, yc2, color
     inc xc
     inc xc2 ; left part of the left quarter ends
Loop lll;    
;---------
    mov ax, xl ; right
    add ax, 17
    mov xc, ax
    
    mov ax, xc
    add ax, 3
    mov xc2, ax
    
    mov ax, yl
    add ax, 15
    mov yc, ax
    
    LineTo xc, yc, xc2, yc, color;
    add xc, 2
    
    mov ax, yc
    inc ax
    mov yc2, ax
    
    LineTo xc, yc, xc, yc2, color  ; right bottom of the red
    
    
    add xc, 2
    sub yc, 5
    sub yc2, 13
    
    mov cx, 3
llll: ;// right
     LineTo xc, yc, xc, yc2, color
     inc xc
     sub yc, 2
     inc yc2
Loop llll; 

 popa
ret
draw_left_quater Endp;
;-----------------------------------------------------
draw_right_quarter PROC ; *********
pusha
    ;относительно левого верхнего угла
    
     mov ax, xl
     add ax, 25
     mov xc, ax
     
     mov ax, yl
     add ax, 8
     mov yc, ax
     
     mov ax, xl
     add ax, 35
     mov xc2, ax
     
     mov ax, yl
     add ax, 19
     mov yc2, ax
     
     filled_rectangle xc, yc, xc2, yc2, color; через регистры - не работает
     
     mov ax, xl ; left side
     add ax, 22
     mov xc, ax
     
     mov ax, yc2
     dec ax
     mov yc, ax
    
    
     ;sub yc2, 5
     mov ax, yl
     add ax, 15
     mov yc2, ax
     
     
     mov cx, 3
vertical:
    LineTo xc, yc, xc, yc2, color
    sub yc2, 3
    inc xc
loop vertical

    ;--- bottom
    add xc, 2
    
    mov ax, xc
    add ax, 7
    mov xc2, ax
    
    add yc, 2
LineTo xc, yc, xc2, yc, color

    ;---- right ---
    add xc2, 2
    sub yc, 3
    
    mov ax, yc
    sub ax, 10
    mov yc2, ax
    
    mov cx, 4
vertical2:
    LineTo xc2, yc, xc2, yc2, color
    sub yc, 3
    inc xc2
Loop vertical2
    ; --- horizontal (top)
    mov ax, xl
    add ax, 25
    mov xc, ax
    
    mov ax, xc
    inc ax
    mov xc2, ax
    
    mov ax, yl
    add ax, 6
    mov yc, ax
    
    LineTo   xc, yc, xc2,yc, color
    
    add xc2, 2
    inc yc
    LineTo   xc, yc, xc2,yc, color
    
    
popa
ret
draw_right_quarter endP

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Draw_Windows macro  corner_x, corner_y;
    pusha
        ;---- left --------------------------
    mov ax, corner_x
    mov xl, ax          ; RED
    
    mov ax, corner_y
    mov yl, ax
    
    mov color, 40;
    call draw_left_quater;
    ;-----------
    sub xl, 4  ;            ;BLUE
    add yl, 14 
    
    mov color, 55
    call draw_left_quater
    ;---------------------- right ----------
     mov ax, corner_x
    mov xl, ax          ; GREEN
    
    mov ax, corner_y
    mov yl, ax
    
    mov color, 47
    call draw_right_quarter;
    ;------------------------
	sub xl, 4  ;            ;       YELLOW
    add yl, 14 
    
    mov color, 68
    call draw_right_quarter;
    
    popa
endm

;--------------------------
Hide_Windows macro corner_x, corner_y;
    pusha
    
    mov ax, corner_x
    mov xl, ax          ; RED
    
    mov ax, corner_y
    mov yl, ax
    
    mov color, 0;
    call draw_left_quater;
    ;-----------
    sub xl, 4  ;            ;BLUE
    add yl, 14 
    
    mov color, 0
    call draw_left_quater
    ;---------------------- right ----------
     mov ax, corner_x
    mov xl, ax          ; GREEN
    
    mov ax, corner_y
    mov yl, ax
    
    mov color, 0
    call draw_right_quarter;
    ;------------------------
	sub xl, 4  ;            ;       YELLOW
    add yl, 14 
    
    mov color, 0
    call draw_right_quarter;
    
    popa
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
	mov  ax,0013h		;переходим в гр. режим 320*200
    int  10h

	
	cls 0 ; цвет фона
	
;\\\\\\\\\\\\\\\\\ startng	\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    
    ;---- reading ----
        call file_reading;
        
        call proc_ascii_to_dw    
    ;===============

    mov bx, 0
Infinite_cycle:
    cmp bx, 0
        je go_
    
    Hide_Windows OUTP[bx-4], OUTP[bx-2]
    
go_:   cmp OUTP[bx], -1
        jne Show
    
    mov bx, 0;
        
        
        
        
    Show:   mov si, bx
            add si, 2
            Draw_Windows OUTP[bx], OUTP[si]
   
                ; ожидание нажатия любой клавиши
                xor	ax,ax
                int	16h
            
        
    add bx, 4
    jmp Infinite_cycle
    
	exitin:
;\\\\\\\\\\\\\\\\\\ stopping \\\\\\\\\\\\\\\\\\\\\\\\\\
; ожидание нажатия любой клавиши
	xor	ax,ax
	int	16h
; завершение EGA режима, переход в текстовый
	mov	ax,0003h
	int	10h
; завершение программы
	mov	ax,4c00h
	int	21h


;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish
ENDS

END	Start
