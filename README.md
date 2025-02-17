# Описание

Это пример скрипта monitoring.sh для мониторинга процесса с именем test.

Скрипт monitoring.sh надо разместить в /usr/local/bin/monitoring.sh либо сделать на него симлинк.
Далее Systemd сервис monitoring.service надо разместить в /etc/systemd/system/monitoring.service либо сделать на него симлинк.
Скрипт запускается командой `sudo systemctl start monitoring.service`.

Что делает скрипт:
- Мониторит процесса test в среде linux
- Запускаться при запуске системы (при использовании monitoring.service)
- Отрабатывет каждую минуту
- Если процесс test запущен, то скрипт стучится на сервер мониторинга по адресу https://test.com/monitoring/test/api
- Если процесс test был перезапущен, то скрипт пишет сообщение в лог /var/log/monitoring.log
- Если процесс не запущен то скрипт ничего не делает (за исключением проверки связи с сервером мониторинга)
- Если сервер мониторинга не доступен, так же скрипт также пишет об этом в лог.

# Диагностика

Для диагностики работы скрипта можно использовать примеры процессов на Bash и на C из папки test.
Для имитации работы сервера мониторинга можно использовать скрипт на Python из папки web-mon-server.

## Запуск web-mon-server
Скрипт web-mon-server требует наличия следующих библиотек: `flask`, `flask-sslify`.
Для работы на 443 порту скрипт надо запускать с правами root.
Для развертывания нужной среды можно использовать `pipenv`:
```bash
# Генерируем самоподписные ключи
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
sudo pipenv run python3
sudo pipenv run pip install flask
sudo pipenv run pip install flask-sslify

```
Тогда запуск скрипта будет выглядеть так:
```bash
sudo pipenv run python3 web-mon-server.py
```

Скрипт пишет логи в файл monitoring_server.log из папки со скриптом.
Для отладки скрипта web-mon-server можно использовать команды
```bash
curl --insecure -X POST -H "Content-Type: application/json" -d '{"status":"running","pid":"1234"}' https://127.0.0.1:443/monitoring/test/api
curl -s -k --head --request GET "https://127.0.0.1:443/monitoring/test/api"
tail -f monitoring_server.log
```
