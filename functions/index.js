const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.enviarNotificacionMensaje = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const mensaje = snap.data();
    const chatId = context.params.chatId;

    // Obtener participantes del chat
    const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
    const participantes = chatDoc.data()?.participantes || [];

    const destinatarios = participantes.filter(uid => uid !== mensaje.remitenteId);

    for (const uid of destinatarios) {
      const userDoc = await admin.firestore().collection('users').doc(uid).get();
      const token = userDoc.data()?.fcmToken;

      if (token) {
        const payload = {
          notification: {
            title: "Nuevo mensaje",
            body: mensaje.texto || "📷 Imagen",
            android_channel_id: "mensaje_channel", // 🔧 canal obligatorio en Android 13+
          },
          data: {
            chatId: chatId,
            remitenteId: mensaje.remitenteId,
          },
        };

        try {
          await admin.messaging().sendToDevice(token, payload);
          console.log(`✅ Notificación enviada a ${uid}`);
        } catch (error) {
          console.error(`❌ Error al enviar a ${uid}:`, error);
        }
      }
    }
  });
