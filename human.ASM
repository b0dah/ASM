comment *
Ибрагимов Беслан 2 курс 22 группа 2018 год
Программа:
Человек осуществляет движение влево,вправо и прыжок, поднимает левую руку и открывает дверь.
Положение двери, ее цвет и цвет кожи человека задается цифрами в меню "Параметры" или нажатием Enter(значения поумолчанию).
Данные сохраняются в файл. При появлении человека и двери, их положение и цвет задаются, исходя из последних данных(Даже при повторном запуске программы).
Информация по упрвлении им находится в пункте меню "Помощь".
*
TITLE "Ваш комментарий программы"

INCLUDE IO.ASM

MODEL	small

ST1 SEGMENT             ;Описали сегмент стека;
	DB 128 DUP(?)
ST1 ENDS

DATA SEGMENT public

max DB  12
len DB ?
pole db 12 dup ('$')   				; или ('$'),если при нормальном выводе строки в досе , или (?),но, если при этом вывести строку введенную нами в досе, выведется непонятно что
		                               	; Впринципе в файл все равно запишется то, что нужно нам. Но на всякий случай, лучше поставить ($)
read1 db 12 dup('$')

r 	 dw ?                       		; радиус прорисовываемой окружности
x1 	 dw ?                     		; координаты квадрата, внутри которого наш круг(это х1)
x2 	 dw ?
y1 	 dw ?
y2 	 dw ?
kv1 	 dw ?                     		; это значение квадратов радиуса круга и его координат
kv2 	 dw ?
kvr 	 dw ?
vosst1   dw ?                  			; значение восстановления,т.е значение, на которое надо опустить круг , чтобы его центр был в (0,0) и была бы применима формула x^2 + y^2 = r^2
vosst2   dw ?                			; vosst1 - значение восстановления по x , vosst2 - значение восстановления по y
nachaly1 dw ?                			; это то начальное значение у1 с которым идем в процедуру. Оно нужно ,что бы восстановить это значение, а то в процедуре оно менялось.
xr1 	 dw ?
xr2 	 dw ?
yr1 	 dw ?
yr2 	 dw ?
color 	 db ?
kolL 	 dw 0
kolR 	 dw 0
colorhead db 66
colordoor db 68
Doorx1 dw	240
Doorx2 dw	255 
Doory1 dw	30 
Doory2 dw	200
two	dw 	2 
positions dw ?
buffer dw 0

chis dw 0
ten db 10

message  db '   1. Пуск',13,10
	 db '   2. Настройка',13,10
	 db '   3. Помощь',13,10
	 db '   4. Выход$'

message1 db 'перемешение: d-вправо,a-влево',13,10,10
	 db 'Shift+d-открывается дверь и рот человека(он удивлен)',13,10,10
	 db 'Shift+a-дверь закрывается',13,10,10
	 db 'Shift+w-поднимается левая рука',13,10,10
	 db 'Space-прыжок ',13,10,10
	 db 'Shift+s-опускается левая рука',13,10,10
	 db 'При приближении к двери и поднятии руки  автоматически открывается дверь$'

message2 db 'Введите цвет кожи:$'
message3 db 'Введите цвет двери:$'
message4 db 'Введите положение двери(в порядке:x1,x2,y1,y2):$'


error db 'ERROR!!!$'

names    db 'human.txt',0

DATA ENDS


CODE SEGMENT public            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;

Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
macrorect macro xrh1,xrh2,yrh1,yrh2,colorh
	local	Normal1,Normal2

	mov	bl,	colorh
	mov	color,	bl

	mov	bl,	color           ; смотрим, мы рисуем кожу
	mov	bh,	0
	cmp	bx,	66              ; если да, то меняем ее цвет в соответствии с установленным значением
	jne	Normal1
	mov	bl,	colorhead
	mov	color,	bl
	jmp	Normal2	

Normal1:                                ; если нет, то смотрим, мы рисуем двеь
	cmp	bx,	68
	jne	Normal2
	mov	bl,	colordoor       ; если да, то меняем ее цвет в соответствии с установленным значением	
	mov	color,	bl
Normal2:                                ; в результате измененное значение цвета color
	mov	si,	xrh1
	mov	xr1,	si
	mov	si,	xrh2
	mov	xr2,	si            ; теперь устанавливаем координаты прямоугольника
	mov	si,	yrh1
	mov	yr1,	si
	mov	si,	yrh2
	mov	yr2,	si
	call	rectangle               ; вызываем процедуру рисования прямоугольника
endm
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
macrocircle macro rc1,xc1,xc2,yc1,yc2,vosst1c,vosst2c,colorc
	local	Norm1

	mov	bl,	colorc
	mov	color,	bl

	mov	bl,	color         ; смотрим, мы рисуем кожу
	mov	bh,	0
	cmp	bx,	66            ; если да, то меняем ее цвет в соответствии с установленным значением
	jne	Norm1
	mov	bl,	colorhead
	mov	color,	bl
                                      ; в результате измененное значение цвета color
