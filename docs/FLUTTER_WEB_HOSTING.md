# AniCard Battle — Flutter Web no Firebase Hosting

## Antes de publicar

- Confirme no Firebase Console → Firestore Database → Rules que as regras ativas correspondem a `firestore.rules` deste repositório. Um commit NÃO as publica.
- Confira `users/{uid}` privado para outros jogadores e `publicProfiles/{uid}` contendo só nome/avatar/troféus/deck/cosméticos; teste com **duas contas**.
- Não é preciso executar migração administrativa se você aceitar que jogadores antigos só aparecerão no ranking após fazer login novamente.
- O app é uma demonstração: as recompensas/moedas do próprio jogador ainda são manipuláveis pelo cliente (sem anticheat no servidor).

## Configurar Firebase Web

1. No Firebase Console → Configurações do projeto → Seus apps → app Web, copie os valores do **SDK cliente** (`apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`, `storageBucket` e, se houver, `measurementId`).
2. Na raiz do repositório copie `web-firebase-config.example.json` para `web-firebase-config.json`:
   `Copy-Item web-firebase-config.example.json web-firebase-config.json`
3. Preencha o arquivo local com os valores correspondentes. Ele está no `.gitignore`. **Nunca coloque service account, chave privada, API de servidor ou token privilegiado aqui.** As configurações do cliente Firebase são identificadores públicos que o browser verá após o build.
4. Se `measurementId` não existir, deixe `FIREBASE_WEB_MEASUREMENT_ID` como string vazia.
5. Mantenha o `.env` nativo como antes. No navegador, o app usa somente os `--dart-define` informados na compilação e não tenta buscar `.env`.

## Testar com Chrome

```powershell
git pull origin main
flutter pub get
flutter devices
flutter run -d chrome --dart-define-from-file=web-firebase-config.json
```

Teste cadastro, login, ranking, batalha, deck e cosméticos. Acesso com diferentes contas deve estar conforme as regras; se houver `permission-denied`, verifique as regras ATIVAS e os documentos correspondentes.

## Gerar o site

```powershell
flutter build web --release --dart-define-from-file=web-firebase-config.json
```

O Flutter gera os arquivos estáticos em `build/web`. `firebase.json` já aponta o Hosting para essa pasta e possui fallback para `/index.html`.

**Atenção aos assets:** `pubspec.yaml` ainda lista o arquivo nativo `.env` como asset. Ele deve conter apenas configuração pública do SDK Firebase, nunca chaves administrativas; confira se nenhum valor sigiloso foi colocado nele antes de gerar o build. O Hosting ignora arquivos ocultos no deploy. A configuração Web efetivamente usada no JavaScript é a que foi fornecida via `--dart-define-from-file`.

## Publicar Hosting

Instale a CLI do Firebase (requer Node.js):

```powershell
npm install -g firebase-tools
firebase login
firebase projects:list
firebase deploy --only hosting --project anicard-battle
```

Não é necessário executar `firebase init` de novo: a configuração de Hosting já está em `firebase.json`. `--only hosting` não publica regras do Firestore.

Depois de publicar, confira no Firebase Console → Authentication → Settings → Authorized domains. Se o domínio publicado não estiver listado, adicione **apenas o hostname** do site (por exemplo, `anicard-battle.web.app`; não inclua `https://`). Teste cadastro/login e todas as funcionalidades pela URL publicada. O domínio personalizado exigirá autorização separada.

### Se aparecer erro

- `Flutter not found`: configure o Flutter no PATH e rode `flutter doctor`.
- `firebase: command not found`: confirme instalação global e PATH do npm.
- `FirebaseOptions ... missing`: valores ausentes/inválidos no JSON de configuração.
- `permission-denied`: confirme as regras realmente publicadas e o perfil público do usuário.
- Falha no login em produção: valide `Authorized domains` no Firebase Authentication.
- Build falha por ausência do `.env`: a configuração nativa do projeto ainda o declara como asset em `pubspec.yaml`; mantenha o arquivo local (somente identificadores públicos) durante o build.

Nunca envie seu JSON de conta de serviço nem segredos de backend para o repositório.
