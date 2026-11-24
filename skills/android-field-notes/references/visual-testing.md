# Visual testing: Roborazzi / Robolectric

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## Setup yang terbukti jalan
- Plugin `io.github.takahirom.roborazzi` 1.46.1, `org.robolectric:robolectric` 4.14.1, `androidx.test:core` 1.5.0.
- `testOptions.unitTests.includeAndroidResources = true`
- System property `robolectric.graphicsMode=NATIVE`
- Golden di `src/test/roborazzi_golden/`
- Run pertama harus online (`--offline` gagal kalau dependency test belum ada di cache).
- Paparazzi pernah **gagal** di AGP 8.6 (API drift + Jetifier crash). Roborazzi jalan.

## Pola verifikasi port: golden Compose vs render XML
Render komponen **asli** (Compose) sebagai golden PNG, render port XML, lalu banding pixel. Pola ini menangkap bug warna, gradient-vs-solid, spacing, dan font padding yang lolos audit statik.
- Compare bawaan Roborazzi menolak keras beda ukuran ±1px. Solusinya: capture manual (`view.draw(Canvas(bitmap))`) + comparator yang meng-crop area overlap dengan toleransi. Kalibrasi dari data noise: threshold ratio 0.02, slack 2px.
- **Bisa di-golden:** komponen stateless yang menerima `state` (tanpa VM/LaunchedEffect), termasuk layar penuh, dengan fixture state.
- **Tidak bisa di-golden (serahkan ke QA device):** form full-screen stateful yang reveal-nya diatur imperatif saat runtime, WebView, animasi (shimmer).
- "Dihost komponen yang sama, jadi 1:1 by construction" **bukan** alasan untuk skip golden. Tetap buktikan dengan pixel.

## Host ComposeView di Robolectric (render View → PNG)
1. `testImplementation` `androidx.activity:activity-compose`.
2. Buat owner test yang mengimplementasikan `LifecycleOwner` + `SavedStateRegistryOwner` + `OnBackPressedDispatcherOwner`. Panggil `performRestore(null)` saat state INITIALIZED, **baru** pindah ke RESUMED. Kalau urutannya terbalik: "Restarter must be created during init".
3. `setViewTreeLifecycleOwner` / `setViewTreeSavedStateRegistryOwner` di **container FrameLayout** (recomposer berjalan naik ke ancestor) **dan** di ComposeView.
4. `addView` sebelum measure. Kalau tidak: "Cannot locate windowRecomposer".
5. `CompositionLocalProvider(LocalOnBackPressedDispatcherOwner provides owner)` kalau screen memakai `BackHandler`.
6. `shadowOf(Looper.getMainLooper()).idle()` untuk flush composition.

## Pola test layout matriks
Inflate layout di N ukuran layar × M rasio konten, lalu assert:
(a) elemen penting berada di dalam viewport, (b) rasio kotak gambar tidak melenceng lebih dari 5% dari rasio drawable, (c) cap ukuran dipatuhi.
Uji mutasi setiap bagian fix (rantai putus, `constrainedHeight=false`, cap dibuang, layout lama). Semuanya harus FAILED, baseline harus PASS.

## Golden di luar repo
Kalau golden sengaja tidak di-commit (disimpan di tempat lain):
- **Wajib restore sebelum `verify`.** Tanpa baseline, semua capture dilaporkan `added` dan lolos tanpa membandingkan apa pun.
- Golden baru harus didaftarkan ke script sync. Kalau tidak, file itu hilang diam-diam saat restore berikutnya.
- macOS TCC memblokir Gradle daemon membaca `~/Library/Mobile Documents` (iCloud): "does not exist and cannot be created". Penyebabnya lokasi, bukan spasi di path. Solusinya: script copy, atau beri Full Disk Access ke Java/Android Studio.
- Konsekuensinya: hanya mesin itu yang punya baseline; CI/mesin lain lolos kosong.
