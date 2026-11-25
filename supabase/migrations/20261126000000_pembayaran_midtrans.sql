-- ==========================================================
-- COCOKIN: Pembayaran Premium via Midtrans (mode sandbox)
-- Jalankan sekali di SQL Editor dashboard database cloud.
-- Aman dijalankan ulang (idempotent).
-- ==========================================================

-- 1. Masa aktif premium (NULL = selamanya / lifetime)
alter table public.pengguna
  add column if not exists premium_hingga timestamptz;

-- 2. Catatan setiap transaksi pembayaran
create table if not exists public.pembayaran (
  id              bigserial primary key,
  order_id        text        not null unique,
  id_pengguna     bigint      not null references public.pengguna (id_pengguna) on delete cascade,
  paket           text        not null check (paket in ('bulanan', 'lifetime')),
  nominal         integer     not null check (nominal > 0),
  status          text        not null default 'pending'
                  check (status in ('pending', 'lunas', 'gagal', 'kedaluwarsa', 'dibatalkan', 'refund')),
  status_midtrans text,
  metode          text,
  snap_token      text,
  redirect_url    text,
  dibuat_pada     timestamptz not null default now(),
  diperbarui_pada timestamptz not null default now(),
  lunas_pada      timestamptz
);

create index if not exists pembayaran_id_pengguna_idx on public.pembayaran (id_pengguna);

-- 3. Tabel pembayaran hanya boleh disentuh server (service role).
--    RLS aktif tanpa policy = aplikasi (anon) tidak bisa baca/tulis sama sekali.
alter table public.pembayaran enable row level security;
revoke all on public.pembayaran from anon, authenticated;
revoke all on sequence public.pembayaran_id_seq from anon, authenticated;

-- 4. Kunci kolom premium di tabel pengguna.
--    Sebelumnya aplikasi bisa langsung mengubah status_premium = true tanpa bayar.
--    Sekarang hanya server (setelah pembayaran terverifikasi) yang boleh mengubahnya.
--    Aplikasi tetap boleh: membaca, mendaftar (nama/email/password/role), dan reset password.
revoke insert, update on public.pengguna from anon, authenticated;
grant insert (nama, email, password, role) on public.pengguna to anon, authenticated;
grant update (nama, password)             on public.pengguna to anon, authenticated;

-- Catatan: status_premium & premium_hingga otomatis bernilai default (false / NULL)
-- saat pendaftaran, dan hanya diubah oleh fungsi server "notifikasi-midtrans" /
-- "cek-pembayaran" yang memakai service role.
