;Написал Ясько М.Л. 21группа 2005г.
ideal                         
P386                            

SEGMENT CODE               
ASSUME 	cs:code,ds:code          

START:	mov    	ax,0013h            
	int     	10h

	mov     	ax,cs
	mov     	ds,ax               
	mov     	ax,0a000h
	mov     	es,ax               

	lea     	si,[Palette]       		;Установка палитры
	mov     	dx,3c8h
	xor     	al,al
	mov     	dx,3c9h
	mov     	cx,189*3
	repz    	outsb
;=======Переменые===================
	mov     	[Zoff],300 		; ось z - расстояние до обьекта
 	mov	[figure],1
	mov     	[DeltaX],1          	; Скорость вращения вокруг оси Х
	mov	[mx],160
	mov	[my],100
men1:	mov     	[DeltaY],1          	; -/- Y
	mov     	[DeltaZ],1          	; -/- Z
	mov     	[Xoff],256		; плоскость (X,Y) -
	mov	[Yoff],256         	; - Для вычисления координат обьекта на экране


;=======Программа===================
;== Вывод меню ==
men:
	call	menup

	mov    	ax,0013h            
	int     	10h

	lea     	si,[Palette]       
	mov     	dx,3c8h
	xor     	al,al
	mov     	dx,3c9h
	mov     	cx,189*3
	repz    	outsb
	call	vwait			;задержка,чтоб отчистиллся буфер клавы
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
	call	vwait
;===================================
Mcikl:	call	mainproc
	call	cubename
	call	Klava
	call	delcname
	jmp	men
;=======Выход=======================
exitin:	mov     	ax,0003h		;завершение вга режима, переход в текстовый          
    	int     	10h
    	mov     	ax,4c00h            
    	int     	21h                     	;завершение программы

;=======Подпрограммы================
proc	openf
;открытие файла
	xor	ax,ax
	xor	cx,cx
	mov	ah,3ch
	int	21h
	jnc	qaz
	call	errmess
qaz:
ret
endp	openf

proc	psave
;создаёт файл, записывает параметры в файл
	mov	ah,3ch		;создание файла
	lea	dx,filename
	xor	cx,cx
	xor	al,al
	int	21h
	mov	[opis],ax
	
saving:	mov	ah,40h		;запись
	mov	dx,[deltax]
	mov	[buff],dx
	mov	bx,[opis]
	lea	dx,buff
	mov	cx,2
	int	21h

	mov	ah,40h		;запись
	mov	dx,[zoff]
	mov	[buff],dx
	mov	bx,[opis]
	lea	dx,buff
	mov	cx,2
	int	21h

	mov	ah,40h		;запись
	mov	dx,[figure]
	mov	[buff],dx
	mov	bx,[opis]
	lea	dx,buff
	mov	cx,2
	int	21h

	mov	ah,40h		;запись
	mov	dx,[mx]
	mov	[buff],dx
	mov	bx,[opis]
	lea	dx,buff
	mov	cx,2
	int	21h

	mov	ah,40h		;запись
	mov	dx,[my]
	mov	[buff],dx
	mov	bx,[opis]
	lea	dx,buff
	mov	cx,2
	int	21h


	mov	ah,42h		;Указатель
	mov	bx,[opis]
	xor	cx,cx
	xor	dx,dx
	mov	al,0
	int	21h

ret
endp	psave

proc 	ErrMess
;вывод ошибки
	mov     	ah,2h
   	xor     	bx,bx
  	xor     	dx,dx
	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
 	mov     	ah,9h
	lea	dx,Msg60
	int     	21h

ret
endp	ErrMess

proc	help
;Меню "помощь"
	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)

rept 10
	mov     	ah,9h
	lea	dx,Msg46
   	int     	21h
endm
	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)

	mov     	ah,9h
	lea	dx,Msg50
   	int     	21h

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,6    
	int     	10h         		;Устанавливает курсор в позицию (dl,dh)

	mov     	ah,9h
	lea	dx,Msg51
   	int     	21h

