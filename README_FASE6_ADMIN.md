# MOZ LIVROS R — Fase 6: Administração de encomendas

Esta fase acrescenta um painel de encomendas para o administrador e operações seguras no servidor.

## O que foi acrescentado
- Lista de encomendas do Firestore e detalhes do cliente.
- Resumo de encomendas, pagamentos confirmados e receita confirmada em MT.
- Definição da taxa de entrega ao domicílio.
- Confirmação manual de pagamento com referência da transacção.
- Actualização do estado de preparação, transporte, levantamento e entrega.
- Regras Firestore impedem alterações directas às encomendas pelo aplicativo.
- Cloud Functions verificam a permissão `admin == true` no servidor.

## Como abrir o painel
A página `AdminOrdersPage` foi adicionada em `lib/main.dart`. Depois de configurar Firebase e autenticar uma conta com a permissão administrativa, ligue esta página ao botão/rota de administração da aplicação.

## Configuração necessária
1. Configure Firebase para Android e Web, como explicado nas fases anteriores.
2. Instale Firebase CLI e inicie sessão no projecto correcto.
3. Na pasta `functions`, execute `npm install`.
4. Faça deploy: `firebase deploy --only functions`.
5. Publique as regras: `firebase deploy --only firestore:rules`.
6. Defina a custom claim `admin: true` para a conta do proprietário através de um ambiente administrativo seguro (Admin SDK). Nunca permita que o próprio aplicativo atribua essa permissão.
7. No Flutter, execute `flutter pub get`.

## Atenção sobre pagamentos
O botão de confirmação é uma confirmação MANUAL. Antes de o usar, o administrador deve confirmar o recebimento na conta oficial do comerciante e registar a referência verdadeira. Uma captura de ecrã enviada pelo cliente não prova, por si só, que o dinheiro entrou.

Ainda não existe integração automática com APIs de M-Pesa, e-Mola ou mKesh. Para isso serão necessários contratos/acesso de comerciante, documentação e credenciais oficiais. Não coloque credenciais secretas no aplicativo.

## Atenção sobre PDFs
Esta fase não implementa ainda a entrega protegida dos PDFs pagos. Os ficheiros PDF continuam bloqueados pelas regras de armazenamento da fase anterior até ser criado o mecanismo seguro de autorização/descarga.

## Observação
O projecto é uma base de desenvolvimento. Não foi possível compilar ou testar contra o seu projecto Firebase real porque as credenciais e a configuração Firebase ainda não foram fornecidas.
