package com.mycompany.aula_autenticacao.service;

import com.mycompany.aula_autenticacao.model.Fatura;
import com.mycompany.aula_autenticacao.repository.FaturaRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * CAMADA SERVICE (Regras de Negócio do Modelo MVC) - Orquestra as operações sobre Faturas.
 * Fluxo da Requisição: FaturaController -> FaturaService -> FaturaRepository -> SQLite.
 */
@Service // Marca a classe como componente da camada de serviço do Spring
public class FaturaService {

    private final FaturaRepository faturaRepository;

    // Injeção de Dependência via construtor para desacoplar o Service da implementação do banco
    public FaturaService(FaturaRepository faturaRepository) {
        this.faturaRepository = faturaRepository;
    }

    /**
     * Passo 2 do fluxo HTTP: Chamado pelo FaturaController após o Spring Security
     * confirmar que o usuário possui o perfil RESPONSAVEL.
     */
    @Transactional(readOnly = true) // Garante consistência transacional e otimiza a leitura no Hibernate
    public List<Fatura> listarTodas() {
        // Passo 3 do fluxo HTTP: Busca todas as faturas cadastradas no banco SQLite
        return faturaRepository.findAll();
    }
}

