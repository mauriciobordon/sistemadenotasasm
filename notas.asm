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

        LEA registrador,TABELA[65]
        MOV CL,linha
        AND CX,0Fh

        PASSALINHA:
            ADD registrador,60
        LOOP PASSALINHA

        POPF
        POP CX

    ENDM

.STACK 100h
.DATA

    ;TABELA EXEMPLO
    ;ID--NOME------------------------------P1----P2----P3----MEDIA
    ;01--teste-----------------------------00----00----00----00
    ;02--Mauricio Lima Bordon--------------00----00----00----00
    ;03--Isabela Everton Crestana----------00----00----00----00
    ;04--Ricardo Pannain-------------------00----00----00----00
    ;05--Pessoa 5--------------------------00----00----00----00

    ;Header na primeira linha. Restante:
    ; 2 espacos para o ID
    ; 2 '-' para espacamento
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
    TABELA DB 10,13, "ID--NOME", 30 DUP('-'), "P1", 4 DUP('-'), "P2", 4 DUP('-'), "P3", 4 DUP('-'), "MEDIA"
           DB 5 DUP(10,13, "00--", 34 DUP('-'), 3 DUP("00", 4 DUP('-')), "00"), '$'
    MSG_MENU DB 10,13,"Escolha uma opcao:"
             DB 10,13,"    1- Incluir aluno"
             DB 10,13,"    2- Incluir/alterar notas"
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
              DB 10,13,"Cancelando operacao..."
              DB 10,13,"(Remova um aluno para adicionar outro ou edite um ja existente)$"

    MSG_P_ATUAIS DB 10,13,"Pesos atuais: $"
    MSG_P_INSIRA DB 10,13,"Insira os novos pesos (valores de 0 a 9):$"
    MSG_P_P DB 10,13,"    PX: $"

    MSG_N_MENU DB 10,13,"Escolha uma opcao:"
               DB 10,13,"    1- Incluir todas as notas para uma das provas"
               DB 10,13,"    2- Alterar uma nota nota de um aluno"
               DB 10,13," > $"
    MSG_N1_PROVA DB 10,13,"Insira a prova com que deseja trabalhar: P$"
    MSG_N1_NOTADE DB 10,13,"Nota de $"
    MSG_N2_ID DB 10,13,"Insira o ID do aluno com que deseja trabalhar: $"
    MSG_N2_PROVA DB 10,13,"Insira a prova cuja nota deseja alterar: P$"
    MSG_N2_ESCOLHIDA DB 10,13,"Altere a nota escolhida: $"

;tabela:
    ;primeira linha (titulos) com 63 bytes
    ;segunda linha comeca com 2 bytes para breakline (tratar primeira linha como 65 bytes)
    ;seguindo essa logica, adiciona-se 60 a cada proxima linha
