MODEL	small

ST1 SEGMENT             ;���ᠫ� ᥣ���� �⥪�;
	DB 128 DUP(?)
ST1 ENDS

DATA SEGMENT

DATA ENDS

CODE SEGMENT            ;���뫨 ᥣ���� ����;
ASSUME SS:ST1,DS:DATA,CS:CODE    ;�易�� ॣ���஢� ᥣ����� � ᥣ���⠬�;

Start:
	push	ds
	push	ax

	mov	ax, data	
	mov	ds, ax
;

; ��⠭���� EGA ����� ०���
	;mov ax, 13h
	mov	ax,12h
	int	10h

; �窠
	mov	ah,0ch		; ⨯ ���뢠���
	mov	al,10		; 梥� (0..127)
	;mov	cx,100		; ���न��� �� x (0..319)
	;mov	dx,100		; ���न��� �� y (0..199)
	;int	10h		; ���뢠��� �� �뢮� ���ᥫ�
	
	
	mov dx, 100
	mov cx, 100
	
draw:
    int 10h
    inc cx
    
    cmp cx, 500
        jle draw;

exitin:
; �������� ������ �� ������
	xor	ax,ax
	int	16h
; �����襭�� EGA ०���, ���室 � ⥪�⮢�
	mov	ax,0003h
	int	10h
; �����襭�� �ணࠬ��
	mov	ax,4c00h
	int	21h

;
	pop	ax
	pop	ds

ENDS

END	Start
