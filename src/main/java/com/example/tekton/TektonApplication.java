package com.example.tekton;

import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.reactive.function.server.RouterFunction;
import org.springframework.web.reactive.function.server.ServerResponse;

import static org.springframework.web.reactive.function.server.RouterFunctions.route;

@SpringBootApplication
public class TektonApplication {

    public static void main(String[] args) {
        SpringApplication.run(TektonApplication.class, args);
    }

    @Bean
    RouterFunction<ServerResponse> routes() {
        return route()
                .GET("/", request -> ServerResponse.ok().bodyValue(""))
                .GET("/hello", request -> ServerResponse.ok().bodyValue("G'Day Mate!"))
                .build();
    }

    @Bean
    ApplicationRunner runner() {
        return args -> {
            System.out.println("hi there!");
        };
    }

}
