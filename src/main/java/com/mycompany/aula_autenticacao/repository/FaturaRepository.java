package com.mycompany.aula_autenticacao.repository;

import com.mycompany.aula_autenticacao.model.Fatura;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * CAMADA REPOSITORY - Interface de acesso a dados da entidade Fatura.
 * Responsável por traduzir chamadas de método em consultas SQL no arquivo SQLite via Hibernate/JDBC.
 */
@Repository // Registra a interface como componente da camada de persistência
public interface FaturaRepository extends JpaRepository<Fatura, Long> {
}

