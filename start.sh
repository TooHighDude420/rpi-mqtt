#!/bin/bash

mosquitto -c /etc/mosquitto/mosquitto.conf &
python3 -u /app/main.py