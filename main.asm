[org 0x0100]
jmp startingScreen
timer:
push ax
cmp word[scrollMapFlag], 1
je timerExit
dec word[scrollMapCounter]
cmp word[scrollMapCounter], 0
je timerFlagUpdate
jmp timerExit
timerFlagUpdate:
mov word[scrollMapFlag], 1
mov word[scrollMapCounter], 3
timerExit:
mov al, 0x20
out 0x20, al
pop ax
iret
gameplaykbisr:
push ax
cmp word[escPressed], 1
jne gameplaykbisrNext
pop ax
jmp far [cs:oldisr]
gameplaykbisrNext:
in al, 0x60
cmp al, 0x4D
je rightArrowPressed
cmp al, 0x4B
je leftArrowPressed
cmp al, 0x01
je actualEscapePressed
jmp noChainEnd
rightArrowPressed:
add word[tempCarCol], 13
cmp word[tempCarCol], 52
ja escapePressed
jmp noChainEnd
leftArrowPressed:
sub word[tempCarCol], 13
cmp word[tempCarCol], 18
jb escapePressed
jmp noChainEnd
escapePressed:
mov word[exitFlag], 1
jmp noChainEnd
actualEscapePressed:
mov word[escPressed], 1

noChainEnd:
mov al, 0x20
out 0x20, al
pop ax
iret

startingkbisr:
push ax

in al, 0x60
cmp al, 0x39
je spacePressed
jmp noChainEndStarting
spacePressed:
mov word[startGameFlag], 1
jmp noChainEndStarting

noChainEndStarting:
mov al, 0x20
out 0x20, al
pop ax
iret

clearScreen:
push bp
mov bp, sp
push es
pusha

mov ax, 0xb800
mov es, ax
mov di, 0
mov ax, [bp+4]
mov cx, 2000
l1:
mov [es:di], ax
add di, 2
loop l1

popa
pop es
pop bp
ret 2

printCols:
push bp
mov bp, sp
push es
pusha

mov bx, [bp+8]
mov si, [bp+6]
cmp si, 79
ja inv
add si, 1
cmp bx, si
ja inv
mov ax, 0xb800
mov es, ax
mov di, bx
shl di, 1
mov ax, [bp+4]
mov cx, 25
l2:
mov dx, si
sub dx, bx
l3:
mov [es:di], ax
add di, 2
sub dx, 1
jnz l3
add di, 160
mov dx, si
sub dx, bx
shl dx, 1
sub di, dx
loop l2
inv:

popa
pop es
pop bp
ret 6

lineCol:
push bp
mov bp, sp
push es
pusha

mov dx, [bp+4]
mov ax, 0xb800
mov es, ax
mov di, dx
shl di, 1
add di, 160
mov ax, 0x7720
mov cx, 5
lineColL1:
mov dx, 3
lineColL2:
mov [es:di], ax
add di, 160
sub dx, 1
jnz lineColL2
add di, 320
loop lineColL1

popa
pop es
pop bp
ret 2

printLines:
push bp
mov bp, sp
pusha

push 33
call lineCol
push 46
call lineCol

popa
pop bp
ret

setDi:
push bp
mov bp, sp
pusha

mov di, 0
mov dx, [bp+6]
mov cx, 80
mulLoop:
add di, dx
loop mulLoop
add di, [bp+4]
shl di, 1
mov [bp+8], di

popa
pop bp
ret 4

tree:            ;bp->   4:size   6:treeValue   8:truckValue   10:col   12:row
push bp
mov bp, sp
push es
pusha