Norm1:	
	mov	si,	rc1
	mov	r,	si           ; устанавливаем радиус круга
	mov	si,	xc1
	mov	x1,	si           ; устанавливаем координаты прямоугольника, в который будет вписан круг
	mov	si,	xc2
	mov	x2,	si
	mov	si,	yc1
	mov	y1,	si
	mov	si,	yc2
	mov	y2,	si
	mov	si,	vosst1c
	mov	vosst1,	si       ; устанавливаем значение восствановления координат для использовании формулы круга
	mov	si,	vosst2c
	mov	vosst2,	si
	call	circle	             	

endm
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Obrabotka1 macro
	push	ax
	push	ax

	mov	bx,	ax
	mov	ah,	42h
	mov	cx,	0
	mov	dx,	positions
	mov	al,	0
	int	21h

	pop	ax

	mov	bx,	ax              ; в bx дескриптор файла
	mov	ah,	3fh             ; режим чтения из файла
	Lea	dx,	read1           ; адрес буфера данных, куда посимвольно будут записываться прочитанные данные
	mov	cl,	4	        ; количество байт, которое нужно прочитать
	mov	ch,	0
	int	21h                     ; результат в ax - реально прочитанное количество байтов
	call	strtoint
endm
;------------------------------------------------------------------------------------------------------------------------------------------------------------
        mov  ax,0013h			;переходим в гр. режим 320*200
        int  10h
	
	mov	ah,	0BH     	; говорим, что сейчас будем устанавливаем цвета
	mov	bx,	00      	; номер видео страницы (палитра , цвет и тд) По умолчанию 00
	int	10h
;------------------------------------------------------------------------------------------------------------------------------------------------------------
;###################################################################################################################
Menu:	
	macrorect 0,320,0,200,0         ; очищаем экран
	
	mov	ah,	02              ; устнавливаем позицию курсора(опускаем ее)
	mov	bh,	00
	mov	dh,	10
	mov	dl,	0
	int	10h
	
	mov	ah,	9               ; выводим пункты меню
	LEA	dx,	message
	int	21h 
	jmp	Menu2
;-------------------------
Menu1:	jmp	Menu
;-------------------------	
Menu2:	mov	ah,	02              ; восстанавливаем позицию курсора 
	mov	bh,	00
	mov	dh,	0
	mov	dl,	0
	int	10h		

	mov	ah,	1               ; ждем нажатия символа одного из пунктов меню
	int	21h

	macrorect 0,320,0,200,0         ; очищаем экран
	
	cmp	al,	31h             ; если мы нажали "1", то запускаем нашего человечка
	jne	No1
	jmp	Main
No1:	cmp	al,	32h             ; если "2", то с помощью файлов настраиваем цвета(кожи головы и двери.Для примера пока так)
	je	file01
	cmp	al,	33h             ; если "3", то выводим информацию об управлении
	jne	No2
	jmp	help
No2:	cmp	al,	34h             ; если "4", то выходим из программы
	jne	Menu1
	jmp	Ex2	
