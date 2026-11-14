package com.mycompany.aula_autenticacao.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * CAMADA MODEL (MVC) - Entidade que representa uma Fatura financeira da assinatura.
 * Trata-se de um dado sensível que só deve ser acessado pelo perfil RESPONSAVEL.
 */
@Entity // Mapeia a classe para uma tabela relacional via JPA/Hibernate
@Table(name = "faturas") // Nome da tabela no SQLite
public class Fatura {

    @Id // Chave primária da tabela "faturas"
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Geração automática de ID sequencial
    private Long id;

    @Column(nullable = false)
    private String mesReferencia;

    @Column(nullable = false)
    private Double valor;

    @Column(nullable = false)
    private String statusPagamento;

    // Construtor vazio exigido pelo JPA
    public Fatura() {
    }

    public Fatura(String mesReferencia, Double valor, String statusPagamento) {
        this.mesReferencia = mesReferencia;
        this.valor = valor;
        this.statusPagamento = statusPagamento;
    }

    // Getters e Setters usados na serialização para JSON (ex: {"id": 1, "mesReferencia": "Novembro/2026", ...})
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getMesReferencia() {
        return mesReferencia;
    }

    public void setMesReferencia(String mesReferencia) {
        this.mesReferencia = mesReferencia;
    }

    public Double getValor() {
        return valor;
    }

    public void setValor(Double valor) {
        this.valor = valor;
    }

    public String getStatusPagamento() {
        return statusPagamento;
    }

    public void setStatusPagamento(String statusPagamento) {
        this.statusPagamento = statusPagamento;
    }
}

