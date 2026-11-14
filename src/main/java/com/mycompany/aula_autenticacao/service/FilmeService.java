package com.mycompany.aula_autenticacao.service;

import com.mycompany.aula_autenticacao.model.Filme;
import com.mycompany.aula_autenticacao.repository.FilmeRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * CAMADA SERVICE (Regras de Negócio do Modelo MVC) - Orquestra as operações sobre Filmes.
 * Fluxo da Requisição: FilmeController -> FilmeService -> FilmeRepository -> SQLite.
 */
@Service // Define esta classe como um componente de Serviço (regras de negócio) gerenciado pelo Spring
public class FilmeService {

    private final FilmeRepository filmeRepository;

    // Injeção de Dependência via construtor (boa prática recomendada pelo Spring)
    public FilmeService(FilmeRepository filmeRepository) {
        this.filmeRepository = filmeRepository;
    }

    /**
     * Passo 2 do fluxo HTTP: O Controller aciona este método no Service,
     * que por sua vez solicita os registros ao Repository.
     */
    @Transactional(readOnly = true) // Abre uma transação otimizada apenas para leitura no banco de dados
    public List<Filme> listarTodos() {
        // Passo 3 do fluxo HTTP: Aciona o Repository (executa SELECT * FROM filmes no SQLite)
        return filmeRepository.findAll();
    }
}

