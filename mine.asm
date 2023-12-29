assume 	cs:code,ds:data

data	segment
	indx	db 0
	indy	db 0
	pox		db 0
	poy		db 0
	snum	db 0
	msgt	db 'Mine Sweeping',0
	wint	db 'YOU WIN',0
	loset	db 'YOU FAILED',0
	exitt	db 'Press any key to exit.',0
	boldtt	db 0dah
			db 18 dup (0c4h)
			db 0bfh,0
	boldt	db 0c4h,0
	boldbt	db 0c0h
			db 18 dup (0c4h)
			db 0d9h,0
	minel	dw 11 dup (0)
			dw 9 dup (0,9 dup (0109h),0)
			dw 11 dup (0)
data	ends

code	segment
	init:
		mov ax,data
		mov ds,ax
		mov ax,0b800h
		mov es,ax
		xor bp,bp
		mov cx,2000
		il:
			mov byte ptr es:[bp],0
			add bp,2
			loop il
		ret
	output:
		push ax
		push bp
		push si
		push cx
		push dx
		mov ax,2
		mul byte ptr indx
		mov bp,ax
		mov ax,160
		mul byte ptr indy
		add bp,ax
		
		ol:
			mov al,ds:[si]
			cmp al,0
			je oe
			mov es:[bp],al
			inc si
			add bp,2
			jmp ol
		oe:
			cmp cl,1
			je onl
			mov ax,bp
			shr ax,1
			mov cl,80
			div cl
			mov byte ptr indx,ah
			mov byte ptr indy,al
			jmp oet
		onl:
			mov byte ptr indx,0
			inc byte ptr indy
		oet:
			pop dx
			pop cx
			pop si
			pop bp
			pop ax
			ret
	draw:
		push ax
		push bp
		push si
		push cx
		mov si,offset boldtt
		mov cl,1
		call output
		mov ax,2
		mul byte ptr indx
		mov bp,ax
		mov ax,160
		mul byte ptr indy
		add bp,ax
		mov si,offset minel
		add si,24
		mov cx,9
		dlh:
			push cx
			mov byte ptr es:[bp],0b3h
			add bp,2
			mov cx,9
			dll:
				mov al,ds:[si]
				cmp al,9
				je drw
				mov byte ptr es:[bp],' '
				add al,48
				mov byte ptr es:[bp+2],al
				jmp dnl
				drw:
					mov byte ptr es:[bp],0dbh
					mov byte ptr es:[bp+2],0dbh
				dnl:
					add bp,4
					add si,2
					loop dll
			mov byte ptr es:[bp],0b3h
			add si,4
			add bp,122
			add byte ptr indy,1
			pop cx
			loop dlh
		mov cl,1
		mov si,offset boldbt
		call output
		pop cx
		pop si
		pop bp
		pop ax
		ret
	pack:
		push ax
		push si
		push cx
		push dx
		mov si,offset minel
		mov cx,10
		pl:
			push cx
			mov ah,2ch
			int 21h
			xor ah,ah
			mov al,dl
			mov bx,ax
			shl bx,1
			cmp byte ptr ds:[si+bx+24+1],1
			jne rl
			mov byte ptr ds:[si+bx+24+1],2
			mov ax,dx
			pop cx
			loop pl
			jmp prt
			rl:
				pop cx
				inc cx
				loop pl
		prt:
			pop dx
			pop cx
			pop si
			pop ax
			ret
	show:
		push ax
		push bp
		push cx
		mov al,poy
		xor ah,ah
		mov cx,80
		mul cx
		mov bp,ax
		mov al,pox
		shl al,1
		xor ah,ah
		add bp,ax
		add bp,80*2+1
		shl bp,1
		inc bp
		xor byte ptr es:[bp],00001000b
		xor byte ptr es:[bp+2],00001000b
		pop cx
		pop bp
		pop ax
		ret

	main:
		call show
		ml:
			mov ah,0
			int 16h
			cmp ah,1
			je me
			cmp ah,4dh
			jne tl
			cmp byte ptr pox,8
			je mnle
			call show
			inc byte ptr pox
			jmp mnl
			tl:
				cmp ah,4bh
				jne tu
				cmp byte ptr pox,0
				je mnle
				call show
				dec byte ptr pox
				jmp mnl
			tu:
				cmp ah,48h
				jne td
				cmp byte ptr poy,0
				je mnle
				call show
				dec byte ptr poy
				jmp mnl
			td:
				cmp ah,50h
				jne to
				cmp byte ptr poy,8
				je mnle
				call show
				inc byte ptr poy
				jmp mnl
			to:
				cmp ah,39h
				jne mnle
				call open
				jmp mnle
			mnl:
				call show
			mnle:
				jmp ml
		me:
			ret
	open:
		push ax
		push si
		push cx
		push dx
		mov si,offset minel
		mov al,byte ptr poy
		inc al
		xor ah,ah
		mov cx,11
		mul cx
		shl ax,1
		add si,ax
		mov al,pox
		inc al
		xor ah,ah
		shl al,1
		add si,ax
		cmp byte ptr ds:[si+1],2
		jne co
		jmp exit
		co:
			xor cl,cl
			mov ch,byte ptr ds:[si+1-24]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1-22]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1-20]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1-2]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1+2]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1+20]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1+22]
			shr ch,1
			add cl,ch
			mov ch,byte ptr ds:[si+1+24]
			shr ch,1
			add cl,ch
			mov byte ptr ds:[si],cl
			mov byte ptr indx,0
			mov byte ptr indy,1
			call draw
			inc byte ptr snum
			cmp byte ptr snum,71
			je exitw
		pop dx
		pop cx
		pop si
		pop ax
		ret
	exitw:
		mov cl,1
		mov si,offset wint
		call output
		mov si,offset exitt
		call output
		jmp exitww
	exit:
		mov cl,1
		mov si,offset loset
		call output
		mov si,offset exitt
		call output
		mov bp,323
		mov si,offset minel
		add si,25
		mov cx,9
		ll:
			push cx
			mov cx,9
			lnl:
				cmp byte ptr ds:[si],2
				jne lsn
				mov byte ptr es:[bp],00001100b
				mov byte ptr es:[bp+2],00001100b
			lsn:
				add si,2
				add bp,4
				loop lnl
			add si,4
			add bp,124
			pop cx
			loop ll
	exitww:
		mov ah,0
		int 16h
	exitr:
		mov ax,4c00h
		int 21h
	start:
		call init
		mov cl,1
		mov si,offset msgt
		call output
		call draw
		call pack
		call main
		jmp exitr
code ends

end start