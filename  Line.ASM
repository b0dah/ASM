MODEL	small

ST1 SEGMENT             ;���ᠫ� ᥣ���� �⥪�;
	DB 128 DUP(?)
ST1 ENDS

DATA SEGMENT
    x0 dw ?
    x1 dw ?
    y0 dw ?
    y1 dw ?
    color dw ?
; -- for LineTo
    deltax dw ?
    deltay dw ?
    error0 dw ?
    deltaerror dw ?
    directiony dw 1
    x dw ?
    y dw ?
    
DATA ENDS

CODE SEGMENT            ;���뫨 ᥣ���� ����;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;�易�� ॣ���஢� ᥣ����� � ᥣ���⠬�;
; ==================================
LineTo macro x0, y0, x1, y1, color
local draw, next, go_bottom
;PUSHA
push ax
push bx
push cx
push dx
        mov	ah,0ch		; ⨯ ���뢠���
        mov	al, color		; 梥� (0..15)
        
        mov bx, x1
        sub bx, x0
        mov deltax, bx ; deltax = x1 - x0
        
        mov bx, y1
        sub bx, y0
        mov deltay, bx ; deltay = y1 - x0
        
        mov error0, 0;
        
        mov bx, deltay
        mov deltaerror, bx ; deltaerror = deltay
        
        mov bx, y0
        mov y, bx ;  y -> y0
    ; --- direction y --
        mov bx, y1
        sub bx, y0
        cmp bx, 0
            jge go_bottom
            
        mov directiony, -1
        
    go_bottom:
        mov bx, x0
        mov x, bx; x -> x0
        
draw:   mov	cx, x		; ���न��� �� x (0..319)
        mov	dx, y		; ���न��� �� y (0..199)
        int	10h		; ���뢠��� �� �뢮� ���ᥫ�
    
        mov bx, deltaerror
        add error0, bx
        
        ;----------
        mov bx, error0
        add bx, bx
        
        cmp bx, deltax
            jl next
            
        mov bx, directiony
        add y, bx ; INC Y
        
        mov bx, deltax
        sub error0, bx
        
        ;----------
        
    next:
        inc x
        
    mov bx, x1 ; cond of exitin
    cmp x, bx
        jle draw;
	
;POPA
push dx
push cx

push bx
push ax


endm
;===================================
Start:
	push	ds
	push	ax

	mov	ax, data	
	mov	ds, ax
;

; ��⠭���� EGA ����� ०���
	;mov ax, 13h
	mov	ax,0012h
	int	10h

; �窠
	mov	ah,0ch		; ⨯ ���뢠���
	mov	al,10		; 梥� (0..127)
	mov	cx,600		; ���न��� �� x (0..319)
	mov	dx,100		; ���न��� �� y (0..199)
	int	10h		; ���뢠��� �� �뢮� ���ᥫ�
	
    LineTo 200, 100, 400, 200, 10
	
;=========== horizontal line ==========	
	mov dx, 100
	mov cx, 0
	
draw1:
    int 10h
    inc cx
    
    cmp cx, 640
        jle draw1;
;======= end of horizontal line

exitin:
; �������� ������ �� ������
	xor	ax,ax
	int	16h
; �����襭�� EGA ०���, ���室 � ⥪�⮢�
	mov	ax,0003h
	int	10h
; �����襭�� �ணࠬ��
	mov	ax,4c00h
	int	21h

;
	pop	ax
	pop	ds

ENDS

END	Start
