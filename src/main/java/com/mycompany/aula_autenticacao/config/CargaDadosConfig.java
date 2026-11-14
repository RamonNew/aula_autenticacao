package com.mycompany.aula_autenticacao.config;

import com.mycompany.aula_autenticacao.model.Fatura;
import com.mycompany.aula_autenticacao.model.Filme;
import com.mycompany.aula_autenticacao.model.Perfil;
import com.mycompany.aula_autenticacao.model.Usuario;
import com.mycompany.aula_autenticacao.repository.FaturaRepository;
import com.mycompany.aula_autenticacao.repository.FilmeRepository;
import com.mycompany.aula_autenticacao.repository.UsuarioRepository;
import jakarta.annotation.PostConstruct;
import java.util.List;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * CARGA INICIAL DE DADOS - Popula o banco SQLite automaticamente logo após a inicialização.
 * Garante que a API já esteja pronta para testes em aula assim que o projeto for compilado e executado.
 */
@Configuration // Marca como classe de configuração gerenciada pelo Spring
public class CargaDadosConfig {

    private final UsuarioRepository usuarioRepository;
    private final FilmeRepository filmeRepository;
    private final FaturaRepository faturaRepository;
    private final PasswordEncoder passwordEncoder;

    public CargaDadosConfig(
            UsuarioRepository usuarioRepository,
            FilmeRepository filmeRepository,
            FaturaRepository faturaRepository,
            PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.filmeRepository = filmeRepository;
        this.faturaRepository = faturaRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * @PostConstruct: Informa ao Spring que este método deve ser executado automaticamente
     * uma única vez, logo após a construção da classe e injeção das dependências.
     */
    @PostConstruct
    public void carregarDadosIniciais() {
        // 1. Insere usuários de teste (apenas se a tabela estiver vazia)
        if (usuarioRepository.count() == 0) {
            Usuario pai = new Usuario(
                "responsavel",
                passwordEncoder.encode("123456"), // Senha criptografada com BCrypt
                Perfil.RESPONSAVEL
            );
            Usuario filho = new Usuario(
                "crianca",
                passwordEncoder.encode("123456"), // Senha criptografada com BCrypt
                Perfil.CRIANCA
            );
            usuarioRepository.saveAll(List.of(pai, filho));
        }

        // 2. Insere filmes de exemplo no catálogo (apenas se a tabela estiver vazia)
        if (filmeRepository.count() == 0) {
            filmeRepository.saveAll(List.of(
                new Filme("Toy Story", "Animação", "Livre"),
                new Filme("Divertida Mente 2", "Animação / Família", "Livre"),
                new Filme("Interestelar", "Ficção Científica", "10 anos")
            ));
        }

        // 3. Insere faturas financeiras de exemplo (apenas se a tabela estiver vazia)
        if (faturaRepository.count() == 0) {
            faturaRepository.saveAll(List.of(
                new Fatura("Outubro/2026", 39.90, "PAGA"),
                new Fatura("Novembro/2026", 39.90, "ABERTA")
            ));
        }
    }
}

