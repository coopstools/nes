  ldx $02ff     ; determines whether X or Y is updated (0 for Y, 3 for X
  lda $02fd     ; determine number of sprites by dividing last spot in memory by 4
  lsr
  lsr
  tay           ; load number of sprites into Y
@inner_mvgen:
  lda $0200, x
  adc $02fe     ; determines offset for pos ($ff for -1, $01 for +1)
  sta $0200, x
  clc
  inx
  inx
  inx
  inx
  dey
  bne @inner_mvgen
  rti