mov ax, 0xb800
mov es, ax
push 0
push word[bp+12] ;row
push word[bp+10] ;col
call setDi
pop di
mov cx, [bp+4]
mov ax, [bp+8]
treeL1:
mov [es:di], ax
sub di, 160
loop treeL1
mov ax, [bp+6]
mov dx, [bp+4]
cmp dx, 2
je size2TreeTop
jmp size3TreeTop
size2TreeTop:
mov [es:di], ax
sub di, 2
mov [es:di], ax
add di, 4
mov [es:di], ax
sub di, 160
mov [es:di], ax
sub di, 2
mov [es:di], ax
sub di, 2
mov [es:di], ax
sub di, 160
add di, 2
mov [es:di], ax
jmp treeExit
size3TreeTop:
mov [es:di], ax
sub di, 4
mov [es:di], ax
add di, 2
mov [es:di], ax
add di, 4
mov [es:di], ax
add di, 2
mov [es:di], ax
sub di, 160
mov cx, 5
size3TreeTopl1:
mov [es:di], ax
sub di, 2
loop size3TreeTopl1
sub di, 160
add di, 4
mov [es:di], ax
add di, 2
mov [es:di], ax
add di, 2
mov [es:di], ax
sub di, 160
sub di, 2
mov [es:di], ax
jmp treeExit
treeExit:

popa
pop es
pop bp
ret 10

printTrees:
push bp
mov bp, sp
push es
pusha

push 21 ;row
push 13 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 2 ;tree size
call tree
push 11 ;row
push 4 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 2 ;tree size
call tree
push 20 ;row
push 6 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 3 ;tree size
call tree
push 10 ;row
push 12 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 3 ;tree size
call tree
push 22 ;row
push 66 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 3 ;tree size
call tree
push 17 ;row
push 73 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 2 ;tree size
call tree
push 11 ;row
push 64 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 2 ;tree size
call tree
push 10 ;row
push 75 ;column
push 0x6720 ;trunk value
push 0x2720 ;tree value
push 3 ;tree size
call tree

popa
pop es
pop bp
ret

printMap:
push bp
mov bp, sp
push es
pusha

push 0x0ADB
call clearScreen
push 19
push 60
push 0x0720
call printCols
push 20
push 20
push 0x6720
call printCols
push 59
push 59
push 0x6720
call printCols
call printLines
call printTrees

popa
pop es
pop bp
ret

printBox:        ; bp->  4:endRow  6:startRow  8:endCol  10:startCol  12:value
push bp
mov bp, sp
push es
pusha

mov ax, 0xb800
mov es, ax
mov bx, [bp+10]
mov si, [bp+8]
add si, 1
cmp bx, si
ja printBoxInv
mov cx, [bp+4]
add cx, 1
cmp [bp+6], cx
ja printBoxInv
mov ax, [bp+12]
sub cx, [bp+6]
push 0
push word[bp+6]
push word[bp+10]
call setDi
pop di
printBoxL1:
mov dx, si
sub dx, bx
printBoxL2:
mov [es:di], ax
add di, 2
sub dx, 1
jnz printBoxL2
add di, 160
mov dx, si
sub dx, bx
shl dx, 1
sub di, dx
loop printBoxL1
printBoxInv:

popa
pop es
pop bp
ret 10

loadBuffer: ;bp-> 4:no.OfCols 6:no.OfRows 8:startCol 10:startRow 12:buffer 14:bufferDataSegment
push bp
mov bp, sp
push es
push ds
pusha

mov ax, [bp+10]
mov bx, [bp+8]
push 0
push ax
push bx
call setDi
pop si
mov ax, 0xb800
mov ds, ax
mov ax, [bp+14]
mov es, ax
mov di, [bp+12]
mov dx, [bp+6]
mov bx, [bp+4]
shl bx, 1
loadBufferL1:
mov cx, bx
shr cx, 1
cli
cld
rep movsw
sti
add si, 160
sub si, bx
dec dx
jnz loadBufferL1

popa
pop ds
pop es
pop bp
ret 12

unloadBuffer:;bp-> 4:no.OfCols 6:no.OfRows 8:startCol 10:startRow 12:buffer 14:bufferDataSegment
push bp
mov bp, sp
push es
push ds
pusha

