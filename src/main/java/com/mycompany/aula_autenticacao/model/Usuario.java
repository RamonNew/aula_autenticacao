package com.mycompany.aula_autenticacao.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * CAMADA MODEL (MVC) - Entidade que representa o Usuário do sistema.
 * Referências teóricas:
 * - "Persistência de Dados": Mapeamento Objeto-Relacional (ORM) com JPA/Hibernate.
 * - "Recursos de Autenticação": Armazena a Identificação (login), Autenticação (senha) e Autorização (perfil).
 */
@Entity // Indica ao JPA/Hibernate que esta classe deve ser mapeada para uma tabela no banco SQLite
@Table(name = "usuarios") // Define explicitamente o nome da tabela no banco de dados relacional
public class Usuario {

    @Id // Define este atributo como a Chave Primária (Primary Key) da tabela
    @GeneratedValue(strategy = GenerationType.IDENTITY) // O próprio SQLite gera o ID autoincremental
    private Long id;

    @Column(unique = true, nullable = false) // Garante que o ID de identificação (login) seja único e obrigatório
    private String login;

    @JsonIgnore // Impede que a senha saia em um JSON caso a entidade seja serializada
    @Column(nullable = false)
    private String senha;

    @Enumerated(EnumType.STRING) // Salva o texto ("RESPONSAVEL" ou "CRIANCA") no banco em vez de números (0 ou 1)
    @Column(nullable = false)
    private Perfil perfil;

    // Construtor vazio exigido pela especificação JPA para que o Hibernate instancie o objeto via reflexão
    public Usuario() {
    }

    public Usuario(String login, String senha, Perfil perfil) {
        this.login = login;
        this.senha = senha;
        this.perfil = perfil;
    }

    // Getters e Setters: utilizados pelo JPA e pelo serializador JSON (Jackson)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }

    public Perfil getPerfil() {
        return perfil;
    }

    public void setPerfil(Perfil perfil) {
        this.perfil = perfil;
    }
}

