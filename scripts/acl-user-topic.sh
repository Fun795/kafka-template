#!/bin/bash

USER=$1          # имя пользователя
TOPIC=$2         # название топика
ACTION=$3        # add или remove
OPERATION=$4     # операция: Read, Write, All

# Проверка обязательных аргументов
if [[ -z "$USER" || -z "$TOPIC" || -z "$ACTION" || -z "$OPERATION" ]]; then
    echo "Использование: $0 <user> <topic> <add|remove> <Read|Write|All>"
    echo "Пример: $0 chingiz56 t1_1C_organization add Read"
    exit 1
fi

# Проверка допустимых значений действия
if [[ ! "$ACTION" =~ ^(add|remove)$ ]]; then
    echo "Ошибка: действие должно быть 'add' или 'remove', получено: '$ACTION'"
    exit 1
fi

# Проверка допустимых операций
if [[ ! "$OPERATION" =~ ^(Read|Write|All)$ ]]; then
    echo "Ошибка: операция должна быть 'Read', 'Write' или 'All', получено: '$OPERATION'"
    exit 1
fi

# Выполнение команды в контейнере kafka1
if [[ "$ACTION" == "add" ]]; then
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --add \
            --allow-principal "User:$USER" \
            --operation "$OPERATION" \
            --topic "$TOPIC"
elif [[ "$ACTION" == "remove" ]]; then
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --remove \
            --allow-principal
            --principal "User:$USER" \
            --operation "$OPERATION" \
            --topic "$TOPIC" \
            --force
fi