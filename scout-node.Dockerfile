dockerfile
FROM python:3.11-slim
RUN apt-get update && apt-get install -y sqlite3 libsqlite3-dev gcc && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install --no-cache-dir pyjwt requests numpy
COPY scout_process.py /app/scout_process.py
ENTRYPOINT ["python", "/app/scout_process.py"]
