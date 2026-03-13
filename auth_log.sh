#!/bin/bash

# =================================================================
# Script de Auditoria de Logs Internos - Linux Mint
# Alvo: /var/log/auth.log
# =================================================================

LOG_FILE="/var/log/auth.log"

# Verifica se o arquivo de log existe
if [ ! -f "$LOG_FILE" ]; then
    echo "Erro: Arquivo $LOG_FILE não encontrado."
    exit 1
fi

# Verifica se o usuário tem permissão de leitura (root/sudo)
if [ ! -r "$LOG_FILE" ]; then
    echo "Erro: Permissão negada. Execute o script com sudo."
    exit 1
fi

echo "=========================================================="
echo "          RELATÓRIO DE AUDITORIA DE SEGURANÇA             "
echo "          Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "=========================================================="

# --- EXERCÍCIO 1: Senhas Incorretas ---
echo -e "\n[1] TENTATIVAS DE SENHA INCORRETA (Por Usuário):"
# grep: busca falhas de autenticação
# awk: localiza a string 'user' e imprime o próximo campo (o nome)
# sort/uniq: agrupa e conta as ocorrências
grep "authentication failure" "$LOG_FILE" | \
awk -F'[ =]+' '{for(i=1;i<=NF;i++) if($i=="user") print $(i+1)}' | \
sort | uniq -c | awk '{printf "   Usuário: %-15s | Falhas: %d\n", $2, $1}'

# --- EXERCÍCIO 2: Logins Bem-Sucedidos ---
echo -e "\n[2] LOGINS BEM-SUCEDIDOS NO SISTEMA:"
# Busca 'session opened', ignora o cron para não poluir o relatório
# Imprime Data, Hora e o Usuário (11º campo na estrutura padrão do Mint)
grep "session opened" "$LOG_FILE" | grep -v "cron" | \
awk '{print "   Data/Hora: " $1 " " $2 " " $3 " | Usuário: " $11}'

# --- EXERCÍCIO 3: Uso do Comando SU ---
echo -e "\n[3] RASTREIO DO COMANDO 'SU' (Switch User):"
# Busca tentativas de troca de usuário
# O sed limpa os parênteses que o log costuma colocar nos nomes
grep "su:" "$LOG_FILE" | grep "to" | \
awk '{print "   " $6 " tentou mudar para " $8}' | sed 's/(//g; s/)//g'

# --- EXERCÍCIO 4: Auditoria do SUDO ---
echo -e "\n[4] AUDITORIA DE COMANDOS SUDO:"
# Filtra execuções de comandos com privilégio
# O campo $NF no awk pega o último elemento da linha (o comando executado)
grep "sudo:" "$LOG_FILE" | grep "COMMAND" | \
awk -F'[:=]' '{print "   Usuário: " $4 " | Data: " $1 " | Comando: " $NF}'

# --- EXERCÍCIO 5: Logins Rejeitados (Inexistentes/Outros) ---
echo -e "\n[5] LOGINS REJEITADOS (Usuários Inexistentes):"
# Procura explicitamente por 'invalid user' (tentativas de invasão comuns)
grep "Invalid user" "$LOG_FILE" | \
awk '{print "   Usuário Inexistente: " $8 " | Data: " $1 " " $2 " " $3}' | sort | uniq

echo -e "\n=========================================================="
echo "               FIM DO RELATÓRIO                          "
echo "=========================================================="
