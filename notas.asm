TITLE notas
.MODEL SMALL

    RANGE_ERROR MACRO

        PUSH AX
        PUSH DX

        MOV AH,9
        LEA DX,MSG_ERRANGE
        INT 21h

        POP DX
        POP AX

    ENDM

    POSICIONA_LINHA MACRO registrador, linha

        PUSH CX
        PUSHF

        LEA registrador,TABELA[61]
        MOV CL,linha
        AND CX,0Fh

        PASSALINHA:
            ADD registrador,56
        LOOP PASSALINHA

        POPF
        POP CX

    ENDM

.STACK 100h
.DATA

    ;TABELA EXEMPLO
    ;NOME------------------------------P1----P2----P3----MEDIA
    ;teste-----------------------------00----00----00----00
    ;Mauricio Lima Bordon--------------00----00----00----00
    ;Isabela Everton Crestana----------00----00----00----00
    ;Ricardo Pannain-------------------00----00----00----00
    ;Pessoa 5--------------------------00----00----00----00

    ;Header na primeira linha. Restante:
    ; 30 espacos para o nome, sendo completados com '-'
    ; 4 '-' para espacamento
    ; 2 espacos para a nota1
    ; 4 '-' para espacamento
    ; 2 espacos para a nota2
    ; 4 '-' para espacamento
    ; 2 espacos para a nota 3
    ; 4 '-' para espacamento
    ; 2 espacos para a media

    ;Nomes: armazenados na tabela para print e iniciados como nulos (completados com '-')
    ;Notas: armazeadas na tabela para print e menos acessos a menoria e iniciadas como 0
    ;Pesos: armazenados no vetor para calculo de media e iniciados como 1
    ;Quantidade de alunos: armazenada na mensagem MSG_A_INSIRA e iniciada como 0
    ;Medias: calculadas automaticamente na print da tabela

    PESOS DB 1,1,1
    TABELA DB 10,13, "NOME", 30 DUP('-'), "P1", 4 DUP('-'), "P2", 4 DUP('-'), "P3", 4 DUP('-'), "MEDIA"
           DB 5 DUP(10,13, 30 DUP('-'), 4 DUP('-'), "00", 4 DUP('-'), "00", 4 DUP('-'), "00", 4 DUP('-'), "00"), '$'
    MSG_MENU DB 10,13,"Escolha uma opcao:"
             DB 10,13,"    1- Incluir aluno"
             DB 10,13,"    2- Incluir/alterar notas" ;todos os alunos em uma prova ou uma nota individualmente
             DB 10,13,"    3- Imprimir tabela"
             DB 10,13,"    4- Alterar pesos das provas"
             DB 10,13,"    5- Remover aluno"
             DB 10,13,"    0- Sair"
             DB 10,13," > $"
             ;editar aluno?
             ;salvar alteracoes?
             ;pesquisar alunos? - ID? e nome
    MSG_INICIAL DB 10,13,"Sistema de notas inicializado com sucesso!$"
    MSG_ERRANGE DB 10,13,"Valor fora do intervalo! Insira novamente: $"
    MSG_CONTINUAR DB 10,13,"Pressione qualquer tecla para continuar...$"
    MSG_SAIDA DB 10,13,"Saindo do sistema...$"

    MSG_A_INSIRA DB 10,13,"Numero atual de alunos: 0";[26]
                 DB 10,13,"Insira o nome do novo aluno: ", 30 DUP('_'), 30 DUP(8), '$'
    MSG_A_MAX DB 10,13,"Atingido o numero maximo de alunos!"
              DB 10,13,"Cancelando operacao...$"

    MSG_P_ATUAIS DB 10,13,"Pesos atuais: $"
    MSG_P_INSIRA DB 10,13,"Insira os novos pesos (valores de 0 a 9):$"
    MSG_P_P DB 10,13,"    PX: $"

    MSG_N_MENU DB 10,13,"Escolha uma opcao:"
               DB 10,13,"    1- Incluir todas as notas para uma das provas"
               DB 10,13,"    2- Alterar uma nota nota de um aluno"
               DB 10,13," > $"
    MSG_N1_PROVA DB 10,13,"Insira a prova com que deseja desejada: P$"
    MSG_N1_NOTADE DB 10,13,"Nota de $"

