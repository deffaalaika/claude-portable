# Android UI (View/XML, Material, back handling)

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## View & Material gotchas
1. **`android:maxHeight` di RecyclerView = NO-OP.** Atributnya diabaikan diam-diam, jadi sheet setinggi konten penuh. Batasi di runtime: `viewTreeObserver.addOnPreDrawListener { if (height > cap) layoutParams.height = cap; true }`.
2. **`MaterialCardView` yang clickable** tanpa `app:rippleColor` memakai `?attr/colorControlHighlight` dari tema. Dengan tema default hasilnya ripple ungu `#6200EE`. Set `app:rippleColor` secara eksplisit.
3. **`MaterialButton` meng-override tint** sehingga warna background ikut tema (ungu). Untuk tombol custom, pakai `AppCompatButton` atau set `app:backgroundTint="@null"`.
4. `LinearLayout` clickable tanpa background tidak punya ripple.
5. Spinner `ProgressBar` default ≠ loading custom app. Cari dialog loading existing di design system dulu.

## ConstraintLayout: tombol terdorong keluar layar
Kasus nyata: popup gambar + CTA + tombol close. Dilaporkan "hanya di foldable", padahal setelah diuji matriks 7 ukuran × 3 rasio hasilnya **10 dari 21 kasus kepotong**, termasuk HP kecil, tablet, dan landscape.
- **Root cause:** gambar di-center ke parent (top+bottom), sedangkan CTA/close hanya dijangkar di ATAS. View tanpa jangkar bawah tidak masuk perhitungan tinggi, jadi posisinya = tengah layar + tinggi gambar/2 + margin. Gambar membesar, tombol keluar layar.
- **Fix:** rantai vertikal penuh parent → image → CTA → close → parent dengan `layout_constraintVertical_chainStyle="packed"`. Gambar `wrap_content` + `adjustViewBounds="true"` + `maxWidth` dalam **dp** + `layout_constrainedHeight="true"`. Ukuran chrome pakai dp tetap. `fitsSystemWindows="true"`.
- **Jebakan:** `layout_height="0dp"` pada gambar membuat ConstraintLayout yang menentukan tinggi, sehingga **`adjustViewBounds` mati** dan gambar diregangkan, rasio diabaikan. Test clipping tetap hijau. Ketahuan hanya setelah mencetak `width x height` per rasio dan melihat semuanya identik.
- **Cap berbasis `sdp`/`ssp` tidak pernah mengikat**, karena nilainya ikut membesar bersama smallest-width (mis. `_320sdp` = 384dp di sw360). Untuk batas maksimum, pakai `dp` murni.
- `adjustViewBounds` + `wrap_content` tidak pernah memperbesar gambar melebihi `intrinsicWidth`. Di test, drawable stub harus **lebih besar dari window manapun** (mis. 2000px). Kalau tidak, mutasi "buang maxWidth" lolos palsu.

## OnBackPressedDispatcher: urutan ≠ urutan baris
- `addCallback(owner, cb)` dibungkus lifecycle: baru masuk antrian saat **`ON_START`**, dicabut saat `ON_STOP`, lalu didaftar ulang ke **puncak** di setiap `ON_START` berikutnya.
- `addCallback(cb)` tanpa owner langsung masuk antrian saat dipanggil.
- Kombinasi base Activity pakai owner + layar anak tanpa owner di `onCreate` → **base selalu menang (LIFO)**, walaupun anak mendaftar setelah `super.onCreate()`. Gejalanya: tombol back memunculkan dialog keluar app, bukan aksi layar.
- Saat audit, kelompokkan `addCallback` menjadi ber-owner vs tanpa owner. Anak tanpa owner yang base-nya ber-owner harus menonaktifkan handler base. Anak dan base yang sama-sama ber-owner aman.
- Pola back-handling sering lolos analisis statis. Verifikasi di device atau di test lifecycle.

## Port Compose → XML (biar pixel-match)
- `includeFontPadding="false"` di **semua** TextView.
- Compose `Modifier.padding(16).background()` = inset 16 **di luar** background. Di XML: padding outer transparan + child dalam yang ber-background.
- `IconButton` Compose = box 48dp. `CenterAlignedTopAppBar` = tinggi tetap 64dp.
- Komponen di luar `Column.padding` (mis. tombol di `Box` bawah) = full width tanpa margin.
- Background full-screen bisa berupa drawable gradient, bukan warna flat. Cek dulu; kalau salah, seluruh layar beda.
- `LazyColumn(contentPadding)` → RecyclerView butuh `clipToPadding="false"` + padding.
- Warna/gradient: **probe pixel dari golden**, jangan menebak dari membaca kode. Kode tema light/dark mudah salah dibaca.
- Cek string di **semua** locale (`values`, `values-in`, ...). Ada label yang sengaja tidak diterjemahkan.

## WebView
Di Robolectric, WebView render async/blank, jadi tidak bisa di-golden. Verifikasi di device.
