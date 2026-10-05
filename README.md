# Diário Fit

App de treino em Flutter para quem treina funcional e musculação. A pessoa monta o cronograma da semana, segue o treino com cronômetro e acompanha a evolução.

## Funcionalidades

- **Cronograma semanal**: monta cada dia com exercícios do catálogo, copia um dia para outros e limpa o dia ou a semana inteira.
- **Dois tipos de treino**: funcional (rodadas × tempo) e hipertrofia (séries × repetições), com descanso configurável por dia.
- **Treinos prontos**: planos para iniciantes aplicados com um toque.
- **Player de treino**: cronômetro, descanso com contagem regressiva, vibração, tela sempre acesa, ajuste de carga e troca de exercício por um parecido durante o treino.
- **Treino em segundo plano**: o cronômetro segue pelo relógio real; no Android, uma notificação mostra a contagem ao vivo e avisa cada troca de fase.
- **Histórico**: calendário de treinos e contagem de dias seguidos.
- **Perfil**: peso ao longo do tempo, IMC e progresso até a meta.
- **Lembrete**: notificação nos dias que têm treino.
- **Dados no aparelho**: tudo fica salvo localmente e a sessão continua aberta entre um uso e outro.
- **LGPD**: termos de uso, política de privacidade e opção de excluir a conta.

## Rodando

Requer o Flutter (SDK do Dart ^3.12).

```sh
flutter pub get
flutter run
```

Testes e análise:

```sh
flutter test
flutter analyze
```

## Estrutura

```
lib/
  main.dart        abertura do app: carrega os dados e escolhe a primeira tela
  data.dart        modelos, catálogo de exercícios e regras (sequência, IMC, metas)
  storage.dart     salvar/carregar tudo como JSON (shared_preferences)
  reminders.dart   lembretes com notificação local
  ui.dart          tema "Kinetic Volt" e componentes compartilhados
  screens/         uma tela por arquivo
assets/
  icon/            fontes SVG e PNGs do ícone e da splash
  logo_mark.png    monograma usado no logo dentro do app
telas app/         telas de referência do design (Stitch) e o ícone original
test/              testes de regras e da persistência
```

## Ícone e splash

As fontes ficam em `assets/icon/*.svg`. Depois de alterar os PNGs, gere tudo de novo:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

O ícone das notificações (`android/app/src/main/res/drawable-*/ic_notification.png`) é a silhueta branca de `assets/icon/notification.svg`.

## Próximos passos

- Backend no Supabase (login real e sincronização). Os pontos de integração estão marcados com `TODO(supabase)`.
- Vídeos dos exercícios no player.
- Imagens próprias no lugar das temporárias.
