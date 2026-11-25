// Logika bersama untuk integrasi Midtrans (Snap + Core API status).
// Semua kunci rahasia dibaca dari environment variable / secrets server,
// TIDAK PERNAH ditaruh di kode aplikasi Flutter.

import { createClient } from "npm:@supabase/supabase-js@2";

// ---------- Konfigurasi ----------

export const PAKET = {
  bulanan: { nominal: 19000, nama: "Cocokin Premium Bulanan", hari: 30 },
  lifetime: { nominal: 49000, nama: "Cocokin Premium Lifetime", hari: null },
} as const;

export type NamaPaket = keyof typeof PAKET;

export function isNamaPaket(v: unknown): v is NamaPaket {
  return typeof v === "string" && v in PAKET;
}

export const SERVER_KEY = Deno.env.get("MIDTRANS_SERVER_KEY") ?? "";
const IS_PRODUCTION = Deno.env.get("MIDTRANS_IS_PRODUCTION") === "true";

export const SNAP_URL = IS_PRODUCTION
  ? "https://app.midtrans.com/snap/v1/transactions"
  : "https://app.sandbox.midtrans.com/snap/v1/transactions";

const CORE_API_URL = IS_PRODUCTION
  ? "https://api.midtrans.com"
  : "https://api.sandbox.midtrans.com";

export const MODE = IS_PRODUCTION ? "production" : "sandbox";

export function midtransAuthHeader(): string {
  // Midtrans: Basic Auth dengan server key sebagai username dan password kosong.
  return "Basic " + btoa(`${SERVER_KEY}:`);
}

// Klien database dengan service role (otomatis tersedia di Edge Functions).
export const admin = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  { auth: { persistSession: false } },
);

// ---------- Utilitas HTTP ----------

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// ---------- Status Midtrans ----------

export type StatusPembayaran =
  | "pending"
  | "lunas"
  | "gagal"
  | "kedaluwarsa"
  | "dibatalkan"
  | "refund";

export interface DataMidtrans {
  order_id?: string;
  status_code?: string;
  gross_amount?: string;
  transaction_status?: string;
  fraud_status?: string;
  payment_type?: string;
  signature_key?: string;
}

/** Terjemahkan transaction_status Midtrans ke status internal Cocokin. */
export function petakanStatus(d: DataMidtrans): StatusPembayaran {
  switch (d.transaction_status) {
    case "capture":
      // Khusus kartu kredit: hanya "accept" yang dianggap lunas.
      if (d.fraud_status === "accept") return "lunas";
      if (d.fraud_status === "deny") return "gagal";
      return "pending";
    case "settlement":
      return "lunas";
    case "deny":
    case "failure":
      return "gagal";
    case "cancel":
      return "dibatalkan";
    case "expire":
      return "kedaluwarsa";
    case "refund":
    case "partial_refund":
    case "chargeback":
    case "partial_chargeback":
      return "refund";
    default:
      return "pending";
  }
}

/** Verifikasi signature notifikasi: SHA512(order_id + status_code + gross_amount + server_key). */
export async function signatureValid(d: DataMidtrans): Promise<boolean> {
  if (!d.order_id || !d.status_code || !d.gross_amount || !d.signature_key) {
    return false;
  }
  const raw = d.order_id + d.status_code + d.gross_amount + SERVER_KEY;
  const hash = await crypto.subtle.digest(
    "SHA-512",
    new TextEncoder().encode(raw),
  );
  const hex = Array.from(new Uint8Array(hash))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
  return hex === d.signature_key;
}

/** Tanya langsung ke Midtrans status terbaru suatu order (sumber kebenaran). */
export async function ambilStatusMidtrans(
  orderId: string,
): Promise<DataMidtrans | null> {
  const res = await fetch(
    `${CORE_API_URL}/v2/${encodeURIComponent(orderId)}/status`,
    {
      headers: {
        Accept: "application/json",
        Authorization: midtransAuthHeader(),
      },
    },
  );
  const data = (await res.json().catch(() => null)) as DataMidtrans | null;
  // status_code "404" = pengguna belum memilih metode bayar di halaman Snap.
  if (!data || data.status_code === "404") return null;
  return data;
}

// ---------- Penerapan status ke database ----------

export interface HasilPenerapan {
  ditemukan: boolean;
  status: StatusPembayaran;
  premiumAktif: boolean;
  premiumHingga: string | null;
}