mov ax, [bp+10]
mov bx, [bp+8]
push 0
push ax
push bx
call setDi
pop di
mov ax, 0xb800
mov es, ax
mov ax, [bp+14]
mov ds, ax
mov si, [bp+12]
mov dx, [bp+6]
mov bx, [bp+4]
shl bx, 1
unloadBufferL1:
mov cx, bx
shr cx, 1
cli
cld
rep movsw
sti
add di, 160
sub di, bx
dec dx
jnz unloadBufferL1

popa
pop ds
pop es
pop bp
ret 12

printCar:            ;bp->  4:initCarCol  6:initCarRow   8:carBuffer   10:bufferDataSegment
push bp
mov bp, sp
push es
pusha

; mov ax, [bp+4]
; mov cx, [bp+6]
; push word[bp+10]     ;bufferDataSegment
; push word[bp+8]      ;buffer
; push cx              ;row
; push ax              ;col
; push 7               ;no. of rows
; push 10              ;no. of cols
; call loadBuffer
mov ax, [bp+4]
mov cx, [bp+6]
push word[bp+10]     ;bufferDataSegment
push word[bp+8]      ;buffer
push 0               ;row
push 0               ;col
push 25              ;no. of rows
push 80              ;no. of cols
call loadBuffer
add ax, 1
mov bx, ax
add bx, 7
add cx, 1
mov dx, cx
add dx, 5
push 0x1720          ;value
push ax              ;startCol
push bx              ;endCol
push cx              ;startRow
push dx              ;endRow
call printBox
add ax, 1
sub bx, 1
add cx, 1
sub dx, 4
push 0x3720
push ax
push bx
push cx
push dx
call printBox
add cx, 2
add dx, 2
push 0x3720
push ax
push bx
push cx
push dx
call printBox
sub bx, 5
add cx, 2
add dx, 2
push 0x0CDB
push ax
push bx
push cx
push dx
call printBox
add ax, 5
add bx, 5
push 0x0CDB
push ax
push bx
push cx
push dx
call printBox
sub cx, 6
sub dx, 6
push 0x7720
push ax
push bx
push cx
push dx
call printBox
sub ax, 5
sub bx, 5
push 0x7720
push ax
push bx
push cx
push dx
call printBox
sub ax, 2
sub bx, 2
add cx, 2
add dx, 2
push 0x08DB
push ax
push bx
push cx
push dx
call printBox
add cx, 3
add dx, 3
push 0x08DB
push ax
push bx
push cx
push dx
call printBox
add ax, 9
add bx, 9
push 0x08DB
push ax
push bx
push cx
push dx
call printBox
sub cx, 3
sub dx, 3
push 0x08DB
push ax
push bx
push cx
push dx
call printBox

popa
pop es
pop bp
ret 8

scrollMap:          ; bp->   4:mapRowBuffer   6:bufferDataSegment
push bp
mov bp, sp
pusha
push es
push ds

push word[bp+6]      ;bufferDataSegment
push word[bp+4]      ;buffer
push 24              ;row
push 0               ;col
push 1               ;no. of rows
push 80              ;no. of cols
call loadBuffer
mov ax, 0xb800
mov es, ax
mov ds, ax
mov di, 3998
mov si, 3838
mov cx, 1920
cli
std
rep movsw
cld
sti
mov ax, [bp+6]
mov ds, ax
push word[bp+6]      ;bufferDataSegment
push word[bp+4]      ;buffer
push 0               ;row
push 0               ;col
push 1               ;no. of rows
push 80              ;no. of cols
call unloadBuffer

pop ds
pop es
popa
pop bp
ret 4

delay:               ; bp-> 4:delayCounter
push bp
mov bp, sp
push cx
push dx

mov dx, [bp+4]
delayL2:
mov cx, 0xFFFF
delayL1:
loop delayL1
dec dx
jnz delayL2

pop dx
pop cx
pop bp
ret 2

random:               ;bp->   4:upperBound    6:returnValue
push bp
mov bp, sp
pusha
push ds

