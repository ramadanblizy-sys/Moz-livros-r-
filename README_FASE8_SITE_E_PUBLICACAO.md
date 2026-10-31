# MOZ LIVROS R — Fase 8: Preparação do site e publicação

Esta fase prepara a estrutura Web da mesma aplicação Flutter, com identidade visual e metadados para o navegador e instalação como aplicação Web (PWA, conforme suporte do navegador).

## O que foi acrescentado
- Página inicial Web com título e descrição em português.
- Cor oficial verde da marca no navegador.
- Ícone SVG da livraria.
- Manifesto Web com nome, modo de apresentação e cores da marca.
- Instruções de compilação para Web e Android.

## Testar o site no computador
Na pasta principal do projecto:
1. Instale Flutter SDK e configure o ambiente.
2. Execute `flutter pub get`.
3. Configure Firebase para Web. A inicialização actual precisa das opções correctas do seu projecto Firebase; siga a documentação FlutterFire e configure `Firebase.initializeApp` com `DefaultFirebaseOptions.currentPlatform`.
4. Execute `flutter run -d chrome` para testar.
5. Para gerar o site: `flutter build web --release`.
6. Os ficheiros finais estarão em `build/web/`. Publique essa pasta num alojamento HTTPS (por exemplo, Firebase Hosting depois de configurar o projecto).

## Preparar Android
1. Configure Firebase para Android e coloque os ficheiros de configuração exigidos pelo FlutterFire/Gradle.
2. Execute `flutter pub get`.
3. Teste com `flutter run` num telemóvel Android.
4. Gere APK de teste: `flutter build apk --release`.
5. Para Play Store, configure assinatura de lançamento e gere: `flutter build appbundle --release`.

## Antes de abrir ao público
- Testar registo, início de sessão e recuperação de palavra-passe.
- Criar a conta administrativa e atribuir `admin: true` de forma segura no Firebase Admin SDK.
- Testar publicação e edição de livros.
- Testar encomenda de livro físico e digital.
- Verificar pagamentos na conta oficial antes de confirmar no painel.
- Testar custo de entrega, levantamento e actualização de estado.
- Testar acesso a PDF com encomenda paga e recusar acesso com encomenda não paga.
- Definir política de privacidade, termos de venda, política de reembolso e contactos de apoio.
- Confirmar que tem autorização para vender cada livro digital.
- Fazer cópias de segurança e activar regras de segurança no Firebase.

## Estado real do projecto
Este pacote é uma base de desenvolvimento e preparação Web. Não está publicado na Internet, não possui domínio próprio e não está ligado a um projecto Firebase real. A integração automática com M-Pesa, e-Mola e mKesh ainda depende de acesso oficial às APIs/contas de comerciante. O site e o APK/App Bundle precisam de ser compilados e testados no ambiente do proprietário.
