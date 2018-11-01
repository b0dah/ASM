MODEL	small

ST1 SEGMENT             ;Описали сегмент стека;
	DB 128 DUP(?)
ST1 ENDS

DATA SEGMENT

DATA ENDS

CODE SEGMENT            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;

Start:
	push	ds
	push	ax

	mov	ax, data	
	mov	ds, ax
;

; установка EGA видео режима
	;mov ax, 13h
	mov	ax,12h
	int	10h

; точка
	mov	ah,0ch		; тип прерывания
	mov	al,10		; цвет (0..127)
	;mov	cx,100		; координата по x (0..319)
	;mov	dx,100		; координата по y (0..199)
	;int	10h		; прерывание на вывод пикселя
	
	
	mov dx, 100
	mov cx, 100
	
draw:
    int 10h
    inc cx
    
    cmp cx, 500
        jle draw;

exitin:
; ожидание нажатия любой клавиши
	xor	ax,ax
	int	16h
; завершение EGA режима, переход в текстовый
	mov	ax,0003h
	int	10h
; завершение программы
	mov	ax,4c00h
	int	21h

;
	pop	ax
	pop	ds

ENDS

END	Start
