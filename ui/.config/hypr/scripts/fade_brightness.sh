#!/usr/bin/env bash
# Guardar el nivel de brillo actual
brightnessctl -s

# Atenuar gradualmente restando un 5% cada 40 milisegundos (15 pasos)
for i in {1..15}; do
    brightnessctl set 5%- -q
    sleep 0.04
done