repit:	in      	al,60h 
	cmp	al,1
	jne	repit

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)

rept 11
	mov     	ah,9h
	lea	dx,Msg46
   	int     	21h
endm

ret
endp	help

proc	delcname
;удаление надписи в верхнем углу экрана
	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea	dx,Msg46
   	int     	21h
ret
endp	delcname

proc 	cubename
;== Вывод номера куба ==
	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	cmp	[figure],1
	jne	M2
    	lea     	dx,Msg10
	jmp	M0
M2:	cmp	[figure],2
	jne	M3
	lea     	dx,Msg20
	jmp	M0
M3:	lea	dx,Msg30
M0:   	int     	21h

ret
endp	cubename

proc	stats
;вывод данных о кубе
	call	cubename

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,1
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea     	dx,Msg41
	int     	21h
	mov	ax,[deltax]
	call	outint

	mov     	ah,9h
	lea     	dx,Msg42
	int     	21h
	mov	ax,[deltay]
	call	outint
	
	mov     	ah,9h
	lea     	dx,Msg43
	int     	21h
	mov	ax,[deltaz]
	call	outint

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,2
    	int     	10h
	mov     	ah,9h
	lea     	dx,Msg44
	int     	21h
	mov	ax,[zoff]
	call	outint

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,24
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea     	dx,Msg45
	int     	21h

kl:	in      	al,60h
	cmp	al,46
	je	contR

msav:	cmp	al,45
	jne	kl
	call	PSave
contR:
;==очистка==
	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,2
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea     	dx,Msg46
	int     	21h

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,1
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea     	dx,Msg46
	int     	21h

	mov     	ah,2h
   	xor     	bx,bx
    	xor     	dx,dx
	mov	dh,24
    	int     	10h         		;Устанавливает курсор в позицию (dl,dh)
				; на страницу bx
    	mov     	ah,9h
	lea     	dx,Msg46
	int     	21h
;==========
ret
endp	stats



proc	klava
begin1:	in      	al,60h 			;обращение к клаве
			
	cmp	al,16
	jne	cont
	cmp	[deltax],100
	jge	cont
	add	[deltaX],1
cont:
	cmp	al,30
	jne	cont1
	cmp	[deltax],0
	jle	cont1
	sub	[deltaX],1
cont1:
	cmp	al,17
	jne	cont2
	add	[Zoff],1
cont2:
	cmp	al,31
	jne	cont3
	cmp	[zoff],80
	jle	cont3
	sub	[zoff],1
cont3:
	cmp	al,18
	jne	cont4
	add	[Mx],1
cont4:
	cmp	al,32
	jne	cont5
	sub	[Mx],1
cont5:
	cmp	al,19
	jne	cont6
	add	[my],1
cont6:
	cmp	al,33
	jne	cont7
	sub	[my],1
cont7:	
	cmp	al,2
	jne	cont10
	mov	[figure],1
cont10:	
	cmp	al,3
	jne	cont11
	mov	[figure],2

cont11: 	cmp	al,4
	jne	cont12
	mov	[figure],3

cont12:
	cmp	al,44
	jne	cont13
	call	stats
cont13:
	cmp	al,1		;проверка на escape (28-enter)
	jne	Mcikl
ret
endp	klava

proc	menup
;меню
	mov     	ah,2h		;позиция курсора
   	xor     	bx,bx
    	mov     	dx,050fh
    	int     	10h
	mov     	ah,9h
	lea     	dx,Msg01
	int	21h
	mov     	ah,2h		;позиция курсора
   	xor     	bx,bx
    	mov     	dx,060fh
    	int     	10h
	mov	ah,9h
	lea	dx,Msg02
	int	21h	
	mov     	ah,2h		;позиция курсора
   	xor     	bx,bx
    	mov     	dx,070fh
    	int     	10h
	mov     	ah,9h
	lea     	dx,Msg03
	int	21h
	mov     	ah,2h		;позиция курсора
   	xor     	bx,bx
    	mov     	dx,080fh
    	int     	10h
	mov     	ah,9h
	lea     	dx,Msg04
	int	21h

