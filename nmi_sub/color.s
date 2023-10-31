  ldx #$02      ; offset for pallet select
  lda $02fd     ; determine number of sprites by dividing last spot in memory by 4
  lsr
  lsr
  tay           ; load number of sprites into Y
  inc $0202 ; increment selected pallete
  lda $0202 ; load pallette
  and #$03 ; modulo pallete selected by 4 as it may be over 3
@inner_mvgen:
  sta $0200, x ; save pallete on current sprite
  inx
  inx
  inx
  inx
  clc
  dey
  bne @inner_mvgen
  rti
