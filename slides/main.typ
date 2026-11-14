#import "@preview/typslides:1.4.0": *

// Configuração da Apresentação (16:9, tema bluey, fonte legível para projetor)
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  font-size: 19pt,
  link-style: "color",
  show-progress: true,
)

// Ajusta o tamanho da fonte dos blocos de código para nunca estourar a altura do slide
#show raw.where(block: true): set text(size: 13.5pt)

// Funções auxiliares para desenhar diagramas visuais nativos no Typst
#let diag-box(titulo, subtitulo, cor-fundo: rgb("eef5fb"), cor-borda: rgb("2b6cb0")) = box(
  width: 100%,
  inset: (x: 8pt, y: 8pt),
  radius: 6pt,
  fill: cor-fundo,
  stroke: 1.5pt + cor-borda,
)[
  #align(center)[
    #text(weight: "bold", size: 14.5pt, fill: cor-borda)[#titulo] \
    #text(size: 12pt, fill: rgb("333333"))[#subtitulo]
  ]
]

#let seta-dir = align(center + horizon)[#text(size: 20pt, weight: "bold", fill: rgb("2b6cb0"))[➔]]
#let seta-esq-dir = align(center + horizon)[#text(size: 20pt, weight: "bold", fill: rgb("2b6cb0"))[⇄]]
#let seta-baixo = align(center)[#text(size: 18pt, weight: "bold", fill: rgb("2b6cb0"))[⬇]]

// Slide de Capa
#front-slide(
  title: "APIs RESTful Seguras com Spring Boot",
  subtitle: [Arquitetura MVC, Persistência SQLite/JPA, JSON e Controle de Acesso (RBAC)],
  authors: "Prof. Ramon — Programação Back-End",
  info: [Aula de Laboratório • Prática no NetBeans e Insomnia],
)

// Sumário Automático
#table-of-contents()

// =============================================================================
// SEÇÃO 1: CIBERSEGURANÇA, PILARES DA SEGURANÇA E CONTROLE DE ACESSO
// =============================================================================
#title-slide[
  1. Cibersegurança, Pilares da Segurança e Controle de Acesso
]

#slide(title: "Por que Segurança de APIs importa? Casos Reais", outlined: true)[
  Segundo a *OWASP Top 10*, a vulnerabilidade *#stress("A01: Broken Access Control")* (Quebra no Controle de Acesso) é a *falha nº 1 em aplicações Web e APIs*.

  #cols(columns: (1fr, 1fr), gutter: 1.2em)[
    #framed(title: "Caso 1: Capital One e APIs Financeiras")[
      - Usuários comuns autenticados alteram a URI (ex: `/faturas`) e acessam dados financeiros restritos.
      - *Causa:* A API verificava apenas se o usuário estava *logado*, mas não validava seu *perfil de autorização*.
    ]
  ][
    #framed(title: "Caso 2: Vazamento RockYou (Senhas)")[
      - Mais de *32 milhões de senhas* vazaram porque estavam salvas em *texto puro* no banco de dados.
      - *Lição:* Nunca salvar senha sem hash criptográfico (`BCrypt`) e jamais expor a senha no JSON (`@JsonIgnore`).
    ]
  ]
]

#slide(title: "Pilares da Segurança da Informação (ISO 27000)", outlined: true)[
  Todo sistema seguro apoia-se em *4 princípios fundamentais*. Veja o paralelo direto com a API que construiremos no *NetBeans*:

  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    diag-box(
      "1. Confidencialidade (Foco da Aula)",
      [Garantir que dados sensíveis (`/faturas`) sejam vistos apenas por quem tem permissão (`RESPONSAVEL`) e ocultar senhas (`@JsonIgnore` + `BCrypt`).],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
    diag-box(
      "2. Autenticidade (Foco da Aula)",
      [Garantir que o usuário é realmente quem diz ser no momento do logon (validação de `login` e `senha` no `SecurityConfig`).],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
    diag-box(
      "3. Integridade (Paralelo no Banco)",
      [Garantir que os dados não sejam corrompidos ou alterados indevidamente (`@Transactional` no Service e constraints no SQLite).],
      cor-fundo: rgb("eef5fb"),
      cor-borda: rgb("2b6cb0"),
    ),
    diag-box(
      "4. Disponibilidade (Paralelo REST)",
      [Garantir que a API esteja acessível quando solicitada (API *Stateless* leve e controle de conexão do SQLite no `application.properties`).],
      cor-fundo: rgb("eef5fb"),
      cor-borda: rgb("2b6cb0"),
    ),
  )
]