push cs
pop ds
mov ax, [seedForRandom]
add ax, 29
mov [seedForRandom], ax
mov dx, 0
div word[bp+4] 
mov [bp+6], dx

pop ds
popa
pop bp
ret 2

printEnemyCar1:        ;bp->     4:col      6:row
push bp
mov bp, sp
pusha
push ds
push es

push cs
pop ds
mov ax, 0xb800
mov es, ax
push 0
push word[bp+6]
push word[bp+4]
call setDi
pop di
mov si, enemyCarBody
mov cx, 7
printCar1L1:
push cx
mov cx, 10
printCar1L3:
mov ax, [ds:si]
add si, 2
cmp di, 3998
ja printEnemyCar1SkipLine
mov [es:di], ax
printEnemyCar1SkipLine:
add di, 2
loop printCar1L3
pop cx
cmp di, 160
jb printEnemyCar1Exit
sub di, 180
loop printCar1L1
printEnemyCar1Exit:

pop es
pop ds
popa
pop bp
ret 4

printEnemyCar2:        ;bp->     4:col      6:row
push bp
mov bp, sp
pusha
push ds
push es

push cs
pop ds
mov ax, 0xb800
mov es, ax
push 0
push word[bp+6]
push word[bp+4]
call setDi
pop di
mov si, enemyCarBody
mov cx, 7
printCar2L2:
push cx
mov cx, 10
printCar2L3:
mov ax, [ds:si]
add si, 2
cmp di, 3998
ja printEnemyCar2SkipLine
mov [es:di], ax
printEnemyCar2SkipLine:
add di, 2
loop printCar2L3
pop cx
cmp di, 160
jb printEnemyCar2Exit
sub di, 180
loop printCar2L2
printEnemyCar2Exit:

pop es
pop ds
popa
pop bp
ret 4

generateCarRandom:
push bp
mov bp, sp
pusha
push ds

push cs
pop ds
dec word[car1Counter]
cmp word[car1Counter], 0
je enableCar1Flag
jmp enableCarFlagNext
enableCar1Flag:
mov word[car1Flag], 1
enableCarFlagNext:
dec word[car2Counter]
cmp word[car2Counter], 0
je enableCar2Flag
jmp enableCarFlagEnd
enableCar2Flag:
mov word[car2Flag], 1
enableCarFlagEnd:
cmp word[car1Flag], 1
je generateCar1
jmp generateCarRandomNext
generateCar1:
push word[enemyCar1Row]
push word[enemyCar1Col]
call printEnemyCar1
inc word[enemyCar1Row]
cmp word[enemyCar1Row], 32
ja generateCarRandomUpdate1
jmp generateCarRandomNext
generateCarRandomUpdate1:
mov word[enemyCar1Row], 0
push 0
mov ax, 3
push ax
call random
pop ax
push enemyCar1Col
push ax
call setEnemyCarLane
mov word[car1Counter], 25
mov word[car1Flag], 0
generateCarRandomNext:
cmp word[car2Flag], 1
je generateCar2
jmp generateCarRandomExit
generateCar2:
push word[enemyCar2Row]
push word[enemyCar2Col]
call printEnemyCar2
inc word[enemyCar2Row]
cmp word[enemyCar2Row], 32
ja generateCarRandomUpdate2
jmp generateCarRandomExit
generateCarRandomUpdate2:
mov word[enemyCar2Row], 0
push 0
mov ax, 3
push ax
call random
pop ax
push enemyCar2Col
push ax
call setEnemyCarLane
mov word[car2Counter], 25
mov word[car2Flag], 0

generateCarRandomExit:
pop ds
popa
pop bp
ret

setEnemyCarLane:     ;bp->    4:laneNumber    6:carColVariable
push bp
mov bp, sp
pusha
push ds
push es

