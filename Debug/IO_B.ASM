        Title  io_byte
;----------------------------------
sseg    segment PARA STACK 'stack'
        dw      40 DUP (?)
sseg    ends
;---    Сегмент данных ------------
dseg    segment PARA    'data'
Mess1   db      'Введите число A=$'
Mess2   db      'Умножили на   2=$'
TenB    db      10
TenW    dw      10

ResAsc  db      5 DUP ('.'),13,10,'$'
ResBin  db      0

;---        Поле для ввода
NamePar Label Byte
MaxLen  db 3
ActLen  db ?
NameFld db 5 DUP (' ');

dseg    ends

;----------------------------------
cseg    segment PARA    'code'
        ASSUME  cs:cseg, ds:dseg, ss:sseg, es:dseg	;nothing
;---    Основная процедура
main    proc    far
        push    ds              ; Регистр сегмента данных ds в стек
        sub     ax,ax           ; Очищаем регистр ax
        push    ax              ; и в стек
        mov     ax,dseg         ; Адрес сегмента кода
        mov     ds,ax           ;   в ds

        call    cls             ; Очистка экрана

;---    Ввод числа
        mov     dx,050Ah        ; Курсор в строку 5, столбец 10
        call    cur             ; Позиционирование курсора
        lea     dx,Mess1        ; Адрес сообщения 1 в dx
        call    OutMess         ; Вывод сообщения 1

        call    Input           ; Ввод числа в поле NameFld

        mov     dx,060Ah        ; Курсор в строку 6, столбец 10
        call    cur             ; Позиционирование курсора

        call    Asc2Bin         ; Преобразование ASCII в Bin
				; Результат в поле ResBin

        lea     dx,Mess2        ; Адрес сообщения 2 в dx
        call    OutMess         ; Вывод сообщения 2

	sub	ax,ax
	mov     al,ResBin       ; Число в ax
	add     al,al           ; Удваиваем число
	mov     ResBin,al       ; в поле результата

        call    Bin2Asc         ; Преобразование Bin в ASCII
				; Из ResBin в поле ResAsc

        lea     dx,ResAsc       ; Адрес результата в dx
        call    OutMess         ; Вывод результата
        ret                     ; Возврат в DOS
main    endp

;---    Преобразование ASCII в Bin
Asc2Bin proc    near
        lea     di,NameFld; 	; Адрес поля NameFld
        mov     bx,0		; Количество символов
        mov     TenB,10		; Множитель =10
        mov     ResBin,0        ; Результат пока =0
Next1:
	sub	ax,ax
        mov     al,ResBin       ; Готовимся к умножению
        mul     TenB            ; Умножаем на 10
        mov	ResBin,al	; Результат
        mov     cx,[di+bx]      ; Очередной слева символ
        and     cx,000Fh        ; "Очищаем" место "3"
        add     ResBin,cl       ; Накапливаем результат
        inc     bl              ; Считаем количество символов
        cmp     bl,ActLen	; Все ?
        jl	Next1		; Нет - продолжить
        ret
Asc2Bin endp

;---    Преобразование Bin в ASCII
Bin2Asc proc	near
        lea     si,ResAsc+4	; Адрес поля для правой цифры в ResAsc
        mov     ah,0
        mov     al,ResBin       ; Число для преобразования
Next2:
        cmp     al,10		; Число <10 ?
        jl      Exit            ; Да - выход
        mov     ah,0		; Очищаем часть делимого
        div     TenB            ; Делим на 10
        add     ah,30h          ; Добавляем к цифре "3"
        mov     [si],ah         ; Записываем очередной символ
        dec     si
        jmp     Next2           ; Повтор
Exit:
        add     al,30h          ; Добавляем к цифре "3"
        mov     [si],al         ; Записываем последний символ
        ret
Bin2Asc endp

;---        Ввод
input        proc
        mov        ah,0AH	; Номер функции "Ввод"
        lea        dx,NamePar	; Имя области ввода в dx
        int        21h
        ret
input        endp

;---    Вывод сообщения
OutMess proc    near
        mov     ah,09           ; Номер функции "вывод символа"
;       lea     dx,...			; !!! Адрес сообщения уже есть в dx
        int     21h
        ret
OutMess endp

;---    Позиционирование курсора
cur     proc    near
        mov     ah,02           ; Номер функции "позиционирование"
        mov     bh,00           ; Эранный режим 0
;        mov        dh,...              ; Номер строки
;        mov        dl,...              ; Номер столбца
        int     10h
        ret
cur     endp

;---    Очистка экрана
cls     proc    near
        mov     ax,0600h        ; Номер функции "скроллинг"
        mov     bh,07           ; Атрибут экрана (черно-белый)
        mov     cx,0000         ; Левая верхняя позиция курсора
        mov     dx,184Fh        ; Правая нижняя
        int     10h
        ret
cls     endp

cseg    ends
        end     main