#slide(title: "O Cenário do Nosso Laboratório: Streaming Familiar")[
  Imagine uma plataforma de streaming (como *Netflix*, *Disney+* ou *Prime Video*) compartilhada pela família:

  #framed(title: "O Problema de Negócio e Segurança")[
    A criança da casa possui login para assistir desenhos (`GET /filmes`), mas *não pode ter permissão* para acessar a área financeira e visualizar os dados de cobrança da assinatura (`GET /faturas`).
  ]

  - *Perfis de Usuário (Roles) no nosso código Java:*
    - #stress("RESPONSAVEL"): Acesso completo ao catálogo (`/filmes`) e às faturas (`/faturas`).
    - #stress("CRIANCA"): Acesso liberado ao catálogo (`/filmes`), mas *bloqueado com erro `403 Forbidden`* em `/faturas`.
]

#slide(title: "As 4 Etapas do Controle de Acesso", outlined: true)[
  O processo de controle de acesso é dividido em *4 etapas sequenciais*:

  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
    gutter: 6pt,
    diag-box("1. Identificação", [Quem é você? \ `login: "crianca"`]),
    seta-dir,
    diag-box("2. Autenticação", [Prove! \ `senha: "123456"`]),
    seta-dir,
    diag-box("3. Autorização", [Pode acessar? \ Perfil `CRIANCA`]),
    seta-dir,
    diag-box("4. Auditoria", [Registro de logs \ SQL e HTTP]),
  )

  #v(6pt)
  - *Os 3 Fatores de Autenticação:*
    - *O que o usuário sabe:* Senha ou PIN (usado em nossa API via *HTTP Basic Auth*).
    - *O que o usuário tem:* Token temporário, *smart card* ou celular (MFA).
    - *O que o usuário é:* Biometria (impressão digital, reconhecimento facial, íris).
]

#slide(title: "Autenticação vs. Autorização (Códigos HTTP no Insomnia)")[
  #framed(title: "Regra de Ouro")[
    *Autenticação* responde: _"Quem é você?"_ — e vem *antes* da *Autorização*, que responde: _"O que você tem permissão para fazer?"_
  ]

  #cols(columns: (1fr, 1fr), gutter: 1.5em)[
    #framed(title: "HTTP 401 Unauthorized")[
      - Falha na *Identificação / Autenticação*.
      - Você não enviou credenciais no *Insomnia* ou digitou a senha errada.
      - O sistema *não sabe quem você é*.
    ]
  ][
    #framed(title: "HTTP 403 Forbidden")[
      - Falha na *Autorização (RBAC)*.
      - Você acertou login e senha (está autenticado como `CRIANCA`), mas seu perfil *não tem acesso* a `/faturas`.
    ]
  ]
]

#slide(title: "Políticas de Controle de Acesso: DAC, MAC e RBAC")[
  Na Segurança da Informação, classificamos o controle de acesso quanto à política e ao método:

  - *Discricionário (DAC):* O proprietário do recurso decide quem tem acesso.
  - *Obrigatório / Mandatório (MAC):* O sistema impõe níveis rígidos de sensibilidade e classificação (comum em sistemas militares e governamentais).
  - *#stress("Baseado em Perfis (RBAC - Role-Based Access Control)"):*
    - Os direitos de acesso são atribuídos a *perfis/funções* (`RESPONSAVEL` e `CRIANCA`), e não a indivíduos isolados.
    - É o padrão implementado no nosso projeto com *Spring Security* através das anotações `@PreAuthorize` e `hasRole(...)`.
]

// =============================================================================
// SEÇÃO 2: ARQUITETURA MVC, RESTFUL E JSON
// =============================================================================
#title-slide[
  2. Padrão MVC, WebServices RESTful e JSON
]

