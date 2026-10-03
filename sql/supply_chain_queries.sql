-- ============================================================
-- Учебная база "supply_chain"
-- Имитация системы снабжения для отработки SQL и диагностики
-- ============================================================

-- ============================================================
-- ЧАСТЬ 1. СОЗДАНИЕ ТАБЛИЦ
-- ============================================================

-- Поставщики
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    inn VARCHAR(12),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Товары
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2),
    category VARCHAR(50)
);

-- Заказы на закупку
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(id),
    order_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'new',
    total_amount DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Позиции заказа
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES purchase_orders(id),
    product_id INT REFERENCES products(id),
    quantity INT NOT NULL,
    price DECIMAL(10,2)
);

-- Логи операций
CREATE TABLE IF NOT EXISTS operation_logs (
    id SERIAL PRIMARY KEY,
    user_name VARCHAR(50),
    operation VARCHAR(100),
    status VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- ЧАСТЬ 2. ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- ============================================================

-- Поставщики
INSERT INTO suppliers (name, inn, contact_email) VALUES
('ООО "Ромашка"', '7701234567', 'info@romashka.ru'),
('АО "ТехноСнаб"', '7702345678', 'sales@technosnab.ru'),
('ООО "ЛогистикПлюс"', '7703456789', 'order@logplus.ru'),
('ИП Иванов И.И.', '770456789012', 'ivanov@mail.ru'),
('ООО "ГлобалТрейд"', '7705678901', 'trade@global.ru');

-- Товары
INSERT INTO products (sku, name, price, category) VALUES
('SKU-001', 'Ноутбук Lenovo ThinkPad', 85000.00, 'Электроника'),
('SKU-002', 'Монитор Dell 27"', 25000.00, 'Электроника'),
('SKU-003', 'Кресло офисное', 15000.00, 'Мебель'),
('SKU-004', 'Стол письменный', 12000.00, 'Мебель'),
('SKU-005', 'Клавиатура Logitech', 3500.00, 'Электроника'),
('SKU-006', 'МФУ HP LaserJet', 45000.00, 'Электроника');

-- Заказы
INSERT INTO purchase_orders (supplier_id, order_date, status, total_amount) VALUES
(1, '2026-09-01', 'completed', 170000.00),
(2, '2026-09-05', 'completed', 250000.00),
(3, '2026-09-10', 'in_progress', 120000.00),
(1, '2026-09-15', 'new', 85000.00),
(5, '2026-09-20', 'cancelled', 45000.00),
(2, '2026-09-25', 'in_progress', 300000.00);

-- Позиции заказов
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 85000.00),
(2, 2, 10, 25000.00),
(3, 3, 8, 15000.00),
(4, 1, 1, 85000.00),
(5, 6, 1, 45000.00),
(6, 2, 12, 25000.00);

-- Логи операций
INSERT INTO operation_logs (user_name, operation, status, error_message) VALUES
('ivanov', 'Создание заказа', 'success', NULL),
('petrov', 'Обновление статуса', 'success', NULL),
('ivanov', 'Проведение закупки', 'error', 'Таймаут соединения с SAP'),
('sidorov', 'Создание заказа', 'success', NULL),
('petrov', 'Экспорт отчёта', 'error', 'Недостаточно прав'),
('ivanov', 'Проведение закупки', 'success', NULL);

-- ============================================================
-- ЧАСТЬ 3. ЗАПРОСЫ ДЛЯ ДИАГНОСТИКИ И ОТЧЁТОВ
-- ============================================================

-- 3.1. Все поставщики
SELECT * FROM suppliers;

-- 3.2. Заказы со статусом "в работе"
SELECT * FROM purchase_orders WHERE status = 'in_progress';

-- 3.3. Заказы за сентябрь 2026
SELECT * FROM purchase_orders
WHERE order_date BETWEEN '2026-09-01' AND '2026-09-30'
ORDER BY order_date;

-- 3.4. Товары дороже 20000
SELECT sku, name, price FROM products
WHERE price > 20000
ORDER BY price DESC;

-- 3.5. Количество заказов по статусам
SELECT status, COUNT(*) AS count
FROM purchase_orders
GROUP BY status
ORDER BY count DESC;

-- 3.6. Общая сумма заказов по поставщикам
SELECT s.name AS supplier, SUM(po.total_amount) AS total
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.id
GROUP BY s.name
ORDER BY total DESC;

-- 3.7. Ошибки в логах операций
SELECT user_name, operation, error_message, created_at
FROM operation_logs
WHERE status = 'error'
ORDER BY created_at DESC;

-- 3.8. Топ-3 товара по цене
SELECT name, price FROM products
ORDER BY price DESC
LIMIT 3;

-- 3.9. Заказы с деталями (JOIN)
SELECT po.id, s.name AS supplier, po.order_date, po.status, po.total_amount
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.id
ORDER BY po.order_date DESC;

-- 3.10. Количество ошибок по пользователям
SELECT user_name, COUNT(*) AS errors
FROM operation_logs
WHERE status = 'error'
GROUP BY user_name
ORDER BY errors DESC;

-- ============================================================
-- ЧАСТЬ 4. ДИАГНОСТИКА POSTGRESQL (для L2)
-- ============================================================

-- 4.1. Активные запросы (кто что делает прямо сейчас)
SELECT pid, usename, state, query, now() - query_start AS duration
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- 4.2. Только долгие запросы (больше 5 минут)
SELECT pid, usename, state, query, now() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 minutes'
ORDER BY duration DESC;

-- 4.3. "Idle in transaction" (держат блокировки)
SELECT pid, usename, state, query, now() - state_change AS idle_time
FROM pg_stat_activity
WHERE state = 'idle in transaction'
ORDER BY idle_time DESC;

-- 4.4. Список баз и их размер
SELECT datname, pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;

-- 4.5. Размер таблиц в базе
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
       n_live_tup AS live_rows,
       n_dead_tup AS dead_rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- 4.6. Таблицы с большим количеством мёртвых строк (нужен VACUUM)
SELECT relname, n_live_tup, n_dead_tup,
       ROUND(n_dead_tup * 100.0 / NULLIF(n_live_tup + n_dead_tup, 0), 2) AS dead_percent
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;

-- 4.7. Версия PostgreSQL и текущее время
SELECT version(), now();