cikl01:	in	al,60h

	cmp	al,2
	jne	mp1
	ret

mp1:	cmp	al,3
	jne	mp2
	cmp	[opis],0
	jne	opened
	call	errmess
	jmp	cikl01
Opened:	
Loading:	
	mov	ah,3fh
	mov	bx,[opis]
	mov	[buff],0
	lea	dx,buff
	mov	cx,2
	int	21h
	mov	ax,[buff]
	mov	[deltax],ax
	
	mov	ah,3fh
	mov	bx,[opis]
	mov	[buff],0
	lea	dx,buff
	mov	cx,2
	int	21h
	mov	ax,[buff]
	mov	[zoff],ax
	
	mov	ah,3fh
	mov	bx,[opis]
	mov	[buff],1
	lea	dx,buff
	mov	cx,2
	int	21h
	cmp	ax,2
	mov	ax,[buff]
	mov	[figure],ax

	mov	ah,3fh
	mov	bx,[opis]
	mov	[buff],1
	lea	dx,buff
	mov	cx,2
	int	21h
	cmp	ax,2
	mov	ax,[buff]
	mov	[mx],ax

	mov	ah,3fh
	mov	bx,[opis]
	mov	[buff],1
	lea	dx,buff
	mov	cx,2
	int	21h
	cmp	ax,2
	mov	ax,[buff]
	mov	[my],ax

	mov	ah,42h		;Указатель
	mov	bx,[opis]
	xor	cx,cx
	xor	dx,dx
	mov	al,0
	int	21h

	jmp	men1
	ret
	
mp2:	cmp	al,4
	jne	mp3
	call	help
	jmp	men
	ret
	
mp3:	cmp	al,5
	jne	cikl01
	jmp	exitin
ret
endp	menup



	

proc 	Outint
;выводит число из АХ
	push	ax
	push	bx
	push	dx

	cmp	ax,9
	jg	des
	mov	dx,ax
	add	dx,30h
	xor	ax,ax
	mov	ah,02h
	int	21h
	jmp	Eall	
des:	
	mov	bx,10
	xor	dx,dx
	div	bx
	mov	bl,al
	add	dl,30h
	mov	ah,02h
	mov	[mas],dl
	xor	ax,ax
	mov	al,bl
	cmp	ax,9
	jg	sto
	
	mov	dl,al
	add	dl,30h
	mov	ah,02h
	int	21h

	mov	dl,[mas]
	mov	ah,02h
	int	21h

	jmp	eall

sto:	mov	bx,10
	xor	dx,dx
	div	bx
	
	mov	ah,02h
	mov	bl,al
	add	dl,30h
	mov	[mas+1],dl
	mov	dl,bl
	add	dl,30h
	mov	ah,02h
	int	21h	

	mov	dl,[mas+1]
	mov	ah,02h
	int	21h
	mov	dl,[mas]
	mov	ah,02h
	int	21h
eall:
	pop	dx
	pop	bx
	pop	ax
ret
endp Outint

proc vwait
; Waits for vertical retrace to reduce "snow"
    	mov     	dx,3dah
Vrt:
    	in      	al,dx
    	test    	al,8
    	jnz     	Vrt                 	; Wait until Verticle Retrace starts
NoVrt:
    	in      	al,dx
    	test    	al,8
    	jz      	NoVrt               	; Wait until Verticle Retrace ends
ret
endp vwait

proc setrotation
;подсчёт новых углов вращения по осям

	mov	ax,[Xygol]
	mov	bx,[Yygol]	
	mov	cx,[Zygol]

	add	ax,[deltaX]
	and     	ax,11111111b
	mov	[Xygol],ax
	add	bx,[deltaY]
        	and     	bx,11111111b
	mov	[Yygol],bx
	add	cx,[deltaZ]
	and     	cx,11111111b
	mov	[Zygol],cx
	call	sin_cos
