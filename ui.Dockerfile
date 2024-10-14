# ui.Dockerfile
FROM quackai/gradio

WORKDIR /app

# Копирование только необходимых файлов
COPY app.py .

# Запуск приложения
CMD ["python", "app.py"]