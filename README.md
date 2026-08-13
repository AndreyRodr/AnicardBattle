<div align="center">
  <img src="assets/images/AniCard%20Icon.png" alt="Logo do AniCard Battle" width="160">

# AniCard Battle

**Um jogo de cartas colecionáveis sobre animais, desenvolvido em Flutter.**

Monte seu deck, abra pacotes de diferentes biomas e dispute batalhas para avançar no ranking.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
</div>

## Sobre o projeto

O **AniCard Battle** é um card game multiplataforma no qual cada carta representa um animal com atributos e habilidades próprios. O jogador coleciona cartas, escolhe até nove animais para compor seu deck e participa de batalhas com progressão baseada em moedas e troféus.

Os dados da conta e do progresso são sincronizados com o Firebase. O projeto também possui trilha sonora, efeitos, tutorial, missões e recompensas diárias.

## Funcionalidades

- Cadastro, login e recuperação de conta com Firebase Authentication
- Coleção de cartas organizada por animais e biomas
- Montagem de deck com até nove cartas
- Batalhas com cartas, arenas e efeitos sonoros
- Sistema de moedas e troféus
- Ranking de jogadores
- Loja de pacotes
- Pacotes da Floresta Amazônica, Savana Africana e Tundra Polar
- Abertura animada de pacotes com três cartas
- Conversão de cartas repetidas em moedas
- Missões diárias e semanais
- Recompensa diária
- Perfil do jogador
- Tutorial inicial
- Controle de música, efeitos e volume

## Tecnologias

| Tecnologia | Uso |
| --- | --- |
| Flutter e Dart | Interface e lógica multiplataforma |
| Firebase Authentication | Autenticação de usuários |
| Cloud Firestore | Persistência e sincronização do progresso |
| flutter_dotenv | Carregamento de variáveis de ambiente |
| just_audio e audioplayers | Música e efeitos sonoros |
| flip_card | Animação de revelação das cartas |
| Device Preview | Testes da interface em diferentes telas |

## Estrutura principal

```text
lib/
├── controllers/   # Estado e operações de coleção e deck
├── models/        # Modelos de carta e pacote
├── screens/       # Fluxos principais: splash, autenticação, início e batalha
├── services/      # Firebase, áudio, batalhas, coleção e missões
├── simulator/     # Catálogo e lógica de simulação das cartas
├── utils/         # Utilitários e gerenciamento de som
├── views/         # Perfil, deck, batalha, pacotes e loja
├── widgets/       # Componentes visuais reutilizáveis
├── firebase_options.dart
└── main.dart

assets/
├── audio/         # Música e sons dos animais
├── data/          # Catálogo de cartas em JSON
└── images/        # Cartas, arenas, pacotes e elementos da interface
```

## Como executar

### Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) compatível com Dart `^3.11.1`
- Um dispositivo, emulador ou navegador configurado
- Um projeto Firebase com Authentication e Cloud Firestore habilitados

### Instalação

1. Clone o repositório:

```bash
git clone https://github.com/AndreyRodr/AnicardBattle.git
cd AnicardBattle
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Configure o Firebase para as plataformas que deseja executar. Gere o arquivo `lib/firebase_options.dart` com o FlutterFire CLI e adicione os arquivos nativos exigidos pela plataforma:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Crie um arquivo `.env` na raiz. O aplicativo carrega esse arquivo na inicialização; adicione somente as variáveis efetivamente usadas pela sua configuração e nunca publique segredos de backend.

5. Execute o projeto:

```bash
flutter run
```

Para escolher um destino específico:

```bash
flutter devices
flutter run -d <device-id>
```

## Testes e análise

```bash
flutter analyze
flutter test
```

## Fluxo do jogo

1. Crie uma conta ou faça login.
2. Conclua o tutorial inicial.
3. Obtenha pacotes na loja e revele novas cartas.
4. Organize um deck com até nove cartas.
5. Entre em batalha para conquistar recompensas e troféus.
6. Complete missões e acompanhe sua colocação no ranking.

## Observações de segurança

- Não inclua chaves administrativas, contas de serviço ou segredos de backend no aplicativo.
- Arquivos de configuração do Firebase usados pelo cliente identificam o projeto, mas a proteção dos dados depende principalmente das regras do Firestore e do Firebase Authentication.
- Antes de publicar o repositório, revise o histórico de commits e confirme que o arquivo `.env` continua ignorado.
- Restrinja cada usuário, nas regras do Firestore, aos documentos e operações que realmente deve acessar.

## Status

O AniCard Battle está em desenvolvimento. Funcionalidades, balanceamento, interface e regras de progressão podem mudar.

## Autor

Desenvolvido por 
- [Andrey Rodrigues](https://github.com/AndreyRodr).
- [Lucas Teixeira](https://github.com/LucassTeixeiraN)
