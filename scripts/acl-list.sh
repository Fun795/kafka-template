#!/bin/bash

USER=$1  # необязательный параметр: имя пользователя (например, chingiz56)

# Проверка, запущен ли контейнер kafka1
if ! docker inspect kafka1 &>/dev/null; then
    echo "Ошибка: контейнер 'kafka1' не существует или не запущен."
    exit 1
fi

if [[ -z "$USER" ]]; then
    echo
    echo "Список всех ACL в кластере:"
    echo "================================"
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --list
else
    echo
    echo "Список ACL для пользователя: '$USER'"
    echo "========================================"
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --list \
            --principal "User:$USER"
fi