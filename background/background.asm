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


  LDA #%10000000   ;intensify blues
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
 

NMI:
  RTI
 
;;;;;;;;;;;;;;  

.segment "CHARS"
  .incbin "mario.chr"   ;includes 8KB graphics file from SMB1