ret

proc sin_cos
;подсчёт sin & cos углов Xygol,Yygol,Zygol
	
	mov	bx,[Xygol]
	call    	GetSinCos           
	mov    	[Xsin],ax           
	mov    	[Xcos],bx         

	mov     	bx,[Yygol]
	call    	GetSinCos
	mov     	[Ysin],ax
	mov     	[Ycos],bx

	mov     	bx,[Zygol]
	call    	GetSinCos
	mov     	[Zsin],ax
	mov     	[Zcos],bx
ret

proc GetSinCos	
; Вход : bx = угол (0..255)
; Выход: ax=Sin   bx=Cos

	push    	bx                  	; Сохраняем угол
	shl     	bx,1                	; bx:= bx*2
	mov     	ax,[SinCos + bx]    	; получаем синус
	pop     	bx                  	; восстанавливаем угол в БХ
	push    	ax                  	; Синус в стэк
	add     	bx,64               	; добавляем к углу 64, чтоб получить косинус
	and     	bx,11111111b
	shl     	bx,1                
	mov     	ax,[SinCos + bx]    	; косинус
	mov    	bx,ax               	; bx=Cos
	pop     	ax                  	; ax=Sin
ret

endp GetSinCos
endp sin_cos
endp setrotation

proc outpoint
;подсчитывает позицию точки на экране и выводит её на экран
	mov     	ax,[Xoff]           	; Xoff*X / Z+Zoff = позиция точки на экране по Х
	mov     	bx,[X]
	imul    	bx
	mov     	bx,[Z]
	add     	bx,[Zoff]           	; в этом месте задаётся расстояние от экрана до обьекта
	cmp	bx,0
	jne	q12q
	add	bx,1
q12q:
	idiv    	bx
	add     	ax,[Mx]             	; позиция на экране (центр)
	mov     	bp,ax

	mov     	ax,[Yoff]           	; Yoff*Y / Z+Zoff = позиция точки на экране по У
	mov     	bx,[Y]
	imul    	bx
	mov     	bx,[Z]
	add     	bx,[Zoff]           	; в этом месте задаётся расстояние от экрана до обьекта
	cmp	bx,0
	jne	q123q
	add	bx,1
q123q:
	idiv    	bx	
	add     	ax,[My]             	; позиция на экране (центр)
	
;== Рисовать её? ==
	cmp	bp,320
	jge	NoShow
	cmp	bp,0
	jle	NoShow
	cmp	ax,200
	jge	NoShow
	cmp	ax,0
	jle	NoShow
;==============

	mov     	bx,320
	imul    	bx
	add     	ax,bp               	; ax = (y*320)+x
	mov     	di,ax

	mov     	ax,[Z]              	; цвет зависит от расстояния до экрана
	add     	ax,100d            

	mov     	[byte ptr es:di],al 	; Поставить точку цвета AL, в позиции ДИ
;== Определение фигуры ==

	cmp	[figure],1
	jne	Fdel1
	mov	[Del+si],di      	; Сохраняем позицию для удления
	jmp	Noshow

Fdel1:	cmp	[figure],2
	jne	Fdel2
	mov	[del+si-ksicube],di
	jmp	Noshow

Fdel2:	cmp	[figure],3
	jne	Fdel3
	mov	[del+si-ksicube01],di
	jmp	Noshow

Fdel3:

;========================

NoShow:
ret
endp outpoint

proc rotate
;поворачивает точку по 3-ём осям, изменяя координаты x,y,z
;использует Xcos,Xsin,...
	movsx	ax,[Cube+si]		;si=x	в ах координату точки
	mov	[x],ax	
	movsx	ax,[Cube+si+1]		;si+1=y
	mov	[y],ax
	movsx	ax,[Cube+si+2]		;si+2=z
	mov	[z],ax	

