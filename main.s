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

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

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
  lda devexp, x
  sta $0200, x
  inx
  cpx #$18
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
  ldx #$00 	; Set SPR-RAM address to 0
  stx $2003 ; store value in X in location $2003
@loop:
  lda $0200, x 	; Load the sprite info
  sta $2004
  inx
  cpx #$18
  bne @loop

; latch controller
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons

  LDA $4016 ; player 1 - A
  LDA $4016 ; player 1 - B
  LDA $4016 ; player 1 - START
  LDA $4016 ; player 1 - SELECT

; Read Up
  LDA $4016       ; player 1 - UP
  AND #%00000001  ; only look at bit 0
  BEQ ReadUDone   ; branch to ReadADone if button is NOT pressed (0)
  LDA #$ff
  STA $0218
  JSR mvud
ReadUDone:        ; handling this button is done

; Read Down
  LDA $4016
  AND #%00000001
  BEQ ReadDDone
  LDA #$01
  STA $0218
  JSR mvud
ReadDDone:

; Read Left
  LDA $4016
  AND #%00000001
  BEQ ReadLDone
  LDA #$ff
  STA $0218
  JSR mvlr                ; add instructions here to do something when button IS pressed (1)
ReadLDone:

; Read Right
  LDA $4016
  AND #%00000001
  BEQ ReadRDone
  LDA #$01
  STA $0218
  JSR mvlr
ReadRDone:

  rti

;;;;;;;;;;;;;;;;;;;
mvlr:
  LDA $0203
  CLC
  ADC $0218
  STA $0203
  STA $020f

  LDA $0207
  CLC
  ADC $0218
  STA $0207
  STA $0213

  LDA $020b
  CLC
  ADC $0218
  STA $020b
  STA $0217
  RTI

mvud:
  LDA $0200
  CLC
  ADC $0218
  STA $0200
  STA $0204
  STA $0208

  LDA $020c
  CLC
  ADC $0218
  STA $020c
  STA $0210
  STA $0214

  RTI

;;;;;;;;;;;;;;;;;;;

devexp: ; Y  CHR  ATTR   X
  .byte $60, $00, $00, $68 ; 00-03
  .byte $60, $01, $00, $71 ; 04-07
  .byte $60, $06, $00, $7a ; 08-0b
  .byte $69, $01, $00, $68 ; 0c-0f
  .byte $69, $07, $00, $71 ; 10-13
  .byte $69, $05, $00, $7a ; 14-17

; Character memory
.include "sprite.s"