push cs
pop ds
mov bx, [bp+6]
mov ax, [bp+4]
cmp ax, 0
je setLane1
cmp ax, 1
je setLane2
cmp ax, 2
je setLane3
setLane1:
mov word[bx], 22
jmp setEnemyCarLaneExit
setLane2:
mov word[bx], 35
jmp setEnemyCarLaneExit
setLane3:
mov word[bx], 48
jmp setEnemyCarLaneExit
	
setEnemyCarLaneExit:
pop es
pop ds
popa
pop bp
ret 4

checkCarsCollision:
push bp
mov bp, sp
pusha
push es
push ds

mov ax, [initCarRow]
add ax, 1
cmp ax, [enemyCar1Row]
jb row1Matched
cmp ax, [enemyCar2Row]
jb row2Matched
jmp checkCarsCollisionExit
row1Matched:
add ax, 13
cmp ax, [enemyCar1Row]
jb checkCarsCollisionExit
mov dx, [initCarCol]
add dx, 10
cmp dx, [enemyCar1Col]
jb checkCarsCollisionExit
sub dx, 20
cmp dx, [enemyCar1Col]
ja checkCarsCollisionExit
mov word[exitFlag], 1
row2Matched:
add ax, 7
cmp ax, [enemyCar2Row]
jb checkCarsCollisionExit
mov dx, [initCarCol]
add dx, 10
cmp dx, [enemyCar2Col]
jb checkCarsCollisionExit
sub dx, 20
cmp dx, [enemyCar2Col]
ja checkCarsCollisionExit
mov word[exitFlag], 1

checkCarsCollisionExit:
pop ds
pop es
popa
pop bp
ret

printBonusObject:      ;bp->   4:bonusObjectCol   6:bonusObjectRow
push bp
mov bp, sp
pusha
push es
push ds

push cs
pop ds
mov ax, 0xb800
mov es, ax
push 0
push word[bp+6]
push word[bp+4]
call setDi
pop di
mov si, bonusObjectBody
mov cx, 3
printBonusObjectL2:
push cx
mov cx, 6
printBonusObjectL3:
mov ax, [ds:si]
add si, 2
cmp di, 3998
ja printBonusObjectSkipLine
mov [es:di], ax
printBonusObjectSkipLine:
add di, 2
loop printBonusObjectL3
pop cx
cmp di, 160
jb printBonusObjectExit
sub di, 172
loop printBonusObjectL2
printBonusObjectExit:

pop ds
pop es
popa
pop bp
ret 4

generateBonusObjectRandom:
push bp
mov bp, sp
pusha
push es
push ds

dec word[bonusObjectCounter]
cmp word[bonusObjectCounter], 0
jne notEnableBonusObjectFlag
mov word[bonusObjectFlag], 1
notEnableBonusObjectFlag:
cmp word[bonusObjectFlag], 1
jne notPrintBonusObject
push word[bonusObjectRow]
push word[bonusObjectCol]
call printBonusObject
inc word[bonusObjectRow]
cmp word[bonusObjectRow], 28
ja printBonusObjectUpdate
jmp notPrintBonusObject
printBonusObjectUpdate:
mov word[bonusObjectRow], 0
push 0
mov ax, 3
push ax
call random
pop ax
push bonusObjectCol
push ax
call setEnemyCarLane
add word[bonusObjectCol], 2
mov word[bonusObjectFlag], 0
mov word[bonusObjectCounter], 50
notPrintBonusObject:

pop ds
pop es
popa
pop bp
ret

checkBonusObjectCollision:
push bp
mov bp, sp
pusha
push es
push ds

mov ax, [initCarRow]
;add ax, 1
cmp ax, [bonusObjectRow]
jb rowMatched
jmp checkBonusObjectCollisionExit
rowMatched:
add ax, 10
cmp ax, [bonusObjectRow]
jb checkBonusObjectCollisionExit
mov dx, [initCarCol]
add dx, 6
cmp dx, [bonusObjectCol]
jb checkBonusObjectCollisionExit
sub dx, 12
cmp dx, [bonusObjectCol]
ja checkBonusObjectCollisionExit
add word[score], 5
mov word[bonusObjectRow], 0
push 0
mov ax, 3
push ax
call random
pop ax
push bonusObjectCol
push ax
call setEnemyCarLane
add word[bonusObjectCol], 2
mov word[bonusObjectFlag], 0
mov word[bonusObjectCounter], 50

