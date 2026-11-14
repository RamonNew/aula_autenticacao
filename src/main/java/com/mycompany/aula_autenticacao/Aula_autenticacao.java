package com.mycompany.aula_autenticacao;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * CLASSE PRINCIPAL DA APLICAÇÃO SPRING BOOT
 * Ponto de partida que inicializa o servidor web embutido (Tomcat), o banco SQLite,
 * o mapeamento JPA/Hibernate e os filtros de segurança do Spring Security.
 */
@SpringBootApplication // Habilita configuração automática, varredura de pacotes (@Entity, @Service, @RestController)
public class Aula_autenticacao {

    public static void main(String[] args) {
        SpringApplication.run(Aula_autenticacao.class, args);
    }
}