;###############################################################################################################	
;------------------------------------------------------------------------------------------------------------------------------------------------------------
mainhuman macro hrad,hx1,hx2,hy1,hy2,hvosst1,hvosst2,hcolor
	
	macrocircle hrad,hx1,hx2,hy1,hy2,hvosst1,hvosst2,hcolor         		 ; голова         		(17,110,144,50,84,127,67,66)
	                                                 
	macrorect hx1-5,hx2+7,hy1+3,hy2-26,24                      		 ; низ шляпы            	(105,151,53,58,24)

	macrorect hx1+2,hx2,hy1-17,hy2-31,24                      		 ; верх шляпы           	(112,144,33,53,24)

	macrorect hx1-6,hx2+6,hy1+34,hy2+56,33                     	         ; тело                 	(104,150,84,140,33)

	macrocircle hrad-13,hx1+7,hx2-19,hy1+8,hy2-18,hvosst1-6,hvosst2-5,15	         ; правый глаз          	(4,117,125,58,66,121,62,15)

	macrocircle hrad-13,hx1+22,hx2-4,hy1+8,hy2-18,hvosst1+9,hvosst2-5,15	         ; левый глаз           	(4,132,140,58,66,136,62,15)

	macrorect hx1+11,hx2-20,hy1+11,hy2-20,0                      	  	 ; правый зрачок        	(121,124,61,64,0)
	                                                                           
	macrorect hx1+26,hx2-5,hy1+11,hy2-20,0                      		 ; левый зрачок         	(136,139,61,64,0)
	                                                                                     
	macrorect hx1+18,hx2-12,hy1+25,hy2-8,0                    		 ; рот                  	(128,132,75,76,0)

	macrorect hx1-1,hx2-19,hy1+90,hy2+106,24                  		 ; правая одежда ноги   	(109,125,140,190,24)

	macrorect hx1+19,hx2+1,hy1+90,hy2+106,24                  		 ; левая одежда ноги    	(129,145,140,190,24)

	macrorect hx1+21,hx2-2,hy1+140,hy2+116,hcolor	                  		 ; сама левая нога из одежды    (131,142,190,200,66)

	macrorect hx1+21,hx2+4,hy1+144,hy2+116,1                   		 ; левая обувь                  (131,148,194,200,1)
	                                                                                   
	macrorect hx1+1,hx2-22,hy1+140,hy2+116,hcolor	                  		 ; сама правая нога из одежды   (111,122,190,200,66)

	macrorect hx1+1,hx2-16,hy1+144,hy2+116,1                   		 ; правая обувь                 (111,128,194,200,1)

	macrorect hx1-6,hx2-31,hy1+34,hy2+61,26                   		 ; одежда правой руки           (104,113,84,145,26)
	
	macrorect hx1-5,hx2-33,hy1+95,hy2+66,hcolor	                		 ; сама правая рука из одежды   (105,111,145,150,66)
	                         
	macrorect hx1+36,hx2+10,hy1+34,hy2+61,26                  		 ; одежда левой руки            (146,154,84,145,26)

	macrorect hx1+37,hx2+9,hy1+95,hy2+66,hcolor	               			 ; сама левой рука из одежды    (147,153,145,150,66)

endm
;-------------------------------------
;###############################################################################################################
file01:	
	mov	ah,	9
	mov	dx,	offset	message2
	int	21h
	
	mov	buffer,	0
	mov	positions,	0
	call	input                         ; Здесь процедура ввода параметров(слова), которые и запишутся в текстовый файл
	mov	buffer,	1
	cmp	pole[0],	0Dh           ; если нажато "Enter",то оставляем значение по умолчанию
	je	Setting1                      ; проверить, что в файл записаны данные вводимые нами, можно открыв файл "FileParameters.txt", где все программки
	cmp	chis,	0
	je	Setting1

	mov	ax,	chis
	mov	ah,	0
	mov	colorhead,	al
	jmp	Setting3                                   

Setting1:
	mov	pole[1],	36h
	mov	pole[2],	36h
	call	input
;###################################################################################
Setting3:	
	macrorect 0,320,0,200,0
	
	mov	ah,	9
	mov	dx,	offset	message3
	int	21h
	
	add	positions,	4		
	call	input                         ; Здесь процедура ввода параметров(слова), которые и запишутся в текстовый файл

	cmp	pole[0],	0Dh           ; если нажато "Enter",то оставляем значение по умолчанию
	je	Setting2                      ; проверить, что в файл записаны данные вводимые нами, можно открыв файл "FileParameters.txt", где все программки	
	cmp	chis,	0
	je	Setting2

	mov	ax,	chis
	mov	ah,	0
	mov	colordoor,	al
	jmp	Setting4
		
Setting2:
	mov	pole[1],	36h
	mov	pole[2],	38h
	call	input
Setting4:
	macrorect 0,320,0,200,0

	mov	ah,	9
	mov	dx,	offset	message4
	int	21h

IRP p, <Doorx1,Doorx2,Doory1,Doory2>
	local	SetNo5,SetNoo5	

	add	positions,	4
	call	input
	cmp	pole[0],	0Dh
	jne	SetNo5
	jmp	Setting5
SetNo5:
	cmp	chis,	0

	jne	SetNoo5
	jmp	Setting5
SetNoo5:
		
	mov	ax,	chis
	mov	p,	ax

	mov	dl,	13
	mov	ah,	2
	int	21h
endm
	jmp	Setting6

Setting5:
	mov	pole[1],	32h
	mov	pole[2],	34h
	mov	pole[3],	30h
	call	input
	add	positions,	4

	mov	pole[1],	32h
	mov	pole[2],	35h
	mov	pole[3],	35h
	call	input
	add	positions,	4

	mov	pole[1],	33h
	mov	pole[2],	30h
	mov	pole[3],	10h
	call	input
	add	positions,	4

	mov	pole[1],	32h
	mov	pole[2],	30h
	mov	pole[3],	30h
	call	input
	add	positions,	4
Setting6:	
	jmp	Menu
;###################################################################################
;-------------------------------------	
help:	                                     
	LEA	dx,	message1             ; выводим сообщение по управлению
	mov	ah,	9
	int	21h
