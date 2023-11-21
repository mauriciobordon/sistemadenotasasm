TITLE notas
.MODEL SMALL
.STACK 100h
.DATA

    ;TABELA EXEMPLO
    ;NOME------------------------------P1----P2----P3----MEDIA
    ;Nome1-----------------------------00----00----00----00
    ;teste-----------------------------00----00----00----00
    ;Mauricio Lima Bordon--------------00----00----00----00
    ;Isabela Éverton Crestana----------00----00----00----00
    ;Ricardo Pannain-------------------00----00----00----00
    ;Pessoa 5--------------------------00----00----00----00

    ;Header na primeira linha. Restante:
    ; Ate 30 espacos para o nome, sendo completados com '-'
    ; 4 '-' para espacamento
    ; 2 espacos para a nota1
    ; 4 '-' para espacamento
    ; 2 espacos para a nota2
    ; 4 '-' para espacamento
    ; 2 espacos para a nota 3
    ; 4 '-' para espacamento
    ; 2 espacos para a media

    ;Nomes: armazenados na tabela
    ;Notas: armazeadas na tabela
    ;Pesos: armazenados na mensagem MSG_P_ATUAIS

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
    MSG_A_INSIRA DB 10,13,"Insira o nome do aluno (max 30 char): ", 30 DUP('_'), 30 DUP(8), '$'
    MSG_ERRANGE DB 10,13,"Valor fora do intervalo! Insira novamente: $"

;tabela:
    ;primeira linha (titulos) com 59 bytes
    ;segunda linha comeca com 2 bytes para linebreak (tratar primeira linha como 61 bytes)
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX

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
        LEA DX,MSG_A_INSIRA
        INT 21h

        MOV CX,30
        LEA DI,TABELA[61]
        CLD

        INSERE_A:
            MOV AH,2
            MOV DL,32
            INT 21h
            MOV DL,8
            INT 21h
            LE_ALUNO: MOV AH,1
            INT 21h
            CMP AL,13
            JE FIM
            CMP AL,8
            JE INSEREA_BACKESP
            STOSB
        LOOP INSERE_A
        JMP FIM

        INSEREA_BACKESP:
            
            CMP CX,30
            JE INICIAL
            MOV AH,2
            MOV DL,'_'
            INT 21h
            INT 21h
            MOV DL,8
            INT 21h
            INT 21h
            INC CX
            DEC DI
            MOV AL,'-'
            STOSB
            DEC DI
            JMP INSERE_A

        INICIAL:
            MOV AH,2
            MOV DL,32
            INT 21h
            JMP LE_ALUNO

        FIM:
        
        MOV AH,9
        LEA DX,TABELA
        INT 21h
        
        RET

    @NOVOALUNO ENDP


END MAIN

;VER SE COMPENSA ASPAS SIMPLES OU DUPLAS
;IMPLEMENTAR _ NAS NOTAS
;CORES NA MEDIA
;NA EDITAR, FAZER PRINTAR O NOME DELE E COMEÇA NO FINAL, PARA PODER APAGAR MELHOR
;MENSAGEM DE MAXIMO ATINGIDO, ALTERE OU EXCLUA ALGUM (EXCLUA UM PARA ADICIONAR OU ALTERE UM EXISTENTE)
;alunos_atual
;organizar .data: pode compensar guardar as informacoes dentro só da propria tabela ou mensagens
;para editar, pegar da propria tabela: colocar um $ temporario e armazenar o valor onde o $ vai entrar em cima num registrador (o $ deve ser colocado em cima de um "-" - talvez nao precise de registrador -, ou seja, é necessario usar as instrucoes novas para descobrir onde fica o primeiro da linha
;colocar uma tabela de conversao dos chars que assembly nao le (como o Ç)
;adicionar leitura de acentos