.CODE

    MAIN PROC                                           ;Abertura do procedimento principal

        MOV AX,@DATA                                    ;Permite o acesso as informacoes do seguimento de dados
        MOV DS,AX                                       ;=
        MOV ES,AX                                       ;=

        MOV AH,9                                        ;Printa mensagem de abertura
        LEA DX,MSG_INICIAL                              ;=
        INT 21h                                         ;=

        JMP MENU_INICIAL                                
            CONTINUAR: MOV AH,9                         ;Printa mensagem esperando qualquer entrada para continuar e espera a entrada
            LEA DX,MSG_CONTINUAR                        ;=
            INT 21h                                     ;=
            MOV AH,7                                    ;=
            INT 21h                                     ;=
            MOV AH,9                                    ;=

        MENU_INICIAL:                                   ;Printa mensagem de menu, le a opcao escolhida e direciona para a chamada correspondente
            LEA DX,MSG_MENU                             ;=
            INT 21h                                     ;=
            ESCOLHE: MOV AH,1                           ;=
            INT 21h                                     ;=
            CMP AL,30h                                  ;=
            JE SAIR                                     ;=
            CMP AL,31h                                  ;=
            JE NOVOALUNO                                ;=
            CMP AL,32h                                  ;=
            JE NOTA                                     ;=
            CMP AL,33h                                  ;=
            JE PRINTAR                                  ;=
            CMP AL,34h                                  ;=
            JE DEFPESOS                                 ;=
            CMP AL,35h                                  ;=
            JE RMALUNO                                  ;=
            RANGE_ERROR                                 ;Redireciona para o tratamento de erro na entrada
            JMP ESCOLHE                                 ;=

        NOVOALUNO:                                      ;Chama o procedimento para incluir aluno
            CALL @NOVOALUNO                             ;=
            JMP CONTINUAR                               ;Retorna ao menu
        NOTA:                                           ;Chama o procedimento para trabalhar com notas
            CALL @OPCSNOTA                              ;=
            JMP CONTINUAR                               ;Retorna ao menu
        PRINTAR:                                        ;Chama o procedimento para printar a tabela
            CALL @PRINTATABELA                          ;=
            JMP CONTINUAR                               ;Retorna ao menu
        DEFPESOS:                                       ;Chama o procedimento para alterar os pesos das provas
            CALL @DEFPESO                               ;=
            JMP CONTINUAR                               ;Retorna ao menu
        RMALUNO:                                        ;Chama o procedimento para remover aluno
            CALL @REMOVERALUNO                          ;=
            JMP CONTINUAR                               ;Retorna ao menu
        SAIR:                                           ;Printa mensagem de saida do sistema
            MOV AH,9                                    ;=
            LEA DX,MSG_SAIDA                            ;=
            INT 21h                                     ;=

        MOV AH,4CH                                      ;Finaliza o programa
        INT 21h                                         ;=

    MAIN ENDP                                           ;Fechamento do procedimento principal

    @DEFPESO PROC                                       ;Abertura do procedimento de alteracao de pesos

        MOV AH,9                                        ;Printa mensagem de apresentacao dos pesos atuais
        LEA DX, MSG_P_ATUAIS                            ;=
        INT 21h                                         ;=

        MOV CX,3                                        ;Define o contador como 3
        MOV BL,31h                                      ;Coloca o char '1' em BL
        LEA SI,PESOS                                    ;Aponta para o vetor de pesos

        PRINTA_P:                                       ;Laco de print dos pesos atuais
            MOV AH,9                                        ;Define a funcao de print de string
            LEA DX,MSG_P_P                                  ;Aponta o registrador de print de string para a string que contem a apresentacao da prova atual
            MOV MSG_P_P[7],BL                               ;Posiciona o numero da prova atual na string em questao
            INT 21h                                         ;Printa
            MOV AH,2                                        ;Define a funcao de print de char
            MOV DL,[SI]                                     ;Posiciona o peso da prova atual
            OR DL,30h                                       ;Transforma o peso em questao em char
            INT 21h                                         ;Printa
            INC BL                                          ;Passa ao proximo numero de prova
            INC SI                                          ;Passa ao proximo peso no vetor
        LOOP PRINTA_P                                   ;Repete mais duas vezes

        MOV AH,9                                        ;Printa a mensagem pedindo a insercao dos novos pesos
        LEA DX, MSG_P_INSIRA                            ;=
        INT 21h                                         ;=

        MOV CX,3                                        ;Define o contador como 3
        SUB BL,3                                        ;Coloca o char '1' em BL
        SUB SI,3                                        ;Aponta para o vetor de pesos

        INSERE_P:                                       ;Laco de insercao dos novos pesos
            MOV AH,9                                        ;Define a funcao de print de string
            LEA DX, MSG_P_P                                 ;Aponta o registrador de print de string para a string que contem a apresentacao da prova atual
            MOV MSG_P_P[7],BL                               ;Posiciona o numero da prova atual na string em questao
            INT 21h                                         ;Printa
            MOV AH,1                                        ;Define a funcao de leitura de char
            LE_PESO: INT 21h                                ;Le
            CMP AL,30h                                      ;Compara com os extremos e redireciona para o tratamento de erro se necessario
            JB DEFP_ERRANGE                                 ;=
            CMP AL,39h                                      ;=
            JA DEFP_ERRANGE                                 ;=
            AND AL,0Fh                                      ;Nao indo para o tratamento de erro, transforma o char lido em digito decimal
            MOV [SI],AL                                     ;Guarda o digito no vetor de pesos
            INC BL                                          ;Passa ao proximo numero de prova
            INC SI                                          ;Passa ao proximo peso do vetor
        LOOP INSERE_P                                   ;Repete mais duas vezes
        JMP DEFP_RET                                    ;Pula o trecho abaixo (tratamento de erro)

        DEFP_ERRANGE:                                   ;Imprime mensagem de erro e pede reinsercao
            RANGE_ERROR                                 ;=
            JMP LE_PESO                                 ;=

        DEFP_RET: RET                                   ;Retorna ao procedimento principal

    @DEFPESO ENDP                                       ;Fechamento do procedimento de alteracao de pesos

    @NOVOALUNO PROC                                     ;Abertura do procedimento de insercao de aluno

        CMP MSG_A_INSIRA[26],35h                        ;Compara o numero de alunos com '5', redirecionando para saida caso o seja
        JE NOVOA_MAX                                    ;=

        MOV AH,9                                        ;Printa string pedindo insercao do nome do aluno
        LEA DX,MSG_A_INSIRA                             ;=
        INT 21h                                         ;=

        POSICIONA_LINHA DI,MSG_A_INSIRA[26]             ;Chama a macro para apontar DI para o inicio da ultima linha

        MOV CX,30                                       ;Define o contador como 30
        CLD                                             ;Zera o flag de direcao (define incremento de vetor)

        INC DI                                          ;Coloca o ID do aluno adicionado na tabela e posiciona o DI para as proximas acoes
        MOV AL,MSG_A_INSIRA[26]                         ;=
        INC AL                                          ;=
        STOSB                                           ;=
        ADD DI,2                                        ;=

        INSERE_A:                                       ;Laco para leitura do nome
            MOV AH,2                                        ;Printa um espaco vazio na posicao atual da linha de leitura
            MOV DL,32                                       ;=
            INT 21h                                         ;=
            MOV DL,8                                        ;=
            INT 21h                                         ;=
            LE_ALUNO: MOV AH,1                              ;Define funcao de leitura de char
            INT 21h                                         ;Le o char
            CMP AL,13                                       ;Compara com enter, finalizando a leitura caso o seja
            JE NOVOA_FIM                                    ;=
            CMP AL,8                                        ;Compara com backspace, redirecionando para o trecho correspondente
            JE INSEREA_BCKSP                               ;-
            STOSB                                           ;Nao sendo nenhum desses, guarda o char na matriz
        LOOP INSERE_A                                   ;Repete ate o enter ou preencher 30 chars
        JMP NOVOA_FIM                                   ;Pula o trecho abaixo

        INSEREA_BCKSP:                                     ;Label para tratamento de backspace
            CMP CX,30                                       ;Caso tenha tentado apagar sem haver qualquer char digitado, redireciona para o tratamento em questao
            JE INICIAL                                      ;=
            MOV AH,2                                        ;Define funcao de print de char
            MOV DL,'_'                                      ;Printa dois '_' para repreencher a linha de leitura (um para o apagado e outro para o espaco em branco)
            INT 21h                                         ;=
            INT 21h                                         ;=
            MOV DL,8                                        ;Volta duas posicoes na linha de leitura para continuar lendo os proximos chars
            INT 21h                                         ;=
            INT 21h                                         ;=
            INC CX                                          ;Incrementa o contador para compensar o char apagado
            DEC DI                                          ;Decrementa o registrador que aponta para a tabela para poder corrigir o char apagado la
            MOV BYTE PTR [DI],'-'                           ;Substitui o char em questao por '-'
            JMP INSERE_A                                    ;Recomeca a repeticao do loop de insercao

        INICIAL:                                        ;Label para tratamento de backspace sem char digitado
            MOV AH,2                                        ;Printa um espaco para retornar a posicao na linha de leitura
            MOV DL,32                                       ;=
            INT 21h                                         ;=
            JMP LE_ALUNO                                    ;Retorna a repeticao do loop de insercao

        NOVOA_MAX:                                      ;Tratamento de erro: limite de alunos atingido
            MOV AH,9                                    ;Printa mensagem acusando erro e informando saida da operacao
            LEA DX,MSG_A_MAX                            ;=
            INT 21h                                     ;=
            JMP NOVOA_RETORNO                           ;Ignora o incremento de alunos
        
        NOVOA_FIM: INC MSG_A_INSIRA[26]                 ;Incrementa o numero de alunos
        NOVOA_RETORNO: RET                              ;Retorna ao procedimento principal

    @NOVOALUNO ENDP                                     ;Fechamento do procedimento de insercao de aluno

    @OPCSNOTA PROC                                      ;Abertura do procedimento de escolha do tipo de manipulacao de nota

        MOV AH,9                                        ;Printa mensagem do menu de opcoes para manipulacao de nota
        LEA DX,MSG_N_MENU                               ;=
        INT 21h                                         ;=

        MOV AH,1                                        ;Le a opcao escolhida
        N_OPCOES: INT 21h                               ;=
        CMP AL,31h                                      ;Compara com as opcoes possiveis e redireciona para a correspondente ou acusa o erro e pede reinsercao
        JE N_OPC1                                       ;=
        CMP AL,32h                                      ;=
        JE N_OPC2                                       ;=
        RANGE_ERROR                                     ;=
        JMP N_OPCOES                                    ;=

        N_OPC1: CALL @INCLUIRNOTAS                      ;Chama o procedimento para incluir todas as notas de uma prova
                JMP NOPC_RET                            ;Pula para o retorno do procedimento
        N_OPC2: CALL @EDITARNOTA                        ;Chama o procedimento para editar a nota de um aluno especifico

        NOPC_RET: RET                                   ;Retorna ao procedimento principal
        
    @OPCSNOTA ENDP                                      ;Fechamento do procedimento de escolha do tipo de manipulacao de nota

    @INCLUIRNOTAS PROC                                  ;Abertura do procedimento de inclusao de todas as notas de uma prova

        MOV AH,9                                        ;Printa mensagem para pedir escolha de prova
        LEA DX,MSG_N1_PROVA                             ;=
        INT 21h                                         ;=

        N1_PROVA: MOV AH,1                              ;Le a escolha
        INT 21h                                         ;=
        CMP AL,31h                                      ;Compara com os extremos, redirecionando para tratamento de erro se estiver fora do intervalo
        JB N1_P_ERRANGE                                 ;=
        CMP AL,33h                                      ;=
        JA N1_P_ERRANGE                                 ;=

        LEA BX,TABELA[98]                               ;Aponta BX para 6 posicoes antes do segundo digito da primeira nota na tabela
        AND AL,0Fh                                      ;Transforma o char de AL em digito decimal para funcionar como contador

        N1_POS_COLUNA:                                  ;Laco para posicionar BX
            ADD BX,6                                        ;Adiciona 6 em BX
        DEC AL                                          ;Repete ate fazer referencia a nota escolhida
        JNZ N1_POS_COLUNA                               ;=
        CLD                                             ;Zera o flag de direcao (define incremento de vetor)

        LEA SI,TABELA[69]                               ;Aponta SI para a primeira posicao da primeira linha de nomes na tabela
        MOV CL,MSG_A_INSIRA[26]                         ;Guarda em CL o numero de alunos atual para funcionar como contador
        AND CX,0Fh                                      ;Zera os outros bits do contador

        N1_LENOTA:                                      ;Laco para leitura de nota
            MOV DI,SI                                       ;Aponta DI para a primeira posicao da linha atual da tabela
            MOV AL,'-'                                      ;Guarda '-' em AL para ser o char procurado por SCASB
            PUSH CX                                         ;Guarda o valor de CX para que nao se perca com as instrucoes abaixo
            MOV CX,31                                       ;Define o valor maximo de repeticoes como 31
            REPNE SCASB                                     ;Procura a primeira ocorrencia do char '-'
            DEC DI                                          ;Decrementa DI para retornar a posicao que dever ser atualizada
            POP CX                                          ;Recupera o valor guardado de CX
            MOV BYTE PTR [DI],'$'                           ;Cria um fim temporario, para que a string seja lida até o final do nome

            MOV AH,9                                        ;Printa mensagem "Nota de " e o nome do aluno
            LEA DX,MSG_N1_NOTADE                            ;=
            INT 21h                                         ;=
            MOV DX,SI                                       ;=
            INT 21h                                         ;=
            MOV AH,2                                        ;=
            MOV DL,':'                                      ;=
            INT 21h                                         ;=
            MOV DL,32                                       ;=
            INT 21h                                         ;=

            N1_NOTA: MOV AH,1                               ;Le o primeiro char da nota
            INT 21h                                         ;=
            CMP AL,30h                                      ;Caso esteja fora do intervalo, redireciona para o tratamento de erro
            JB N1_NOTA_ERRANGE                              ;=
            CMP AL,39h                                      ;=
            JA N1_NOTA_ERRANGE                              ;=

            CMP AL,31h                                      ;Caso seja diferente de '1', redireciona para o tratamento adequado
            JNE N1_PRIMDIG                                  ;=

            N1_SEGDIG: INT 21h                              ;Caso seja igual a '1', le outro char para definir se é nota 1 ou 10 e realizar o tratamento adequado
            MOV DL,AL                                       ;=
            MOV AL,31h                                      ;=
            CMP DL,13                                       ;=
            JE N1_PRIMDIG                                   ;=
            CMP DL,30h                                      ;=
            JNE N1_SEGDIG_ERRANGE                           ;Caso diferente de '0' ou enter, redireciona para o tratamento de erro
            DEC BX                                          ;Posiciona '1' no algarimos das dezenas da nota em questao
            MOV [BX],AL                                     ;=
            INC BX                                          ;Posiciona '0' no algarismo das unidades
            MOV BYTE PTR [BX],30h                           ;=
            JMP N1_VOLTA                                    ;Pula os tratamentos especificos abaixo

            N1_P_ERRANGE:                                   ;Acusa erro de intervalo e pede para inserir a prova novamente
                RANGE_ERROR                                     ;=
                MOV AH,2                                        ;=
                MOV DL,'P'                                      ;=
                INT 21h                                         ;=
                JMP N1_PROVA                                    ;=
            
            N1_PRIMDIG:                                     ;Caso a nota for de digito unico, adiciona no algarismo das unidades e zera o das dezenas
                OR AL,30h                                   ;=
                MOV [BX],AL                                 ;=
                DEC BX                                      ;=
                MOV BYTE PTR [BX],30h                       ;=
                INC BX                                      ;=

            N1_VOLTA: ADD SI,60                             ;Passa para a proxima linha da tabela no registrador que aponta para o inicio dela
            ADD BX,60                                       ;Passa para a proxima linha da tabela no registrador que aponta para a nota da prova selecionada

            MOV BYTE PTR [DI],'-'                           ;Remove o cifrao temporario adicionado antes
        LOOP N1_LENOTA                                  ;Repete para o numero de alunos existente
        JMP N1_RET                                      ;Ao acabar o loop, pula para o retorno

        N1_NOTA_ERRANGE:                                ;Acusa erro de intervalo no primeiro digito inserido e pede reinsercao
            RANGE_ERROR                                     ;=
            JMP N1_NOTA                                     ;=

        N1_SEGDIG_ERRANGE:                              ;Acusa erro de intervalo no segundo digito inserido e pede reinsercao
            RANGE_ERROR                                     ;=
            JMP N1_SEGDIG                                   ;=

        N1_RET: RET                                     ;Retorna para o procedimento de escolha do tipo de manipulacao de nota

    @INCLUIRNOTAS ENDP                                  ;Fechamento do procedimento de inclusao de todas as notas de uma prova

    @EDITARNOTA PROC                                    ;Abertura do procedimento de edicao de nota especifica

        MOV AH,9
        LEA DX,MSG_N2_ID
        INT 21h
        
        N2_DIGNULO: MOV AH,1
        INT 21h
        CMP AL,30h
        JE N2_DIGNULO
        JB N2_ID_ERRANGE
        CMP AL,MSG_A_INSIRA[26]
        JA N2_ID_ERRANGE

        LEA DI,TABELA[37]
        AND AL,0Fh
        
        N2_ROW:
            ADD DI,60
        DEC AL
        JNZ N2_ROW

        MOV AH,9
        LEA DX,MSG_N2_PROVA
        INT 21h

        MOV AH,1
        INT 21h
        CMP AL,30h
        JB N2_P_ERRANGE
        CMP AL,33h
        JA N2_P_ERRANGE

        AND AL,0Fh

        N2_COL:
            ADD DI,6
        DEC AL
        JNZ N2_COL
        JMP N2_SETLEITURA

        N2_ID_ERRANGE:
            RANGE_ERROR
            JMP N2_DIGNULO

        N2_P_ERRANGE:
            RANGE_ERROR
            MOV AH,2
            MOV DL,'P'
            INT 21h
            JMP N1_PROVA

        N2_SETLEITURA: MOV SI,DI
        CLD

        MOV AH,9
        LEA DX,MSG_N2_ESCOLHIDA
        INT 21h
        
        N2_PRINTA: MOV BL,1
        MOV DI,SI
        MOV AH,2
        MOV DL,[DI]
        INT 21h
        INC DI
        MOV DL,[DI]
        INT 21h
        INC DI

        N2_LEITURA: MOV AH,1
        INT 21h
        CMP AL,13
        JE N2_RET
        CMP AL,8
        JE N2_BCKSP
        CMP AL,30h
        JB N2_NOTA_ERRANGE
        CMP AL,39h
        JA N2_NOTA_ERRANGE

        N2_JMP_BCKSP: CMP BL,1
        JE N2_ESCREVE0
        CMP BL,2
        JE N2_ESCREVE1
        CMP AL,32h
        JB N2_UMOUZERO
        PUSH AX
        MOV AH,2
        MOV DL,8
        INT 21h
        MOV DL,30h
        INT 21h
        POP DX
        INT 21h
        INC DI
        STOSB
        SUB BL,2
        JMP N2_LEITURA

        N2_ESCREVE0:
            MOV AH,2
            MOV DL,8
            INT 21h
            MOV DL,32
            INT 21h
            MOV DL,8
            INT 21h
            JMP N2_LEITURA

        N2_ESCREVE1:
            MOV [DI],AL
            INC DI
            DEC BL
            JMP N2_LEITURA

        N2_BCKSP:
            MOV AH,2
            MOV DL,32
            INT 21h
            CMP BL,3
            JE N2_LEITURA
            MOV DL,8
            INT 21h
            INC BL
            DEC DI
            MOV BYTE PTR [DI],30h
            JMP N2_LEITURA

        N2_NOTA_ERRANGE:
            RANGE_ERROR
            JMP N2_PRINTA

        N2_UMOUZERO:
            MOV [DI],AL
            DEC BL
            INC DI
            JMP N2_LEITURA

        N2_RET: RET

    @EDITARNOTA ENDP                                    ;Fechamento do procedimento de edicao de nota especifica

    @PRINTATABELA PROC                                  ;Abertura do procedimento de print da tabela

        LEA BX,PESOS                                    ;Aponta BX para o vetor de pesos
        LEA SI,TABELA[103]                              ;Aponta SI para o primeiro algarismo da primeira nota
        LEA DI,TABELA[63]                               ;Aponta DI para acima do final da primeira linha de dados
        XOR DX,DX

        MOV CL,MSG_A_INSIRA[26]
        AND CX,0Fh

        PRINT_FINAL:
            ADD DI,60
        LOOP PRINT_FINAL

        MOV CX,3
        PRINT_DIVISOR:
            MOV DH,[BX]
            INC BX
            ADD DL,DH ;DIVISOR EM DL
        LOOP PRINT_DIVISOR

        MOV BYTE PTR [DI],'$'
        XOR DH,DH

        MOV CL,MSG_A_INSIRA[26]
        AND CX,0Fh
        PRINT_MEDIA:
        PUSH CX
        PUSH DX
            XOR DX,DX
            MOV CX,3
            SUB BX,3
            PRINT_SOMATORIA:
                PUSH DX
                CMP BYTE PTR [SI],31h
                JE PRINT_DEZ
                INC SI
                MOV AL,[SI]
                AND AL,0Fh
                JMP PRINT_MULPESO
                PRINT_DEZ: MOV AL,10
                INC SI
                PRINT_MULPESO: MOV DL,[BX]
                INC BX
                MUL DL
                POP DX
                ADD DX,AX
                ADD SI,5
            LOOP PRINT_SOMATORIA

            MOV AX,DX
            XOR DX,DX
            POP CX
            DIV CX

            CMP AX,10
            JE PRINT_MEDIADEZ
            MOV BYTE PTR [SI],30h
            INC SI
            OR AL,30h
            MOV [SI],AL
            JMP PRINT_CONTINUA
            PRINT_MEDIADEZ: MOV BYTE PTR [SI],31h
            INC SI
            MOV BYTE PTR [SI],30h
            PRINT_CONTINUA:
            ADD SI,41

            MOV DX,CX
            POP CX
        LOOP PRINT_MEDIA

        MOV AH,9
        LEA DX,TABELA
        INT 21h

        MOV BYTE PTR [DI],10

        RET

    @PRINTATABELA ENDP                                  ;Fechamento do procedimento de print da tabela

    @REMOVERALUNO PROC                                  ;Abertura do procedimento de remocao de aluno

        MOV AH,9
        LEA DX,TABELA
        INT 21h

        RET

    @REMOVERALUNO ENDP                                  ;Fechamento do procedimento de remocao de aluno


END MAIN                                                ;Fechamento do codigo

;erro quando todos os pesos sao zero
;padronizar as entradas: nao aparecem numeros invalidos na tela, nao tem mensagem de erro de intervalo, soh termina quando tiver o enter