;-------------------------------------	
Yet:	mov	ah,	1
	int	21h                          ; выход из этого пункта только кнопка Escape
	cmp	al,	1bh
	jne	Yet
	jmp	Menu
;-------------------------------------
;########################################################################################################################
Main:
	mov	positions,	0
	mov	len,	4
	
	cmp	buffer,	1
	je	F1
	
F2F: 	mov	ah,	3Dh             ; режим открытия файла
	mov	al,	0               ; режим записи в файл(al=2-чтение и запись;al=1-запись;al=0-чтение)       
	Lea	dx,	names           ; адрес имени файла, которое нужно открыть
	int	21h

	Obrabotka1	

	mov	ax,	chis
	mov	ah,	0
	mov	colorhead,	al
	mov	ah,	0
	jmp	F1F

F1:	cmp	pole[0],	0Dh
	je	F2F


F1F:	mainhuman 17,110,144,50,84,127,67,colorhead	      ; рисуем человека

	cmp	buffer,1
	jne	F3
	jmp	F2

F3:	
	add	positions,	4
	                                              ; НАЧИНАЕМ
	pop	ax

	Obrabotka1

	mov	ax,	chis
	mov	ah,	0
	mov	ColorDoor,	al
	jmp	F3F	

F2:	cmp	pole[0],	0Dh
	je	F3	

F3F:	cmp	buffer,	1
	jne	F5
	jmp	F4
F5:
	add	positions,	4
	pop	ax

	Obrabotka1	

	mov	ax,	chis
	mov	Doorx1,	ax

	add	positions,	4
	pop	ax

	Obrabotka1	

	mov	ax,	chis
	mov	Doorx2,	ax

	add	positions,	4
	pop	ax

	Obrabotka1	

	mov	ax,	chis
	mov	Doory1,	ax

	add	positions,	4
	pop	ax

	Obrabotka1	

	mov	ax,	chis
	mov	Doory2,	ax
	jmp	F5F

F4:	cmp	pole[0],	0Dh
	jne	F5F
	jmp	F5
	
F5F:	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor

	mov	ax,	Doory2
	sub	ax,	Doory1
	mov	dx,	0
	div	two
	add	ax,	Doory1
	mov	dx,	ax
	sub	dx,	2

	mov	cx,	5

Door:	
	push	cx
	mov	ah,	0Ch
	mov	al,	6           ; рисование точки
	mov	cx,	Doorx1
	sub	cx,	2
	int	10h
	inc	dx
	pop	cx
	loop	Door

	mov	ax,	Doory2
	sub	ax,	Doory1
	mov	dx,	0
	div	two
	add	ax,	Doory1
	mov	dx,	ax

	mov	ah,	0Ch
	mov	al,	6           ; рисование точки
	mov	cx,	Doorx1
	dec	cx
	int	10h

	cmp	buffer,	1
	je	F6
	mov	ah,	3Eh             ; режим закрытия файла
	int	21h
F6:	
;--------------------------------------
;########################################################################################################################
;########################################################################################################################
Knopk:	
	mov	ah,	1
	int	21h                                    ; ждем нажатия кнопки


	cmp	al,	1bh  ; ascii code of input character                           ; Если это Escape , то выходим в меню
	jne	Esc1
	jmp	Menu

;########################################################################################################################
;########################################################################################################################
Esc1:	cmp	al,	44h                            ; Если это Shift+d , то открываем дверь 
	je	Esc3
	jmp	Er1
Esc3:	
	push	ax
	sub	Doorx1,	2
	add	Doory1,	1
	macrorect Doorx1,Doorx2,Doory1,Doory2,0                     ; зарисовка прежнего положения двери
	add	Doorx1,	2
	mov	ax,	Doorx2
	sub	ax,	Doorx1
	add	Doorx1,	ax
	add	Doorx2,	30	
	macrorect Doorx1,Doorx2,Doory1,Doory2,68                    ; прорисовка нового положения двери(дверь открыта)
	mov	di,	ax	
	mov	ax,	Doory2
	sub	ax,	Doory1
	mov	dx,	0
	div	two	
	add	Doory1,	ax
	sub	Doory2,	ax
	add	Doory2,	4
	sub	Doory1,	4
	add	Doorx1,	20
	sub	Doorx2,	2
	mov	cx,	Doorx1
	add	cx,	4
	mov	dx,	Doory1
	add	dx,	4
	macrocircle 4,Doorx1,Doorx2,Doory1,Doory2,cx,dx,6        ; прорисовка ручки двери(дверь же открыта)
	sub	Doorx1,	di
	sub	Doorx1,	20
	add	Doorx2,	2
	sub	Doorx2,	30
	sub	Doory1,	ax
	add	Doory1,	3
	add	Doory2,	ax
	sub	Doory2,	4	

	                   

	cmp	kolL,	0                              ; смотрим, это дествие совершено в центре, правее или левее центра
	je	Uno1                                   
	cmp	kolL,	1     
	jne	U2
	jmp	U1