; вращение вокруг оси Х
; Yt = (Y * COS(xygol) - Z * SIN(xygol)) / 256
; Zt = (Y * SIN(xygol) + Z * COS(xygol)) / 256
; Y = Yt
; Z = Zt
	mov	ax,[y]
	mov	bx,[Xcos]
	imul	bx			;ax:=y*cos(xygol)
	mov	bp,ax
	mov	ax,[z]
	mov	bx,[Xsin]
	imul	bx			;ax:=z*sin(xygol)
	sub	bp,ax			;bp:=Y * COS(xygol) - Z * SIN(xygol)
	sar	bp,8			;bp:=(Y * COS(xygol) - Z * SIN(xygol)) / 256
	mov	[Yt],bp	

	mov	ax,[y]
	mov	bx,[Xsin]
	imul	bx			;ax:=y*sin(xygol)
	mov	bp,ax
	mov	ax,[z]
	mov	bx,[Xcos]
	imul	bx			;ax:=z*cos(xygol)
	add	bp,ax			;bp:=Y * SIN(xygol) + Z * COS(xygol)
	sar	bp,8			;bp:=(Y * SIN(xygol) + Z * COS(xygol)) / 256
	mov	[zt],bp

	mov     	ax,[Yt]          
	mov     	[Y],ax
	mov     	ax,[Zt]
	mov     	[Z],ax

; вращение вокруг оси Y
; Xt = X * COS(yygol) - Z * SIN(yygol) / 256
; Zt = X * SIN(yygol) + Z * COS(yygol) / 256
; X = Xt
; Z = Zt	
	mov     	ax,[X]
	mov     	bx,[YCos]
	imul    	bx        
	mov    	bp,ax
	mov     	ax,[Z]
	mov     	bx,[YSin]
	imul    	bx              
	sub     	bp,ax           
	sar     	bp,8            
	mov     	[Xt],bp

	mov     	ax,[X]
	mov     	bx,[YSin]
	imul    	bx               
	mov     	bp,ax
	mov     	ax,[Z]
	mov     	bx,[YCos]
	imul    	bx              
	add     	bp,ax            
	sar     	bp,8             
	mov     	[Zt],bp

	mov     	ax,[Xt]          
	mov     	[X],ax
	mov     	ax,[Zt]
	mov     	[Z],ax

; вращение вокруг оси Z
; XT = X * COS(zygol) - Y * SIN(zygol) / 256
; YT = X * SIN(zygol) + Y * COS(zygol) / 256
; X = XT
; Y = YT
	mov     	ax,[X]
	mov     	bx,[ZCos]
	imul    	bx               
	mov     	bp,ax
	mov     	ax,[Y]
	mov     	bx,[ZSin]
	imul    	bx               
	sub     	bp,ax            
	sar     	bp,8            
	mov     	[Xt],bp

	mov     	ax,[X]
	mov     	bx,[ZSin]
	imul    	bx              
	mov     	bp,ax
	mov     	ax,[Y]
	mov     	bx,[ZCos]
	imul    	bx             
	add     	bp,ax           
	sar     	bp,8           
	mov     	[Yt],bp

	mov     	ax,[Xt]         
	mov     	[X],ax
	mov     	ax,[Yt]
	mov     	[Y],ax

ret
endp rotate

proc mainproc
	call	setrotation	
	
	xor	si,si
;== определение фигуры ==

	cmp	[Figure],1
	jne	F1
	xor	si,si
	mov	cx,numpointscube
	jmp	draw

F1:	cmp	[Figure],2
	jne	F2
	mov 	si,Ksicube
	mov     	cx,numpointscube1
	jmp	draw

F2:	cmp	[figure],3
	jne	F3
	mov	si,ksicube01
	mov	cx,numpointscube2
	jmp	draw

F3:



;========================



