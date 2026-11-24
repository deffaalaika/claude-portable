---
name: android-field-notes
description: Catatan lapangan Android/Kotlin/Gradle dari project sebelumnya (app multi-repo, host app + feature module AAR), dipakai sebagai PANDUAN, bukan patokan benar/salah. Rujuk saat kerja Android - publish/konsumsi AAR atau SNAPSHOT, Gradle dependency/flavor/force resolution, ubah API publik Kotlin yang dipanggil Java atau modul lain, layout View/ConstraintLayout/RecyclerView/Material, OnBackPressedDispatcher, resource merge/string aneh di layar, Roborazzi/Robolectric screenshot test, verifikasi APK/AAR/DEX, porting Compose ke XML, atau sebelum mengklaim test/gate lolos.
---

# Android field notes

## Status catatan ini: panduan, bukan kiblat
Catatan ini berasal dari **codebase lain**, dengan struktur, konvensi, tooling, dan proses tim yang berbeda dari project sekarang. Perlakukan isinya sebagai **heuristik: hal yang layak dicek**, bukan aturan yang menentukan benar/salah.

Urutan prioritas saat ada konflik:
1. Instruksi user dan keputusan tim project sekarang
2. Konvensi yang terlihat di codebase sekarang (README, CLAUDE.md repo, pola kode yang dominan, CI)
3. Catatan ini

Cara pakai:
- **Verifikasi dulu sebelum menerapkan.** Cek apakah situasinya memang sama di project ini (arsitektur, cara konsumsi modul, versi library, tooling test). Kalau tidak sama, abaikan.
- **Jangan memaksakan pola lama.** Kalau project ini punya cara sendiri (mis. monorepo, bukan AAR; tidak pakai Roborazzi; alur publish lain), ikuti cara project ini.
- **Versi yang disebut** (Roborazzi, Robolectric, AGP, Compose, androidx.activity) adalah versi saat kejadian. Perilakunya bisa berbeda di versi lain, jadi cek ulang.
- Kalau catatan ini bertentangan dengan apa yang terlihat di kode, **kode yang menang**. Laporkan perbedaannya ke user, jangan diam-diam "membetulkan" kode supaya cocok dengan catatan.
- Bagian "kasus nyata" adalah ilustrasi kenapa sebuah cek berguna, bukan bukti bahwa masalah yang sama pasti ada di sini.

Yang paling bisa dibawa lintas project adalah **fakta platform** (perilaku Android/Gradle/Kotlin/AGP) dan **disiplin verifikasi**. Yang paling mungkin tidak berlaku adalah **proses** (alur publish, aturan golden, gate bertahap), karena itu kebiasaan tim lama.

## Benang merah
> Source dan "hijau" belum tentu kebenaran. Artefak jadi (APK/AAR/DEX/pixel) sering yang menentukan.
> Hasil nol/hijau tanpa kontrol positif belum membuktikan apa-apa.

## Reference
| Situasi | File |
|---|---|
| Mau mengklaim test/gate lolos, audit parity, menilai regresi | `references/verification.md` |
| Publish/konsumsi AAR, SNAPSHOT, versi, flavor, resource ketimpa | `references/gradle-artifacts.md` |
| Ubah signature publik Kotlin (interface, default param, dipanggil Java) | `references/kotlin-java-abi.md` |
| Layout View/XML, ConstraintLayout, RecyclerView, Material, back handling | `references/android-ui.md` |
| Roborazzi/Robolectric, golden, visual diff Compose vs XML | `references/visual-testing.md` |
| git grep lintas branch, merge trunk, jebakan shell | `references/git-shell.md` |

## Hal yang layak dicurigai
- Teks di layar beda dari source → coba baca APK (`aapt2 dump resources`), jangan berhenti di source.
- Build gagal tapi AAR ada → kemungkinan AAR basi. Build ulang bersih, lalu periksa isinya.
- Menambah default param di interface Kotlin yang dikonsumsi biner modul lain → risiko `NoSuchMethodError`.
- `grep` bilang 0 → cek dulu branch yang sedang ter-checkout.
- State UI baru tanpa snapshot/assert isi → test hijau belum membuktikan apa-apa.
- Parameter input diubah tapi hasil ukur tidak berubah → curigai input itu tidak terpakai.
