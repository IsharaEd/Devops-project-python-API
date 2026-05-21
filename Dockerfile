FROM python:3.12-slim
WORKDIR /app
COPY requirement.txt .
RUN pip install -r requirement.txt
COPY . .
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "python-app:app"]
