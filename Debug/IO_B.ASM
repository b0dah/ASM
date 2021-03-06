        Title  io_byte
;----------------------------------
sseg    segment PARA STACK 'stack'
        dw      40 DUP (?)
sseg    ends
;---    ������� ������ ------------
dseg    segment PARA    'data'
Mess1   db      '������ �᫮ A=$'
Mess2   db      '�������� ��   2=$'
TenB    db      10
TenW    dw      10

ResAsc  db      5 DUP ('.'),13,10,'$'
ResBin  db      0

;---        ���� ��� �����
NamePar Label Byte
MaxLen  db 3
ActLen  db ?
NameFld db 5 DUP (' ');

dseg    ends

;----------------------------------
cseg    segment PARA    'code'
        ASSUME  cs:cseg, ds:dseg, ss:sseg, es:dseg	;nothing
;---    �᭮���� ��楤��
main    proc    far
        push    ds              ; ������� ᥣ���� ������ ds � �⥪
        sub     ax,ax           ; ��頥� ॣ���� ax
        push    ax              ; � � �⥪
        mov     ax,dseg         ; ���� ᥣ���� ����
        mov     ds,ax           ;   � ds

        call    cls             ; ���⪠ ��࠭�

;---    ���� �᫠
        mov     dx,050Ah        ; ����� � ��ப� 5, �⮫��� 10
        call    cur             ; ����樮��஢���� �����
        lea     dx,Mess1        ; ���� ᮮ�饭�� 1 � dx
        call    OutMess         ; �뢮� ᮮ�饭�� 1

        call    Input           ; ���� �᫠ � ���� NameFld

        mov     dx,060Ah        ; ����� � ��ப� 6, �⮫��� 10
        call    cur             ; ����樮��஢���� �����

        call    Asc2Bin         ; �८�ࠧ������ ASCII � Bin
				; ������� � ���� ResBin

        lea     dx,Mess2        ; ���� ᮮ�饭�� 2 � dx
        call    OutMess         ; �뢮� ᮮ�饭�� 2

	sub	ax,ax
	mov     al,ResBin       ; ��᫮ � ax
	add     al,al           ; ��������� �᫮
	mov     ResBin,al       ; � ���� १����

        call    Bin2Asc         ; �८�ࠧ������ Bin � ASCII
				; �� ResBin � ���� ResAsc

        lea     dx,ResAsc       ; ���� १���� � dx
        call    OutMess         ; �뢮� १����
        ret                     ; ������ � DOS
main    endp

;---    �८�ࠧ������ ASCII � Bin
Asc2Bin proc    near
        lea     di,NameFld; 	; ���� ���� NameFld
        mov     bx,0		; ������⢮ ᨬ�����
        mov     TenB,10		; �����⥫� =10
        mov     ResBin,0        ; ������� ���� =0
Next1:
	sub	ax,ax
        mov     al,ResBin       ; ��⮢���� � 㬭������
        mul     TenB            ; �������� �� 10
        mov	ResBin,al	; �������
        mov     cx,[di+bx]      ; ��।��� ᫥�� ᨬ���
        and     cx,000Fh        ; "��頥�" ���� "3"
        add     ResBin,cl       ; ����������� १����
        inc     bl              ; ��⠥� ������⢮ ᨬ�����
        cmp     bl,ActLen	; �� ?
        jl	Next1		; ��� - �த������
        ret
Asc2Bin endp

;---    �८�ࠧ������ Bin � ASCII
Bin2Asc proc	near
        lea     si,ResAsc+4	; ���� ���� ��� �ࠢ�� ���� � ResAsc
        mov     ah,0
        mov     al,ResBin       ; ��᫮ ��� �८�ࠧ������
Next2:
        cmp     al,10		; ��᫮ <10 ?
        jl      Exit            ; �� - ��室
        mov     ah,0		; ��頥� ���� ��������
        div     TenB            ; ����� �� 10
        add     ah,30h          ; ������塞 � ��� "3"
        mov     [si],ah         ; �����뢠�� ��।��� ᨬ���
        dec     si
        jmp     Next2           ; �����
Exit:
        add     al,30h          ; ������塞 � ��� "3"
        mov     [si],al         ; �����뢠�� ��᫥���� ᨬ���
        ret
Bin2Asc endp

;---        ����
input        proc
        mov        ah,0AH	; ����� �㭪樨 "����"
        lea        dx,NamePar	; ��� ������ ����� � dx
        int        21h
        ret
input        endp

;---    �뢮� ᮮ�饭��
OutMess proc    near
        mov     ah,09           ; ����� �㭪樨 "�뢮� ᨬ����"
;       lea     dx,...			; !!! ���� ᮮ�饭�� 㦥 ���� � dx
        int     21h
        ret
OutMess endp

;---    ����樮��஢���� �����
cur     proc    near
        mov     ah,02           ; ����� �㭪樨 "����樮��஢����"
        mov     bh,00           ; �࠭�� ०�� 0
;        mov        dh,...              ; ����� ��ப�
;        mov        dl,...              ; ����� �⮫��
        int     10h
        ret
cur     endp

;---    ���⪠ ��࠭�
cls     proc    near
        mov     ax,0600h        ; ����� �㭪樨 "�஫����"
        mov     bh,07           ; ��ਡ�� ��࠭� (�୮-����)
        mov     cx,0000         ; ����� ������ ������ �����
        mov     dx,184Fh        ; �ࠢ�� ������
        int     10h
        ret
cls     endp

cseg    ends
        end     main