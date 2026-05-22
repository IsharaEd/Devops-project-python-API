FROM python:3.12-slim AS builder 
WORKDIR /app
COPY requirement.txt .
RUN python3 -m venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH
RUN pip install -r requirement.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH=/opt/venv/bin:$PATH
COPY python-app.py .
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "python-app:app"]
