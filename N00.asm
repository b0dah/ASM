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
	mov	ax,0013h
	int	10h

; ᨬ���
	; ��६�饭�� �����
	mov	ah,02h		; ⨯ ���뢠���
	mov	bh,0		; ����� ��࠭��
	mov	dh,10		; (y) ��ப� (0..24; 25 ������ ����� ��������)
	mov	dl,10		; (x) ������� (0..79)
	int	10h		; ���뢠��� �� ��६�饭�� �����
	; �뢮� ᨬ���� �� ⥪�饥 ��������� �����
	mov	ah,09h		; ⨯ ���뢠���
	mov	al,'O'		; ᨬ��� (ASCII code)
	mov	cx,1		; ���-�� ������஢ ᨬ���� �������
	mov	bl,80		; 梥� (0..127)
	int	10h		; ���뢠��� �� �뢮� ᨬ����

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