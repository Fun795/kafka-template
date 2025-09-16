#!/bin/bash

USER=$1          # пользователь Kafka (например, admin)
TOPICS=$2        # список топиков через пробел, в кавычках: "topic1 topic2"
ACTION=$3        # add или remove
OPERATION=$4     # операция: Read, Write, All

# Проверка обязательных аргументов
if [[ -z "$USER" || -z "$TOPICS" || -z "$ACTION" || -z "$OPERATION" ]]; then
    echo "Использование: $0 <user> \"<topic1 topic2 ...>\" <add|remove> <Read|Write|All>"
    echo "Пример: $0 admin \"t1_1C_organization t1_logs\" add Read"
    exit 1
fi

# Проверка корректности действия
if [[ ! "$ACTION" =~ ^(add|remove)$ ]]; then
    echo "Ошибка: действие должно быть 'add' или 'remove', получено: '$ACTION'"
    exit 1
fi

# Проверка корректности операции
if [[ ! "$OPERATION" =~ ^(Read|Write|All)$ ]]; then
    echo "Ошибка: операция должна быть 'Read', 'Write' или 'All', получено: '$OPERATION'"
    exit 1
fi

# Обработка каждого топика
for TOPIC in $TOPICS; do
    if [[ "$ACTION" == "add" ]]; then
        echo "Добавление ACL ($OPERATION) для пользователя '$USER' на топик '$TOPIC'..."
        docker exec -i kafka1 \
            /usr/bin/kafka-acls \
                --bootstrap-server kafka1:9092 \
                --command-config /etc/kafka/admin-client.properties \
                --add \
                --allow-principal "User:$USER" \
                --operation "$OPERATION" \
                --topic "$TOPIC"
    elif [[ "$ACTION" == "remove" ]]; then
        echo "Удаление ACL ($OPERATION) для пользователя '$USER' с топика '$TOPIC'..."
        docker exec -i kafka1 \
            /usr/bin/kafka-acls \
                --bootstrap-server kafka1:9092 \
                --command-config /etc/kafka/admin-client.properties \
                --remove \
                --allow-principal "User:$USER" \
                --operation "$OPERATION" \
                --topic "$TOPIC" \
                --force
    fi
done

echo "Готово: обработано $(echo $TOPICS | wc -w) топиков."