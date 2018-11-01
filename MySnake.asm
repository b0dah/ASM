; использование регистров в этой программе:
        ; AX - различное
        ; BX - адрес головы, хвоста или еды на экране
        ; CX - 0 (старшее слово числа микросекунд для функции задержки)
        ; DX - не используется (модифицируется процедурой random)
        ; DS - сегмент данных программы (следующий после сегмента кода)
        ; ES - видеопамять
        ; DS:DI - адрес головы
        ; DS:SI - адрес хвоста
        ; BP - добавочная длина (змейка растет, пока BP > 0, BP уменьшается на каждом шаге,
        ; пока не станет нулем)
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
    dir dw 1 ; направление движения: 1 - вправо,
    ; -1 - влево, 320 - вниз, -320 - вверх
    
    ;--------
    file_in_name	DB	'file_in.txt',0
    file_handler	DW	?	; хранит идентификатор файла
    
    char_buffer_size	EQU	100 ;                    размер массива
    char_buffer		DB	char_buffer_size DUP(?)
    
    ten dw 10
    negative dw ?
    revers dw ?
    point_count dw 0;
    
    OUTP DW char_buffer_size DUP(?)
    
    
DATA ENDS


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


            ; чтение из файла
                mov	ah,3fh			; 3fh для чтения, 40h для записи
                mov	bx,file_handler		; задание идентификатора файла
                mov	cx,char_buffer_size	; число считываемых байтов
                mov	dx,offset char_buffer	; задание адреса буфера ввода-вывода
                int	21h
                ; ax - число фактически считанных(или записаннных) байтов

                ;mov	char_buffer_count,ax

            ; закрытие файла(иначе данные будут потеряны)
                mov  ah,3eh
                mov  bx,file_handler	; задание идентификатора закрываемого файла
                int  21h
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
	
	  mov ax, 3
        int 10h   ;  граф реж 
        
        mov ah, 9
        lea dx, menu  ; вывод меню
        int 21h
        
    wait_for_key:
        mov ah, 1
        int 21h   ; проверка состояния клавиатуры (?)
        
       
        cmp al, ' '
            jz _begin
        
        cmp al, 27
            jz go_quit
        
        jmp wait_for_key
        
        
_begin:
        
        mov ax,cs
        add ax,1000h
        mov ds,ax
        
        push 0A000h ; 0A000h
        pop es;              ; видеопамять
        
        mov ax,13h ; |гр режим 320*200
        int 10h;     |
        
        mov di,320*200
        mov cx,600h
        
        rep stosb ; Заполнить блок из CX байт по адресу ES:DI содержимым AL
                ;(хх) нарисовали первоначального питона 
                
        ;---- reading ----
        call file_reading;
        
        call proc_ascii_to_dw     
        
        xor si,si ; начальный адрес хвоста в DS:SI - ноль
        ;mov si, OUTP[0]
        
        mov bp, 10 ; начальная длина змейкаа - 10
        ;mov bp, OUTP[2]
        
        jmp init_food ; создать первую еду
        
