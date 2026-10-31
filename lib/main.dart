import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services/firebase_services.dart';
import 'services/order_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/digital_book_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  try {
    await Firebase.initializeApp();
  } catch (e) {
    startupError = e;
  }
  runApp(MozLivrosApp(startupError: startupError));
}

class MozLivrosApp extends StatelessWidget {
  final Object? startupError;
  const MozLivrosApp({super.key, this.startupError});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MOZ LIVROS R',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF168447),
        primary: const Color(0xFF168447),
        secondary: const Color(0xFFFFC928),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F8F7),
    ),
    home: startupError == null
      ? const HomePage()
      : FirebaseSetupPage(error: startupError.toString()),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF168447),
      foregroundColor: Colors.white,
      title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MOZ LIVROS R', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('A sua livraria virtual', style: TextStyle(fontSize: 11)),
      ]),
      actions: [
        IconButton(
          tooltip: 'Conta',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage())),
          icon: const Icon(Icons.person_outline),
        ),
        IconButton(
          tooltip: 'Minhas encomendas',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
      ],
    ),
    body: StreamBuilder(
      stream: BookRepository().watchPublishedBooks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Erro ao carregar catálogo: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Ainda não há livros publicados.'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF168447), Color(0xFF086234)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Conhecimento ao seu alcance',
                style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Encontre livros digitais e físicos, onde estiver.',
                style: TextStyle(color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Livros disponíveis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...docs.map((doc) {
            final b = doc.data();
            return Card(color: Colors.white, child: ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE7F3EB),
                child: Icon(Icons.menu_book, color: Color(0xFF168447))),
              title: Text((b['title'] ?? '').toString()),
              subtitle: Text('${b['author'] ?? ''}\n${b['genre'] ?? ''} • ${b['format'] ?? ''}'),
              isThreeLine: true,
              trailing: Text('${b['priceMzn'] ?? 0} MT',
                style: const TextStyle(color: Color(0xFF168447), fontWeight: FontWeight.bold)),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => BookDetailsPage(bookId: doc.id, book: b))),
            ));
          }),
        ]);
      },
    ),
  );
}

class BookDetailsPage extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> book;
  const BookDetailsPage({super.key, required this.bookId, required this.book});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes do livro')),
    body: Padding(padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Center(child: Icon(Icons.menu_book, size: 110, color: Color(0xFF168447))),
        const SizedBox(height: 20),
        Text((book['title'] ?? '').toString(), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
        Text('Autor: ${book['author'] ?? 'Não indicado'}'),
        Text('Género: ${book['genre'] ?? 'Não indicado'}'),
        Text('Formato: ${book['format'] ?? 'Não indicado'}'),
        const SizedBox(height: 12),
        Text('${book['priceMzn'] ?? 0} MT', style: const TextStyle(fontSize: 22,
          color: Color(0xFF168447), fontWeight: FontWeight.bold)),
        const Spacer(),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage()));
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage(bookId: bookId, book: book)));
          },
          child: const Text('Continuar para compra'))),
      ],
    )),
  );
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Acesso à MOZ LIVROS R')),
    body: Padding(padding: const EdgeInsets.all(22), child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.menu_book, size: 68, color: Color(0xFF168447)),
        const SizedBox(height: 20),
        FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
          child: const Text('Iniciar sessão')),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
          child: const Text('Criar conta de cliente')),
      ],
    )),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false;
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    setState(() => busy = true);
    try {
      await AuthService().signIn(email: email.text, password: password.text);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão iniciada.'))); Navigator.pop(context); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao entrar: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Iniciar sessão')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      TextField(controller: email, keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: true,
        decoration: const InputDecoration(labelText: 'Palavra-passe', border: OutlineInputBorder())),
      const SizedBox(height: 22),
      FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'A entrar...' : 'Entrar')),
    ]));
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController(), email = TextEditingController(),
    phone = TextEditingController(), password = TextEditingController();
  bool busy = false;
  @override void dispose() { name.dispose(); email.dispose(); phone.dispose(); password.dispose(); super.dispose(); }
  Future<void> submit() async {
    if ([name.text, email.text, phone.text, password.text].any((v) => v.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos.'))); return;
    }
    if (password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use pelo menos 6 caracteres na palavra-passe.'))); return;
    }
    setState(() => busy = true);
    try {
      await AuthService().registerCustomer(name: name.text, email: email.text, phone: phone.text, password: password.text);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conta criada.'))); Navigator.pop(context); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no registo: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Criar conta')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome completo', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Número de telefone', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Palavra-passe (mínimo 6 caracteres)', border: OutlineInputBorder())),
      const SizedBox(height: 22),
      FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'A criar conta...' : 'Criar conta')),
    ]));

