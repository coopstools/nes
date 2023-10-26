ldx #$00 	; Set SPR-RAM address to 0
  stx $2003 ; store value in X in location $2003
@loop:
  lda $0200, x 	; Load the sprite info
  sta $2004
  inx
  cpx #$20 ; end of sprite memory
  bne @loop

; latch controller
  lda #$01
  sta $4016
  lda #$00
  sta $4016       ; tell both the controllers to latch buttons

  lda $4016 ; player 1 - A
  lda $4016 ; player 1 - B
  lda $4016 ; player 1 - staRT
  lda $4016 ; player 1 - SELECT

; Read Up
  lda $4016       ; player 1 - UP
  AND #%00000001  ; only look at bit 0
  BEQ ReadUDone   ; branch to ReadADone if button is NOT pressed (0)
  lda #$ff
  sta $02fe
  lda #$00
  sta $02ff
  jsr mvgen
ReadUDone:        ; handling this button is done

; Read Down
  lda $4016
  AND #%00000001
  BEQ ReadDDone
  lda #$01
  sta $02fe
  lda #$00
  sta $02ff
  jsr mvgen
ReadDDone:

; Read Left
  lda $4016
  AND #%00000001
  BEQ ReadLDone
  lda #$ff
  sta $02fe
  lda #$03
  sta $02ff
  jsr mvgen
ReadLDone:

; Read Right
  lda $4016
  AND #%00000001
  BEQ ReadRDone
  lda #$01
  sta $02fe
  lda #$03
  sta $02ff
  jsr mvgen
ReadRDone:

  rti

mvgen:
  .include "mv.s"