#slide(title: "Equivalência do Padrão MVC na Nossa API REST", outlined: true)[
  Veja como as *3 camadas clássicas do MVC* (`View`, `Controller` e `Model`) agrupam os pacotes do nosso projeto no *NetBeans* e a interface no *Insomnia*:

  #grid(
    columns: (1fr, auto, 1fr, auto, 1.5fr),
    gutter: 8pt,
    box(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("fff8e6"), stroke: 2pt + rgb("b7791f"))[
      #align(center)[
        #text(weight: "bold", size: 15pt, fill: rgb("b7791f"))[CAMADA VIEW] \
        #text(size: 11.5pt)[*(Apresentação / Cliente)*]
      ]
      #v(4pt)
      #diag-box("Software Insomnia", [Ou App Mobile / Web \ Envia HTTP e exibe o *JSON*], cor-fundo: white, cor-borda: rgb("b7791f"))
    ],
    seta-esq-dir,
    box(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("eef5fb"), stroke: 2pt + rgb("2b6cb0"))[
      #align(center)[
        #text(weight: "bold", size: 15pt, fill: rgb("2b6cb0"))[CAMADA CONTROLLER] \
        #text(size: 11.5pt)[*(Controle de Fluxo HTTP)*]
      ]
      #v(4pt)
      #diag-box("Pacote controller", [`FilmeController.java` \ `FaturaController.java` \ (`@RestController`)], cor-fundo: white, cor-borda: rgb("2b6cb0"))
    ],
    seta-esq-dir,
    box(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("e6f4ea"), stroke: 2pt + rgb("1e7e34"))[
      #align(center)[
        #text(weight: "bold", size: 15pt, fill: rgb("1e7e34"))[CAMADA MODEL (Agrupada no Servidor)] \
        #text(size: 11.5pt)[*(Regras de Negócio + Estado + Persistência)*]
      ]
      #v(4pt)
      #grid(
        columns: (1fr, 1fr, 1fr),
        gutter: 5pt,
        diag-box("service", [`FilmeService` \ `FaturaService`], cor-fundo: white, cor-borda: rgb("1e7e34")),
        diag-box("model", [`Usuario`, `Filme` \ `Fatura` (`@Entity`)], cor-fundo: white, cor-borda: rgb("1e7e34")),
        diag-box("repository", [`JpaRepository` \ + *SQLite*], cor-fundo: white, cor-borda: rgb("1e7e34")),
      )
    ],
  )
]

#slide(title: "Princípios de WebServices RESTful e JSON", outlined: true)[
  *REST (Representational State Transfer)* utiliza nativamente o protocolo HTTP para comunicação entre sistemas distribuídos:

  #cols(columns: (1fr, 1fr), gutter: 1.2em)[
    - *Recursos identificados por URIs:*
      - `http://localhost:8080/filmes`
      - `http://localhost:8080/faturas`
    - *Stateless (Sem Estado de Sessão):*
      - O servidor não guarda sessão do cliente entre requisições; toda chamada no *Insomnia* envia o cabeçalho `Authorization`.
    - *Verbo HTTP `GET`:* Consulta segura de recursos.
  ][
    ```json
    [
      {
        "id": 1,
        "titulo": "Toy Story",
        "genero": "Animação",
        "classificacaoIndicativa": "Livre"
      }
    ]
    ```
    *Serialização JSON:* O Spring converte automaticamente a `List<Filme>` do Java em um vetor `[...]` de objetos `{ "chave": "valor" }`.
  ]
]

// =============================================================================
// SEÇÃO 3: PERSISTÊNCIA DE DADOS E CAMADA MODEL/REPOSITORY
// =============================================================================
#title-slide[
  3. Persistência com SQLite, JPA/Hibernate e Código no NetBeans
]

#slide(title: "Diagrama da Camada de Persistência em Java", outlined: true)[
  Como o código Java aberto no *NetBeans* grava e consulta dados sem precisarmos instalar um SGBD pesado?

  #grid(
    columns: (1fr, auto, 1fr, auto, 1fr, auto, 1fr),
    gutter: 6pt,
    diag-box("1. Entidade Java", [Classe `@Entity` \ `Usuario`, `Filme`, `Fatura`]),
    seta-dir,
    diag-box("2. Spring Data JPA", [Interface `@Repository` \ `findAll()`, `findByLogin()`]),
    seta-dir,
    diag-box("3. ORM Hibernate", [Traduz Objetos Java \ para comandos SQL]),
    seta-dir,
    diag-box("4. JDBC + SQLite", [Arquivo local \ `streaming.db`], cor-fundo: rgb("e6f4ea"), cor-borda: rgb("1e7e34")),
  )

  #v(8pt)
  - *Vantagens do SGBD + ORM:* Independência de dados, integridade transacional e criação automática das tabelas a partir das classes Java (`ddl-auto=update`).
]