checkBonusObjectCollisionExit:
pop ds
pop es
popa
pop bp
ret

printScore:
push bp
mov bp, sp
pusha
push ds
push es

push cs
pop ds
mov ax, 0 ;xPos
push ax
mov ax, 1 ;yPos
push ax
mov ax, 0000000000100000b 
push ax; attribute (Black on Green)
mov bx, scoreString
push bx ;stringAddress
mov ax, 7
push ax ;stringLenght
call printStr
mov ax, 0000000000100000b
push ax
mov ax, 1
push ax
mov ax, 7
push ax
push word[score]
call printNum

pop es
pop ds
popa
pop bp
ret 

printStr:     ; copied from book page no. 111 
push bp       ; push order: xPos,yPos,attribute,stringAddress(Variable),strLenght
mov bp, sp    ; string must be written with db
push es
pusha

mov ax, 0xb800
mov es, ax
mov al, 80
mul byte[bp+10]
add ax, [bp+12]
shl ax, 1
mov di, ax
mov si, [bp+6]
mov cx, [bp+4]
mov ah, [bp+8]
cld
printStrNextChar:
lodsb
stosw
loop printStrNextChar

popa
pop es
pop bp
ret 10

printNum:   ;copied from book pg. 101 with addition of position of printing and attribute
push bp     ;bp->  4:number  6:Col   8:Row   10:Attribute
mov bp, sp  ;push order:   attribute, row, col, number
push es
pusha

mov ax, 0xb800
mov es, ax
mov ax, [bp+4]
mov bx, 10
mov cx, 0
printNumNextDigit:
mov dx, 0
div bx
add dl, 0x30
push dx
inc cx
cmp ax, 0
jnz printNumNextDigit
push 0
push word[bp+8]
push word[bp+6]
call setDi
pop di
printNumNextPos:
pop dx
mov dh, [bp+10]
mov [es:di], dx
add di, 2
loop printNumNextPos

popa
pop es
pop bp
ret 8

startingScreenChauhdry:
push bp
mov bp, sp
pusha
push es

mov ax, 0xb800
mov es, ax
push 0
mov ax, 7
push ax
mov ax, 11
push ax
call setDi
pop di
mov al, 0xDB
mov ah, 00000000b
mov [es:di], ax
add di, 2
mov cx, 5
rep stosw

pop es
popa
pop bp
ret

startingScreen:; push order: xPos,yPos,attribute,stringAddress(Variable),strLenght
mov ax, 0x0ADB
push ax
call clearScreen
mov ax, 27
push ax
mov ax, 10
push ax
mov ax, 0000000000100000b
push ax
mov bx, introString1
push bx
mov ax, 24
push ax
call printStr
mov ax, 17
push ax
mov ax, 11
push ax
mov ax, 0000000000100000b
push ax
mov bx, introString2
push bx
mov ax, 44
push ax
call printStr
mov ax, 17
push ax
mov ax, 12
push ax
mov ax, 0000000000100000b
push ax
mov bx, introString3
push bx
mov ax, 44
push ax
call printStr
mov ax, 29
push ax
mov ax, 13
push ax
mov ax, 0000000000100000b
push ax
mov bx, introString4
push bx
mov ax, 19
push ax
call printStr
mov ax, 24
push ax
mov ax, 15
push ax
mov ax, 0000000010100000b
push ax
mov bx, introString5
push bx
mov ax, 30
push ax
call printStr
xor ax, ax                        ;Hooking Start
mov es, ax
mov ax, [es:9*4]
mov [oldisr], ax
mov ax, [es:9*4+2]
mov [oldisr+2], ax
cli
mov word[es:9*4], startingkbisr
mov [es:9*4+2], cs                ;Hooking End
sti
startingScreenL1:
cmp word[startGameFlag], 1
jne startingScreenL1
jmp gameplay

