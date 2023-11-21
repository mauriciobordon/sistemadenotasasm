TITLE teste
.MODEL SMALL
.STACK 100h
.DATA
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX

        INICIO:
            MOV AH,1
            INT 21h

            MOV DL,AL

            MOV AH,2
            INT 21h

            MOV DL,13
            INT 21h
        LOOP INICIO

        MOV AH,4CH
        INT 21h

    MAIN ENDP

END MAIN    