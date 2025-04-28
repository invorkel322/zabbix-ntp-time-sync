
#######################################################################################
### Захват пакета с внешнего сервера времени для сравнения времени с физическим.
INTERFACE="any"
PORT="123"
RESULT_FILE_OUT_NTP="/etc/zabbix/scripts/ntp.org_timestamp.txt"
LOG_FILE_OUT_NTP="/var/log/ntp.org_timestamp.log"
OUT_NTP="162.159.200.123"

#Перезапись лог файла. Для диагностики добавить еще одну галку >
echo " " > $LOG_FILE_OUT_NTP
echo "Starting to capture packets with tcpdump..." >> $LOG_FILE_OUT_NTP
echo -f -n > /tmp/output_OUT_NTP.txt

### Запуск tcpdump в фоновом режиме. Для этого в конце команды используется &
timeout 35s sudo /usr/sbin/tcpdump -i "$INTERFACE" host "$OUT_NTP" and port "$PORT" -c 1 -nn -vvv >/tmp/output_OUT_NTP.txt 2>/dev/null &
### $! — PID последнего запущенного в фоне процесса.  Сигнал фонового процесса всегда 0!!!!  .Используется для команды wait.
TCPDUMP_PID=$!
sleep 1
### Запрос времени без внесения изменений.
ntpdate -q $OUT_NTP >> $LOG_FILE_OUT_NTP
### Ожидает завершения указанного PID. + передает реальный код завершения фоновой задачи.
wait $TCPDUMP_PID
### Статус для диагностики и сообщений о результате. $? - сигнал завершения последней команды, в данном случае = код завершения tcpdump,т.к. wait передает код завершения фоновой задачи
TCPDUMP_STATUS=$?
### Переменная указывается последней, т.к. пока tcpdump не завершится в фоне, файл txt будет пустым
output_OUT_NTP=$( cat /tmp/output_OUT_NTP.txt )
if [ $TCPDUMP_STATUS -ne 0 ]; then echo "Failed to capture packets with tcpdump!" >> $LOG_FILE_OUT_NTP
exit 0
else echo "Tcpdump successfully finished!" >> $LOG_FILE_OUT_NTP
fi

### Достаём таймштамп из файла с результатом tcpdump. Конвертируем в unix timestamp
timestamp_OUT_NTP=$(echo "$output_OUT_NTP" | grep -oP "Transmit Timestamp:\s+\K[0-9]+\.[0-9]+")
if [[ -n "$timestamp_OUT_NTP" ]]; then
  echo  "Timestamp is not empty. Calculating Unix timestamp..."  >> $LOG_FILE_OUT_NTP
  integer_part_OUT_NTP=${timestamp_OUT_NTP%%.*}
  unix_timestamp_OUT_NTP=$((integer_part_OUT_NTP - 2208988800))
  echo "Trying to save result in log file..."  >> $LOG_FILE_OUT_NTP
  echo "$unix_timestamp_OUT_NTP" > $RESULT_FILE_OUT_NTP
      if [ $? -ne 0 ]; then
      echo "Failed to save result in log file!" >> $LOG_FILE_OUT_NTP
      exit 1
      fi
  echo "Job is done! Timestamp successfully updated."  >> $LOG_FILE_OUT_NTP
  exit 0
else
  echo "0000000000" > $RESULT_FILE_OUT_NTP
  echo "Timestamp is empty! Check tcpdump results."  >> $LOG_FILE_OUT_NTP
  exit 1
fi
