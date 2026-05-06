FROM python:3.12-slim

WORKDIR /app/backend

COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

COPY backend /app/backend

EXPOSE 3480
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "3480"]
