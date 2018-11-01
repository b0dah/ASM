cgroup group CODE_SEG, DATA_SEG
assume cs:cgroup, ds:cgroup
title PITON
.186 ; для команды push 0A00h
 
CODE_SEG segment byte public
org 100h ; COM-файл


public start

start proc near ;  ==== PROC MAIN
        mov ax, 3
        int 10h   ;  граф реж 
        
        mov ah, 9
        lea dx, menu
        int 21h
        @0:
        mov ah, 1
        int 21h
        cmp al, '1'
        jz @1
        cmp al, '2'
        jz _begin
        cmp al, '3'
        jz @3
        jmp @0
        @1:
        mov ah, 9
        lea dx, about
        int 21h
        jmp @0
        @3: jmp _exit
        _begin:
        
        mov ax,cs
        add ax,1000h
        mov ds,ax
        
        push 0A000h ; 0A000h
        pop es
        mov ax,13h
        int 10h
        mov di,320*200
        mov cx,600h
        rep stosb
        xor si,si ; начальный адрес хвоста в DS:SI
        mov bp,10 ; начальная длина питона - 10
        jmp init_food ; создать первую еду
        main_cycle:
        ; использование регистров в этой программе:
        ; AX - различное
        ; BX - адрес головы, хвоста или еды на экране
        ; CX - 0 (старшее слово числа микросекунд для функции задержки)
        ; DX - не используется (модифицируется процедурой random)
        ; DS - сегмент данных программы (следующий после сегмента кода)
        ; ES - видеопамять
        ; DS:DI - адрес головы
        ; DS:SI - адрес хвоста
        ; BP - добавочная длина (питон растет, пока BP > 0, BP уменьшается на каждом шаге,
        ; пока не станет нулем)
        mov dx,40000 ; пауза - 20 000 микросекунд
        ;mov ah,86h ; (CX = 0 после REP STOSB и
        ; больше не меняется)
        ;int 15h ; задержка
        call delay
        mov ah,1 ; проверка состояния клавиатуры
        int 16h
        jz short no_keypress ; если клавиша не нажата -
        xor ah,ah ; AH = 0 - считать скан-код
        int 16h ; нажатой клавиши в AH,
        cmp al, '3'
        jz _exit
        cmp ah,48h ; если это стрелка вверх,
        jne short not_up
        mov word ptr cs:move_direction,-320 ; изменить
        ; направление движения на "вверх",
        not_up:
        cmp ah,50h ; если это стрелка вниз,
        jne short not_down
        mov word ptr cs:move_direction,320 ; изменить
        ; направление движения на "вниз",
        not_down:
        cmp ah,4Bh ; если это стрелка влево,
        jne short not_left
        mov word ptr cs:move_direction,-1 ; изменить
        ; направление движения на "влево",
        not_left:
        cmp ah,4Dh ; если это стрелка вправо,
        jne short no_keypress
        mov word ptr cs:move_direction,1 ; изменить
        ; направление движения на "вправо",
        no_keypress:
        and bp,bp ; если питон растет (BP > 0),
        jnz short advance_head ; пропустить стирание хвоста,
        lodsw ; иначе: считать адрес хвоста из
        ; DS:SI в AX и увеличить SI на 2
        xchg bx,ax
        mov byte ptr es:[bx],0 ; стереть хвост на экране,
        mov bx,ax
        inc bp ; увеличить BP, чтобы следующая
        ; команда вернула его в 0,
        advance_head:
        dec bp ; уменьшить BP, так как питон
        ; вырос на 1, если стирание хвоста было пропущено, или чтобы вернуть его в 0 - в
        ; другом случае
        add bx,word ptr cs:move_direction
        ; bx = следующая координата головы
        mov al,es:[bx] ; проверить содержимое экрана в точке с
        ; этой координатой,
        and al,al ; если там ничего нет,
        jz short move_worm ; передвинуть голову,
        cmp al,0Dh ; если там еда,
        je short grow_worm ; увеличить длину питона,
        _exit:
        mov ax,3 ; иначе - питон умер,
        int 10h ; перейти в текстовый режим
        retn ; и завершить программу
        move_worm:
        mov [di],bx ; поместить адрес головы в DS:DI
        inc di
        inc di ; и увеличить DI на 2,
        mov byte ptr es:[bx],09 ; вывести точку на экран,
        cmp byte ptr cs:eaten_food,1 ; если предыдущим
        ; ходом была съедена еда,
        je if_eaten_food ; создать новую еду,
        jmp short main_cycle ; иначе - продолжить основной
        ; цикл
        grow_worm:
        push bx ; сохранить адрес головы
        mov bx,word ptr cs:food_at ; bx - адрес еды
        xor ax,ax ; AX = 0
        call draw_food ; стереть еду
        call random ; AX - случайное число
        and ax,3Fh ; AX - случайное число от 0 до 63
        mov bp,ax ; это число будет добавкой к
        ; длине питона
        mov byte ptr cs:eaten_food,1 ; установить флаг
        ; для генерации еды на следующем ходе
        pop bx ; восстановить адрес головы BX
        jmp short move_worm ; перейти к движению питона
        if_eaten_food: ; переход сюда, если еда была съедена
        mov byte ptr cs:eaten_food,0 ; восстановить флаг
        init_food: ; переход сюда в самом начале
        push bx ; сохранить адрес головы
        make_food:
        call random ; AX - случайное число
        and ax,0FFFEh ; AX - случайное четное число
        mov bx,ax ; BX - новый адрес для еды
        xor ax,ax
        cmp word ptr es:[bx],ax ; если по этому адресу
        ; находится тело питона
        jne make_food ; еще раз сгенерировать случайный адрес
        cmp word ptr es:[bx+320],ax ; если на строку ниже
        ; находится тело питона
        jne make_food ; то же самое
        mov word ptr cs:food_at,bx ; поместить новый адрес
        ; еды в food_at,
        mov ax,0D0Dh ; цвет еды в AX
        call draw_food ; нарисовать еду на экране
        pop bx
        jmp main_cycle
start endp
 
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
        mov es:[bx],ax
        mov word ptr es:[bx+320],ax
        retn
draw_food endp
;------------------------------------ 
public random
random proc near
    mov ax,word ptr cs:seed
    mov dx,8E45h
    mul dx
    inc ax
    mov cs:word ptr seed,ax
    retn
random endp
CODE_SEG ends
 
;###############
DATA_SEG segment para public
; переменные
 
 menu   db '1. About', 0ah, 0dh
        db '2. Game start', 0ah, 0dh
        db '3. Exit', 0ah, 0dh, '$'
about   db 0ah, 0dh, ' afftar: ...', 0ah, 0dh, '$'
 
eaten_food db 0
move_direction dw 1 ; направление движения: 1 - вправо,
; -1 - влево, 320 - вниз, -320 - вверх
seed: ; это число хранится за концом, программы
food_at equ seed+2 ; а это - за предыдущим
DATA_SEG ends
 
end start
