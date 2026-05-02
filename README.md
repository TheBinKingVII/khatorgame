# Khatorgame 🎮

Khatorgame adalah sebuah aplikasi berbasis Flutter yang dikembangkan untuk memenuhi tugas mata kuliah Teknologi dan Pemrograman Mobile. Aplikasi ini menyediakan berbagai fitur menarik seperti pencarian diskon game, radar warnet terdekat, asisten chatbot AI (Khator AI), hingga minigames interaktif.

## Identitas Kelompok 👥
Proyek ini dikembangkan oleh:
- **Khatama Putra** (NIM: 123230053)
- **Bintoro** (NIM: 123230059)

**Mata Kuliah**: Teknologi dan Pemrograman Mobile  
**Dosen Pengampu**: Bagus Muhammad Akbar

---

## Struktur Folder 📂

Aplikasi ini menggunakan struktur folder berbasis fitur (*feature-based architecture*) agar kode tetap modular, rapi, dan mudah dipelihara.

```text
khatorgame/
├── lib/
│   ├── core/           # Utility, theme, konstanta, widget global, validator, dan routing
│   ├── features/       # Modul-modul utama aplikasi
│   │   ├── auth/         # Fitur Autentikasi (Login, Register)
│   │   ├── chatbot/      # Fitur Chatbot berbasis AI (Khator AI)
│   │   ├── deals/        # Fitur informasi penawaran dan diskon game
│   │   ├── internetcafe/ # Fitur Radar Warnet dengan peta LBS (Location-Based Service)
│   │   ├── minigames/    # Kumpulan mini-games hiburan
│   │   ├── profile/      # Fitur profil dan manajemen akun pengguna
│   │   └── wishlist/     # Fitur menyimpan game impian
│   ├── screens/        # UI Page/Screen umum seperti Home atau Navigation
│   └── main.dart       # Entry point utama aplikasi
├── assets/             # Kumpulan gambar, icon, atau font lokal
├── .env                # (Perlu Dibuat) Environment variables untuk API Keys
├── pubspec.yaml        # Daftar dependensi package Flutter
└── README.md           # Dokumentasi informasi proyek
```

---

## Cara Menjalankan Aplikasi 🚀

Pastikan Anda sudah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install) pada sistem komputer Anda dan sebuah *emulator* atau perangkat fisik (*physical device*) Android/iOS sudah menyala dan terhubung.

### 1. Dapatkan Source Code
Buka terminal dan arahkan ke dalam folder proyek ini.
```bash
cd khatorgame
```

### 2. Unduh Semua Dependensi
Ambil package dan pustaka yang dibutuhkan menggunakan *Flutter pub get*:
```bash
flutter pub get
```

### 3. Siapkan Environment Variables (`.env`)
Karena project ini menggunakan kunci API seperti Supabase atau API eksternal (Gemini dll), Anda wajib memiliki file `.env` di direktori terluar proyek (sejajar dengan `pubspec.yaml`).
Buat file bernama `.env` dan masukkan API keys Anda:
```env
# Contoh isi file .env:
SUPABASE_URL="isi_dengan_url_supabase_anda"
SUPABASE_ANON_KEY="isi_dengan_anon_key_supabase_anda"
GEMINI_API_KEY="isi_dengan_api_key_gemini_anda"
# Tambahkan key lain jika dibutuhkan...
```

### 4. Menjalankan Aplikasi
Pilih device yang tersedia, kemudian ketik perintah berikut pada terminal:
```bash
flutter run
```
Aplikasi akan dikompilasi dan diluncurkan ke perangkat atau emulator Anda. Selamat mencoba! 🎉

---

## Setup Database (Supabase) 🗄️

Untuk memastikan seluruh fungsionalitas aplikasi (seperti autentikasi, profil, wishlist, dan voucher) berjalan dengan baik, Anda perlu membuat tabel-tabel berikut di dalam project Supabase Anda. 

Jalankan perintah SQL berikut di **SQL Editor** Supabase:

```sql
-- 1. Buat tabel users terlebih dahulu
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL UNIQUE,
  username text UNIQUE,
  full_name text,
  password_hash text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- 2. Buat tabel profiles
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL DEFAULT ''::text,
  full_name text NOT NULL DEFAULT ''::text,
  avatar_url text NOT NULL DEFAULT ''::text,
  currency_code text NOT NULL DEFAULT 'USD'::text,
  notifications_enabled boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES public.users(id)
);

-- 3. Buat tabel vouchers
CREATE TABLE public.vouchers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code text NOT NULL,
  nominal integer NOT NULL DEFAULT 0,
  user_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vouchers_pkey PRIMARY KEY (id),
  CONSTRAINT vouchers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- 4. Buat tabel wishlists
CREATE TABLE public.wishlists (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  deal_id text NOT NULL,
  title text NOT NULL,
  price text NOT NULL,
  image_url text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  store_id text,
  store_name text,
  CONSTRAINT wishlists_pkey PRIMARY KEY (id),
  CONSTRAINT wishlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```
