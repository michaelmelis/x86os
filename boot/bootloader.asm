%define BIOS_START 0x7c00	; BIOS loads bootsector to this address
%define START_SS 0x07e0
%define START_SP 0x08f0
%define NEWBLSEG 0x0900
%define PRTBLSTRT 0x01bfe + 0x7c00 ; Start of partition table
%define PRTBLEND 0x01fd + 0x7c00   ; End of partition table
%define PRTBLSZ PRTBLEND - PRTBLSTRT

	bits	16

dap:
	db	0x10
	db	0x00
blkcnt:	dw	0x0003
	dw	PRTBLSZ
	dw	0x0000
	dd	0x0000_0001
	dd	0x0000_0000

drive_num:
	dw	0

	;; Set up segments
	mov	[drive_num], ax
	mov	ax, BIOS_START
	mov	ds, ax
	mov	ax, NEWBLSEG
	mov	es, ax
	mov	ax, START_SS
	mov	ss, ax
	mov	sp, START_SP

	;; Move the partition table to the begining of the
	;; new bootloader code (0x9000)
	mov	si, PRTBLSTRT
	xor	di, di
	mov	cx, PRTBLSZ
	rep
	movsb

	;; Read stage 2 of bootloader to 9000:0000 + PRTBLSZ
	;; from sectors 2,3,4 (1 indexed)
	xor	ax, ax
	xor	dx, dx
	mov	dl, [drive_num]
	mov	si, dap
	mov	ah, 0x42
	int	0x13		;BIOS extended read (LBA)

	;; jmp to newly read-in bootloader code
	jmp	[es:blkcnt]

	times  510 - ($ - $$) db 0
	
	
