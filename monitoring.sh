#!/bin/bash
# Запускать с правами на доступ к файлу /var/log/monitoring.log

# Указываем путь к лог-файлу
LOG_FILE="/var/log/monitoring.log"
#debug
#LOG_FILE="monitoring.log"

# URL сервера мониторинга
MONITORING_SERVER="https://test.com/monitoring/test/api"
#debug
#MONITORING_SERVER="https://127.0.0.1:443/monitoring/test/api"

# Функция для записи в лог
log_message() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Функция для проверки доступности сервера мониторинга
check_server_availability() {
    if curl -s -k --head --request GET "$MONITORING_SERVER" | grep "200 OK" > /dev/null; then
        return 0 # Сервер доступен
    else
        return 1 # Сервер недоступен
    fi
}

# Функция для проверки и мониторинга процесса
monitor_process() {
    # Проверяем доступность сервера мониторинга перед выполнением других действий
    if ! check_server_availability; then
        log_message "Сервер мониторинга недоступен: $MONITORING_SERVER"
        return
    fi

    # Получаем текущий PID процесса
    CURRENT_PID=$(ps aux | grep -E '(\./)?test(\.[^/]*)?$' | grep -v grep | awk '{print $2}')

    # Проверяем, существует ли процесс
    if [ -n "$CURRENT_PID" ]; then
        # Если процесс существует, сравниваем PID
        if [ "$INITIAL_PID" != "$CURRENT_PID" ]; then
            log_message "PID изменился с $INITIAL_PID на $CURRENT_PID"
            INITIAL_PID="$CURRENT_PID"
        fi

        #Отправляем информацию на сервер мониторинга
        curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d "{\"status\":\"running\",\"pid\":\"$CURRENT_PID\"}" \
            "$MONITORING_SERVER"
        
        #debug
        #RESPONSE=$(curl --insecure -s -o /dev/null -w "%{http_code}" -X POST \
        #    -H "Content-Type: application/json" \
        #    -d "{\"status\":\"running\",\"pid\":\"$CURRENT_PID\"}" \
        #    "$MONITORING_SERVER")
            
        # Можно было бы еще и логировать результат отправки данных на сервер. 
        # Но в ТЗ не задано
        #debug
        #if [ "$RESPONSE" -eq 200 ]; then
        #    log_message "Успешно отправлены данные: статус=running, PID=$CURRENT_PID"
        #else        
        #    log_message "Ошибка при отправке данных на сервер: HTTP $RESPONSE"
        #fi
        
    else
        # Если процесс не существует, обновляем INITIAL_PID на пустую строку
        if [ -n "$INITIAL_PID" ]; then
            log_message "Процесс test был остановлен"
            INITIAL_PID=""
        fi
    fi
}

# Получаем начальный PID процесса, если он запущен
INITIAL_PID=$(ps aux | grep -E '(\./)?test(\.[^/]*)?$' | grep -v grep | awk '{print $2}')

# Бесконечный цикл мониторинга
while true
do
    monitor_process
#debug
#    sleep 10
	sleep 60
done
