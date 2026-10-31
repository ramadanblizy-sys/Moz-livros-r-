import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

function requireAdmin(request: { auth?: { uid: string; token: Record<string, unknown> } }) {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Inicie sessão para continuar.");
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError("permission-denied", "Apenas o administrador pode executar esta ação.");
  }
  return request.auth.uid;
}

function requiredOrderId(data: Record<string, unknown>): string {
  const id = data.orderId;
  if (typeof id !== "string" || id.trim().length < 5 || id.length > 150) {
    throw new HttpsError("invalid-argument", "Identificador da encomenda inválido.");
  }
  return id.trim();
}

function safeMzn(value: unknown, field: string): number {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value < 0 || value > 100000000) {
    throw new HttpsError("invalid-argument", `${field} deve ser um valor inteiro em MT.`);
  }
  return value;
}

/**
 * O administrador define a taxa de entrega depois de verificar a localização.
 * A operação é feita no servidor, nunca diretamente pelo aplicativo do cliente.
 */
export const adminQuoteOrder = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const orderId = requiredOrderId(request.data ?? {});
  const deliveryFeeMzn = safeMzn(request.data?.deliveryFeeMzn, "Custo de entrega");

  const ref = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Encomenda não encontrada.");
    const order = snap.data()!;
    if (order.deliveryType !== "home") {
      throw new HttpsError("failed-precondition", "Esta encomenda não requer taxa de entrega ao domicílio.");
    }
    if (order.paymentStatus === "paid") {
      throw new HttpsError("failed-precondition", "Não é possível alterar o custo após a confirmação do pagamento.");
    }
    const bookPrice = safeMzn(order.bookPriceMzn, "Preço do livro");
    tx.update(ref, {
      deliveryFeeMzn,
      totalMzn: bookPrice + deliveryFeeMzn,
      deliveryFeeStatus: "quoted",
      quoteUpdatedAt: FieldValue.serverTimestamp(),
      quoteUpdatedBy: adminUid
    });
  });
  return { ok: true };
});

/**
 * Confirmação manual: usar somente depois de confirmar a transação na conta
 * oficial do comerciante (M-Pesa/e-Mola/mKesh). Não confiar apenas em capturas.
 */
export const adminConfirmPayment = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const orderId = requiredOrderId(request.data ?? {});
  const providerReference = request.data?.providerReference;
  if (typeof providerReference !== "string" || providerReference.trim().length < 3 || providerReference.length > 120) {
    throw new HttpsError("invalid-argument", "Introduza a referência da transação verificada.");
  }

  const ref = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Encomenda não encontrada.");
    const order = snap.data()!;
    if (order.paymentStatus === "paid") {
      throw new HttpsError("already-exists", "O pagamento já foi confirmado.");
    }
    if (order.deliveryType === "home" && order.deliveryFeeStatus !== "quoted") {
      throw new HttpsError("failed-precondition", "Defina primeiro o custo de entrega.");
    }
    if (typeof order.totalMzn !== "number" || !Number.isSafeInteger(order.totalMzn)) {
      throw new HttpsError("failed-precondition", "O total da encomenda ainda não está definido.");
    }
    tx.update(ref, {
      paymentStatus: "paid",
      status: "payment_confirmed",
      paymentConfirmedAt: FieldValue.serverTimestamp(),
      paymentConfirmedBy: adminUid,
      providerReference: providerReference.trim()
    });
  });
  return { ok: true };
});

const allowedStatuses = new Set(["prepared", "in_transit", "ready_for_pickup", "delivered"]);

export const adminUpdateDeliveryStatus = onCall(async (request) => {
  const adminUid = requireAdmin(request);
  const orderId = requiredOrderId(request.data ?? {});
  const status = request.data?.status;
  if (typeof status !== "string" || !allowedStatuses.has(status)) {
    throw new HttpsError("invalid-argument", "Estado de entrega inválido.");
  }

  const ref = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Encomenda não encontrada.");
    const order = snap.data()!;
    if (order.paymentStatus !== "paid") {
      throw new HttpsError("failed-precondition", "Confirme o pagamento antes de avançar a entrega.");
    }
    if (order.format === "digital" && status !== "delivered") {
      throw new HttpsError("failed-precondition", "Encomendas digitais não usam estados de transporte.");
    }
    tx.update(ref, {
      status,
      deliveryStatusUpdatedAt: FieldValue.serverTimestamp(),
      deliveryStatusUpdatedBy: adminUid
    });
  });
  return { ok: true };
});


/**
 * Emite um link temporário para um PDF somente quando o utilizador comprou
 * o livro digital e o pagamento foi confirmado. O PDF nunca fica público.
 */
export const getDigitalBookDownloadUrl = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Inicie sessão para aceder ao livro.");
  }
  const orderId = requiredOrderId(request.data ?? {});
  const ref = db.collection("orders").doc(orderId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Encomenda não encontrada.");

  const order = snap.data()!;
  const isAdmin = request.auth.token.admin === true;
  if (!isAdmin && order.customerUid !== request.auth.uid) {
    throw new HttpsError("permission-denied", "Esta encomenda pertence a outro cliente.");
  }
  if (order.paymentStatus !== "paid") {
    throw new HttpsError("failed-precondition", "O pagamento ainda não foi confirmado.");
  }
  if (order.format !== "digital") {
    throw new HttpsError("failed-precondition", "Esta encomenda não é de um livro digital.");
  }
  if (typeof order.bookId !== "string" || order.bookId.length < 1) {
    throw new HttpsError("failed-precondition", "A encomenda não tem um livro associado.");
  }

  const bookSnap = await db.collection("books").doc(order.bookId).get();
  if (!bookSnap.exists) throw new HttpsError("not-found", "Livro não encontrado.");
  const book = bookSnap.data()!;
  const filePath = book.pdfStoragePath;
  if (typeof filePath !== "string" || !filePath.startsWith("private-pdfs/")) {
    throw new HttpsError("failed-precondition", "O PDF deste livro ainda não foi carregado na pasta privada.");
  }

  const { getStorage } = await import("firebase-admin/storage");
  const bucket = getStorage().bucket();
  const file = bucket.file(filePath);
  const [exists] = await file.exists();
  if (!exists) throw new HttpsError("not-found", "Ficheiro PDF não encontrado.");

  const [url] = await file.getSignedUrl({
    version: "v4",
    action: "read",
    expires: Date.now() + 5 * 60 * 1000
  });
  return { url, expiresInSeconds: 300, title: book.title ?? order.bookTitle ?? "Livro digital" };
});
