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
	mov	ax,0013h
	int	10h

; символ
	; перемещение курсора
	mov	ah,02h		; тип прерывания
	mov	bh,0		; видео страница
	mov	dh,10		; (y) строка (0..24; 25 делает курсор невидимым)
	mov	dl,10		; (x) колонка (0..79)
	int	10h		; прерывание на перемещение курсора
	; вывод символа на текущее положение курсора
	mov	ah,09h		; тип прерывания
	mov	al,'O'		; символ (ASCII code)
	mov	cx,1		; кол-во экземпляров символа записать
	mov	bl,80		; цвет (0..127)
	int	10h		; прерывание на вывод символа

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