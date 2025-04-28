# NTP Timestamp Capture Script

Скрипт для захвата и сравнения времени с внешним NTP-сервером (`162.159.200.123`) с помощью `tcpdump`. Результат сохраняется в файл для мониторинга (например, в Zabbix).

## 📋 Оглавление
- [Возможности](#-возможности)
- [Как это работает](#-как-это-работает)
- [Файлы и логи](#-файлы-и-логи)
- [Установка и настройка](#-установка-и-настройка)
- [Возможные проблемы](#-возможные-проблемы)
- [Пример использования](#-пример-использования)
- [Лицензия](#-лицензия)

## 🔍 Возможности
- Захват NTP-пакетов с указанного сервера
- Конвертация метки времени из NTP-формата в Unix-формат
- Логирование всех этапов работы
- Интеграция с системами мониторинга (Zabbix, Prometheus)

## 🛠️ Как это работает?
1. **Захват пакета**:
   - Скрипт запускает `tcpdump` для прослушивания UDP-порта 123 (NTP)
   - Фильтрует пакеты от сервера `162.159.200.123`

2. **Извлечение времени**:
   ```plaintext
   Unix Timestamp = NTP Timestamp - 2208988800
   (разница между 1900 и 1970 годом в секундах)
Сохранение результата:

Успешный результат: /etc/zabbix/scripts/ntp.org_timestamp.txt

При ошибке: 0000000000

📂 Файлы и логи
Назначение	Путь
Результат	/etc/zabbix/scripts/ntp.org_timestamp.txt
Логи	/var/log/ntp.org_timestamp.log
Временные данные	/tmp/output_OUT_NTP.txt
⚙️ Установка и настройка
Зависимости
bash
# Для Debian/Ubuntu:
sudo apt install tcpdump ntpdate

# Для CentOS/RHEL:
sudo yum install tcpdump ntpdate
1. Клонирование репозитория
bash
git clone https://github.com/yourname/ntp-timestamp-monitor.git
cd ntp-timestamp-monitor
2. Настройка прав
bash
chmod +x ntp_capture.sh
3. Запуск
bash
sudo ./ntp_capture.sh
4. Автоматизация (cron)
bash
# Добавьте в cron для выполнения каждые 5 минут:
*/5 * * * * /path/to/ntp_capture.sh
🚨 Возможные проблемы
Ошибка	Решение
Failed to capture packets	Проверьте доступность сервера и правила фаервола
Permission denied	Запускайте с sudo или добавьте пользователя в группу tcpdump
Timestamp is empty	Убедитесь, что tcpdump видит трафик на интерфейсе
📌 Пример использования
Сравнение времени
bash
LOCAL_TIME=$(date +%s)
NTP_TIME=$(cat /etc/zabbix/scripts/ntp.org_timestamp.txt)
DIFF=$((LOCAL_TIME - NTP_TIME))
echo "Разница: $DIFF секунд"
Интеграция с Zabbix
Добавьте в конфиг агента:

ini
UserParameter=ntp.time, cat /etc/zabbix/scripts/ntp.org_timestamp.txt
Создайте элемент данных типа Zabbix trapper
