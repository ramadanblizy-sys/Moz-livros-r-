# MOZ LIVROS R — Fase 7: Acesso protegido aos livros digitais (PDF)

## O que esta fase acrescenta
- Uma Cloud Function chamada `getDigitalBookDownloadUrl`.
- Verificação de sessão, propriedade da encomenda, pagamento confirmado e formato digital.
- Geração de URL temporário de leitura/descarga (5 minutos).
- Regras do Storage bloqueiam leitura directa de PDFs.
- Serviço Flutter `DigitalBookService`.
- Página reutilizável `DigitalBookAccessPage` para abrir o PDF no dispositivo.

## Como preparar os ficheiros PDF
1. No Firebase Storage, crie a pasta `private-pdfs/`.
2. Carregue cada PDF autorizado para venda nessa pasta.
3. No documento do livro em Firestore (`books/{bookId}`), grave o campo `pdfStoragePath` com o caminho exacto, por exemplo:
   `private-pdfs/livro-portugues-5-classe.pdf`
4. O campo `format` usado na encomenda deve ser `digital` para livros digitais.
5. Publique as regras e funções:
   `firebase deploy --only storage,functions`

## Como ligar a página ao histórico de compras
No cartão de cada encomenda do cliente, quando `paymentStatus == 'paid'` e `format == 'digital'`, navegue para:
`DigitalBookAccessPage(orderId: doc.id, bookTitle: order['bookTitle'] ?? 'Livro digital')`.

## Segurança
- Não torne a pasta `private-pdfs/` pública.
- Não guarde URLs assinados nos documentos Firestore nem no catálogo.
- O servidor verifica se a encomenda pertence ao utilizador autenticado e se foi paga.
- O link expira em 5 minutos; o cliente pode pedir outro enquanto tiver direito.
- A confirmação do pagamento continua a depender do processo seguro da Fase 6.
- Carregue apenas PDFs que tenha autorização legal para comercializar.

## Limitações desta fase
A página abre o PDF através do navegador/aplicação PDF instalada no dispositivo. Um leitor embutido dentro da aplicação, com controlo avançado contra cópia, é uma melhoria futura; nenhum sistema consegue impedir totalmente capturas de ecrã ou cópias feitas por um utilizador autorizado.

## Configuração
- Configure Firebase Android/Web.
- Execute `flutter pub get`.
- Dentro de `functions`, execute `npm install`.
- Faça deploy das Cloud Functions e regras de Storage.
- Atribua `admin: true` apenas à conta administrativa através do Admin SDK.
- O projecto ainda precisa de configuração com as credenciais reais do Firebase e de testes num dispositivo.