;tabela:
    ;primeira linha (titulos) com 59 bytes
    ;segunda linha comeca com 2 bytes para linebreak (tratar primeira linha como 61 bytes)
    ;seguindo essa logica, adiciona-se 56 a cada proxima linha
.CODE

    MAIN PROC

        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX

        MOV AH,9
        LEA DX,MSG_INICIAL
        INT 21h

        JMP MENU_INICIAL
            CONTINUAR: MOV AH,9
            LEA DX,MSG_CONTINUAR
            INT 21h
            MOV AH,7 ;LEITURA DE CHAR SEM ECHO
            INT 21h
            MOV AH,9

        MENU_INICIAL:
            LEA DX,MSG_MENU
            INT 21h
            ESCOLHE: MOV AH,1
            INT 21h
            CMP AL,30h
            JE SAIR
            CMP AL,31h
            JE NOVOALUNO
            CMP AL,32h
            JE NOTA
            CMP AL,33h
            JE PRINTAR
            CMP AL,34h
            JE DEFPESOS
            CMP AL,35h
            JE RMALUNO
            RANGE_ERROR
            JMP ESCOLHE

        NOVOALUNO:
            CALL @NOVOALUNO
            JMP CONTINUAR
        NOTA:
            CALL @OPCSNOTA
            JMP CONTINUAR
        PRINTAR:
            CALL @PRINTATABELA
            JMP CONTINUAR
        DEFPESOS:
            CALL @DEFPESO
            JMP CONTINUAR
        RMALUNO:
            CALL @REMOVERALUNO
            JMP CONTINUAR
        SAIR:
            MOV AH,9
            LEA DX,MSG_SAIDA
            INT 21h

        MOV AH,4CH
        INT 21h

    MAIN ENDP

    PRINTATABELA PROC

        MOV AH,9
        ;LEA DX,TABELA2
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
            LEA DX,MSG_P_P
            MOV MSG_P_P[7],BL
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
            LEA DX, MSG_P_P
            MOV MSG_P_P[7],BL
            INT 21h
            MOV AH,1
            LE_PESO: INT 21h
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
            RANGE_ERROR
            JMP LE_PESO

        DEFP_RET: RET

    @DEFPESO ENDP

    @NOVOALUNO PROC

        CMP MSG_A_INSIRA[26],35h
        JE NOVOA_MAX

        MOV AH,9
        LEA DX,MSG_A_INSIRA
        INT 21h

        ;LEA DI,TABELA[61]
        ;MOV CL,MSG_A_INSIRA[26]
        ;AND CX,0Fh
        ; MOV AL,MSG_A_INSIRA[26]
        POSICIONA_LINHA DI,MSG_A_INSIRA[26]
        ;NOVOA_GOTOLINE:
        ;    ADD DI,56
        ;LOOP NOVOA_GOTOLINE

        MOV CX,30
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

        INC MSG_A_INSIRA[26]
        
        MOV AH,9
        LEA DX,TABELA
        INT 21h
        JMP RETORNO

        NOVOA_MAX:
            MOV AH,9
            LEA DX,MSG_A_MAX
            INT 21h

        RETORNO: RET

    @NOVOALUNO ENDP

    @OPCSNOTA PROC

        MOV AH,9
        LEA DX,MSG_N_MENU
        INT 21h

        MOV AH,1
        N_OPCOES: INT 21h

        CMP AL,31h
        JE N_OPC1
        CMP AL,32h
        JE N_OPC2
        RANGE_ERROR
        JMP N_OPCOES

        N_OPC1: CALL @INCLUIRNOTAS
                JMP NOPC_RET
        N_OPC2: CALL @EDITARNOTA

        NOPC_RET: RET
        
    @OPCSNOTA ENDP

    @INCLUIRNOTAS PROC

        MOV AH,9
        LEA DX,MSG_N1_PROVA
        INT 21h
        
        N1_PROVA: MOV AH,1
        INT 21h

        CMP AL,31h
        JB N1_OPC_ERRANGE
        CMP AL,33h
        JA N1_OPC_ERRANGE
