.286
INCLUDE IO.ASM

MODEL	small

ST1 SEGMENT             ;Описали сегмент стека;
	DB 1280 DUP(?)
ST1 ENDS

DATA SEGMENT

DATA ENDS

CODE SEGMENT            ;открыли сегмент кода;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;связали регистровые сегменты с сегментами;

draw proc
begin:  
  ; ds указывает на видеопамять  
  push 0b800H  
  pop ds  
  ; установить графический режим 40×25  
  int 10H  
  ; bx = 700H - смещение, по которому находиться грузовик  
  mov bh, 7H  
   
main_loop:  
        ; Задержка и вывод грузовика на экран  
        xchg cx, ax  ; mov ah, 0  
        int 1AH  
        mov [bx], dl 
        
    delay:  
        int 1AH  
        cmp [bx], dl  
            je delay  
        
        ; si - смещение следующего препятствия  
        xchg ax, si  
        add al, dl  
        xchg ax, si  
        
        xchg ax, cx   ; mov cx, 0  
        
        ; Получение нажатой клавиши  
        in al, 60H 
        
        cmp al, 77  
            jnz keytest1 
            
        ; вправо  
        inc bx  
        inc bx  
        
    keytest1:  
        ; влево  
        ja keytest2  
        dec bx  
        dec bx  
        
    keytest2:  
        ; очистка буфера клавиатуры  
        mov ah, 0CH  
        int 21H  
        
    ; скролл экрана на 1 строчку  
        mov ax, 0701H  
        mov dx, 1827H  
        int 10H  
            
    ; вывод препятствия  
        mov [si], ax  
        
    ; вывод травы и разделительной полосы  
        mov [di+51], dx  
        
    ; проверка что перед грузовиком нет препятствий  
        cmp [bx], dh  
            ja main_loop  
   
  ret  
;-------------------
Start:
	push	ds
	push	ax
	mov	ax, data	
	mov	ds, ax
;========== Ниже пишите Ваш код ==============================
	
	call Draw;
	

;========== Заканчивайте писать Ваш код======================
	pop	ax
	pop	ds
Exit:
	finish
ENDS

END	Start
