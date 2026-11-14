package com.mycompany.aula_autenticacao.repository;

import com.mycompany.aula_autenticacao.model.Filme;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * CAMADA REPOSITORY - Interface de acesso a dados da entidade Filme.
 * Ao estender JpaRepository<Filme, Long>, ganhamos métodos prontos como findAll(), save() e count()
 * sem precisar escrever nenhuma linha de SQL manualmente.
 */
@Repository // Registra a interface como um Bean de persistência gerenciado pelo Spring
public interface FilmeRepository extends JpaRepository<Filme, Long> {
}

