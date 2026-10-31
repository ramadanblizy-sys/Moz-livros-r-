# MOZ LIVROS R — Fase 9: Preparação Android e testes

## O que esta fase entrega
- Script para gerar a estrutura Android padrão do Flutter sem substituir uma pasta Android já existente.
- Script equivalente para Windows.
- Guia de configuração real do Firebase para Android e Web.
- Lista de testes antes de abrir a livraria ao público.

## Requisitos no computador
- Flutter SDK instalado e configurado no PATH.
- Android Studio instalado com Android SDK.
- Um telemóvel Android com Depuração USB activada, ou emulador Android.
- Conta Firebase e acesso de administrador ao projecto.
- Firebase CLI e FlutterFire CLI.

## Preparar o projecto
### Windows
Execute `scripts/preparar_flutter_android.bat`.

### Linux/macOS
Execute `bash scripts/preparar_flutter_android.sh`.

Os scripts geram a pasta Android apenas se ela ainda não existir e executam `flutter pub get`.

## Ligar Firebase
Siga `firebase/README_CONFIGURACAO.md`. É obrigatório executar `flutterfire configure` e inicializar Firebase com `DefaultFirebaseOptions.currentPlatform`. Este pacote não contém as chaves reais do Firebase.

## Testar no telemóvel
1. Ligue o telefone por USB e autorize a depuração, ou abra um emulador.
2. Execute `flutter devices`.
3. Execute `flutter run`.
4. Teste o registo, login, catálogo, encomenda, painel administrativo e acesso a PDF.

## Gerar pacote de teste
APK:
```bash
flutter build apk --debug
```
O APK de depuração ficará normalmente em `build/app/outputs/flutter-apk/app-debug.apk`.

APK de lançamento (depois de configurar assinatura):
```bash
flutter build apk --release
```

App Bundle para Play Store (depois de configurar assinatura):
```bash
flutter build appbundle --release
```

## Checklist mínimo de aceitação
- [ ] Cliente consegue criar conta e iniciar sessão.
- [ ] Cliente consegue ver livros publicados e pesquisar.
- [ ] Cliente A não consegue ler encomendas do Cliente B.
- [ ] Cliente não consegue criar ou alterar permissões de administrador.
- [ ] Admin consegue publicar livros e gerir encomendas.
- [ ] Pagamento só é confirmado depois de verificação na conta oficial.
- [ ] Taxa de entrega é definida antes de confirmar encomenda ao domicílio.
- [ ] PDF não abre para encomenda não paga.
- [ ] PDF abre para o comprador autenticado com pagamento confirmado.
- [ ] Encomenda física permite acompanhar preparação e entrega.
- [ ] App funciona em diferentes tamanhos de ecrã.
- [ ] Política de privacidade, termos e contactos estão publicados.

## Limitação importante
Ainda não foi gerado um APK nesta sessão porque não temos Flutter SDK/Android SDK nem as credenciais do projecto Firebase do proprietário. Esta fase prepara os scripts e passos para gerar o APK no computador com Android Studio. Também é necessário validar e testar a aplicação real antes de publicar na Play Store.
