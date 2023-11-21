TITLE notas
.MODEL SMALL
.STACK 100h
.DATA
    PESOS DB 8,5,9
    TABELA DB 10,13, "NOME", 30 DUP('-'), "P1", 4 DUP('-'), "P2", 4 DUP('-'), "P3", 4 DUP('-'), "MEDIA"
           DB 5 DUP(10,13, 30 DUP('-'), 4 DUP('-'), "00", 4 DUP('-'), "00", 4 DUP('-'), "00", 4 DUP('-'), "00"), '$'
    TABELA2 DB 10,13, "NOME", 30 DUP( ), "P1", 4 DUP( ), "P2", 4 DUP( ), "P3", 4 DUP( ), "MEDIA"
            DB 5 DUP(10,13, 30 DUP( ), 4 DUP( ), "00", 4 DUP( ), "00", 4 DUP( ), "00", 4 DUP( ), "00"), '$'
    MSG_MENU DB 10,13,"Escolha uma opcao:"
             DB 10,13,"1- Incluir aluno"
             DB 10,13,"2- Incluir/alterar notas" ;todos os alunos em uma prova ou uma nota individualmente
             DB 10,13,"3- Imprimir tabela"
             DB 10,13,"4- Alterar pesos das provas"
             DB 10,13,"5- Remover aluno$"
             ;editar aluno?
    MSG_P_ATUAIS DB 10,13,"Pesos atuais: $"
    MSG_P DB 10,13,"    PX: $"
    MSG_P_INSIRA DB 10,13,"Insira os novos pesos (valores de 0 a 9):$"
    MSG_A_NOME DB 10,13,"Insira o nome do aluno (max 30 char): $"
    MSG_A_LINE DB 30 DUP('_'),'$'
    MSG_ERRANGE DB 10,13,"Valor fora do intervalo! Insira novamente: $"

;tabela:
    ;primeira linha (titulos) com 59 bytes
    ;segunda linha comeca com 2 bytes para linebreak (tratar primeira linha como 61 bytes)
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX

        ;CALL @DEFPESO
        CALL @NOVOALUNO


        MOV AH,4CH
        INT 21h

    MAIN ENDP

    PRINTATABELA PROC

        MOV AH,9
        LEA DX,TABELA2
        INT 21h

        MOV CL,'4'
        MOV BX,1
        MOV SI,61

        MOV TABELA[SI][BX], CL

        LEA DX,TABELA
        INT 21h

        RET

    PRINTATABELA ENDP

    @DEFPESO PROC

        MOV AH,9
        LEA DX, MSG_P_ATUAIS
        INT 21h

        MOV CX,3
        MOV BL,31h
        LEA SI,PESOS

        PRINTA_P:
            MOV AH,9
            LEA DX,MSG_P
            MOV MSG_P[7],BL
            INT 21h
            MOV AH,2
            MOV DL,[SI]
            OR DL,30h
            INT 21h
            INC BL
            INC SI  
        LOOP PRINTA_P

        MOV AH,9
        LEA DX, MSG_P_INSIRA
        INT 21h

        MOV CX,3
        MOV BL,31h
        SUB SI,3

        INSERE_P:
            MOV AH,9
            LEA DX, MSG_P
            MOV MSG_P[7],BL
            INT 21h
            LE_PESO: MOV AH,1
            INT 21h
            CMP AL,30h
            JB DEFP_ERRANGE
            CMP AL,39h
            JA DEFP_ERRANGE
            MOV [SI],AL
            INC BL
            INC SI
        LOOP INSERE_P
        JMP DEFP_RET

        DEFP_ERRANGE:
            MOV AH,9
            LEA DX,MSG_ERRANGE
            INT 21h
            JMP LE_PESO

        DEFP_RET: RET

    @DEFPESO ENDP

    @NOVOALUNO PROC

        MOV AH,9
        LEA DX, MSG_A_NOME
        INT 21h
        ; LEA DX, MSG_A_LINE
        ; INT 21h
        

        MOV CX,30
        LEA DI,TABELA[61]
        MOV AH,1

        INSERE_A:

            LE_ALUNO: INT 21h
            CMP AL,13
            JE NOVOA_RET
            CMP AL,8 ;COMPARA COM BACKSPACE
            JE INSEREA_APAGA
            MOV [DI],AL
            INC DI

        LOOP INSERE_A
        JMP NOVOA_RET

        INSEREA_APAGA:
            MOV AH,2
            MOV DL,32 ;PRINTA ESPACO
            INT 21h
            MOV AH,1
            CMP CX,30 ;SE JA TIVER 30 NO CONTADOR, NAO EXECUTA ABAIXO
            JE LE_ALUNO
            MOV AH,2
            MOV DL,8
            INT 21h
            MOV AH,1
            INC CX
            JMP LE_ALUNO

        NOVOA_RET:

        MOV AH,9
        LEA DX,TABELA
        INT 21h

        RET

    @NOVOALUNO ENDP

END MAIN

;adicionar correção de caixa de texto
;VER SE EH MELHOR O JMP ANTES DO RET OU DEPOIS
;VER SE COMPENSA ASPAS SIMPLES OU DUPLAS