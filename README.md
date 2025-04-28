# NTP Timestamp Capture Script  

Скрипт для захвата и сравнения времени с внешним NTP-сервером (`162.159.200.123`) с помощью `tcpdump`. Результат сохраняется в файл для мониторинга (например, в Zabbix).  

---

## **🔍 Возможности**  
- Захват NTP-пакетов с указанного сервера.  
- Конвертация метки времени из NTP-формата (с 1900 года) в Unix-формат (с 1970 года).  
- Логирование всех этапов работы.  
- Интеграция с системами мониторинга (Zabbix, Prometheus).  

---

## **🛠️ Как это работает?**  
1. **Захват пакета**:  
   - Скрипт запускает `tcpdump` на интерфейсе `any` для прослушивания UDP-порта `123` (NTP).  
   - Фильтрует пакеты от сервера `162.159.200.123`.  
2. **Извлечение времени**:  
   - Извлекает поле `Transmit Timestamp` из захваченного пакета.  
   - Конвертирует его в Unix-время по формуле:  
     ```plaintext
     Unix Timestamp = NTP Timestamp - 2208988800 (разница между 1900 и 1970 годом в секундах)
     ```  
3. **Сохранение результата**:  
   - Успешный результат записывается в `$RESULT_FILE_OUT_NTP` (по умолчанию `/etc/zabbix/scripts/ntp.org_timestamp.txt`).  
   - При ошибке сохраняется `0000000000`.  

---

## **📂 Файлы и логи**  
- **Результат**: `/etc/zabbix/scripts/ntp.org_timestamp.txt` (можно изменить в переменной `RESULT_FILE_OUT_NTP`).  
- **Логи**: `/var/log/ntp.org_timestamp.log` (очищается при каждом запуске).  
- **Временные данные**: `/tmp/output_OUT_NTP.txt` (сырой вывод `tcpdump`).  

---

## **⚙️ Установка и настройка**  
### **Зависимости**  
Убедитесь, что установлены:  
```bash
sudo apt install tcpdump ntpdate  # Для Debian/Ubuntu
sudo yum install tcpdump ntpdate  # Для CentOS/RHEL
1. Клонирование репозитория
https://github.com/invorkel322/zabbix-ntp-time-sync.git
cd zabbix-ntp-time-sync
2. Настройка прав
Дайте скрипту права на выполнение:
chmod +x ntp_capture.sh
3. Запуск вручную
sudo ./ntp_capture.sh
4. Автоматизация (cron/Zabbix)
Добавьте в cron для регулярного выполнения (например, каждые 5 минут):
*/5 * * * * /path/to/ntp_capture.sh
Для Zabbix:
Используйте UserParameter в конфиге агента:
UserParameter=ntp.time, cat /etc/zabbix/scripts/ntp.org_timestamp.txt

🚨 Возможные проблемы
Ошибка	Решение
Failed to capture packets	Проверьте доступность сервера (ping 162.159.200.123) и правила фаервола.
Permission denied	Запускайте скрипт с sudo или добавьте пользователя в группу tcpdump.
Timestamp is empty	Убедитесь, что tcpdump видит трафик на интерфейсе (попробуйте указать конкретный интерфейс вместо any).

📌 Пример использования
Сравнение времени с локальным сервером
LOCAL_TIME=$(date +%s)
NTP_TIME=$(cat /etc/zabbix/scripts/ntp.org_timestamp.txt)
DIFF=$((LOCAL_TIME - NTP_TIME))
echo "Разница: $DIFF секунд"
Интеграция с Zabbix
Скрипт сохраняет метку в файл, который можно читать через Zabbix-агент.

Создайте элемент данных типа Zabbix trapper или SSH.