#slide(title: "Configurando o SQLite: application.properties")[
  No arquivo `src/main/resources/application.properties` do projeto no *NetBeans*:

  ```properties
  # Cria o arquivo "streaming.db" automaticamente na raiz do projeto
  spring.datasource.url=jdbc:sqlite:streaming.db
  spring.datasource.driver-class-name=org.sqlite.JDBC

  # SQLite usa trava em arquivo único: 1 conexão evita erro SQLITE_BUSY (Disponibilidade)
  spring.datasource.hikari.maximum-pool-size=1

  # Dialeto que ensina o Hibernate a falar o SQL específico do SQLite
  spring.jpa.database-platform=org.hibernate.community.dialect.SQLiteDialect

  # Cria/atualiza as tabelas automaticamente a partir das classes @Entity
  spring.jpa.hibernate.ddl-auto=update
  spring.jpa.show-sql=true
  ```
]

#slide(title: "Camada Model: Perfil.java e Usuario.java", outlined: true)[
  No pacote `model`, mapeamos os usuários e seus perfis de segurança:

  ```java
  public enum Perfil {
      RESPONSAVEL, // Pode acessar /filmes e /faturas
      CRIANCA      // Pode acessar apenas /filmes
  }

  @Entity // Mapeia a classe para uma tabela no SQLite via Hibernate
  @Table(name = "usuarios")
  public class Usuario {
      @Id
      @GeneratedValue(strategy = GenerationType.IDENTITY)
      private Long id;

      @Column(unique = true, nullable = false)
      private String login; // Etapa 1: Identificação única

      @JsonIgnore // Confidencialidade: NUNCA envia a senha no JSON!
      @Column(nullable = false)
      private String senha; // Etapa 2: Autenticação (Hash BCrypt)

      @Enumerated(EnumType.STRING)
      private Perfil perfil; // Etapa 3: Autorização (RBAC)
  }
  ```
]

#slide(title: "Camada Model: Filme.java e Fatura.java")[
  Retornamos as próprias entidades para manter o projeto enxuto e didático. O serializador Jackson lê os métodos `getters` para montar o JSON:

  #cols(columns: (1fr, 1fr), gutter: 1em)[
    ```java
    @Entity
    @Table(name = "filmes")
    public class Filme {
        @Id
        @GeneratedValue(strategy =
            GenerationType.IDENTITY)
        private Long id;

        private String titulo;
        private String genero;
        private String classificacaoIndicativa;
        // Construtor + Getters/Setters
    }
    ```
  ][
    ```java
    @Entity
    @Table(name = "faturas")
    public class Fatura {
        @Id
        @GeneratedValue(strategy =
            GenerationType.IDENTITY)
        private Long id;

        private String mesReferencia;
        private Double valor;
        private String statusPagamento;
        // Construtor + Getters/Setters
    }
    ```
  ]
]

#slide(title: "Camadas Repository e Service (Fluxo de Dados)", outlined: true)[
  #cols(columns: (1fr, 1fr), gutter: 1em)[
    *Pacote `repository` (Acesso a Dados):*
    ```java
    @Repository
    public interface UsuarioRepository
        extends JpaRepository<Usuario, Long> {
        // Gera: SELECT * FROM usuarios
        //       WHERE login = ?
        Optional<Usuario> findByLogin(
            String login);
    }

    @Repository
    public interface FilmeRepository
        extends JpaRepository<Filme, Long> {
    }
    ```
  ][
    *Pacote `service` (Regra de Negócio):*
    ```java
    @Service
    public class FaturaService {
        private final FaturaRepository repo;

        public FaturaService(
            FaturaRepository repo) {
            this.repo = repo;
        }

        @Transactional(readOnly = true)
        public List<Fatura> listarTodas() {
            return repo.findAll();
        }
    }
    ```
  ]
]

