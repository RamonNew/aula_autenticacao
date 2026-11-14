package com.mycompany.aula_autenticacao.repository;

import com.mycompany.aula_autenticacao.model.Usuario;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * CAMADA REPOSITORY - Interface de comunicação com o banco de dados SQLite para a tabela "usuarios".
 * Referência teórica: "Persistência de Dados" - Uso do framework Spring Data JPA sobre o Hibernate/JDBC.
 */
@Repository // Indica ao Spring que esta interface é um componente de acesso a dados (DAO/Repository)
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Query Method do Spring Data JPA: o próprio nome do método gera automaticamente o SQL:
    // SELECT * FROM usuarios WHERE login = ?
    // Usado na etapa de Identificação/Autenticação para localizar o usuário no SQLite.
    Optional<Usuario> findByLogin(String login);
}

