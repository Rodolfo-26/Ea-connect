const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendChatNotification = onDocumentCreated("chats/{chatId}/messages/{messageId}", async (event) => {
  try {
    const snap = event.data;
    if (!snap) {
      console.log("No snapshot data");
      return;
    }

    const message = snap.data();
    const chatId = event.params.chatId;
    const texto = message.texto || "";
    const remitenteId = message.remitenteId;

    const db = getFirestore();
    const chatDoc = await db.collection("chats").doc(chatId).get();

    if (!chatDoc.exists) {
      console.log("Chat no encontrado:", chatId);
      return;
    }

    const participantes = chatDoc.data().participantes || [];
    const destinatarios = participantes.filter(uid => uid !== remitenteId);

    const tokens = [];

    for (const uid of destinatarios) {
      const userDoc = await db.collection("users").doc(uid).get();
      if (userDoc.exists) {
        const token = userDoc.data().fcmToken;
        if (token) tokens.push(token);
      }
    }

    if (tokens.length === 0) {
      console.log("No hay tokens para enviar notificación");
      return;
    }

    const payload = {
      notification: {
        title: "Nuevo mensaje en chat",
        body: texto,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      }
    };

    const response = await getMessaging().sendToDevice(tokens, payload);
    console.log("Notificaciones enviadas:", response.successCount);
  } catch (error) {
    console.error("Error en la función sendChatNotification:", error);
  }
});
