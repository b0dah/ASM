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

Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
	mov  ax,0013h		;переходим в гр. режим 320*200
    int  10h
	
	;parallelogram   40 170 1 1 90 100 120
	
	cls 0 ; цвет фона
	mov cx,15
	mov x0,300
F1:	
	;parallelogram 30, x0, 60, 30, 60, 60, 120
	lineto  200 x0 100 100 100
	add x0,15
	Loop F1
	
	
	
	
	inint ax;
;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish
ENDS

END	Start