U2:	jmp	Ujump1
;------------------
Uno1:	jmp	U	
;------------------
Ujump1:
	pop	ax	
	mainhuman 17,125,159,50,84,142,67,colorhead	       ; рисуем новое положение (правее центра)
	macrocircle 4,141,142,72,73,145,76,0           ; прорисовываем(открываем) ему рот правее центра

	cmp	al,	57h
	je	U6
	jmp	U5

U6:	macrorect 161,169,84,150,0                     ; Зарисовываем старое положение левой руки(правее центра)
       	macrorect 161,222,84,92,26                     ; рисуем новое положение одежды руки
	macrorect 222,227,85,91,66                     ; рисуем новое положение самой руки
		
U5:	jmp	Knopk

U1:	
       	mainhuman 17,95,129,50,84,112,67,colorhead	       ; рисуем новое положение (левее центра)
	macrocircle 4,111,112,72,73,115,76,0           ; прорисовываем(открываем) ему рот левее центра
	jmp	Knopk

U:	
	mainhuman 17,110,144,50,84,127,67,colorhead	      ; рисуем человека
	macrocircle 4,126,127,72,73,130,76,0           ; прорисовываем(открываем) ему рот в центре
	jmp	Knopk
;########################################################################################################################
Er1:	cmp	al,	20h                            ; если нажат Space, то прыгаем
	je	Esc2
	jmp	Er2

Esc2:	
	cmp	kolL,	0                              ; определяем, где прыгаем(в центре, левее или правее)
	jne	P2
	jmp	P
P2:	cmp	kolL,	1
	jne	P3
	jmp	P1
P3:	macrorect 117,170,50,200,0                      ; зарисовываем прежнее положение(до) правее центра
	mainhuman 17,125,159,40,74,142,57,colorhead	       ; рисуем новое положение(чуть выше) также правее центра

	macrorect 117,170,10,190,0                      ; зарисовываем новое положение
	mainhuman 17,125,159,50,84,142,67,colorhead	       ; рисуем старое положение правее центра
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor

	jmp	Knopk                                  ; прыжок совершен

P:
	macrorect 100,200,30,200,0                      ; зарисовываем прежнее положение(до) в центре
	mainhuman 17,110,144,40,74,127,57,colorhead	       ; рисуем новое положение(чуть выше) также в центре

	macrorect 100,200,20,200,0                      ; зарисовываем новое положение
	mainhuman 17,110,144,50,84,127,67,colorhead	       ; рисуем старое положение в центре
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	jmp	Knopk                                  ; прыжок совершен

P1:     
	macrorect 75,200,30,200,0                      ; зарисовываем прежнее положение(до) левее центра
	mainhuman 17,95,129,40,74,112,57,colorhead	       ; рисуем новое положение(чуть выше) также левее центра

	macrorect 75,200,20,200,0                      ; зарисовываем новое положение
	mainhuman 17,95,129,50,84,112,67,colorhead	       ; рисуем старое положение левее центра
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	jmp	Knopk	                               ; прыжок совершен
;########################################################################################################################
Er2:    cmp	al,	64h                            ; Если нажата d, то делаем перемещение вправо
	je	Esc4
	jmp	Er3

Esc4:                                                  ; определяем, делаем мы перемещение в какой части
	cmp	kolR,	0
	je	T
	cmp	kolR,	-1
	jne	T2
	jmp	T1
T2:	jmp	Knopk                                  ; Если человек и так правее центра, то еще дальше он не пойдет

T:	
	macrorect 90,164,30,200,0	                       ; Зарисовываем старое положение(центр)
	mainhuman 17,125,159,50,84,142,67,colorhead	       ; рисуем новое положение (правее центра)
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	inc	kolR                                   ; KolR(KolL) говорит где человек: в центре-они по 0 , левее центра = -1(+1) , правее центра = +1(-1) 
	dec	kolL                                   ; здесь мы распределяем их в соответствии с перемещением
	jmp	Knopk                                  ; перемещение вправо совершено

T1:
	macrorect 85,179,30,200,0                        ; Зарисовываем старое положение(левее центра)
	mainhuman 17,110,144,50,84,127,67,colorhead           ; рисуем новое положение (в центре)
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	inc	kolR                                   ; KolR(KolL) говорит где человек: в центре-они по 0 , левее центра = -1(+1) , правее центра = +1(-1)
	dec	kolL	                               ; здесь мы распределяем их в соответствии с перемещением
	jmp	Knopk		                       ; перемещение вправо совершено
