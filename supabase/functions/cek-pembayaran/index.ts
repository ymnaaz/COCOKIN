// POST /functions/v1/cek-pembayaran
// Body: { "order_id": "COCOKIN-12-1764100000000" }
// Dipanggil aplikasi setelah pengguna kembali dari halaman pembayaran.
// Server menanyakan status langsung ke Midtrans (bukan percaya ke aplikasi),
// lalu mengaktifkan premium jika sudah lunas.

import {
  ambilStatusMidtrans,
  corsHeaders,
  json,
  SERVER_KEY,
  terapkanStatus,
} from "../_shared/midtrans.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ success: false, message: "Metode tidak didukung." }, 405);
  }
  if (!SERVER_KEY) {
    return json({
      success: false,
      message: "Server pembayaran belum dikonfigurasi.",
    }, 500);
  }

  const body = await req.json().catch(() => ({}));
  const orderId = typeof body.order_id === "string" ? body.order_id : "";
  if (!orderId) {
    return json({ success: false, message: "order_id wajib diisi." }, 400);
  }

  const dataMidtrans = await ambilStatusMidtrans(orderId);
  const hasil = await terapkanStatus(orderId, dataMidtrans);

  if (!hasil.ditemukan) {
    return json({ success: false, message: "Tagihan tidak ditemukan." }, 404);
  }

  return json({
    success: true,
    order_id: orderId,
    status: hasil.status,
    premium_aktif: hasil.premiumAktif,
    premium_hingga: hasil.premiumHingga,
  });
});
