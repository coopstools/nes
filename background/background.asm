.segment "HEADER"
  .byte $4E, $45, $53, $1A
  .byte 1               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $00, $01       ; mapper 0, vertical mirroring

.segment "VECTORS"
  .addr NMI
  .addr RESET
  .addr 0

.segment "STARTUP"

.segment "CODE"

RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2

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
  cpx #$20
  bne @loop
; begin loading sprites into ram
  LDA #$80
  STA $0200        ; put sprite 0 in center ($80) of screen vert
  STA $0203        ; put sprite 0 in center ($80) of screen horiz
  LDA #$00
  STA $0201        ; tile number = 0
  STA $0202        ; color = 0, no flipping
; enable rendering
  lda #%10000000	; Enable NMI
  sta $2000
  lda #%00010000	; Enable Sprites
  sta $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
NMI:
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer

  RTI        ; return from interrupt
 
palettes:
  ; Background Palette
  .byte $0f, $12, $36, $3a
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00
  .byte $0f, $00, $00, $00

  ; Sprite Palette
  .byte $0F, $1C, $15, $14
  .byte $0F, $02, $38, $3C
  .byte $0F, $1C, $15, $14
  .byte $0F, $02, $38, $3C

.segment "CHARS"
  .org $0000
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