;########################################################################################################################
Er3:    cmp	al,	61h                            ; Если нажата a, то делаем перемещение влево
	je	Esc5
	jmp	Er4

Esc5:
	cmp	kolL,	0                              ; определяем, делаем мы перемещение в какой части
	je	B
	cmp	kolL,	-1
	jne	B2
	jmp	B1                                     ; Если человек и так левее центра, то еще дальше он не пойдет
B2:	jmp	Knopk
B:
	macrorect 80,174,30,200,0                        ; Зарисовываем старое положение(центр)
	mainhuman 17,95,129,50,84,112,67,colorhead	       ; рисуем новое положение (левее центра)
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	inc	kolL                                   ; KolR(KolL) говорит где человек: в центре-они по 0 , левее центра = -1(+1) , правее центра = +1(-1)
	dec	kolR                                   ; здесь мы распределяем их в соответствии с перемещением
	jmp	Knopk                                  ; перемещение влево совершено

B1:	
	macrorect 60,170,30,200,0                        ; Зарисовываем старое положение(правее)
	mainhuman 17,110,144,50,84,127,67,colorhead	       ; рисуем новое положение (в центре)
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	inc	kolL                                   ; KolR(KolL) говорит где человек: в центре-они по 0 , левее центра = -1(+1) , правее центра = +1(-1)
	dec	kolR                                   ; здесь мы распределяем их в соответствии с перемещением
	jmp	Knopk	                               ; перемещение влево совершено
;########################################################################################################################
Er4:	cmp	al,	57h                            ; Если нажато Shift+w - поднимаем левую руку

	je	N
	jmp	Er5
	                                               ; определяем в какой части мы поднимаем левую руку
N:	cmp	kolL,	0
	jne	N3
	jmp	N1
N3:	cmp	KolL,	1
	je	N2no1
	macrorect 161,169,84,150,0                     ; Зарисовываем старое положение левой руки(правее центра)
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	jmp	N2jump1
;------------------------------------                  ; большие прыжки
N2no1:	jmp	N2
;------------------------------------
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
N2jump1:
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	macrorect 161,222,84,92,26                     ; рисуем новое положение одежды руки
	macrorect 222,227,85,91,66                     ; рисуем новое положение самой руки
	jmp	Esc3                                   ; левая рука поднята

N2:	
       	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	macrorect 131,139,84,150,0                     ; зарисовываем старое положение левой руки(левее центра)
	macrorect 131,192,84,92,26                     ; рисуем новое положение одежды руки
	macrorect 192,197,85,91,66                     ; рисуем новое положение самой руки
	jmp	Knopk 	                               ; левая рука поднята

N1:	
       	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	macrorect 146,154,84,150,0                     ; зарисовываем старое положение левой руки(в центре)
	macrorect 146,207,84,92,26                     ; рисуем новое положение одежды руки
	macrorect 207,212,85,91,66                     ; рисуем новое положение самой руки
	jmp	Knopk                                  ; левая рука поднята
;########################################################################################################################
Er5:	cmp	al,	41h                            ; Если нажато Shift+a , то дверь закрывается
	je	I
	jmp	Er6

I:
;	macrorect 240,255,40,200,68                    ; зарисовывается открытая дверь
;	macrorect 255,310,40,200,0                     ; рисуется закрытая дверь
	macrorect Doorx1,Doorx2,Doory1,Doory2,68

	add	Doory1,	1
	mov	ax,	Doorx2
	sub	ax,	Doorx1
	add	Doorx1,	ax
	add	Doorx2,	30

	macrorect Doorx1,Doorx2,Doory1,Doory2,0

	sub	Doory1,	1
	sub	Doorx1,	ax
	sub	Doorx2,	30

	mov	ax,	Doory2
	sub	ax,	Doory1
	mov	dx,	0
	div	two
	add	ax,	Doory1
	mov	dx,	ax
	sub	dx,	2

	mov	cx,	5

Door1:	
	push	cx
	mov	ah,	0Ch
	mov	al,	6           ; рисование точки
	mov	cx,	Doorx1
	sub	cx,	2
	int	10h
	inc	dx
	pop	cx
	loop	Door1

	mov	ax,	Doory2
	sub	ax,	Doory1
	mov	dx,	0
	div	two
	add	ax,	Doory1
	mov	dx,	ax

	mov	ah,	0Ch
	mov	al,	6           ; рисование точки
	mov	cx,	Doorx1
	dec	cx
	int	10h

	cmp	kolL,	0
	je	I4
	jmp	I1	
	
I4:	mainhuman 17,110,144,50,84,127,67,colorhead	      ; рисуем человека(в центре)
	jmp	I3

I1:	cmp	kolL,	-1
	je	I5
	jmp	I2

I5:	mainhuman 17,125,159,50,84,142,67,colorhead	       ; рисуем новое положение (правее центра)
	jmp	I3

