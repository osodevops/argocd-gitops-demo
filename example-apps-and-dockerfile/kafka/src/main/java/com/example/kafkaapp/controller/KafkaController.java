package com.example.kafkaapp.controller;

import com.example.kafkaapp.service.KafkaProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class KafkaController {

    @Autowired
    private KafkaProducerService producerService;

    @GetMapping("/produce/{message}")
    public String produce(@PathVariable String message) {
        producerService.sendMessage("test-topic", message);
        return "Message sent: " + message;
    }

    @GetMapping("/consume")
    public String consume() {
        // This endpoint does nothing because the consumer is already listening to the topic.
        return "Consuming messages from Kafka...";
    }
}
