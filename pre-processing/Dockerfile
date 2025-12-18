FROM python:3.10-slim

WORKDIR /opt/ml/code

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY preprocess.py .
COPY src/ src/

ENV SAGEMAKER_PROGRAM=train.py
ENTRYPOINT ["python", "preprocess.py"]