pauseScreen:
push ax
mov ah, 0x00
int 0x16
cmp al, 'y'
je pauseScreenYPressed
cmp al, 'n'
je pauseScreenNPressed
call pauseScreen
jmp pauseScreenExit
pauseScreenYPressed:
mov word[exitFlag], 1
jmp pauseScreenExit
pauseScreenNPressed:
mov word[escPressed], 0
pauseScreenExit:
pop ax
ret

printPauseScreen:
pusha
push 0x08DB          ;value
push 22              ;startCol
push 57              ;endCol
push 6               ;startRow
push 17              ;endRow
call printBox
push 27       ;xPos
push 8        ;yPos
mov ax, 0000000000000111b 
push ax       ;attribute (White on Black)
mov bx, pauseScreenStr1
push bx       ;stringAddress
mov ax, 27
push ax       ;stringLenght
call printStr
push 27       ;xPos
push 15       ;yPos
mov ax, 0000000000000111b 
push ax       ;attribute (White on Black)
mov bx, pauseScreenStr2
push bx       ;stringAddress
mov ax, 6
push ax       ;stringLenght
call printStr
push 48       ;xPos
push 15       ;yPos
mov ax, 0000000000000111b 
push ax       ;attribute (White on Black)
mov bx, pauseScreenStr3
push bx       ;stringAddress
mov ax, 5
push ax       ;stringLenght
call printStr
popa
ret

gameplay:
cli                                       ;gameplay Hooking
mov word[es:9*4], gameplaykbisr           ;Hooking End
xor ax, ax
mov es, ax
mov ax, [es:8*4]
mov [oldtimer], ax
mov ax, [es:8*4+2]
mov [oldtimer+2], ax
mov word[es:8*4], timer
mov [es:8*4+2], cs
; Clear carBackBuffer
mov di, carBackBuffer
mov cx, 2000
mov ax, 0x0720
clearCarBuf:
    mov [di], ax
    add di, 2
    loop clearCarBuf 
call printMap
push ds
push carBackBuffer
push word[initCarRow]
push word[initCarCol]
call printCar
sti
gameLoop:
; push ds               ;bufferDataSegment
; push carBackBuffer    ;buffer
; push word[initCarRow] ;row
; push word[initCarCol] ;col
; push 7                ;no. of rows
; push 10               ;no. of cols
; call unloadBuffer
push ds                ;bufferDataSegment
push carBackBuffer     ;buffer
push 0                 ;row
push 0                 ;col
push 25                ;no. of rows
push 80                ;no. of cols
call unloadBuffer
cli
mov ax, [tempCarRow]
mov [initCarRow], ax
mov ax, [tempCarCol]
mov [initCarCol], ax
sti
push ds
push mapRowBuffer
cmp word[scrollMapFlag], 1
jne notScrollMap
call scrollMap
mov word[scrollMapFlag], 0
notScrollMap:
push ds
push carBackBuffer
push word[initCarRow]
push word[initCarCol]
call printCar
;print all the things here that don't need scrolling
call  generateCarRandom
call generateBonusObjectRandom
call checkBonusObjectCollision
call printScore
call checkCarsCollision
cmp word[escPressed], 1
jne gameLoopNext
push ds                     ;bufferDataSegment
push pauseScreenBuffer      ;buffer
push 0                      ;row
push 0                      ;col
push 25                     ;no. of rows
push 80                     ;no. of cols
call loadBuffer
call printPauseScreen
call pauseScreen
push ds                ;bufferDataSegment
push pauseScreenBuffer ;buffer
push 0                 ;row
push 0                 ;col
push 25                ;no. of rows
push 80                ;no. of cols
call unloadBuffer
gameLoopNext:
push 4
call delay
cmp word[exitFlag], 0
je gameLoop

