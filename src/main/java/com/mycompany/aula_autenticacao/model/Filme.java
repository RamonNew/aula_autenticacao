package com.mycompany.aula_autenticacao.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * CAMADA MODEL (MVC) - Entidade que representa o recurso Filme no catálogo de streaming.
 * Ao ser retornada pelo Controller, o Spring converte automaticamente seus atributos em um objeto JSON.
 */
@Entity // Marca a classe como uma tabela gerenciada pelo ORM (Hibernate)
@Table(name = "filmes") // Nome da tabela no SQLite
public class Filme {

    @Id // Chave primária da tabela "filmes"
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Autoincremento no SQLite
    private Long id;

    @Column(nullable = false) // Coluna obrigatória (NOT NULL)
    private String titulo;

    @Column(nullable = false)
    private String genero;

    @Column(nullable = false)
    private String classificacaoIndicativa;

    // Construtor padrão obrigatório para o Hibernate
    public Filme() {
    }

    public Filme(String titulo, String genero, String classificacaoIndicativa) {
        this.titulo = titulo;
        this.genero = genero;
        this.classificacaoIndicativa = classificacaoIndicativa;
    }

    // Os métodos Getters abaixo são lidos pelo Jackson para gerar os pares "chave": "valor" no JSON
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getGenero() {
        return genero;
    }

    public void setGenero(String genero) {
        this.genero = genero;
    }

    public String getClassificacaoIndicativa() {
        return classificacaoIndicativa;
    }

    public void setClassificacaoIndicativa(String classificacaoIndicativa) {
        this.classificacaoIndicativa = classificacaoIndicativa;
    }
}