draw:	call	rotate			;Поворот точки
	call	outpoint			;вывод точки
	add 	si,3			;Следующая точка
	loop	draw

	call	vwait

	xor	si,si
	xor	al,al			;Черный цвет = 0

;== Определение фигуры для удаления ==

	cmp	[Figure],1
	jne	Fd1
	mov	cx,numpointscube
	jmp	delet

Fd1:	cmp	[Figure],2
	jne	Fd2
	mov	cx,numpointscube1
	jmp	delet

Fd2:	cmp	[figure],3
	jne	Fd3
	mov	cx,numpointscube2
	jmp	delet

Fd3:

;=====================================
;===закрашивание точек===
delet:  	mov	di,[del+si]		;в ДИ координата очередной точки
	mov     	[byte ptr es:di],al	;её закрашивание
	add	si,3			;следующая точка
	loop 	delet
ret	
endp mainproc
;=======DATA=========================

Label SinCos Word       		; 256 значений, по 10 в строке(таблица синусов и косинусов)
dw 0,6,13,19,25,31,38,44,50,56
dw 62,68,74,80,86,92,98,104,109,115
dw 121,126,132,137,142,147,152,157,162,167
dw 172,177,181,185,190,194,198,202,206,209
dw 213,216,220,223,226,229,231,234,237,239
dw 241,243,245,247,248,250,251,252,253,254
dw 255,255,256,256,256,256,256,255,255,254
dw 253,252,251,250,248,247,245,243,241,239
dw 237,234,231,229,226,223,220,216,213,209
dw 206,202,198,194,190,185,181,177,172,167
dw 162,157,152,147,142,137,132,126,121,115
dw 109,104,98,92,86,80,74,68,62,56
dw 50,44,38,31,25,19,13,6,0,-6
dw -13,-19,-25,-31,-38,-44,-50,-56,-62,-68
dw -74,-80,-86,-92,-98,-104,-109,-115,-121,-126
dw -132,-137,-142,-147,-152,-157,-162,-167,-172,-177
dw -181,-185,-190,-194,-198,-202,-206,-209,-213,-216
dw -220,-223,-226,-229,-231,-234,-237,-239,-241,-243
dw -245,-247,-248,-250,-251,-252,-253,-254,-255,-255
dw -256,-256,-256,-256,-256,-255,-255,-254,-253,-252
dw -251,-250,-248,-247,-245,-243,-241,-239,-237,-234
dw -231,-229,-226,-223,-220,-216,-213,-209,-206,-202
dw -198,-194,-190,-185,-181,-177,-172,-167,-162,-157
dw -152,-147,-142,-137,-132,-126,-121,-115,-109,-104
dw -98,-92,-86,-80,-74,-68,-62,-56,-50,-44
dw -38,-31,-25,-19,-13,-6

Label Cube Byte           		; рассотяние между точками куба = 20
	c = -35            		; 5x*5y*5z=125 точек
	rept 5
              b = -35
              rept 5
                  a = -35
                  rept 5
                      db a,b,c
                      a = a + 20
           	  endm
              b = b + 20
              endm
        c = c + 20
        endm

Label Cube1 byte		;2 фигура

c=-35	
rept 80
db c,-35,-35
c=c+1
endm

c=-35	
rept 80          
db c,-35,45
c=c+1
endm

c=-35	
rept 80
db c,45,-35
c=c+1
endm

c=-35	
rept 80
db c,45,45
c=c+1
endm

c=-35	
rept 80
db -35,c,-35
c=c+1
endm

c=-35	
rept 80
db 45,c,-35
c=c+1
endm

c=-35	
rept 80
db -35,c,45
c=c+1
endm

c=-35	
rept 80
db 45,c,45
c=c+1
endm

c=-35	
rept 80
db -35,-35,c
c=c+1
endm

c=-35	
rept 80
db 45,-35,c
c=c+1
endm

c=-35	
rept 80
db -35,45,c
c=c+1
endm

c=-35	
rept 80
db 45,45,c
c=c+1
endm