// =============================================================================
// SEÇÃO 4: CONTROLLERS, SPRING SECURITY E PRÁTICA NO INSOMNIA
// =============================================================================
#title-slide[
  4. Controllers, Spring Security e Prática no Insomnia
]

#slide(title: "Camada Controller: Controle de Acesso com @PreAuthorize", outlined: true)[
  Compare lado a lado os dois endpoints RESTful no pacote `controller`:

  #cols(columns: (1fr, 1fr), gutter: 1em)[
    *`FilmeController.java` (Liberado a ambos):*
    ```java
    @RestController
    @RequestMapping("/filmes")
    public class FilmeController {
        private final FilmeService service;

        @GetMapping
        @PreAuthorize(
          "hasAnyRole('RESPONSAVEL','CRIANCA')"
        )
        public List<Filme> listarFilmes() {
            return service.listarTodos();
        }
    }
    ```
  ][
    *`FaturaController.java` (Restrito):*
    ```java
    @RestController
    @RequestMapping("/faturas")
    public class FaturaController {
        private final FaturaService service;

        @GetMapping
        @PreAuthorize(
          "hasRole('RESPONSAVEL')"
        )
        public List<Fatura> listarFaturas() {
            return service.listarTodas();
        }
    }
    ```
  ]
]

#slide(title: "Diagrama Geral: Como o SecurityConfig.java Funciona", outlined: true)[
  Veja o caminho exato que a requisição faz desde o *Insomnia* até o *NetBeans* e o banco *SQLite*:

  #grid(
    columns: (1fr, auto, 1.1fr, auto, 1.1fr, auto, 1fr),
    gutter: 6pt,
    diag-box(
      "1. Insomnia",
      [Aba *Basic Auth* \ Envia `login` e `senha` no Header HTTP],
      cor-fundo: rgb("fff8e6"),
      cor-borda: rgb("b7791f"),
    ),
    seta-dir,
    diag-box(
      "2. SecurityFilterChain",
      [*NetBeans (`SecurityConfig`)* \ Intercepta a requisição Stateless],
    ),
    seta-dir,
    diag-box(
      "3. UserDetailsService",
      [Busca `findByLogin` no *SQLite* e valida hash `BCrypt`],
    ),
    seta-dir,
    diag-box(
      "4. Autorização RBAC",
      [Checa `hasRole`: \ `200 OK` (Controller) \ ou `403 Forbidden`],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
  )

  #v(6pt)
  - *Arquivo no NetBeans:* `config/SecurityConfig.java` (contém as funções `@Bean securityFilterChain()`, `@Bean userDetailsService()` e `@Bean passwordEncoder()`).
]

#slide(title: "Tomada de Decisão: securityFilterChain() em SecurityConfig.java")[
  Na função `securityFilterChain(HttpSecurity http)` do arquivo `SecurityConfig.java`, o Spring Security executa esta *árvore de decisão* a cada chamada do *Insomnia*:

  #diag-box(
    "Requisição HTTP chega do Insomnia (Stateless / CSRF Desabilitado)",
    [Verifica cabeçalho `Authorization: Basic ...` via método `.httpBasic()`],
  )
  #seta-baixo
  #grid(
    columns: (1fr, 1.3fr, 1.3fr),
    gutter: 8pt,
    diag-box(
      "1. Sem Login ou Senha Inválida?",
      [*Decisão:* Falha na Autenticação \ *Retorno:* `HTTP 401 Unauthorized`],
      cor-fundo: rgb("fde8e8"),
      cor-borda: rgb("c53030"),
    ),
    diag-box(
      "2. Rota GET /filmes",
      [*Regra:* `.hasAnyRole("RESPONSAVEL", "CRIANCA")` \ *Adulto (`RESPONSAVEL`):* `200 OK` \ *Criança (`CRIANCA`):* `200 OK`],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
    diag-box(
      "3. Rota GET /faturas",
      [*Regra:* `.hasRole("RESPONSAVEL")` \ *Adulto (`RESPONSAVEL`):* `200 OK` \ *Criança (`CRIANCA`):* `403 Forbidden`],
      cor-fundo: rgb("fff8e6"),
      cor-borda: rgb("b7791f"),
    ),
  )
]