class CheckoutPage extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> book;
  const CheckoutPage({super.key, required this.bookId, required this.book});
  @override State<CheckoutPage> createState() => _CheckoutPageState();
}
class _CheckoutPageState extends State<CheckoutPage> {
  final phone = TextEditingController(), address = TextEditingController(), pickup = TextEditingController();
  String payment = 'M-Pesa', delivery = 'Entrega ao domicílio';
  bool busy = false;
  bool get physical {
    final f = (widget.book['format'] ?? '').toString();
    return f == 'Físico' || f == 'PDF e físico';
  }
  @override void dispose() { phone.dispose(); address.dispose(); pickup.dispose(); super.dispose(); }
  Future<void> placeOrder() async {
    if (phone.text.trim().isEmpty) { show('Indique o seu número de telefone.'); return; }
    if (physical && delivery == 'Entrega ao domicílio' && address.text.trim().isEmpty) {
      show('Indique a morada para entrega.'); return;
    }
    if (physical && delivery == 'Levantamento' && pickup.text.trim().isEmpty) {
      show('Indique o ponto de recolha pretendido.'); return;
    }
    setState(() => busy = true);
    try {
      final id = await OrderService().createOrder(
        bookId: widget.bookId,
        bookTitle: (widget.book['title'] ?? '').toString(),
        format: (widget.book['format'] ?? 'PDF').toString(),
        bookPriceMzn: (widget.book['priceMzn'] as num?)?.toInt() ?? 0,
        paymentMethod: payment,
        deliveryType: delivery,
        customerPhone: phone.text,
        deliveryAddress: address.text,
        pickupPoint: pickup.text,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderConfirmationPage(orderId: id, isHomeDelivery: physical && delivery == 'Entrega ao domicílio')));
      }
    } catch (e) { show('Não foi possível criar a encomenda: $e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  void show(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Finalizar encomenda')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Text((widget.book['title'] ?? '').toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text('Preço do livro: ${widget.book['priceMzn'] ?? 0} MT'),
      const SizedBox(height: 18),
      TextField(controller: phone, keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Número de telefone para contacto', border: OutlineInputBorder())),
      const SizedBox(height: 18),
      const Text('Método de pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
      DropdownButtonFormField<String>(value: payment, decoration: const InputDecoration(border: OutlineInputBorder()),
        items: const ['M-Pesa', 'e-Mola', 'mKesh'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => payment = v ?? payment)),
      if (physical) ...[
        const SizedBox(height: 18),
        const Text('Como pretende receber o livro?', style: TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(value: delivery, decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const ['Entrega ao domicílio', 'Levantamento'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => delivery = v ?? delivery)),
        const SizedBox(height: 12),
        if (delivery == 'Entrega ao domicílio')
          TextField(controller: address, maxLines: 3, decoration: const InputDecoration(
            labelText: 'Morada / bairro / referência', border: OutlineInputBorder()))
        else
          TextField(controller: pickup, decoration: const InputDecoration(
            labelText: 'Ponto de recolha pretendido', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        const Text('A taxa de transporte será calculada conforme a localização e confirmada pela loja antes do pagamento.',
          style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
      const SizedBox(height: 22),
      FilledButton(onPressed: busy ? null : placeOrder, child: Text(busy ? 'A criar encomenda...' : 'Registar encomenda')),
      const SizedBox(height: 12),
      const Text('Esta etapa regista um pedido pendente. Ainda não cobra dinheiro nem confirma automaticamente o pagamento.',
        style: TextStyle(fontSize: 12, color: Colors.deepOrange)),
    ]),
  );
}

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final bool isHomeDelivery;
  const OrderConfirmationPage({super.key, required this.orderId, required this.isHomeDelivery});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Encomenda registada')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline, size: 76, color: Color(0xFF168447)),
        const SizedBox(height: 16),
        const Text('O seu pedido foi registado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('Número da encomenda: $orderId', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(isHomeDelivery
          ? 'A loja irá confirmar o custo de transporte e enviar as instruções de pagamento.'
          : 'A loja irá verificar o pedido e enviar as instruções de pagamento.'),
        const SizedBox(height: 22),
        FilledButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
          child: const Text('Ver minhas encomendas')),
      ],
    )),
  );
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return Scaffold(appBar: AppBar(title: const Text('Minhas encomendas')),
        body: const Center(child: Text('Inicie sessão para consultar as suas encomendas.')));
    }
    return Scaffold(appBar: AppBar(title: const Text('Minhas encomendas')),
      body: StreamBuilder(
        stream: OrderService().customerOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text('Ainda não tem encomendas.'));
          return ListView(padding: const EdgeInsets.all(16), children: orders.map((doc) {
            final o = doc.data();
            final fee = o['deliveryFeeMzn'];
            final total = o['totalMzn'];
            return Card(color: Colors.white, child: ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFF168447)),
              title: Text((o['bookTitle'] ?? 'Livro').toString()),
              subtitle: Text('Estado: ${o['status'] ?? 'pending'}\nPagamento: ${o['paymentStatus'] ?? 'awaiting_payment'}\nTransporte: ${fee == null ? 'Por confirmar' : '$fee MT'}'),
              isThreeLine: true,
              trailing: Text(total == null ? 'A confirmar' : '$total MT',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF168447))),
            ));
          }).toList());
        },
      ));
  }
}

class FirebaseSetupPage extends StatelessWidget {
  final String error;
  const FirebaseSetupPage({super.key, required this.error});
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Padding(
    padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.settings, size: 60, color: Color(0xFF168447)),
      const SizedBox(height: 16),
      const Text('Configuração Firebase necessária', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      const Text('Configure o projecto Firebase e os ficheiros da plataforma conforme o README.', textAlign: TextAlign.center),
      const SizedBox(height: 12),
      Text(error, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    ]),
  )));
}


class DigitalBookAccessPage extends StatefulWidget {
  const DigitalBookAccessPage({
    super.key,
    required this.orderId,
    required this.bookTitle,
  });

  final String orderId;
  final String bookTitle;

  @override
  State<DigitalBookAccessPage> createState() => _DigitalBookAccessPageState();
}

class _DigitalBookAccessPageState extends State<DigitalBookAccessPage> {
  final _service = DigitalBookService();
  bool _busy = false;

  Future<void> _openBook() async {
    setState(() => _busy = true);
    try {
      final access = await _service.requestAccess(widget.orderId);
      final uri = Uri.parse(access.url);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o PDF neste dispositivo.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Acesso não autorizado ou indisponível: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu livro digital')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 64),
              const SizedBox(height: 16),
              Text(widget.bookTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text(
                'O acesso só é autorizado depois da confirmação do pagamento. '
                'O endereço do PDF é temporário e expira em poucos minutos.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _busy ? null : _openBook,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_busy ? 'A verificar...' : 'Ler / descarregar PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
