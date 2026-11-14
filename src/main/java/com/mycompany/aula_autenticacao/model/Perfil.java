package com.mycompany.aula_autenticacao.model;

/**
 * Enumeração que define os Perfis de Acesso (Roles) do sistema.
 * Referência teórica: "Recursos de Autenticação" - Controle de Acesso Baseado em Perfis (RBAC).
 */
public enum Perfil {
    RESPONSAVEL, // Acesso total: pode consultar filmes e faturas financeiras
    CRIANCA      // Acesso restrito: pode consultar apenas o catálogo de filmes
}

