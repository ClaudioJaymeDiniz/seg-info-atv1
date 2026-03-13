#!/bin/bash

# =================================================================
# Script de Auditoria de Pacotes e Atividade - Linux Mint
# Alvos: /var/log/dpkg.log e /var/log/syslog
# =================================================================

DPKG_LOG="/var/log/dpkg.log"
AUTH_LOG="/var/log/auth.log"

# Verifica permissões de root
if [ "$EUID" -ne 0 ]; then 
  echo "Erro: Por favor, execute como root (sudo)."
  exit 1
fi

echo "=========================================================="
echo "          RELATÓRIO DE SOFTWARE E ATIVIDADE               "
echo "          Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo "=========================================================="

# --- EXERCÍCIO 11: Pacotes Instalados na Última Semana ---
echo -e "\n[11] PACOTES INSTALADOS NA ÚLTIMA SEMANA:"
# Filtra 'install', pega os logs dos últimos 7 dias comparando a data inicial da linha
# O awk filtra pela data (YYYY-MM-DD)
last_week=$(date -d "7 days ago" +%Y-%m-%d)
awk -v date="$last_week" '$1 >= date && $3 == "install" {print "   Data: " $1 " " $2 " | Pacote: " $4}' "$DPKG_LOG"

# --- EXERCÍCIO 12: Pacotes Removidos do Sistema ---
echo -e "\n[12] HISTÓRICO DE PACOTES REMOVIDOS:"
# Busca 'remove' ou 'purge' no log do dpkg
grep -E "remove|purge" "$DPKG_LOG" | \
awk '{print "   Data: " $1 " | Ação: " $3 " | Pacote: " $4}'

# --- EXERCÍCIO 13: Rastreio de Comandos (apt/dpkg) ---
echo -e "\n[13] RASTREIO DE USO DO GERENCIADOR DE PACOTES:"
# O auth.log registra quem executou o sudo apt ou sudo dpkg
grep -E "COMMAND=.*(apt|apt-get|dpkg)" "$AUTH_LOG" | \
awk -F'[:=]' '{print "   Usuário: " $4 " | Comando: " $NF}'

# --- EXERCÍCIO 14: Tempo de Atividade (Uptime e Boot) ---
echo -e "\n[14] ANÁLISE DE TEMPO DE ATIVIDADE:"
# uptime -p mostra o tempo ligado de forma amigável
# last reboot/shutdown mostra os eventos de sistema
echo "   Tempo atual ligado: $(uptime -p)"
echo "   Último Boot: $(last reboot | head -n 1 | awk '{print $5,$6,$7,$8}')"
echo "   Último Shutdown: $(last -x shutdown | head -n 1 | awk '{print $5,$6,$7,$8}')"

# --- EXERCÍCIO 15: Filtro por Horário (Ex: 14h às 15h) ---
# Vamos usar o /var/log/syslog como exemplo
echo -e "\n[15] EVENTOS NO SYSLOG ENTRE 14:00 E 15:00 (Hoje):"
TARGET_LOG="/var/log/syslog"
# O regex '^... [0-9 ]+ 14:' busca linhas que começam com qualquer mês, dia e hora 14
grep "^$(date +%b) $(date +%e) 14:" "$TARGET_LOG" | tail -n 10 | \
awk '{print "   Hora: " $3 " | Evento: " $0}' | cut -c 1-80

echo -e "\n=========================================================="
echo "               FIM DO RELATÓRIO                          "
echo "=========================================================="
