// POST /functions/v1/notifikasi-midtrans
// Webhook (HTTP Notification) yang dipanggil server Midtrans setiap kali
// status transaksi berubah. Harus di-deploy TANPA verifikasi JWT
// (Midtrans tidak mengirim token login), jadi keamanannya dijaga dengan:
//   1. Verifikasi signature_key (SHA512 + server key rahasia).
//   2. Menanyakan ulang status ke Midtrans sebelum mengubah database.

import {
  ambilStatusMidtrans,
  DataMidtrans,
  json,
  SERVER_KEY,
  signatureValid,
  terapkanStatus,
} from "../_shared/midtrans.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ success: false, message: "Metode tidak didukung." }, 405);
  }
  if (!SERVER_KEY) {
    return json({ success: false, message: "Belum dikonfigurasi." }, 500);
  }

  const notif = (await req.json().catch(() => ({}))) as DataMidtrans;

  if (!(await signatureValid(notif))) {
    console.warn("Notifikasi ditolak: signature tidak valid", notif.order_id);
    return json({ success: false, message: "Signature tidak valid." }, 403);
  }

  const orderId = notif.order_id!;
  // Sumber kebenaran tetap status langsung dari Midtrans.
  const terbaru = (await ambilStatusMidtrans(orderId)) ?? notif;
  const hasil = await terapkanStatus(orderId, terbaru);

  if (!hasil.ditemukan) {
    // Misal: tombol "Test notification" di dashboard Midtrans memakai order_id contoh.
    // Balas 200 supaya Midtrans tidak terus mengirim ulang.
    console.log("Notifikasi untuk order yang tidak dikenal:", orderId);
    return json({ success: true, message: "Order tidak dikenal, diabaikan." });
  }

  return json({ success: true, status: hasil.status });
});
