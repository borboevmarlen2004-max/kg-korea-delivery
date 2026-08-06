/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onCall, HttpsError} = require("firebase-functions/https");
const {getAuth} = require("firebase-admin/auth");
const {initializeApp} = require("firebase-admin/app");
initializeApp();
// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});
exports.makeAdmin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Сиз аккаунтка кирген эмессиз.",
    );
  }

  const email = request.auth.token.email;

  if (email !== "miki@gmail.com") {
    throw new HttpsError(
        "permission-denied",
        "Админ укугу жок.",
    );
  }

  await getAuth().setCustomUserClaims(request.auth.uid, {
    admin: true,
  });

  return {
    success: true,
    message: "Admin укугу берилди.",
  };
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.testPayment = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Сиз аккаунтка кирген эмессиз.",
    );
  }

  const orderId = request.data.orderId;

  if (!orderId) {
    throw new HttpsError(
        "invalid-argument",
        "orderId берилген жок.",
    );
  }

  return {
    success: true,
    orderId: orderId,
    message: "Тесттик төлөм кабыл алынды.",
  };
});

