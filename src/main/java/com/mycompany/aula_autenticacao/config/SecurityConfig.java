package com.mycompany.aula_autenticacao.config;

import com.mycompany.aula_autenticacao.model.Usuario;
import com.mycompany.aula_autenticacao.repository.UsuarioRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * CONFIGURAÇÃO DE SEGURANÇA - Implementa Identificação, Autenticação e Autorização (RBAC).
 * Referência teórica: "Recursos de Autenticação"
 * 1. Identificação: O usuário informa seu "login" no cabeçalho HTTP Basic Auth.
 * 2. Autenticação: O sistema valida "o que o usuário sabe" (senha criptografada com BCrypt).
 * 3. Autorização: O sistema verifica o Perfil (RESPONSAVEL ou CRIANCA) antes de liberar o endpoint.
 */
@Configuration // Indica que esta classe define configurações e Beans gerenciados pelo Spring
@EnableWebSecurity // Habilita a proteção de segurança web do Spring Security nas requisições HTTP
@EnableMethodSecurity // Habilita o uso da anotação @PreAuthorize diretamente nos Controllers
public class SecurityConfig {

    /**
     * Define a corrente de filtros de segurança (SecurityFilterChain) que intercepta toda requisição HTTP.
     */
    @Bean // Registra o retorno deste método no contêiner de Injeção de Dependências do Spring
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Desabilita CSRF pois uma API RESTful é Stateless (não usa sessão/cookies de navegador)
            .csrf(csrf -> csrf.disable())

            // Define a política Stateless (conceito central da unidade "Webservices RESTful"):
            // cada requisição HTTP é independente e deve enviar suas credenciais.
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // Regras de Autorização Baseada em Perfis (Role-Based Access Control - RBAC):
            .authorizeHttpRequests(auth -> auth
                // GET /filmes -> liberado para usuários autenticados com perfil RESPONSAVEL ou CRIANCA
                .requestMatchers(HttpMethod.GET, "/filmes").hasAnyRole("RESPONSAVEL", "CRIANCA")

                // GET /faturas -> restrito EXCLUSIVAMENTE ao perfil RESPONSAVEL (CRIANCA recebe 403 Forbidden)
                .requestMatchers(HttpMethod.GET, "/faturas").hasRole("RESPONSAVEL")

                // Qualquer outro endpoint exige autenticação
                .anyRequest().authenticated()
            )

            // Habilita Autenticação HTTP Basic (envio de usuário e senha no cabeçalho Authorization)
            .httpBasic(Customizer.withDefaults());

        return http.build();
    }

    /**
     * Conecta o Spring Security ao nosso banco de dados SQLite através do UsuarioRepository.
     * Durante o logon, busca o usuário pelo login (Identificação) e entrega a senha e o perfil
     * para o Spring Security validar (Autenticação e Autorização).
     */
    @Bean
    public UserDetailsService userDetailsService(UsuarioRepository usuarioRepository) {
        return login -> {
            Usuario usuario = usuarioRepository.findByLogin(login)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + login));

            // Converte nossa entidade Usuario para o objeto UserDetails do Spring Security
            return User.builder()
                .username(usuario.getLogin())
                .password(usuario.getSenha())
                .roles(usuario.getPerfil().name()) // Adiciona automaticamente o prefixo ROLE_ (ex: ROLE_RESPONSAVEL)
                .build();
        };
    }

    /**
     * Define o algoritmo de hash BCrypt para criptografar as senhas no banco de dados.
     * Boa prática citada em "Recursos de Autenticação": nunca armazenar senhas em texto puro!
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