label cube2 byte		;3 фигура
b = -35
rept 5
a = -35
rept 5
db a,b,-35
a = a + 20
endm
b = b + 20
endm

b = -35
rept 5
a = -35
rept 5
db a,b,45
a = a + 20
endm
b = b + 20
endm

c=-15
rept 3
b=-35
rept 2
a=-35
rept 5
db a,b,c
a = a + 20
endm
b = b + 80
endm
c=c+20
endm

c=-15
rept 3
a=-35
rept 2
b=-35
rept 5
db a,b,c
b = b + 20
endm
a = a + 80
endm
c=c+20
endm

Label Palette Byte             
       db 0,0,0                 
       d = 63
       rept 63
         db d,d,d
         db d,d,d
         db d,d,d
         d = d - 1
       endm

;label Palette byte 			; 2-ая палитра
;	 db  3 dup (0)
;            db  14 dup (60,40,30)    
;
;           db  63,0,0
;            db  2,0,0
;            db  7,0,0
 ;           db  9,0,0
;           db 12,0,0
;            db 15,0,0
;           db 17,0,0
;          db 20,0,0
;            db 22,0,0
;            db 25,0,0
 ;           db 30,0,0
  ;         db 35,0,0
   ;         db 40,0,0
    ;        db 45,0,0
     ;       db 50,0,0
;           db 63,0,0



X      	DW 	?            		;координаты точки
Y      	DW 	?
Z      	DW 	?

Xt     	DW 	?            
Yt     	DW 	?
Zt     	DW 	?

Xygol 	DW 	0             		;угол поворота
Yygol 	DW 	0
Zygol 	DW 	0

DeltaX 	DW 	?             		;скорость вращения вокруг осей
DeltaY 	DW 	?
DeltaZ 	DW 	?

Xoff   	DW 	?		;смещение обьекта относительно центра
Yoff   	DW 	?
Zoff   	DW 	?             		; расстояние от экрана до обьекта

XSin   	DW 	?             		;для подсчета матрицы поворота
XCos   	DW 	?
YSin   	DW 	?
YCos   	DW 	?
ZSin   	DW 	?
ZCos   	DW 	?

Figure	dw	?		;номер фигуры


Mx     	DW 	160           		; середина экрана
My     	DW 	100

NumPointsCube 	EQU	125        		; кол-во точек в кубе
NumpointsCube1	EQU	960
Numpointscube2	EQU	110
KsiCube		EQU	375		;125*3
Ksicube01		EQU	3255		;

Msg01	db	"1.Rotate$"
Msg02	db	"2.Load$"
Msg03	db	"3.Help$"
Msg04	db	"4.Exit$"
Msg10	db	"Cube-1$"
Msg20	db	"Cube-2$"
Msg30	db	"Cube-3$"
Msg41	db	"Rotation  X:$"
Msg42	db	"  Y:$"
Msg43	db	"  Z:$"
Msg44	db	"Distantion: $"
Msg45	db	"Continue: C   Save: X$"
Msg46	db	"                                         $"
Msg50	db	"HELP:                                   1,2,3- vibor objekta.                   Q,A- skorost' vraweniya vokryg osi X.   W,S- Rasstoyanie do ob'ekta po osi Z.   E,D- sdvig po gorizontali.              R,F- po vertikali.                      $"
Msg51	db	"Z- dannie kyba.                         (C- prodoljit', X- soxranit')           Esc- vihod v menu.                      Programmed by Yasko Michael.            21gryppa, 2 kyrs, FPM, 2005g.$"
Msg60	db	"No savings..$"

Mas	db	3 dup(?)

Filename	db	"d:\save.txt",0
Opis	dw	0			;Описатель файла
Del  	DW 	numPointsCube1 DUP (?)     	; массив адресов точек, для удаления


Buff	dw	?			;Буфер чтения из файла
Loo	dw	0			;Кол-во повторений цикла
ENDS	code
END	Start

