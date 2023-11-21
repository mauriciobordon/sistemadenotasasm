TITLE teste
.MODEL SMALL
.STACK 100h
.DATA
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX

        

        MOV AH,4CH
        INT 21h

    MAIN ENDP

END MAIN    