I2:	
	mainhuman 17,95,129,50,84,112,67,colorhead	       ; рисуем новое положение (левее центра)
I3:
	jmp	Knopk                                  ; дверь закрыта
;########################################################################################################################	
Er6:	cmp	al,	53h                            ; Если нажато Shift+s , то опускаем левую руку
	je	O
	jmp	Knopk

O:	cmp	kolL,	0                              ; определяем в какой части мы опускаем левую руку
	jne	O3
	jmp	O1
O3:	cmp	kolL,	-1
	je	O2no1

	macrorect 131,197,84,92,0                      ; Зарисовываем старое положение левой руки(левее центра)
	jmp	O2jump1
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;------------------------------------
O2no1:	jmp	O2                   ; Большой прыжок
;------------------------------------
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
O2jump1:macrorect 131,139,84,145,26                    ; рисуем новое положение одежды руки
	macrorect 132,138,145,150,66	               ; рисуем новое положение самой руки
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	jmp	Knopk                                  ; левая рука опущена
	
O2:	macrorect 161,227,84,92,0                      ; зарисовываем старое положение левой руки(правее центра)
	macrorect 161,169,84,145,26                    ; рисуем новое положение одежды руки
	macrorect 162,168,145,150,66	               ; рисуем новое положение самой руки
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	jmp	I                                      ; левая рука опущена

O1:	
	macrorect 146,212,84,92,0                      ; зарисовываем старое положение левой руки(в центре)
	macrorect 146,154,84,145,26                    ; рисуем новое положение одежды руки
	macrorect 147,153,145,150,66	               ; рисуем новое положение самой руки
	macrorect Doorx1,Doorx2,Doory1,Doory2,ColorDoor
	jmp	Knopk                                  ; левая рука опущена
;########################################################################################################################
Ex1:    
	mov	ah,	1
	int	21h
	
Ex2:	mov  ax,0003h			; текстовый режим и выход
        int  10h

        mov  ax,4c00h           	; выход из программы
        int  21h
	
;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
circle proc 
push	ax
push	bx
push	cx
push	dx
push	x1                  		; занесли в стек значения координат, чтобы при выходе из процедуры они не изменились
push	y1                  		; а то в самой процедуре они меняются
push	x2
push	y2

	mov	si,	r
	add	si,	si
        
	mov	bx,	y1
	mov	nachaly1,	bx

	mov	cx,	si         	; проверяем квадрат размером 10*10 (внешний по x, внутренний по y)
M:	
	push	cx                 	; заносим в стек , чтобы создать внутренний цикл
	mov	cx,	si        	; внутренний цикл

M1:	push	cx	             	; заносим в стек, чтобы сохранить счетчик цикла(а то внутри цикла cx меняется)
	mov	ax,	x1            	; Работаем по формуле X^2 + Y^2 = R^2
	sub	ax,	vosst1         	; т.к у нас квадрат не в центре , то перемещаем его в центр (0;0) с помощью "sub ax, vosst1" и "sub ax, vosst2"
	mul	ax                      ; vosst1, vosst2 - величины , на которые нужно опустить рассматриваемый квадрат по x(vosst1)  и по y(vosst2)
	mov	kv1,	ax             	; kv1 = (X-vosst1)^2

	mov	ax,	y1             	; vosst1 и vosst2 равны т.к это квадрат
	sub	ax,	vosst2        	; там мы опустили квадрат по x , а сейчас опускаем квадрат по y
	mul	ax
	mov	kv2,	ax            	; kv2 = (Y-vosst2)^2
	                   	
	mov	ax,	r             	; r - радиус окружности
	mul	r
	mov	kvr,	ax            	; kvr = R^2
	
	mov	ax,	kv1
	add	ax,	kv2           	; теперь сравниваем ( (x-vosst1)^2 + (y-vosst2)^2 ) с r^2
	cmp	ax,	kvr           	;Если меньше либо равно ,то рисуем точку(внутренность окружности)
	jge	M2                    	; Иначе , ничего не делаем и идем дальше смотреть

	mov	ah,	0Ch
	mov	al,	color           ; рисование точки
	mov	cx,	x1
	mov	dx,	y1
	int	10h


M2:	inc	y1                      ; движемся по y (внутренний цикл)
	pop	cx                      ; востанавливаем счетчик внутреннего цикла
	loop	M1
	inc	x1                      ; как только закончили движение по y, то увеличиваем x(продвижение внешним циклом по x) 
	                                ; восстанавливаем начальное значение y(nachaly1) и идем дальше
	mov	bx,	nachaly1
	mov	y1,	bx
	
	pop	cx                      ; конец цикла. Восстанавливаем счетчик внешнего цикла
	loop	M

