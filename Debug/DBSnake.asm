;
.286
INCLUDE IO.ASM

MODEL	small

ST1 SEGMENT             ;Описали сегмент стека;
	DB 1280 DUP(?)
ST1 ENDS


DATA SEGMENT
            ; переменные
    
    menu   db ' ', 0ah, 0dh
            db ' ', 0ah, 0dh
            db ' ', 0ah, 0dh
            db ' ', 0ah, 0dh
            db ' ', 0ah, 0dh
            db ' ============================== SNAKE ==============================', 0ah, 0dh
            db ' ', 0ah, 0dh
            db ' ', 0ah, 0dh
            db '     press |SPACE| to play      ', 0ah, 0dh
            db '     press |ESC| to exit     ', 0ah, 0dh, '$'
    
    eaten_food db 0
    move_direction dw 1 ; направление движения: 1 - вправо,
    ; -1 - влево, 320 - вниз, -320 - вверх
    
    ;--------
    file_in_name	DB	'file_in.txt',0
    file_handler	DW	?	; хранит идентификатор файла
    
    char_buffer_size	EQU	10 ;                    размер массива
    char_buffer		DB	char_buffer_size DUP(?)
    char_buffer_count	DW	0
    
    ten dw 10
    negative dw ?
    revers dw ?
    point_count dw 0;
    
    OUTP DW char_buffer_size DUP(?)
    
    
DATA ENDS

;===================================================================================
CODE SEGMENT            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;
        ;  == PROCEDURES ==
delay proc
    pusha
    mov ah, 0
    int 1ah
    mov bx,dx
    add bx, 1 ; задержка в тиках (1/18 сек)
    d1:
    int 1ah
    cmp dx, bx
    jb d1
    popa
    ret
delay endp
;--------------------------
    public draw_food
draw_food proc near
        mov es:[bx],ax ; ячейка сетки экрана получает цвет (| * |)
        mov word ptr es:[bx+320],ax
        retn        ; near return
draw_food endp
;------------------------------------ 
    public random
random proc near
    mov ax,word ptr cs:seed
    mov dx,8E45h
    mul dx
    inc ax
    mov cs:word ptr seed,ax
    retn        ; near return
random endp
;-------------------------------------
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
	    ;---- reading ----
        call file_reading;
        
        call proc_ascii_to_dw    
         ;===============
	 
    
        
        xor si,si ; начальный адрес хвоста в DS:SI - ноль
        ;mov si, 100
        
        ;mov bp, 100 ; начальная длина змейкаа - 10
        
        outint outp[0]
        mov bp, OUTP[0]
        
        outint bp
    
 
;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish

ENDS



END	Start
