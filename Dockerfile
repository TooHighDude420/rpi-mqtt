FROM debian:bookworm

COPY main.py /app/main.py
COPY start.sh /app/start.sh
COPY requirements.txt /app/requirements.txt

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mosquitto \
        python3 \
        python3-pip \
        mosquitto-clients \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages -r /app/requirements.txt

WORKDIR /app

COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

CMD ["sh", "/app/start.sh"]