pop	y2                       	; Восстановили значения координат
pop	x2
pop	y1
pop	x1
pop	dx                            	; и регистры
pop	cx
pop	bx
pop	ax

ret

endp	
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
rectangle proc
push	ax
push	bx
push	cx
push	dx

	mov	bx,	xr2             ; определяем длину прямоугольника
	sub	bx,	xr1

	mov	si,	yr2             ; определяем высоту прямоугольника
	sub	si,	yr1

	
	mov	cx,	si              ; внешний цикл по высоту(Y)
R1:	
	push	cx
	mov	cx,	bx              ; внутренний цикл по длине(X)
R2:	
	push	cx
	mov	ah,	0Ch             ; последовательно проходя прямоугольник рисуем точки
	mov	al,	color
	mov	cx,	xr1
	mov	dx,	yr1
	int	10h

	inc	xr1                     ; движение по длине
	pop	cx
	loop	R2
	inc	yr1                     ; движение по высоте
	sub	xr1,	bx              ; восстановление начального положения прохода по длине
	pop	cx
	loop	R1

pop	dx
pop	cx
pop	bx
pop	ax

ret

endp
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
input proc
push	ax
push	bx
push	cx
push	dx
	
	mov	dl,	13              ; newline 2 раза
	mov	ah,	2
	int	21h

	mov	dl,	10
	mov	ah,	2
	int	21h

	mov	dl,	10
	mov	ah,	2
	int	21h
	
	MOV  ah, 0Ah                    ; обращаемся к функции 0Ah прерывания 21h
	LEA DX,  max                    ;имя области ввода в dx (максимальное число вводимых символов)
	iNT  21h                        ;вызываем прерывание 21h для ввода числа
        	                        ; Образовалась введенная нами строка pole, размера не выше max
E3:	cmp	buffer,	0
	jg	E1	
	mov	ah,	3Ch             ; режим создания файла
	lea	dx,	names           ; имя файла
	xor	cx,	cx              ; cx=0 значит обычный файл
	int	21h
	newline
	outint	cx
	jmp	E2

E1: 	mov	ah,	3Dh             ; режим открытия файла
	mov	al,	1               ; режим записи в файл(al=2-чтение и запись;al=1-запись;al=0-чтение)       
	Lea	dx,	names           ; адрес имени файла, которое нужно открыть
	int	21h

E2:	push	ax

	mov	bx,	ax
	mov	ah,	42h
	mov	cx,	0
	mov	dx,	positions
	mov	al,	0
	int	21h

	pop	ax	

	mov	bx,	ax              ; в bx дескриптор файла(уникальное его имя)
	mov	ah,	40h             ; режим записи в файл
	mov	al,	1               ; режим записи в файл(al=2-чтение и запись;al=1-запись;al=0-чтение)
	Lea	dx,	pole            ; в dx адрес буфера данных, который надо записать
	mov	cl,	4               ; в cx то количество байтов(len), которое необходимо записать в файл
	mov	ch,	0
	int	21h

	mov	ah,	3Eh             ; режим закрытия файла
	int	21h

	mov	ah,	3Dh             ; режим открытия файла
	mov	al,	0               ; режим записи в файл(al=2-чтение и запись;al=1-запись;al=0-чтение)       
	Lea	dx,	names           ; адрес имени файла, которое нужно открыть
	int	21h

	push	ax

	mov	bx,	ax
	mov	ah,	42h
	mov	cx,	0
	mov	dx,	positions
	mov	al,	0
	int	21h
 
	pop	ax	

	mov	bx,	ax              ; в bx дескриптор файла
;*
	push	bx
;*
	mov	ah,	3fh             ; режим чтения из файла
	mov	al,	0
	Lea	dx,	read1           ; адрес буфера данных, куда посимвольно будут записываться прочитанные данные
	mov	cl,	4	        ; количество байт, которое нужно прочитать (len)
	mov	ch,	0
	int	21h                     ; результат в ax - реально прочитанное количество байтов

	call	strtoint
;*
	pop	bx
;*
	mov	ah,	3Eh             ; режим закрытия файла
	int	21h

E:
pop	dx
pop	cx
pop	bx
pop	ax
ret
endp                      

strtoint proc                                   ; перевод числа в строку
pushf

 	mov	chis,	0
	mov	cl,	len
	mov	ch,	0
	mov	bx,	0
Perev:	
	mov	ax,	chis
	mov	dl,	read1[bx]
	mov	dh,	0
	cmp	dx,	30h
	jl	Perev2
	cmp	dx,	39h
	jg	Perev2
	mul	ten
	mov	chis,	ax
	sub	dx,	30h
	add	chis,	dx
Perev2:	
	inc	bx
	loop	Perev
Perev3:
popf
ret
endp

ENDS

END	Start