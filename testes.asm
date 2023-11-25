TITLE projetin
.MODEL SMALL
.STACK 100h
.DATA
    PESOS DB 3 DUP(1)
    TABELA DB 10,13, "ID--NOME", 30 DUP('-'), "P1", 4 DUP('-'), "P2", 4 DUP('-'), "P3", 4 DUP('-'), "MEDIA"
           DB 5 DUP(10,13, "00--", 34 DUP('-'), 3 DUP("00", 4 DUP('-')), "00"), '$'
    TABELA2 DB 10,13, "NOME", 30 DUP( ), "P1", 4 DUP( ), "P2", 4 DUP( ), "P3", 4 DUP( ), "MEDIA"
            DB 5 DUP(10,13, 30 DUP( ), 4 DUP( ), "00", 4 DUP( ), "00", 4 DUP( ), "00", 4 DUP( ), "00"), '$'
    MSG_MENU DB 10,13,"Escolha uma opcao:"
             DB 10,13,"1- Incluir aluno"
             DB 10,13,"2- Incluir notas"
             DB 10,13,"3- Imprimir tabela"
             DB 10,13,"4- Alterar nota de aluno"
             DB 10,13,"5- Alterar peso de prova"
             DB 10,13,"6- Remover aluno$"
    MSG_P_ATUAIS DB 10,13,"Pesos atuais:"
              DB 10,13,"    P1: Y"
              DB 10,13,"    P2: Y"
              DB 10,13,"    P3: Y$"
    MSG_P_INSIRA DB 10,13,"Insira os novos pesos (valores de 1 a 9):$"
    MSG_P_NOVO DB 10,13,"    PX: $"
    MSG_ERRANGE DB 10,13,"Valor fora do intervalo! Insira novamente: $"

;tabela:
    ;primeira linha (titulos) com 59 bytes
    ;segunda linha comeca com 2 bytes para linebreak (tratar primeira linha como 61 bytes)
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX

        ;CALL @DEFPESO
        CALL PRINTATABELA


        MOV AH,4CH
        INT 21h

    MAIN ENDP

    PRINTATABELA PROC

        MOV AH,9
        LEA DX,TABELA
        INT 21h

        LEA BX,TABELA[121]
        ;ADD BX,41
        MOV BYTE PTR [BX],'X'
        

        INT 21h

        RET

    PRINTATABELA ENDP

    ; @DEFPESO PROC

    ;     LEA SI,PESOS
    ;     LEA DI,MSG_P_ATUAIS+25

    ;     MOV CX,3

    ;     LACO2:

    ;         MOV BL,[SI]
    ;         OR BL,30h
    ;         MOV [DI],BL
    ;         INC SI
    ;         ADD DI,11

    ;     LOOP LACO2

    ;     MOV AH,9
    ;     LEA DX,MSG_P_ATUAIS
    ;     INT 21h
    ;     LEA DX,MSG_P_INSIRA
    ;     INT 21h

    ;     MOV CX,3
    ;     MOV BL,31h
    ;     LEA SI,PESOS

    ;     LACO:
    ;         MOV AH,9
    ;         MOV MSG_P_NOVO[7],BL
    ;         LEA DX,MSG_P_NOVO
    ;         INT 21h
    ;         INC BL

    ;         LEPESO: MOV AH,1
    ;         INT 21h

    ;         CMP AL,'1'
    ;         JB ERRANGEPESO
    ;         CMP AL,'9'
    ;         JA ERRANGEPESO
            
    ;         MOV [SI],AL

    ;         AND AL,0Fh
    ;         INC SI

    ;     LOOP LACO

    ;     JMP RETORNAPESO
        
    ;     ERRANGEPESO:
    ;         MOV AH,9
    ;         LEA DX,MSG_ERRANGE
    ;         INT 21h
    ;         JMP LEPESO

    ;     RETORNAPESO: RET

    ; @DEFPESO ENDP

END MAIN

;adicionar correção de caixa de texto