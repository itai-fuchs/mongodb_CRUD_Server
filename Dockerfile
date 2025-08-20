FROM python:3.11-slim

WORKDIR /app
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY services ./services

EXPOSE 8000
CMD ["uvicorn", "services.data_loader.app:app", "--host", "0.0.0.0", "--port", "8000"]
