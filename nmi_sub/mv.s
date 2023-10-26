  ldx $02ff     ; determines whether X or Y is updated (0 for Y, 3 for X
  ldy #$08      ; determines how many sprites are updated
@inner_mvgen:
  lda $0200, x
  clc
  adc $02fe     ; determines offset for pos ($ff for -1, $01 for +1)
  sta $0200, x
  inx
  inx
  inx
  inx
  dey
  bne @inner_mvgen
  rti
