#!/bin/bash

# Cores para o relatório
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[0;31m'
AZUL='\033[0;34m'
NC='\033[0m' # Sem Cor

echo -e "${AZUL}==========================================================${NC}"
echo -e "${AZUL}          RELATÓRIO DE ATIVIDADE DO SISTEMA               ${NC}"
echo -e "          Data: $(date '+%d/%m/%Y %H:%M:%S')"
echo -e "${AZUL}==========================================================${NC}"

# --- 6. ÚLTIMO BOOT ---
echo -e "\n${VERDE}[6] ÚLTIMA INICIALIZAÇÃO DO SISTEMA:${NC}"
uptime -s | awk '{print "    O sistema subiu em: " $1 " às " $2}'

# --- 7. EVENTOS DE SHUTDOWN/REBOOT ---
echo -e "\n${VERDE}[7] HISTÓRICO DE DESLIGAMENTO E REINICIALIZAÇÃO:${NC}"
# Pega as últimas 5 ocorrências para não ficar gigante
last -x | grep -E "reboot|shutdown" | head -n 5 | awk '{printf "    Evento: %-10s | %s %s %s %s\n", $1, $5, $6, $7, $8}'

# --- 8. FALHAS DO KERNEL ---
echo -e "\n${VERDE}[8] MENSAGENS DE ERRO DO KERNEL (Últimas 10):${NC}"
# dmesg -T usa horários legíveis
sudo dmesg -T | grep -iE "error|fail|critical" | tail -n 10 | sed 's/^/    /'

# --- 9. STATUS DE SERVIÇOS RECENTES ---
echo -e "\n${VERDE}[9] ALTERAÇÃO DE STATUS DE SERVIÇOS (Systemd):${NC}"
# journalctl pega logs do sistema
sudo journalctl -n 20 | grep -E "Starting|Started|Stopping|Stopped" | \
tail -n 10 | awk '{print "    Serviço: " $5 " " $6 " | Hora: " $3}'

# --- 10. PROBLEMAS DE HARDWARE ---
echo -e "\n${VERDE}[10] POSSÍVEIS PROBLEMAS DE HARDWARE (Disk/USB):${NC}"
# Busca no syslog por termos de hardware comuns
HARDWARE_ERRORS=$(sudo grep -iE "sda|sdb|usb|disk|mount" /var/log/syslog | grep -iE "error|fail|warning" | tail -n 5)

if [ -z "$HARDWARE_ERRORS" ]; then
    echo -e "    ${VERDE}Nenhum erro crítico de hardware detectado nos logs recentes.${NC}"
else
    echo -e "${VERMELHO}$HARDWARE_ERRORS${NC}" | sed 's/^/    /'
fi

echo -e "\n${AZUL}==========================================================${NC}"
echo -e "                FIM DA ANÁLISE DO SISTEMA                 "
echo -e "${AZUL}==========================================================${NC}"
