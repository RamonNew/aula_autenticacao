# API RESTful de Catálogo e Streaming — Autenticação e Controle de Acesso (RBAC)

Projeto de referência desenvolvido em **Java 17** com **Spring Boot 3**, estruturado sob o padrão arquitetural **MVC**, persistência relacional com **JPA/Hibernate + SQLite** e segurança baseada em perfis (**Role-Based Access Control — RBAC**) utilizando **Spring Security**.

---

## Nota sobre Escopo Didático e Decisões Arquiteturais

> **Aviso Técnico:** Este repositório foi projetado especificamente como **material didático para aula de laboratório acadêmico** na disciplina de Programação Back-End.
>
> Para maximizar a clareza conceitual e permitir a compreensão ponta a ponta do fluxo de uma requisição HTTP dentro de uma janela de aula prática, parte da complexidade acidental de projetos corporativos foi intencionalmente abstraída:
> 1. **Retorno Direto de Entidades (Sem DTOs/Mappers):** Os controladores REST serializam diretamente as entidades JPA (`Filme` e `Fatura`) para JSON, reduzindo o *boilerplate* e evidenciando o papel do serializador Jackson e da anotação `@JsonIgnore` na proteção de atributos sensíveis (como o hash de senha em `Usuario`).
> 2. **Banco de Dados Relacional Embutido (SQLite):** Adotou-se o SQLite em arquivo local (`streaming.db`) com carga automática via `@PostConstruct`, eliminando a dependência de contêineres Docker ou servidores SGBD externos durante a execução em laboratório.
> 3. **Autenticação Stateless via HTTP Basic Auth:** Utilizada para demonstrar de forma transparente os cabeçalhos HTTP de **Identificação**, **Autenticação** (com hash irreversível `BCrypt`) e **Autorização** (`401 Unauthorized` vs. `403 Forbidden`), acompanhada de material de referência sobre evolução para **Tokens JWT (JSON Web Token)** nos slides da disciplina.

---

## Tecnologias Utilizadas

* **Java 17** + **Maven**
* **Spring Boot 3.2.5**
  * `spring-boot-starter-web` (Endpoints RESTful e serialização JSON via Jackson)
  * `spring-boot-starter-data-jpa` (Persistência de dados com Hibernate 6 / Spring Data JPA)
  * `spring-boot-starter-security` (Autenticação HTTP Basic, `BCryptPasswordEncoder` e RBAC com `@PreAuthorize`)
* **SQLite JDBC (`org.xerial:sqlite-jdbc`)** + **`hibernate-community-dialects`** (`SQLiteDialect`)
* **Typst (`typslides`)** — Código-fonte dos slides da aula localizado no diretório [`slides/`](./slides)

---

## Arquitetura do Projeto (Padrão MVC)

```text
aula_autenticacao/
├── pom.xml                                  # Dependências Maven e configuração do Spring Boot
├── slides/                                  # Apresentação didática da aula em Typst (typslides)
│   ├── main.typ
│   └── bibliography.bib
└── src/main/
    ├── resources/
    │   └── application.properties           # Configuração JDBC/SQLite e Hibernate DDL
    └── java/com/mycompany/aula_autenticacao/
        ├── Aula_autenticacao.java           # Classe principal (@SpringBootApplication)
        ├── config/
        │   ├── SecurityConfig.java          # SecurityFilterChain Stateless, RBAC e BCrypt
        │   └── CargaDadosConfig.java        # Carga inicial automática no SQLite (@PostConstruct)
        ├── model/
        │   ├── Perfil.java                  # Enum de perfis: RESPONSAVEL e CRIANCA
        │   ├── Usuario.java                 # Entidade JPA de usuário (@Entity)
        │   ├── Filme.java                   # Entidade JPA de filmes do catálogo (@Entity)
        │   └── Fatura.java                  # Entidade JPA de faturas financeiras (@Entity)
        ├── repository/
        │   ├── UsuarioRepository.java       # Interface Spring Data JPA (inclui findByLogin)
        │   ├── FilmeRepository.java         # Interface Spring Data JPA para Filme
        │   └── FaturaRepository.java        # Interface Spring Data JPA para Fatura
        ├── service/
        │   ├── FilmeService.java            # Regra de negócio e transação (@Transactional)
        │   └── FaturaService.java           # Regra de negócio e transação (@Transactional)
        └── controller/
            ├── FilmeController.java         # Endpoint GET /filmes (RESPONSAVEL e CRIANCA)
            └── FaturaController.java        # Endpoint GET /faturas (Exclusivo RESPONSAVEL)
```

---

## Regras de Negócio e Controle de Acesso (RBAC)

Na inicialização da aplicação (`@PostConstruct` em `CargaDadosConfig`), o banco `streaming.db` é populado automaticamente com dois usuários de perfis distintos (ambos com senha criptografada via **BCrypt**):

| Usuário (`login`) | Senha | Perfil (`Role`) | `GET /filmes` | `GET /faturas` |
| :--- | :--- | :--- | :---: | :---: |
| `responsavel` | `123456` | `ROLE_RESPONSAVEL` | `200 OK` (Permitido) | `200 OK` (Permitido) |
| `crianca` | `123456` | `ROLE_CRIANCA` | `200 OK` (Permitido) | `403 Forbidden` (Negado) |
| *Sem credenciais* | — | *Anônimo* | `401 Unauthorized` | `401 Unauthorized` |

---

## Como Executar o Projeto

### 1. Via NetBeans IDE
1. Abra o projeto Maven no **NetBeans**.
2. Pressione **F6 (Run Project)**.
3. O servidor Tomcat embutido iniciará na porta `8080` e o arquivo `streaming.db` será criado automaticamente na raiz do diretório.

### 2. Via Terminal (Maven)
```bash
mvn spring-boot:run
```

---

## Roteiro de Testes (Insomnia ou cURL)

No **Insomnia**, crie uma requisição `GET`, selecione a aba **`Auth` ➔ `Basic Auth`** e teste os 4 cenários abaixo:

1. **Acesso sem autenticação (`No Auth`):**
   ```bash
   curl -i http://localhost:8080/filmes
   # Retorno esperado: HTTP/1.1 401 Unauthorized
   ```
2. **Perfil `CRIANCA` consultando o catálogo de filmes:**
   ```bash
   curl -i -u crianca:123456 http://localhost:8080/filmes
   # Retorno esperado: HTTP/1.1 200 OK (Array JSON de filmes)
   ```
3. **Perfil `CRIANCA` tentando acessar faturas financeiras (Bloqueio RBAC):**
   ```bash
   curl -i -u crianca:123456 http://localhost:8080/faturas
   # Retorno esperado: HTTP/1.1 403 Forbidden
   ```
4. **Perfil `RESPONSAVEL` consultando faturas financeiras:**
   ```bash
   curl -i -u responsavel:123456 http://localhost:8080/faturas
   # Retorno esperado: HTTP/1.1 200 OK (Array JSON de faturas)
   ```
