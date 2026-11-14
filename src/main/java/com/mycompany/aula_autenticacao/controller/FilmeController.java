package com.mycompany.aula_autenticacao.controller;

import com.mycompany.aula_autenticacao.model.Filme;
import com.mycompany.aula_autenticacao.service.FilmeService;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * CAMADA CONTROLLER (MVC) - Porta de entrada HTTP da API RESTful para o recurso "/filmes".
 * Referências teóricas:
 * - "Implementação com Modelo MVC": Recebe a requisição do cliente, aciona o Service e devolve a resposta.
 * - "Webservices RESTful" e "Manipulação de Objetos JSON": Retorna uma lista Java serializada em JSON.
 */
@RestController // Combina @Controller + @ResponseBody: converte o retorno dos métodos diretamente para JSON
@RequestMapping(value = "/filmes", produces = MediaType.APPLICATION_JSON_VALUE) // Define a URI base "/filmes" e garante saída em JSON
public class FilmeController {

    private final FilmeService filmeService;

    // Injeção de dependência da camada Service
    public FilmeController(FilmeService filmeService) {
        this.filmeService = filmeService;
    }

    /**
     * Passo 1 do fluxo HTTP: Atende requisições GET em http://localhost:8080/filmes
     * Controle de Acesso (RBAC): Acessível por qualquer usuário autenticado (RESPONSAVEL ou CRIANCA).
     */
    @GetMapping // Mapeia o verbo HTTP GET (usado em REST para buscar/consultar recursos sem efeitos colaterais)
    @PreAuthorize("hasAnyRole('RESPONSAVEL', 'CRIANCA')") // Autorização: exige que o usuário autenticado tenha um dos dois perfis
    public List<Filme> listarFilmes() {
        // Aciona o Service (Passo 2), que busca no Repository (Passo 3) e retorna a lista serializada em JSON
        return filmeService.listarTodos();
    }
}

