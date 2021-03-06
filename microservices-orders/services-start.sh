#!/bin/bash

RESTPORT=18894
JAR=/usr/share/java/kafka-streams-examples/kafka-streams-examples-5.2.0-standalone.jar

java -cp $JAR io.confluent.examples.streams.microservices.OrdersService broker:9092 http://schema-registry:8081 localhost $RESTPORT > /dev/null 2>&1 &

sleep 10

java -cp $JAR io.confluent.examples.streams.microservices.AddInventory 20 20 broker:9092 > /dev/null 2>&1 &

for SERVICE in "InventoryService" "FraudService" "OrderDetailsService" "ValidationsAggregatorService" "EmailService"; do
  echo "Starting $SERVICE"
  java -cp $JAR io.confluent.examples.streams.microservices.$SERVICE broker:9092 http://schema-registry:8081 > /dev/null 2>&1 &
done

sleep 10

java -cp $JAR io.confluent.examples.streams.microservices.PostOrdersAndPayments $RESTPORT broker:9092 http://schema-registry:8081 > /dev/null 2>&1 &