#slide(title: "Fluxo de Autenticação: userDetailsService() e passwordEncoder()")[
  Ainda no arquivo `SecurityConfig.java`, veja como as funções `userDetailsService()` e `passwordEncoder()` validam a identidade no banco *SQLite*:

  #grid(
    columns: (1fr, auto, 1.1fr, auto, 1.1fr, auto, 1.1fr),
    gutter: 6pt,
    diag-box(
      "1. Login Recebido",
      [`userDetailsService` recebe o `login` enviado pelo *Insomnia*],
    ),
    seta-dir,
    diag-box(
      "2. Busca no SQLite",
      [Chama `usuarioRepository` \ `.findByLogin(login)` na tabela `usuarios`],
    ),
    seta-dir,
    diag-box(
      "3. Valida BCrypt",
      [`passwordEncoder()` compara a senha digitada com o Hash do banco],
      cor-fundo: rgb("fff8e6"),
      cor-borda: rgb("b7791f"),
    ),
    seta-dir,
    diag-box(
      "4. Monta Perfil",
      [`User.builder().roles(...)` \ Define `ROLE_RESPONSAVEL` ou `ROLE_CRIANCA`],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
  )

  #v(8pt)
  #framed[
    *Por que `BCryptPasswordEncoder`?* Mesmo que um invasor copie o arquivo `streaming.db`, ele verá apenas hashes irreversíveis (ex: `$2a$10$X9v...`), nunca a senha `"123456"`!
  ]
]

#slide(title: "Objetos Criados no Banco: CargaDadosConfig.java (@PostConstruct)")[
  No arquivo `CargaDadosConfig.java`, a função `carregarDadosIniciais()` anotada com `@PostConstruct` instancia e salva no *SQLite* os dois perfis da nossa família:

  #grid(
    columns: (1fr, 1fr),
    gutter: 12pt,
    box(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("e6f4ea"), stroke: 2pt + rgb("1e7e34"))[
      #align(center)[
        #text(weight: "bold", size: 15pt, fill: rgb("1e7e34"))[Objeto `Usuario` — ADULTO (Pai)]
      ]
      #v(4pt)
      - *`login`:* `"responsavel"`
      - *`senha`:* `passwordEncoder.encode("123456")`
      - *`perfil`:* `Perfil.RESPONSAVEL`
      - *Permissões na API:*
        - `GET /filmes` ➔ *Liberado (`200 OK`)*
        - `GET /faturas` ➔ *Liberado (`200 OK`)*
    ],
    box(width: 100%, inset: 10pt, radius: 6pt, fill: rgb("fff8e6"), stroke: 2pt + rgb("b7791f"))[
      #align(center)[
        #text(weight: "bold", size: 15pt, fill: rgb("b7791f"))[Objeto `Usuario` — CRIANÇA (Filho)]
      ]
      #v(4pt)
      - *`login`:* `"crianca"`
      - *`senha`:* `passwordEncoder.encode("123456")`
      - *`perfil`:* `Perfil.CRIANCA`
      - *Permissões na API:*
        - `GET /filmes` ➔ *Liberado (`200 OK`)*
        - `GET /faturas` ➔ *Bloqueado (`403 Forbidden`)*
    ],
  )
]

#focus-slide[
  Demonstração Prática \
  NetBeans + Insomnia
]

#slide(title: "Roteiro de Testes Práticos no Insomnia", outlined: true)[
  Com a aplicação rodando no *NetBeans (F6)* na porta `8080`, executaremos *4 testes no software Insomnia* (aba *Auth -> Basic Auth*):

  #grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    diag-box(
      "Teste 1: Sem Credenciais (No Auth)",
      [`GET http://localhost:8080/filmes` \ Resultado: *401 Unauthorized* (Não Autenticado)],
      cor-fundo: rgb("fde8e8"),
      cor-borda: rgb("c53030"),
    ),
    diag-box(
      "Teste 2: Criança acessa Filmes",
      [`GET http://localhost:8080/filmes` (`crianca` / `123456`) \ Resultado: *200 OK* + Lista JSON de Filmes],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
    diag-box(
      "Teste 3: Criança tenta acessar Faturas",
      [`GET http://localhost:8080/faturas` (`crianca` / `123456`) \ Resultado: *403 Forbidden* (Barrado no RBAC!)],
      cor-fundo: rgb("fde8e8"),
      cor-borda: rgb("c53030"),
    ),
    diag-box(
      "Teste 4: Responsável acessa Faturas",
      [`GET http://localhost:8080/faturas` (`responsavel` / `123456`) \ Resultado: *200 OK* + Lista JSON de Faturas],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
  )
]

