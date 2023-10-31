# nes
Messing With NES Assembler

## Installed Tools
```shell
brew install cc65 fceux
```
cc65 is our assembly compiler suite (it continas a few fun tools for C and assembly, but I am only using the nes compiler).

fceux is an NES emulator with a few nice debugging tools

## Build and Run
In the IDE, I normally setup a shell script that runs the command:
```shell
cl65 main.s --verbose --target nes -o demo.nes && fceux demo.nes --fullscreen 1
```
Pretty simply, this builds the source code in `main.s`, and outputs an NES rom to `demo.nes`. It then starts up an instance of `fceux` running the demo.nes rom.

# Internals

## Reserved Global Memory
| location | scope        | description |
| --- |--------------| --- |
| $02fd | intro screen | number of spites grouped in logo