main_cycle:
        
        mov dx,40000 ; ПАУЗА - 20 000 микросекунд      ; mov ah,86h ; (CX = 0 после REP STOSB и больше не меняется)
        call delay
        
        
        mov ah,1 ; проверка состояния клавиатуры
        int 16h
        
        jz short no_keypress ; если клавиша не нажата -
        xor ah,ah ; AH = 0 - считать скан-код
        int 16h ; нажатой клавиши в AH,
       
        go_quit:
        cmp al, 27  ;|  EXITING     if pressed E at the any time ( 27 <==> ESC )
            jz _quit ;|
            
        cmp ah,48h ; если это стрелка вверх,
            jne short not_up
            
        mov word ptr cs:dir,-320 ; изменить
                                ; направление движения на "вверх",
        
        not_up:
        cmp ah,50h ; если это стрелка вниз,
            jne short not_down
            
        mov word ptr cs:dir,320 ; изменить
        ; направление движения на "вниз",
        
        not_down:
        cmp ah,4Bh ; если это стрелка влево,
            jne short not_left
            
        mov word ptr cs:dir,-1 ; изменить
        ; направление движения на "влево",
        
        not_left:
        cmp ah,4Dh ; если это стрелка вправо,
            jne short no_keypress
            
        mov word ptr cs:dir,1 ; изменить
        ; направление движения на "вправо",
        
        no_keypress:
        and bp,bp ; если змейка растет (BP > 0),
            jnz short advance_head ; пропустить стирание хвоста,
        
        lodsw ; иначе: считать адрес хвоста из DS:SI в AX и увеличить SI на 2 ( lodsw - загрузить строку в AX из индексного регистра )
        xchg bx,ax
        
        mov byte ptr es:[bx],0 ; стереть хвост на экране, - ячейка экрана - черная
        mov bx,ax
        inc bp ; увеличить BP, чтобы следующая
        ; команда вернула его в 0,
        
                ; движется вперед - стираем хвост
        
        advance_head: ; передвижение головы
        
        dec bp ; уменьшить BP, так как змейка вырос на 1, если стирание хвоста было пропущено, или чтобы вернуть его в 0 - в
        ; другом случае
        add bx,word ptr cs:dir
        ; bx = следующая координата головы
        mov al,es:[bx] ; проверить содержимое экрана в точке с
        ; этой координатой,
        and al,al ; если там ничего нет,
            jz short move_snake ; передвинуть голову,
            
        cmp al,0Dh ; если там еда,
            je short snake_grows ; увеличить длину змейки,
        
    _quit: ; ** 
        mov ax,3 ; иначе - змейка умер,
        int 10h ; перейти в текстовый режим
        ;retn ; и завершить программу
        jmp exit; ***
        
    ;<1> - не съел - просто движется
    move_snake:
        mov [di],bx ; поместить адрес головы в DS:DI
        inc di
        inc di ; и увеличить DI на 2,
        mov byte ptr es:[bx],02 ; вывести точку на экран, <GREEN>
        cmp byte ptr cs:eaten_food,1 ; если предыдущим ходом была съедена еда,
            je if_eaten_food ; создать новую еду,
        
        jmp short main_cycle ; иначе - продолжить основной цикл ( = countinue => )
        
    ;<2> - съел, растет
    snake_grows:
    push bx ; сохранить адрес головы
        mov bx,word ptr cs:food_at ; bx - адрес еды
        xor ax,ax ; AX = 0
        call draw_food ; стереть еду
        call random ; AX - случайное число
        and ax,3Fh ; AX - случайное число от 0 до 63
        mov bp,ax ; это число будет добавкой к длине змейки
        
        mov byte ptr cs:eaten_food,1 ; установить флаг
        ; для генерации еды на следующем ходе
        
    pop bx ; восстановить адрес головы BX
        
        jmp short move_snake ; перейти к движению 
        
        if_eaten_food: ; переход сюда, если еда была съедена
        mov byte ptr cs:eaten_food,0 ; восстановить флаг
        
        init_food: ; переход сюда в самом начале
    push bx ; сохранить адрес головы
        
        make_food:
            call random ; AX - случайное число
            and ax,0FFFEh ; AX - случайное четное число
            
            mov bx,ax ; BX - НОВЫЙ АДРЕС ДЛЯ ЕДЫ
            xor ax,ax
            
            cmp word ptr es:[bx],ax ; если по этому адресу находится тело змейки
                jne make_food ; еще раз сгенерировать случайный адрес (! чтобы не появилась на теле ! )
                
            cmp word ptr es:[bx+320],ax ; если на строку ниже находится тело змейки
                jne make_food ; то же самое
                
            mov word ptr cs:food_at,bx ; поместить новый адрес еды в food_at,
            
            mov ax,0D0Dh ; цвет еды в AX
            ;mov ax,13 ; цвет еды в AX
            call draw_food ; нарисовать еду на экране
        
    pop bx
jmp main_cycle
;------------------------------------------------------------
        seed: ; это число хранится за концом, программы

        food_at equ seed+2 ; а это - за предыдущим
                ; - для организации РАНДОМА 
;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish

ENDS



END	Start
