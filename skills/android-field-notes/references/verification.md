# Disiplin verifikasi

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## Kontrol positif
Setiap pengecekan "nol" (grep 0 hit, diff kosong, 0 field beda, `unchanged: N`) harus punya kontrol positif: sesuatu yang **pasti** berubah atau ada harus ikut terdeteksi. Kalau kontrol positif tidak tertangkap, yang salah adalah polanya, bukan buktinya yang bersih.

Script audit yang melaporkan "0 field / 0 diff / semua identik" biasanya extractor-nya gagal diam-diam. Contoh di macOS: BSD awk tidak punya `match()` 3-argumen. Pakai `perl -ne`, cetak jumlahnya, dan isolasi satu data class per kali kalau satu file `.kt` berisi beberapa class.

## Golden yang hilang = gate palsu
- State UI yang tidak punya golden tidak akan pernah gagal, dan hasilnya terbaca persis seperti "semua hijau". Kasus nyata: komponen diganti total, 10 golden lama tetap `unchanged`; dua bug lolos 72 test dan baru ketahuan dari screenshot device.
- `assertExists()` hanya membuktikan node ada, bukan isinya benar. Teks yang beda per locale butuh golden per locale + `assertTextEquals(...)`.
- Jalankan `verify` **sebelum** `record`, supaya perubahan terlihat sebagai `changed`/`added`.
- Uji mutasi: rusak sengaja, pastikan FAILED, lalu kembalikan.
- Kalau mengubah parameter input (mis. rasio gambar) tidak mengubah hasil ukur sama sekali, input itu tidak terpakai. Itu bukan tanda layout-nya kokoh.

## Keputusan dibuktikan dari isi, bukan nama
- Inventaris (jumlah endpoint, event) biasanya dikerjakan teliti. Yang sering meleset justru **keputusan implementasi** yang "diverifikasi lewat nama", mis. "client Retrofit sama karena nama konfigurasinya sama", padahal interceptor-nya beda 4 header + signature. Untuk client/header/serializer/signature/path: baca body interceptor/serializer dan diff header per header.
- Telusuri request sampai lapisan datasource. Kasus nyata: port hanya meniru konfigurasi HTTP client, tidak men-trace header auth yang ditambahkan per-request di lapisan datasource, dan **semua** API jadi 401 di runtime walau semua gate statik lulus.
- Kotlin computed `val` (getter) bukan wire field. Di diff terlihat "ekstra", tapi di-port sebagai getter, bukan field ter-serialisasi.
- **Nilai wire enum:** kotlinx.serialization meng-serialisasi enum dengan **nama konstanta**, kecuali ada `@SerialName` atau serializer custom. Field `.type`/kode lain bukan nilai wire. Buktikan lewat serializer dan konfigurasi `Json` client, lalu kunci dengan round-trip test yang meng-assert string literal di wire.
- Ktor/kotlinx `encodeDefaults` default-nya `false`: properti yang bernilai default (mis. `= null`) tidak ikut ke body.

## Regresi atau existing?
Bug yang ketemu **saat** mengerjakan perubahan belum tentu **disebabkan** perubahan itu.
```bash
git -C <repo> diff origin/<trunk> origin/<branch-kerja> -- <file>     # kosong = existing
git log -1 --format="%h %ad %an" --date=short origin/<trunk> -- <file>  # umur kode
```
- Kasus nyata: satu gejala = 4 bug bertumpuk, 3 di antaranya existing. Perbaiki yang regresi saja, dan catat sisanya sebagai existing + siapa yang harus memutuskan.
- Diff yang ada tapi tidak menyentuh logika bug ≠ regresi.
- Diff kosong menutup kasus untuk **perubahan kode**, bukan untuk perubahan lingkungan (versi library, urutan callback, resource transitif).
- Build gagal → `git stash` → build → bandingkan. Gagal identik tanpa perubahan sendiri = pre-existing.

## Klaim pihak kedua
- Laporan subagent adalah sumber sekunder. Klaim "X tidak ada" paling gampang salah (keyword/direktori salah) dan paling menentukan keputusan. Grep sendiri dulu.
- Dokumen/handoff bilang ada X titik tapi grep bilang 0 → curigai bacaan sendiri dulu (branch salah?), jangan langsung menyimpulkan dokumennya salah.
- Handoff mencatat status per tanggal update. Cek ulang dengan git sebelum mengandalkan angkanya.
- Audit ulang (deep verify): re-grep tiap file sendiri. Verifikasi sesi lalu bisa salah baca juga (mis. salah palette light/dark).

## Porting / migrasi 1:1
- Build hijau + test hijau bukan bukti parity. Guard kecil yang jauh dari logika utama (mis. `len < 3` sebelum submit) bisa hilang dan semua test tetap hijau. Yang menangkapnya: baca berdampingan source vs port, cabang per cabang.
- Kalau eksekusi dikerjakan model lebih kecil, langkah review side-by-side wajib di model terkuat dan tidak boleh formalitas.
- Bug di source lama direplikasi 1:1 (dan di-assert test eksplisit), lalu dilaporkan, bukan diperbaiki diam-diam.
- Kalau QA device tertunda (blocker eksternal), verifikasi statik harus lebih dalam dan visual-diff jadi default tanpa perlu disuruh.

## Gate integrasi
Test hijau ≠ siap rilis. Gate integrasi yang benar: build APK → cek isi DEX (signature call site) → cek dependency resolution (`dependencyInsight`, panah `a -> b`).