exitGame:            ;along with unhooking
mov ax, [oldisr]
mov [es:9*4], ax
mov ax, [oldisr+2]
mov [es:9*4+2], ax
mov ax, [oldtimer]
mov [es:8*4], ax
mov ax, [oldtimer+2]
mov [es:8*4+2], ax
mov sp, 0xFFFE
mov ax, 0x0ADB
push ax
call clearScreen
mov ax, 33
push ax
mov ax, 11
push ax
mov ax, 0000000000100000b
push ax
mov bx, endString1
push bx
mov ax, 12
push ax
call printStr
mov ax, 34
push ax
mov ax, 12
push ax
mov ax, 0000000000100000b
push ax
mov bx, endString2
push bx
mov ax, 10
push ax
call printStr
mov ax, 35 ;xPos
push ax
mov ax, 14 ;yPos
push ax
mov ax, 0000000000100000b 
push ax; attribute (Black on Green)
mov bx, scoreString
push bx ;stringAddress
mov ax, 7
push ax ;stringLenght
call printStr
mov ax, 0000000000100000b
push ax
mov ax, 14
push ax
mov ax, 42
push ax
push word[score]
call printNum
mov ax, 0x4c00	
int 0x21	

oldtimer: dd 0
scrollMapCounter: dw 3
scrollMapFlag: dw 0
initCarRow: dw 17
initCarCol: dw 35
tempCarRow: dw 17
tempCarCol: dw 35
mapRowBuffer: times 80 dw 0x0720
carBackBuffer: times 2000 dw 0x0720
oldisr: dd 0
exitFlag: dw 0
seedForRandom: dw 5
enemyCarBody:
dw 0x0720, 0x0720, 0x7720, 0x0720, 0x0720, 0x0720, 0x0720, 0x7720, 0x0720, 0x0720
dw 0x0720, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x0720
dw 0x08DB, 0x4020, 0x3720, 0x3720, 0x3720, 0x3720, 0x3720, 0x3720, 0x4020, 0x08DB
dw 0x0720, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x0720
dw 0x0720, 0x4020, 0x3720, 0x3720, 0x3720, 0x3720, 0x3720, 0x3720, 0x4020, 0x0720
dw 0x08DB, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x4020, 0x08DB
dw 0x0720, 0x4020, 0x0CDB, 0x4020, 0x4020, 0x4020, 0x4020, 0x0CDB, 0x4020, 0x0720
enemyCar1Row: dw 0
enemyCar1Col: dw 35
enemyCar2Row: dw 0
enemyCar2Col: dw 48
car1Flag: dw 0
car2Flag: dw 0
car1Counter: dw 1
car2Counter: dw 18
bonusObjectBody:
dw 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB
dw 0x0EDB, 0x06DB, 0x06DB, 0x06DB, 0x06DB, 0x0EDB
dw 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB, 0x0EDB 
bonusObjectRow: dw 0
bonusObjectCol: dw 37
bonusObjectFlag: dw 0
bonusObjectCounter: dw 9
score: dw 0
scoreString: db 'Score: '
introString1: db 'Game Name: Block Driving'                     ;24 lenght
introString2: db 'Name1: Muhammad Ahmad Butt   Roll1: 24L-0889' ;44 lenght
introString3: db 'Name2: Anas Irfan            Roll2: 24L-0747' ;44 lenght
introString4: db 'Semester: Fall 2025'                          ;19 lenght
introString5: db 'Press SPACE to start the game!'               ;30 lenght
startGameFlag: dw 0
endString1: db 'Nice Attempt' ;12 lenght
endString2: db 'Game Over!'   ;10 lenght
escPressed: dw 0
pauseScreenBuffer: times 2000 dw 0x0720
pauseScreenStr1: db 'Do you really want to exit?'    ;27 lenght
pauseScreenStr2: db 'Yes(y)'                         ;6 lenght
pauseScreenStr3: db 'No(n)'                          ;5 lenght
