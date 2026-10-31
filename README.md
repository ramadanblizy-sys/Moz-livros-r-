# MOZ LIVROS R — Fase 5: encomendas e fluxo de compra

## Funcionalidades preparadas
- Cliente autenticado abre um livro e inicia a encomenda.
- Escolhe M-Pesa, e-Mola ou mKesh como método pretendido.
- Para livros físicos, escolhe entrega ao domicílio ou levantamento.
- Informa telefone e endereço/ponto de recolha.
- Encomenda fica registada no Firestore com estado `pending`.
- Cliente consulta as suas encomendas.
- Para entrega ao domicílio, taxa e total ficam por confirmar pela loja.
- Regras impedem que o cliente altere o estado e o pagamento da encomenda.

## Configuração
1. Configure Firebase como descrito no README da fase anterior.
2. Execute `flutter pub get`.
3. Publique `firebase/firestore.rules` nas regras do Firestore.
4. Execute `flutter run` ou `flutter run -d chrome`.

## Limitações importantes
- Os botões M-Pesa, e-Mola e mKesh registam apenas o método escolhido. Não fazem cobrança nem consultam transacções.
- A loja deve confirmar pagamentos através de integração oficial ou conferência manual num painel seguro.
- Não aceite capturas de ecrã como prova suficiente de pagamento.
- A confirmação do pagamento e a alteração de `paymentStatus`/`status` devem ser feitas por backend confiável, nunca pelo cliente.
- O cálculo automático da entrega ainda não existe; o administrador informa a taxa depois de receber a morada.
- Acesso/leitura de PDFs pagos ainda não está implementado. Os PDFs devem permanecer privados e ser entregues por backend após validação de pagamento.
- Antes de produção, validar preços no servidor a partir do documento do livro para impedir manipulação pelo cliente.


Consulte `README_FASE6_ADMIN.md` para configurar o painel administrativo e as Cloud Functions da Fase 6.

Consulte `README_FASE7_LIVROS_DIGITAIS.md` para configurar os PDFs protegidos e o acesso após pagamento.

Consulte `README_FASE8_SITE_E_PUBLICACAO.md` para preparar o site Web e compilar a versão Android.

Consulte `README_FASE9_TESTES_ANDROID_FIREBASE.md` e `firebase/README_CONFIGURACAO.md` para preparar Android e ligar o Firebase real.
