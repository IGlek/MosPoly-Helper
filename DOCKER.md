# 🐳 Docker - Руководство по развертыванию

## Содержание
- [Быстрый старт](#быстрый-старт)
- [Подробная настройка](#подробная-настройка)
- [Управление контейнером](#управление-контейнером)
- [Мониторинг и отладка](#мониторинг-и-отладка)
- [Производственное развертывание](#производственное-развертывание)

## Быстрый старт

### 1. Установка Docker

**Ubuntu/Debian:**
```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Установка Docker Compose
sudo apt install docker-compose-plugin

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
```

**macOS:**
```bash
# Установка через Homebrew
brew install --cask docker
```

**Windows:**
Скачайте [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)

### 2. Настройка проекта

```bash
# Клонирование репозитория
git clone https://github.com/EDeev/mospoly-helper.git
cd mospoly-helper

# Создание файла .env
cp .env.example .env

# Редактирование .env (добавьте ваш BOT_TOKEN)
nano .env
```

### 3. Запуск

```bash
# Сборка и запуск в фоновом режиме
docker-compose up -d

# Проверка статуса
docker-compose ps

# Просмотр логов
docker-compose logs -f
```

## Подробная настройка

### Структура Docker-файлов

```
mospoly-helper/
├── Dockerfile              # Описание образа контейнера
├── docker-compose.yml      # Конфигурация сервисов
├── .dockerignore          # Исключения при сборке
├── .env                   # Переменные окружения (не в Git!)
└── .env.example           # Шаблон переменных окружения
```

### Переменные окружения (.env)

```env
# Основная конфигурация
BOT_TOKEN=your_bot_token_here
```

### Volumes (монтируемые директории)

Данные сохраняются между перезапусками контейнера благодаря volumes:

| Локальная директория | Директория в контейнере | Назначение |
|----------------------|-------------------------|------------|
| `./src/videos` | `/app/src/videos` | Исходные видеофрагменты (read-only) |
| `./src/data/cache` | `/app/src/data/cache` | Кеш сгенерированных маршрутов |
| `./src/data/users` | `/app/src/data/users` | Данные пользователей |
| `./logs` | `/app/logs` | Журналы работы бота |

## Управление контейнером

### Основные команды

```bash
# Запуск
docker-compose up -d                    # В фоновом режиме
docker-compose up                       # С выводом логов в терминал

# Остановка
docker-compose stop                     # Остановка без удаления
docker-compose down                     # Остановка и удаление контейнера

# Перезапуск
docker-compose restart                  # Быстрый перезапуск
docker-compose down && docker-compose up -d  # Полный перезапуск

# Пересборка
docker-compose build                    # Пересборка образа
docker-compose up -d --build            # Пересборка и запуск
```

### Работа с контейнером

```bash
# Выполнение команд внутри контейнера
docker-compose exec mospoly-helper-bot python combine.py

# Интерактивная оболочка
docker-compose exec mospoly-helper-bot /bin/bash

# Копирование файлов
docker cp local_file.txt mospoly-helper-bot:/app/
docker cp mospoly-helper-bot:/app/file.txt ./
```

## Мониторинг и отладка

### Просмотр логов

```bash
# Все логи
docker-compose logs

# Последние 100 строк с обновлением
docker-compose logs --tail=100 -f

# Логи за последний час
docker-compose logs --since 1h

# Логи конкретного сервиса
docker-compose logs mospoly-helper-bot
```

### Проверка состояния

```bash
# Статус контейнеров
docker-compose ps

# Использование ресурсов
docker stats mospoly-helper-bot

# Проверка health check
docker inspect --format='{{.State.Health.Status}}' mospoly-helper-bot
```

### Отладка проблем

```bash
# Проверка сети
docker network inspect mospoly-helper_default

# Инспектирование контейнера
docker inspect mospoly-helper-bot

# События Docker
docker events --filter container=mospoly-helper-bot
```

## Производственное развертывание

### 1. Подготовка сервера

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker и Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install docker-compose-plugin

# Создание пользователя для бота
sudo useradd -m -s /bin/bash botuser
sudo usermod -aG docker botuser
```

### 2. Настройка автозапуска

Docker Compose автоматически настроит перезапуск контейнера благодаря `restart: unless-stopped` в docker-compose.yml.

Проверка:
```bash
# Перезагрузка сервера
sudo reboot

# После перезагрузки проверка
docker-compose ps
```

### 3. Настройка logrotate

Создайте файл `/etc/logrotate.d/docker-containers`:

```
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    missingok
    delaycompress
    copytruncate
}
```

### 4. Мониторинг

Используйте systemd для мониторинга:

```bash
# Создайте файл /etc/systemd/system/mospoly-bot.service
[Unit]
Description=MosPoly Helper Bot
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/path/to/mospoly-helper
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
User=botuser

[Install]
WantedBy=multi-user.target
```

```bash
# Активация сервиса
sudo systemctl daemon-reload
sudo systemctl enable mospoly-bot.service
sudo systemctl start mospoly-bot.service
sudo systemctl status mospoly-bot.service
```

### 5. Резервное копирование

```bash
# Скрипт резервного копирования (backup.sh)
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/mospoly-bot"

mkdir -p $BACKUP_DIR

# Остановка контейнера
docker-compose stop

# Резервное копирование данных
tar -czf $BACKUP_DIR/data_$DATE.tar.gz ./src/data

# Запуск контейнера
docker-compose start

# Удаление старых резервных копий (старше 30 дней)
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

Добавьте в crontab:
```bash
# Резервное копирование каждый день в 3:00
0 3 * * * /path/to/backup.sh
```

## Обновление бота

```bash
# 1. Получение обновлений
git pull

# 2. Остановка контейнера
docker-compose down

# 3. Пересборка образа
docker-compose build

# 4. Запуск обновленной версии
docker-compose up -d

# 5. Проверка логов
docker-compose logs -f
```

## Очистка ресурсов

```bash
# Удаление неиспользуемых образов
docker image prune -a

# Удаление неиспользуемых volumes
docker volume prune

# Полная очистка системы Docker
docker system prune -a --volumes
```

## Решение типичных проблем

### Проблема: Контейнер не запускается

```bash
# Проверка логов
docker-compose logs

# Проверка переменных окружения
docker-compose config

# Пересборка образа
docker-compose build --no-cache
docker-compose up -d
```

### Проблема: Недостаточно места на диске

```bash
# Проверка использования места
docker system df

# Очистка
docker system prune -a
```

### Проблема: Контейнер постоянно перезапускается

```bash
# Проверка статуса health check
docker inspect --format='{{.State.Health}}' mospoly-helper-bot

# Запуск без автоперезапуска для отладки
docker-compose run --rm mospoly-helper-bot python bot.py
```

## Полезные ссылки

- [Официальная документация Docker](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

<div align="center">
<sub>Создано с ❤️ для удобства развертывания МосПолиХелпер</sub>
</div>
