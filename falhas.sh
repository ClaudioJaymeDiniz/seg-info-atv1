#!/bin/bash

# =================================================================
# Script de Auditoria Avançada: Falhas, Serviços e Monitoramento
# Alvos: /var/log/syslog, /var/log/auth.log, /var/log/dpkg.log
# =================================================================

SYSLOG="/var/log/syslog"
AUTH_LOG="/var/log/auth.log"
DPKG_LOG="/var/log/dpkg.log"

echo "=========================================================="
echo "          RELATÓRIO DE FALHAS E MONITORAMENTO             "
echo "=========================================================="

# --- 16: Mensagens Críticas ---
echo -e "\n[16] ALERTAS CRÍTICOS (Critical, Fatal, Segfault):"
grep -Ei "critical|fatal|segfault" "$SYSLOG" | tail -n 10 | awk '{print "   " $0}'

# --- 17: Frequência por Serviço ---
echo -e "\n[17] TOP 5 SERVIÇOS QUE MAIS GERAM LOGS:"
# O 5º campo do syslog geralmente é o nome do processo/serviço
awk '{print $5}' "$SYSLOG" | cut -d'[' -f1 | cut -d':' -f1 | \
sort | uniq -c | sort -rn | head -n 5 | awk '{printf "   Serviço: %-15s | Ocorrências: %d\n", $2, $1}'

# --- 18: Falhas de Login e Método ---
echo -e "\n[18] DETALHES DE FALHAS DE AUTENTICAÇÃO:"
grep -i "check pass; user unknown\|authentication failure" "$AUTH_LOG" | \
awk '{
    metodo="desconhecido"; 
    if ($0 ~ /sshd/) metodo="SSH"; 
    else if ($0 ~ /su:/) metodo="SU"; 
    else if ($0 ~ /sudo:/) metodo="SUDO";
    print "   Data: " $1 " " $2 " | Método: " metodo
}' | tail -n 5

# --- 19: Monitoramento em Tempo Real (Exemplo de Comando) ---
# Nota: Para um script de aula, você pode deixar o comando comentado ou explicar
echo -e "\n[19] COMANDO PARA MONITORAMENTO EM TEMPO REAL:"
echo "   Execute: tail -f $AUTH_LOG | grep 'failure'"

# --- 20: Pacotes Atualizados ---
echo -e "\n[20] HISTÓRICO DE ATUALIZAÇÕES (Updates):"
grep " upgrade " "$DPKG_LOG" | \
awk '{print "   Data: " $1 " | Pacote: " $4 " | Versão: " $5 " -> " $6}'

# --- 21: Alertas de um Serviço Específico (Ex: Cron) ---
echo -e "\n[21] ERROS E AVISOS DO SERVIÇO CRON:"
grep "cron" "$SYSLOG" | grep -Ei "error|warning" | tail -n 5 | awk '{print "   " $0}'

# --- 22: Segfault e Processos Mortos (Killed) ---
echo -e "\n[22] PROCESSOS FINALIZADOS ABRUPTAMENTE (Segfault/Killed):"
grep -Ei "segfault|killed" "$SYSLOG" | \
awk '{print "   Data: " $1 " " $2 " | Evento: " $0}' | cut -c 1-100

# --- 23: Tempo de Sessão do Usuário ---
echo -e "\n[23] TEMPO DE PERMANÊNCIA DOS USUÁRIOS (Sessões):"
# O comando 'last' já calcula a duração das sessões entre parênteses
last | grep -v "still logged in" | head -n 5 | \
awk '{print "   Usuário: " $1 " | Duração: " $10}'

echo -e "\n=========================================================="
echo "               FIM DO RELATÓRIO FINAL                    "
echo "=========================================================="
