# Guia de Contribuição - Malpa

Olá, Macaco! Este documento é o nosso guia para manter o projeto organizado e o desenvolvimento fluindo sem problemas. Seguir estas diretrizes nos ajudará a entender o trabalho uns dos outros e a manter um histórico de projeto limpo e legível.

Nossa filosofia é: **"Comunicação clara e commits pequenos e frequentes."**

## Índice
* [Fluxo de Trabalho com Git (GitHub)](#-fluxo-de-trabalho-com-git-git-flow)
* [Padrão de Mensagens de Commit](#-padrão-de-mensagens-de-commit)
* [Processo de Pull Request (PR)](#-processo-de-pull-request-pr)
* [Boas Práticas Gerais](#-boas-práticas-gerais)

---

## Fluxo de Trabalho com Git (GitHub)

Usamos um modelo de branches simples para organizar nosso trabalho. A regra mais importante é: **ninguém envia código diretamente para as branches `main` ou `develop`**. Todo o trabalho é feito em branches separadas.

### Nossas Branches Principais
* **`main`**: Contém apenas as versões estáveis e de entrega do jogo (Alpha, Beta, Final). É a nossa "versão de produção".
* **`develop`**: É a branch principal de desenvolvimento. Ela contém a versão mais atual do projeto, com todas as novas funcionalidades já integradas. Pode estar instável às vezes.

### O Processo Passo a Passo

1.  **Pegue uma Tarefa:** Antes de começar, pegue uma tarefa do nosso quadro no Trello.

2.  **Atualize seu `develop` local:**
    ```bash
    git checkout develop
    git pull origin develop
    ```

3.  **Crie sua Branch de Trabalho:** Crie uma nova branch a partir da `develop`. O nome da branch deve ser descritivo.
    * Para novas funcionalidades: `feature/nome-da-funcionalidade` (ex: `feature/sistema-de-combo-professor-calculo`)
    * Para correção de bugs: `fix/descricao-do-bug` (ex: `fix/bug-pulo-infinito`)
    ```bash
    git checkout -b feature/nome-da-sua-feature
    ```

4.  **Faça seu Trabalho:** Programe a funcionalidade, crie a arte, escreva o roteiro. Faça commits pequenos e focados.

5.  **Envie sua Branch para o GitHub:**
    ```bash
    git push -u origin feature/nome-da-sua-feature
    ```

6.  **Abra um Pull Request (PR):** No GitHub, abra um PR da sua branch (`feature/...`) para a branch `develop`.

7.  **Revisão de Código:** Pelo menos **uma** outra pessoa da equipe deve revisar seu PR. O revisor deve testar a funcionalidade e verificar se o código segue nossos padrões.

8.  **Merge:** Após a aprovação, o PR é "mergeado" na branch `develop`.

9.  **Limpeza:** Após o merge, você pode deletar sua branch de feature.

---

## Padrão de Mensagens de Commit

Para que nosso histórico de commits seja fácil de ler, vamos seguir um padrão simples. Todo commit deve ter um **tipo** e uma **mensagem curta e no imperativo**.

**Formato:** `tipo: Mensagem curta no imperativo`

**Exemplo:** `feat: Adiciona sistema de pulo duplo para o jogador`

### Tipos de Commit

| Tipo | Emoji | Descrição |
|---|---|---|
| `feat` | 🎨 | **Nova funcionalidade** (feature). Qualquer coisa nova que o usuário final verá. |
| `fix` | 🐛 | **Correção de bug**. |
| `docs` | 📝 | **Mudanças na documentação** (README, GDD, comentários no código). |
| `style` | ✨ | **Formatação de código**, sem alteração na lógica (ponto e vírgula, indentação). |
| `refactor` | ♻️ | **Refatoração de código**, sem corrigir bug ou adicionar feature. |
| `assets` | 🖼️ | **Adição ou atualização de arquivos de arte, som, etc.** |
| `build` | 📦 | **Mudanças no processo de build** ou configurações do Godot. |
| `chore` | 🔧 | **Outras tarefas** que não modificam o código-fonte (ex: `.gitignore`). |

### Exemplos Bons vs. Ruins

* ✅ **Bom:** `fix: Impede que o jogador saia da tela na fase 1`
* ✅ **Bom:** `feat: Implementa a barra de especial`
* ✅ **Bom:** `docs: Atualiza o GDD com a lista de golpes do Professor Marudi`
* ❌ **Ruim:** `bug`
* ❌ **Ruim:** `consertei o problema`
* ❌ **Ruim:** `Update`

---

## Processo de Pull Request (PR)

O Pull Request é nossa principal ferramenta de revisão de código. Ele garante a qualidade e o compartilhamento de conhecimento.

### Criando um Bom PR
* **Título Claro:** O título do PR deve resumir a mudança. Pode ser o mesmo da sua principal mensagem de commit (ex: `feat: Adiciona menu principal`).
* **Descrição Detalhada:** Use o template abaixo para descrever seu PR. Explique **o que** você fez, **por que** fez e **como testar**.

### Template para Descrição do PR

```markdown
**O que este PR faz?**
(Descreva em poucas palavras a principal mudança.)

**Por que esta mudança é necessária?**
(Qual problema ela resolve? Qual feature ela adiciona? Se for o caso, link a tarefa do Trello.)

**Como testar?**
(Passos para que o revisor possa testar a mudança. Ex: "1. Abra a cena `MainMenu.tscn`. 2. Clique no botão 'Jogar'. 3. Verifique se a cena `Level01.tscn` é carregada.")

**Screenshots ou GIFs (se aplicável):**
(Cole aqui imagens ou GIFs que mostrem a mudança em ação.)