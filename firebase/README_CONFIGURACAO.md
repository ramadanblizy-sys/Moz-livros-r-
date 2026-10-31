# Configuração Firebase do MOZ LIVROS R

Este projecto não contém credenciais Firebase. Não copie credenciais de exemplo da Internet.

## 1. Criar projecto
- Crie um projecto na consola Firebase.
- Registe a aplicação Android com o identificador de pacote que decidir usar.
- Registe também a aplicação Web.
- Active Authentication (Email/Password), Cloud Firestore, Storage e Functions.

## 2. Gerar configuração Flutter
Na pasta principal do projecto:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Seleccione o projecto Firebase e as plataformas Android e Web. A ferramenta gera `lib/firebase_options.dart` e configura os ficheiros de plataforma necessários.

Depois altere `main.dart` para inicializar assim:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```
E acrescente o import:
```dart
import 'firebase_options.dart';
```

## 3. Publicar regras e funções
Com Firebase CLI instalado e apontado para o projecto correcto:
```bash
firebase deploy --only firestore:rules,storage,functions
```
Na pasta `functions`:
```bash
npm install
npm run build
```

## 4. Administrador
A conta do proprietário deve receber a custom claim `admin: true` por um processo seguro com Firebase Admin SDK. Nunca crie um botão no aplicativo para o utilizador se tornar administrador.

## 5. Testar primeiro
Use um projecto Firebase de testes, não o projecto de produção. Faça testes com:
- Conta cliente A e conta cliente B.
- Conta administrativa.
- Livro físico e livro digital.
- Encomenda não paga e encomenda paga.
- Tentativa de um cliente consultar a encomenda de outro.
- Tentativa de aceder a PDF sem pagamento.
