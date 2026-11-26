# 🍝 LondonFood

Aplicativo mobile de receitas desenvolvido em **Flutter** como projeto final da disciplina **Introdução ao Desenvolvimento Mobile com Flutter** (UniFil).

O app permite **descobrir receitas, pesquisar pelo nome, ler ingredientes e modo de preparo e salvar favoritos**. Os dados vêm da API pública [DummyJSON Recipes](https://dummyjson.com/docs/recipes).

> O projeto foi baseado no guia visual "Saborê" fornecido pelo professor, com identidade visual própria (nome, cores e layout).
> O nome técnico do projeto Flutter é `saia_da_5a_serie`, conforme pedido na Atividade 01.

---

## 📱 Funcionalidades

| Requisito | Descrição | Como foi implementado |
|---|---|---|
| **RF01 – Tela principal** | Identidade do app e acesso à listagem e à pesquisa | Aba **Explorar** com logo, banner, campo de busca e lista. As receitas começam a carregar ao abrir o app |
| **RF02 – Listagem** | Receitas da API com nome e imagem | Cartões com foto, nome, tempo, dificuldade e nota. Se a imagem faltar ou falhar, aparece um ícone no lugar. A lista permite rolagem |
| **RF03 – Pesquisa** | Pesquisa remota pelo nome | Usa o endpoint de busca da API. Remove espaços do início e do fim (`trim`), recusa consulta vazia com mensagem explicativa e tem o botão **Limpar pesquisa** |
| **RF04 – Detalhes** | Ingredientes, instruções e dados úteis | Tela com foto, culinária, dificuldade, nota, tempo total, porções, ingredientes e passos numerados, com rolagem para conteúdo longo |
| **RF05 – Favoritos** | Adicionar e remover durante a sessão, sem duplicatas | Botão de coração nos cartões e nos detalhes. Aba **Favoritos** com a lista salva. Duplicatas são evitadas comparando o `id` |
| **RF06 – Carregamento** | Feedback durante a busca | Indicador "Carregando receitas…". O botão de pesquisar fica desativado enquanto busca |
| **RF07 – Erros** | Falha de rede, status de erro e corpo incompatível | Cada caso gera uma mensagem compreensível com o botão **Tentar novamente** |
| **RF08 – Ausência de resultados** | Diferenciar cada situação | Telas distintas para **nenhum resultado**, **erro de rede** e **favoritos vazios** |
| **RF09 – Navegação** | Abrir detalhes e voltar mantendo o contexto | Navegação em pilha (`Navigator.push`/`pop`). Ao voltar dos detalhes, a pesquisa continua na tela |

---

## 🗺️ Telas e navegação

```
          ┌──────────── barra inferior ────────────┐
          │                                        │
     [ Explorar ] ◄────────────────────────► [ Favoritos ]
       │      │                                    │
       │      └──► Pesquisar ──► Detalhes          └──► Detalhes
       └──► Detalhes
```

- **Explorar:** tela principal com pesquisa, banner e lista de receitas
- **Pesquisar:** campo de busca, resultados, "nenhum resultado" e erros
- **Detalhes:** informações completas da receita e botão de favorito
- **Favoritos:** receitas salvas na sessão, ou mensagem de lista vazia

---

## 🌐 Uso da API

Endpoints utilizados (`https://dummyjson.com`):

| Endpoint | Uso |
|---|---|
| `GET /recipes?limit=50` | Listagem da tela principal |
| `GET /recipes/search?q={nome}` | Pesquisa por nome |
| `GET /recipes/{id}` | Disponível no serviço para buscar uma receita específica |

Campos utilizados: `id`, `name`, `ingredients`, `instructions`, `image`, `prepTimeMinutes`, `cookTimeMinutes`, `servings`, `rating`, `difficulty`, `cuisine` e `mealType`.

Os dados da API são exibidos em inglês, como permitido no enunciado. Apenas a dificuldade é traduzida (Easy → Fácil, Medium → Média, Hard → Difícil).

---

## 🧠 Decisões técnicas

- **Validação dos dados (`receita.dart`):** cada campo do JSON tem o tipo conferido antes do uso. Nome ausente vira "Receita sem nome"; listas ausentes viram listas vazias; `rating` é lido como `num` (aceita inteiro ou decimal); `mealType` é tratado como lista; porções só aparecem se forem maiores que zero. Receitas sem `id` válido são descartadas sem derrubar a lista inteira.
- **Tempo total:** só é calculado quando `prepTimeMinutes` **e** `cookTimeMinutes` existem. Se algum faltar, a tela mostra "Tempo não informado", em vez de substituir a ausência por zero.
- **Tratamento de erros (`receita_service.dart`):** as requisições são assíncronas, com limite de 10 segundos. São tratados separadamente: falha de rede/tempo esgotado, status HTTP diferente de 200 e corpo em formato inesperado. Todos geram uma mensagem amigável (`ErroApi`).
- **Tela de detalhes:** reaproveita o objeto completo recebido na listagem/pesquisa, pois a resposta da API já contém ingredientes e instruções. Isso evita uma nova requisição. O método `buscarPorId` foi mantido no serviço caso seja necessário no futuro.
- **Carregamento único:** a lista é buscada no `initState`, ou seja, uma única vez ao abrir a tela, e não a cada reconstrução.
- **Consultas concorrentes:** o botão de pesquisa fica desativado durante a busca, e cada pesquisa recebe um número. Se uma resposta antiga chegar depois de uma mais nova, ela é ignorada.
- **Favoritos:** mantidos em memória durante a sessão, em uma única instância de `ChangeNotifier` compartilhada por todas as telas (fonte única de verdade). Qualquer alteração atualiza automaticamente os corações e a aba Favoritos.
- **Abas preservadas:** a barra inferior usa `IndexedStack`, que mantém as abas Explorar e Favoritos ativas ao alternar entre elas.

---

## 📁 Estrutura do projeto

```
lib/
├── main.dart              # Ponto de entrada e tema do app
├── tela_principal.dart    # Moldura com a barra inferior (Explorar / Favoritos)
├── home_page.dart         # Aba Explorar (tela principal)
├── pesquisa_page.dart     # Tela de pesquisa
├── detalhes_page.dart     # Tela de detalhes da receita
├── favoritos_page.dart    # Aba Favoritos
├── receita.dart           # Modelo da receita e validação do JSON
├── receita_service.dart   # Comunicação com a API e tratamento de erros
├── favoritos.dart         # Estado dos favoritos (ChangeNotifier)
├── widgets.dart           # Componentes visuais reutilizáveis
└── cores.dart             # Paleta de cores do app
```

---

## 🛠️ Tecnologias e dependências

| Item | Versão |
|---|---|
| Flutter SDK | 3.47.7 (canal stable) |
| Dart | 3.13.5 |
| [`http`](https://pub.dev/packages/http) | ^1.6.0 (requisições à API) |
| `cupertino_icons` | ^1.0.9 |

**Ambiente de desenvolvimento:** Android Studio, testado no **Chrome (web)** e no **emulador Android Pixel 8 (Android 17, API 37)**.

---

## ▶️ Como executar

**Pré-requisitos:** Flutter instalado (`flutter doctor` sem erros para a plataforma escolhida) e conexão com a internet.

1. Clone o repositório:
   ```bash
   git clone https://github.com/FernandoJR07/saia_da_5a_serie.git
   cd saia_da_5a_serie
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Execute o app:
   ```bash
   # No navegador
   flutter run -d chrome

   # Em um emulador ou celular Android conectado
   flutter run
   ```

4. (Opcional) Gere o instalador Android:
   ```bash
   flutter build apk --release
   ```
   O arquivo fica em `build/app/outputs/flutter-apk/app-release.apk`.

> **Dica:** as receitas da API estão em inglês, então pesquise em inglês (ex.: `pizza`, `chicken`, `cake`, `pasta`).

---

## 👤 Autor

**Fernando Junior** – [@FernandoJR07](https://github.com/FernandoJR07)

Engenharia de Software – UniFil