// =============================================================================
// SEÇÃO 5: EVOLUÇÃO PARA O MERCADO — TOKENS DE ACESSO (JWT)
// =============================================================================
#title-slide[
  5. Referência de Mercado: Tokens de Acesso (JWT)
]

#slide(title: "Alternativa ao Basic Auth: Tokens de Acesso (JWT)", outlined: true)[
  No laboratório usamos *HTTP Basic Auth* (fator _"o que o usuário sabe"_ enviado a cada requisição). Em grandes sistemas em produção, evolui-se para *Tokens Temporários* (*JWT — JSON Web Token*):

  #grid(
    columns: (1fr, auto, 1.1fr, auto, 1.1fr),
    gutter: 6pt,
    diag-box(
      "1. Login Único",
      [Cliente envia `login` e `senha` apenas 1 vez em `POST /login`],
    ),
    seta-dir,
    diag-box(
      "2. Geração do Token JWT",
      [Servidor valida no SQLite e devolve um *Token assinado* com validade (ex: 1h)],
      cor-fundo: rgb("fff8e6"),
      cor-borda: rgb("b7791f"),
    ),
    seta-dir,
    diag-box(
      "3. Acesso com Bearer Token",
      [No *Insomnia*, o cliente envia apenas o Token no Header (sem trafegar a senha!)],
      cor-fundo: rgb("e6f4ea"),
      cor-borda: rgb("1e7e34"),
    ),
  )

  #v(6pt)
  - *Estrutura de um Token JWT (3 partes em Base64 separadas por ponto):*
    - #text(fill: rgb("c53030"), weight: "bold")[`Header (Algoritmo)`] `.` #text(fill: rgb("6b46c1"), weight: "bold")[`Payload (JSON com Perfil Embutido)`] `.` #text(fill: rgb("2b6cb0"), weight: "bold")[`Signature (Assinatura Criptográfica)`]
]

#slide(title: "Como o Token JWT Carrega o Perfil em JSON na Requisição")[
  Veja como o *Token* viaja na requisição HTTP e como ele traz um *objeto JSON embutido* com o perfil do usuário (`RESPONSAVEL` ou `CRIANCA`):

  #cols(columns: (1fr, 1fr), gutter: 1em)[
    *1. Como vai no Header da Requisição (Insomnia):*
    ```http
    GET /faturas HTTP/1.1
    Host: localhost:8080
    Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.
      eyJzdWIiOiJyZXNwb25zYXZlbCIsInBlcmZpbCI6I
      lJFU1BPTlNBVkVMIiwiZXhwIjoxNzYzMTI0MDAwfQ.
      8K9v_AssinaturaSecretaDoServidor
    ```

    #diag-box(
      "Vantagem Stateless do JWT",
      [A API confere a assinatura criptográfica do Token e lê o perfil direto do JSON embutido, sem precisar consultar o banco SQLite a cada clique!],
    )
  ][
    *2. O JSON Embutido no Token (Payload Decodificado):*
    ```json
    {
      "sub": "responsavel",
      "nome": "Adulto da Família",
      "perfil": "RESPONSAVEL",
      "iat": 1763120400,
      "exp": 1763124000
    }
    ```
    - `"sub"`: Identificação do usuário (`login`).
    - `"perfil"`: Papel usado na Autorização RBAC (`RESPONSAVEL` ou `CRIANCA`).
    - `"exp"`: Expiração automática do token.
  ]
]

// Slide de Referências Bibliográficas (exibe todas as obras do arquivo .bib no final, sem citações no texto)
#let bib = bibliography("bibliography.bib", full: true)
#bibliography-slide(bib)
