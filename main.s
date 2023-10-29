.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a staRTUP section, even if it's empty
.segment "staRTUP"

; Main code segment for the program
.segment "CODE"

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
vblankwait1:
  bit $2002
  bpl vblankwait1

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

;; second wait for vblank, PPU is ready after this
vblankwait2:
  bit $2002
  bpl vblankwait2
; load sprites into ram
  ldx #$00
@next_sprite:
  lda hellorld, x
  sta $0200, x
  inx
  cpx #$24 ; end of sprite memory; should match line 7 intro.s
  bne @next_sprite

main:
load_palettes:
  lda $2002
  lda #$3f
  sta $2006
  lda #$00
  sta $2006
  ldx #$00
@loop:
  lda palettes, x
  sta $2007
  inx
  cpx #$18
  bne @loop

enable_rendering:
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

forever:
  jmp forever

;;;;;;;;;;;;;;;;;;;

nmi:
  .include "nmi_sub/intro.s"

;;;;;;;;;;;;;;;;;;;

hellorld: ; Y  CHR  ATTR   X
  .byte $60, $07, $00, $68 ; 00-03 H
  .byte $60, $04, $00, $71 ; 04-07 E
  .byte $60, $0b, $00, $7a ; 08-0b L
  .byte $60, $0b, $00, $83 ; 0c-0f L
  .byte $60, $0e, $00, $8c ; 10-13 O
  .byte $69, $11, $00, $7a ; 14-17 R
  .byte $69, $0b, $00, $83 ; 18-1b L
  .byte $69, $03, $00, $8c ; 1c-1f D
  .byte $69, $1a, $00, $95 ; 20-23

; Character memory
.include "sprite.s"
