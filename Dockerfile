# Используем официальный Python образ
FROM python:3.10-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Устанавливаем системные зависимости и FFmpeg
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Копируем requirements.txt
COPY requirements.txt .

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код проекта
COPY src/ /app/src/

# Создаем необходимые директории для данных
RUN mkdir -p /app/src/data/cache \
    /app/src/data/users \
    /app/logs

# Устанавливаем рабочую директорию для запуска бота
WORKDIR /app/src/code

# Команда для запуска бота
CMD ["python", "bot.py"]