;;
        LEA BX,TABELA[90]
        AND AL,0Fh

        N1_POS_COLUNA:
            ADD BX,6
        DEC AL
        JNZ N1_POS_COLUNA
        CLD
;
        ;;LEA DI,TABELA[61]
        ; MOV AL,'-'
        ; REPNE SCASB
        ; MOV [DI],'$'

        LEA SI,TABELA[61]
        XOR DX,DX
;        
        MOV CL,MSG_A_INSIRA[26]
        AND CX,0Fh

        N1_LENOTA:
            MOV DI,SI
            MOV AL,'-'
            PUSH CX
            MOV CX,31
            REPNE SCASB
            DEC DI
            POP CX
            MOV BYTE PTR [DI],'$'

            MOV AH,9
            LEA DX,MSG_N1_NOTADE
            INT 21h
            MOV DX,SI
            INT 21h
            MOV AH,2
            MOV DL,':'
            INT 21h
            MOV DL,32
            INT 21h
            JMP N1_NOTA

            N1_SEGDIG: CMP AL,1
            JNZ ACABA_NOTA
            
            N1_NOTA: MOV AH,1
            INT 21h
            CMP AL,13
            JE ACABA_NOTA
            CMP AL,30h
            JB N1_NOTA_ERRANGE
            CMP AL,39h
            JA N1_NOTA_ERRANGE

            ;MOV [BX],AL
            PUSH AX
            MOV DL,AL
            MOV AL,10
            MUL DL
            POP AX
            AND AL,0Fh
            ADD DL,AL

            JMP N1_SEGDIG

            ACABA_NOTA:
            CMP DX,10
            JE N1_DEZ
            MOV [BX],DL

            N1_VOLTA: ADD SI,56
            ADD BX,56

            MOV BYTE PTR [DI],'-'
            ;;MOV SI,DI
        LOOP N1_LENOTA


        
        MOV DX,SI
        JMP N1_RET

        N1_OPC_ERRANGE:
            RANGE_ERROR
            MOV AH,2
            MOV DL,'P'
            INT 21h
            JMP N1_PROVA

        N1_DEZ:
            DEC BX
            MOV BYTE PTR [BX],31h
        JMP N1_VOLTA

        N1_NOTA_ERRANGE:
            RANGE_ERROR
            JMP N1_NOTA

        N1_RET: RET

    @INCLUIRNOTAS ENDP

    @EDITARNOTA PROC

        RET

    @EDITARNOTA ENDP

    @PRINTATABELA PROC

        MOV AH,9
        LEA DX,TABELA
        INT 21h

        RET

    @PRINTATABELA ENDP

    @REMOVERALUNO PROC

        RET

    @REMOVERALUNO ENDP


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
;acentuar as mensagens de .DATA
;usar dois mov ah,2 no lugar de px (o que é mais pesado em assembly x86? um acesso à memória para printar uma string de 3 caracteres ou printar esses mesmos 3 caracteres usando MOV ah,2?)
;alterar a macro2 para os casos de linha a linha, nao de linha especifica
;ADICIONAR "PRESSIONE QUALQUER TECLA PARA CONTINUAR" EM MACRO
;zerar as notas antes de adicionar coisa em cima
;-> colocar zero no bit de '1'0 ou no 1'0'





    ;PERGUNTAR DOS POPS E PUSHS
    ;PERGUNTAR SE A FUNCAO @OPCSNOTA PRECISA DE RET
    