#!/bin/bash

USER=$1          # имя пользователя
GROUP=$2         # название consumer group (например, connect-cluster)
ACTION=$3        # add или remove

# Проверка обязательных аргументов
if [[ -z "$USER" || -z "$GROUP" || -z "$ACTION" || -z "All" ]]; then
    echo "Использование: $0 <user> <group> <add|remove> <Read|Describe|All>"
    echo "Пример: $0 erc-user connect-cluster add Read"
    exit 1
fi

# Проверка допустимых значений действия
if [[ ! "$ACTION" =~ ^(add|remove)$ ]]; then
    echo "Ошибка: действие должно быть 'add' или 'remove', получено: '$ACTION'"
    exit 1
fi

# Выполнение команды в контейнере kafka1
if [[ "$ACTION" == "add" ]]; then
    echo "Добавление доступа для пользователя '$USER' на группу '$GROUP'..."
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --add \
            --allow-principal "User:$USER" \
            --operation "All" \
            --group "$GROUP"
elif [[ "$ACTION" == "remove" ]]; then
    echo "Удаление доступа для пользователя '$USER' с группы '$GROUP'..."
    docker exec -i kafka1 \
        /usr/bin/kafka-acls \
            --bootstrap-server kafka1:9092 \
            --command-config /etc/kafka/admin-client.properties \
            --remove \
            --allow-principal "User:$USER" \
            --operation "All" \
            --group "$GROUP" \
            --force
fi

echo "Готово."