/**
 * Simpan status terbaru sebuah order dan, jika baru saja lunas,
 * aktifkan premium pengguna. Aman dipanggil berulang kali (idempotent):
 * premium hanya diperpanjang satu kali per order.
 */
export async function terapkanStatus(
  orderId: string,
  d: DataMidtrans | null,
): Promise<HasilPenerapan> {
  const { data: bayar } = await admin
    .from("pembayaran")
    .select("order_id, id_pengguna, paket, nominal, status")
    .eq("order_id", orderId)
    .maybeSingle();

  if (!bayar) {
    return {
      ditemukan: false,
      status: "pending",
      premiumAktif: false,
      premiumHingga: null,
    };
  }

  let status: StatusPembayaran = d ? petakanStatus(d) : "pending";

  // Tolak jika nominal yang dibayar tidak sama dengan tagihan.
  if (
    status === "lunas" &&
    d?.gross_amount !== undefined &&
    Math.round(Number(d.gross_amount)) !== bayar.nominal
  ) {
    console.error(
      `Nominal tidak cocok untuk ${orderId}: ${d.gross_amount} vs ${bayar.nominal}`,
    );
    status = "gagal";
  }

  const sekarang = new Date().toISOString();

  if (status === "lunas") {
    // Update bersyarat: hanya satu pemanggilan yang berhasil mengubah ke "lunas".
    const { data: baruLunas } = await admin
      .from("pembayaran")
      .update({
        status: "lunas",
        status_midtrans: d?.transaction_status ?? null,
        metode: d?.payment_type ?? null,
        lunas_pada: sekarang,
        diperbarui_pada: sekarang,
      })
      .eq("order_id", orderId)
      .neq("status", "lunas")
      .select("order_id");

    if (baruLunas && baruLunas.length > 0) {
      await aktifkanPremium(bayar.id_pengguna, bayar.paket as NamaPaket);
    }
  } else if (bayar.status !== "lunas") {
    // Jangan menimpa order yang sudah lunas dengan status lain (kecuali refund dicatat).
    await admin
      .from("pembayaran")
      .update({
        status,
        status_midtrans: d?.transaction_status ?? null,
        metode: d?.payment_type ?? null,
        diperbarui_pada: sekarang,
      })
      .eq("order_id", orderId);
  } else if (status === "refund") {
    await admin
      .from("pembayaran")
      .update({
        status: "refund",
        status_midtrans: d?.transaction_status ?? null,
        diperbarui_pada: sekarang,
      })
      .eq("order_id", orderId);
  }

  const premium = await statusPremium(bayar.id_pengguna);
  return {
    ditemukan: true,
    status: bayar.status === "lunas" && status !== "refund" ? "lunas" : status,
    ...premium,
  };
}

async function aktifkanPremium(idPengguna: number, paket: NamaPaket) {
  const { data: user } = await admin
    .from("pengguna")
    .select("status_premium, premium_hingga")
    .eq("id_pengguna", idPengguna)
    .maybeSingle();

  const sudahLifetime = user?.status_premium === true &&
    user?.premium_hingga === null;

  let premiumHingga: string | null = null;
  if (paket === "bulanan" && !sudahLifetime) {
    // Perpanjang dari masa aktif yang masih berjalan, atau mulai dari sekarang.
    const sisa = user?.premium_hingga ? new Date(user.premium_hingga) : null;
    const dasar = sisa && sisa > new Date() ? sisa : new Date();
    dasar.setDate(dasar.getDate() + (PAKET.bulanan.hari ?? 30));
    premiumHingga = dasar.toISOString();
  }

  const { error } = await admin
    .from("pengguna")
    .update({ status_premium: true, premium_hingga: premiumHingga })
    .eq("id_pengguna", idPengguna);

  if (error) console.error("Gagal mengaktifkan premium:", error);
}

export async function statusPremium(
  idPengguna: number,
): Promise<{ premiumAktif: boolean; premiumHingga: string | null }> {
  const { data: user } = await admin
    .from("pengguna")
    .select("status_premium, premium_hingga")
    .eq("id_pengguna", idPengguna)
    .maybeSingle();

  const hingga = (user?.premium_hingga as string | null) ?? null;
  const aktif = user?.status_premium === true &&
    (hingga === null || new Date(hingga) > new Date());
  return { premiumAktif: aktif, premiumHingga: hingga };
}
