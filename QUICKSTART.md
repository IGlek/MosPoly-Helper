# 🚀 Быстрый старт - МосПолиХелпер

## Запуск за 3 минуты

### Шаг 1: Клонирование репозитория
```bash
git clone https://github.com/EDeev/mospoly-helper.git
cd mospoly-helper
```

### Шаг 2: Настройка токена бота
```bash
# Создайте файл .env из шаблона
cp .env.example .env

# Добавьте токен бота (получите у @BotFather в Telegram)
echo "BOT_TOKEN=ваш_токен_здесь" > .env
```

### Шаг 3: Запуск через Docker
```bash
# Запуск бота
docker-compose up -d

# Проверка логов
docker-compose logs -f
```

## Альтернатива: Запуск без Docker

### Шаг 1: Установка зависимостей
```bash
# Установка Python зависимостей
pip install -r requirements.txt

# Установка FFmpeg
# Ubuntu/Debian:
sudo apt update && sudo apt install ffmpeg

# macOS:
brew install ffmpeg
```

### Шаг 2: Настройка токена
```bash
# Откройте src/code/config.py и замените токен
nano src/code/config.py
```

### Шаг 3: Запуск
```bash
cd src/code
python bot.py
```

## Проверка работы

После запуска:
1. Найдите бота в Telegram: [@MosPoly_Helperbot](https://t.me/MosPoly_Helperbot)
2. Отправьте команду `/start`
3. Попробуйте построить маршрут командой `/route`

## Полезные команды Docker

```bash
# Остановка бота
docker-compose down

# Перезапуск
docker-compose restart

# Просмотр логов
docker-compose logs -f

# Обновление и перезапуск
git pull
docker-compose up -d --build
```

## Нужна помощь?

- 📖 Подробная документация: [README.md](README.md)
- 🐳 Руководство по Docker: [DOCKER.md](DOCKER.md)
- 📧 Email: support@new-devs.ru
- 🐙 Issues: [GitHub Issues](https://github.com/EDeev/mospoly-helper/issues)

---

<div align="center">
<sub>Готово! Ваш бот запущен и готов к работе 🎉</sub>
</div>
