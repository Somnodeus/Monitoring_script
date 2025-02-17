from flask import Flask, request
import logging
from datetime import datetime
from flask_sslify import SSLify

app = Flask(__name__)

# Настройка логгирования
logging.basicConfig(filename='monitoring_server.log', level=logging.INFO,
                    format='%(asctime)s - %(message)s', datefmt='%d-%b-%y %H:%M:%S')

@app.route('/monitoring/test/api', methods=['GET', 'POST'])
def handle_monitoring_request():
    if request.method == 'GET':
        return "GET request received", 200
    else:
        # Логирование времени запроса, метода и данных запроса
        log_message = f"Received request: {request.method} - {request.data.decode('utf-8')}"
        logging.info(log_message)
        # Простой ответ для подтверждения получения запроса
        return "Request received", 200

if __name__ == '__main__':
    # Принудительное использование HTTPS
    sslify = SSLify(app)
    # Запуск сервера в режиме отладки на всех интерфейсах, порт 443
    # Используйте sudo для привязки к порту 443, который обычно зарезервирован для root
    app.run(host='0.0.0.0', port=443, ssl_context=('cert.pem', 'key.pem'), debug=True)
