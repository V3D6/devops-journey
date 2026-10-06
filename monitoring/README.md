# Мониторинг: Zabbix + Grafana

## Стек
- Zabbix Server 7.4.14
- Zabbix Agent 2
- Grafana 11.6.0
- Плагин: alexanderzobnin-zabbix-app 6.8.0

## Что сделано
- Установлен и настроен Zabbix Server + Agent
- Подключён PostgreSQL к Zabbix Agent 2
- Установлена Grafana 11.6.0
- Установлен плагин Zabbix 6.8.0
- Создан API Token в Zabbix (Zabbix 7.2+ не поддерживает Basic Auth)
- Zabbix подключён к Grafana как Data Source через API Token
- Создан дашборд с метриками CPU, памяти, диска

## Грабли, которые прошёл

### 1. Invalid signature плагина Zabbix
**Проблема:** Grafana блокировала плагин как `Invalid signature`.
**Решение:** удалить `MANIFEST.txt` и `go_plugin_build_manifest` из папки плагина. Включить `allow_loading_unsigned_plugins` в `grafana.ini`.

### 2. Несовместимость плагина с Grafana 12
**Проблема:** плагин 6.9.1 падал с ошибкой `Minified React error #130` на Grafana 12.2.8.
**Решение:** откатить Grafana до 11.6.0, установить плагин 6.8.0.

### 3. Apache режет заголовок Authorization
**Проблема:** плагин логинился, но следующие запросы падали с `Incorrect user name or password`.
**Решение:** включить `sudo a2enconf php8.5-fpm`, перезагрузить Apache.

### 4. Basic Auth не поддерживается в Zabbix 7.2+
**Проблема:** `basic auth is not supported for Zabbix v7.2 and later`.
**Решение:** создать API Token в Zabbix (User settings → API tokens), в Grafana выбрать Auth type = API Token.

### 5. Zabbix Server не подключался к базе
**Проблема:** в логах `Access denied for user 'zabbix'@'localhost' (using password: NO)`.
**Решение:** в `/etc/zabbix/zabbix_server.conf` раскомментировать строку `DBPassword=ZabbixPass123`, перезапустить Zabbix Server.

# Мониторинг: Zabbix + Grafana

## Стек
- Zabbix Server 7.4.14
- Zabbix Agent 2
- Grafana 11.6.0
- Плагин: alexanderzobnin-zabbix-app 6.8.0

## Что сделано
- Установлен и настроен Zabbix Server + Agent
- Подключён PostgreSQL к Zabbix Agent 2
- Установлена Grafana 11.6.0
- Установлен плагин Zabbix 6.8.0
- Создан API Token в Zabbix (Zabbix 7.2+ не поддерживает Basic Auth)
- Zabbix подключён к Grafana как Data Source через API Token
- Создан дашборд с метриками CPU, памяти, диска

## Грабли, которые прошёл

### 1. Invalid signature плагина Zabbix
**Проблема:** Grafana блокировала плагин как `Invalid signature`.
**Решение:** удалить `MANIFEST.txt` и `go_plugin_build_manifest` из папки плагина. Включить `allow_loading_unsigned_plugins` в `grafana.ini`.

### 2. Несовместимость плагина с Grafana 12
**Проблема:** плагин 6.9.1 падал с ошибкой `Minified React error #130` на Grafana 12.2.8.
**Решение:** откатить Grafana до 11.6.0, установить плагин 6.8.0.

### 3. Apache режет заголовок Authorization
**Проблема:** плагин логинился, но следующие запросы падали с `Incorrect user name or password`.
**Решение:** включить `sudo a2enconf php8.5-fpm`, перезагрузить Apache.

### 4. Basic Auth не поддерживается в Zabbix 7.2+
**Проблема:** `basic auth is not supported for Zabbix v7.2 and later`.
**Решение:** создать API Token в Zabbix (User settings → API tokens), в Grafana выбрать Auth type = API Token.

### 5. Zabbix Server не подключался к базе
**Проблема:** в логах `Access denied for user 'zabbix'@'localhost' (using password: NO)`.
**Решение:** в `/etc/zabbix/zabbix_server.conf` раскомментировать строку `DBPassword=ZabbixPass123`, перезапустить Zabbix Server.

## Полезные команды

```bash
# Проверка статуса
sudo systemctl status zabbix-server zabbix-agent apache2 mariadb grafana-server

# Проверка портов
sudo ss -tulpn | grep -E '10050|10051|3000|5432|3306'

# Логи Zabbix Server
sudo tail -f /var/log/zabbix/zabbix_server.log

# Логи Grafana
sudo journalctl -u grafana-server -f

# Проверка API Zabbix
curl -X POST -H "Content-Type: application/json" http://127.0.0.1/zabbix/api_jsonrpc.php -d '{"jsonrpc":"2.0","method":"apiinfo.version","params":{},"id":1}'
