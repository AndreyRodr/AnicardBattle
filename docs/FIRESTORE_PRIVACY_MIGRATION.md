# Migração de privacidade do Firestore — AniCard Battle

Esta mudança separa os documentos privados `users/{uid}` dos dados de classificação e adversários em `publicProfiles/{uid}`.

## Modelo de dados

| Coleção | Conteúdo | Permissão de leitura |
| --- | --- | --- |
| `users/{uid}` | Moedas, inventário, missões, pacotes, dados da conta | Somente o proprietário |
| `publicProfiles/{uid}` | Nome público, troféus, avatar, deck equipado, cosméticos equipados | Usuários autenticados |

O app não grava o campo `email` em nenhuma coleção; o endereço é consultado diretamente pelo Firebase Authentication na tela de perfil. **Perfis públicos não devem conter e-mail nem qualquer dado privado.**

**Limite conhecido do projeto demonstrativo:** o próprio jogador ainda pode modificar moedas e troféus via cliente. As regras impedem modificar contas alheias e ler seus documentos privados, mas não fornecem anticheat ou validação de recompensa no servidor.

## Ordem obrigatória — não publicar regras restritivas antes da migração

1. Verifique se o cadastro atual não grava e-mail em `users` e remova quaisquer e-mails antigos, inclusive da coleção que será usada como pública.
2. Faça backup dos dados importantes antes da migração. Use uma conta com permissões administrativas no Firebase.
3. Instale as dependências de manutenção localmente: `npm --prefix scripts install`. O `node_modules/` está ignorado pelo Git.
4. Configure **Application Default Credentials** para o projeto correto, mantendo qualquer JSON de credenciais **fora do repositório**. Exemplo no PowerShell (somente na sua máquina): `$env:GOOGLE_APPLICATION_CREDENTIALS="C:\\caminho-fora-do-git\\credenciais-firebase.json"`. Nunca envie esse JSON ao ChatGPT ou faça commit.
5. Confira o ID do projeto antes de executar: por padrão é `anicard-battle`. Opcionalmente defina `GOOGLE_CLOUD_PROJECT`.
6. Rode `node scripts/migrate_public_profiles.mjs` (simulação sem gravações).
7. Rode `node scripts/migrate_public_profiles.mjs --apply` e confira a coleção `publicProfiles` no Console: a quantidade de perfis deve corresponder à quantidade de documentos `users`, sem campos privados. O script pode ser reexecutado antes do corte; evite executá-lo depois do app estar em uso, pois pode sobrescrever dados públicos mais recentes com dados antigos.
8. Integre a branch que contém a leitura do ranking/batalhas por `publicProfiles`. **Antes do primeiro acesso do app atualizado**, publique as regras contidas em `firestore.rules` pelo Console ou `firebase deploy --only firestore:rules --project anicard-battle`. Combine os passos para minimizar indisponibilidade dos clientes antigos, que ainda tentam ler todos os documentos `users`.
9. Faça testes com pelo menos duas contas diferentes: cadastro; login existente; ranking; abertura do perfil; troca de avatar/nome; equipar e desequipar cartas; selecionar adversário; batalhar, ganhar/perder troféus; cosméticos; logout/login. Confira que `users/{uid}` não é legível pela outra conta e `publicProfiles/{uid}` só apresenta os campos permitidos.
10. Depois de validar também no Flutter Web, configure e publique o Firebase Hosting.

### Atenção

- **Não basta commitar `firestore.rules`**: a mudança só vale no Firebase após publicá-las e confirmar a versão ativa no Console.
- A função `ensureForCurrentUser` cria o perfil público para contas antigas **apenas quando o proprietário entrar novamente**. O script administrativo migra as contas que ainda não voltaram a entrar.
- Nenhum arquivo de chave privada, `.env`, credencial de serviço ou token administrativo deve ir para o Git.
- As configurações normais do Firebase no cliente Flutter (API key / App ID / Project ID) não são segredos administrativos; o acesso aos dados é garantido pelas Security Rules.
