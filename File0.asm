; читает текст(не более 100 символов)
; из файла file_in_name(если файла нет, выводит сообщение ERR_FileNotFound),
; создает файл с именем file_out_name, выводит в него прочитанный текст,
; при успешном завершении выводит строку GoodEnd

MODEL	small

ST1 SEGMENT	; Сегмент стека

	DB	128	DUP(?)

ST1 ENDS

DATA SEGMENT

 ERR_FileNotFound	DB	'Error. Input file not found.',13,10,'$'
 GoodEnd		DB	'Read and write were successful.',13,10,'$'

 file_in_name		DB	'file_in.txt',0
 file_out_name		DB	'file_out.txt',0
 file_handler		DW	?	; хранит идентификатор файла

 char_buffer_size	EQU	100
 char_buffer		DB	char_buffer_size DUP(?)
 char_buffer_count	DW	0	; текущее число символов в буфере

DATA ENDS

CODE SEGMENT			; открыли сегмент кода
ASSUME SS:ST1,DS:DATA,CS:CODE	; связали регистровые сегменты с сегментами

Start:
	push	ds
	push	ax

	mov	ax, data	
	mov	ds, ax
;

; открытие существующего файла
	mov	ah,3dh
	mov	al,0	; режим доступа: 0 чтение, 1 запись, 2 чтение-запись
	mov	dx,offset file_in_name	; задание адреса имени файла
	int	21h
	mov	file_handler,ax		; сохранение идентификатора файла

	jnc	SkipErrNotFound		; переход если файл существует

	; обработка ошибки: вывод ERR_FileNotFound на экран
	mov	ax,@data
	mov	dx,offset ERR_FileNotFound
	mov	ah,09h
	int	21h
	jmp	exitin

SkipErrNotFound:

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

; создание файла(существующий перезаписывается)
	mov	ah,3ch
	mov	cx,0		; атрибут файла: 0 обычный,
	mov	dx,offset file_out_name	; задание адреса имени файла
	int	21h
	mov	file_handler,ax	; сохранение идентификатора файла

; вывод в файл
	mov	ah,40h			; 3fh для чтения, 40h для записи
	mov	bx,file_handler		; задание идентификатора файла
	mov	cx,char_buffer_count	; число записываемых байтов
	mov	dx,offset char_buffer	; задание адреса буфера ввода-вывода
	int	21h

; закрытие файла(иначе данные будут потеряны)
	mov  ah,3eh
	mov  bx,file_handler	; задание идентификатора закрываемого файла
	int  21h

	; вывод сообщения об успешном завершении на экран
	mov	ax,@data
	mov	dx,offset GoodEnd
	mov	ah,09h
	int	21h
	jmp	exitin

exitin:
; ожидание нажатия любой клавиши
	xor	ax,ax
	int	16h
; завершение программы
	mov	ax,4c00h
	int	21h

;
	pop	ax
	pop	ds

ENDS

END	Start
