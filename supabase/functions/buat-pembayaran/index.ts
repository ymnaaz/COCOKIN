// POST /functions/v1/buat-pembayaran
// Body: { "email": "nama@gmail.com", "paket": "bulanan" | "lifetime" }
// Membuat tagihan di Midtrans Snap dan mengembalikan link halaman pembayaran.
// Harga ditentukan di server, bukan dari aplikasi, supaya tidak bisa dimanipulasi.

import {
  admin,
  corsHeaders,
  isNamaPaket,
  json,
  MODE,
  midtransAuthHeader,
  PAKET,
  SERVER_KEY,
  SNAP_URL,
  statusPremium,
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
  const email = typeof body.email === "string"
    ? body.email.trim().toLowerCase()
    : "";
  const paket = body.paket;

  if (!email || !isNamaPaket(paket)) {
    return json({
      success: false,
      message: "Data pembayaran tidak lengkap.",
    }, 400);
  }

  const { data: user, error: userErr } = await admin
    .from("pengguna")
    .select("id_pengguna, nama, email")
    .eq("email", email)
    .maybeSingle();

  if (userErr) console.error("Gagal mencari pengguna:", userErr);
  if (!user) {
    return json({
      success: false,
      message: "Akun tidak ditemukan. Silakan masuk ulang.",
    }, 404);
  }

  const premium = await statusPremium(user.id_pengguna);
  if (premium.premiumAktif && premium.premiumHingga === null) {
    return json({
      success: false,
      message: "Akunmu sudah Premium selamanya.",
    }, 409);
  }

  const info = PAKET[paket];
  // Format order_id: maks 50 karakter, hanya huruf/angka/-/_/.
  const orderId = `COCOKIN-${user.id_pengguna}-${Date.now()}`;

  const { error: insertErr } = await admin.from("pembayaran").insert({
    order_id: orderId,
    id_pengguna: user.id_pengguna,
    paket,
    nominal: info.nominal,
    status: "pending",
  });
  if (insertErr) {
    console.error("Gagal mencatat pembayaran:", insertErr);
    return json({
      success: false,
      message: "Gagal membuat tagihan. Coba lagi.",
    }, 500);
  }

  const snapRes = await fetch(SNAP_URL, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      Authorization: midtransAuthHeader(),
    },
    body: JSON.stringify({
      transaction_details: { order_id: orderId, gross_amount: info.nominal },
      item_details: [{
        id: paket,
        price: info.nominal,
        quantity: 1,
        name: info.nama,
      }],
      customer_details: { first_name: user.nama, email: user.email },
      expiry: { unit: "minutes", duration: 60 },
    }),
  });

  const snap = await snapRes.json().catch(() => ({}));

  if (!snapRes.ok || !snap.redirect_url) {
    console.error("Midtrans menolak pembuatan transaksi:", snapRes.status, snap);
    await admin.from("pembayaran")
      .update({ status: "gagal", diperbarui_pada: new Date().toISOString() })
      .eq("order_id", orderId);
    return json({
      success: false,
      message: "Layanan pembayaran sedang bermasalah. Coba lagi nanti.",
    }, 502);
  }

  await admin.from("pembayaran")
    .update({ snap_token: snap.token, redirect_url: snap.redirect_url })
    .eq("order_id", orderId);

  return json({
    success: true,
    mode: MODE,
    order_id: orderId,
    paket,
    nominal: info.nominal,
    snap_token: snap.token,
    redirect_url: snap.redirect_url,
  });
});
