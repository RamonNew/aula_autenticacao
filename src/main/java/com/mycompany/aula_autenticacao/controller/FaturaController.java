package com.mycompany.aula_autenticacao.controller;

import com.mycompany.aula_autenticacao.model.Fatura;
import com.mycompany.aula_autenticacao.service.FaturaService;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * CAMADA CONTROLLER (MVC) - Porta de entrada HTTP da API RESTful para o recurso "/faturas".
 * Demonstra a diferença entre Autenticação (401 Unauthorized) e Autorização (403 Forbidden).
 */
@RestController // Indica um controlador REST onde todo retorno de método é serializado diretamente em JSON
@RequestMapping(value = "/faturas", produces = MediaType.APPLICATION_JSON_VALUE) // URI do recurso "/faturas" trafegando apenas JSON
public class FaturaController {

    private final FaturaService faturaService;

    // Injeção de dependência da camada Service
    public FaturaController(FaturaService faturaService) {
        this.faturaService = faturaService;
    }

    /**
     * Passo 1 do fluxo HTTP: Atende requisições GET em http://localhost:8080/faturas
     * Controle de Acesso (RBAC): Estritamente autorizado apenas para o perfil RESPONSAVEL.
     * Se um usuário autenticado com perfil CRIANCA tentar acessar, o Spring Security
     * intercepta a chamada antes mesmo de entrar no método e retorna HTTP 403 Forbidden!
     */
    @GetMapping // Mapeia requisições HTTP GET para este método
    @PreAuthorize("hasRole('RESPONSAVEL')") // Autorização restrita: bloqueia o perfil CRIANCA com erro 403 Forbidden
    public List<Fatura> listarFaturas() {
        // Aciona o Service (Passo 2), que aciona o Repository (Passo 3) e devolve o array JSON de faturas
        return faturaService.listarTodas();
    }
}

