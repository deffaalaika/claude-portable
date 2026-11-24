# Kotlin ↔ Java dan kompatibilitas biner

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## Default param di interface Kotlin = binary-incompatible
Menambah param ber-default di method **interface** Kotlin itu source-compatible tapi **binary-incompatible**. Tidak ada bridge method lama: `invoke(String)` hilang dari ABI, yang tersisa hanya `invoke(String,String,String)` + `invoke$default(...)`. Modul konsumen yang AAR-nya di-compile sebelum perubahan tetap memanggil `invoke(String)`, lalu **`NoSuchMethodError` di runtime**, walaupun kode konsumen itu tidak disentuh sama sekali.

Aturan:
- Ganti signature publik → republish semua konsumen (lihat `gradle-artifacts.md`).
- Lebih aman: tambahkan overload baru dan biarkan yang lama tetap ada (deprecated).

## Default param tidak menolong pemanggil Java
Java memanggil constructor/method Kotlin secara **posisional penuh** dan tidak membaca default.
- Menambah param di **tengah** → argumen Java bergeser/tertukar → error, atau lebih buruk lagi, tipe kebetulan cocok.
- Menambah di **akhir** → Java butuh N+1 argumen → compile error, kecuali ada `@JvmOverloads`.

Langkah sebelum mengubah signature komponen shared:
1. `grep -rln 'NamaKelas'` di seluruh workspace, lalu pisahkan `.java` dan `.kt`.
2. Param baru di posisi **paling akhir** + default + `@JvmOverloads` di constructor/fun, supaya overload arity lama ikut ter-generate.
3. Mengedit komponen shared existing → tanya user dulu, lalu publish.
4. Opsi nol-risiko: buat pembungkus lokal di modul konsumen.

## Lain-lain
- Kotlin `const val` tidak meng-generate getter. Kode Java yang memanggil `getXxx()` untuk const tidak bisa compile; akses sebagai field statis.
- `runBlocking` di jalur UI (mis. helper "async lalu return") adalah smell. Catat, tapi jangan ubah diam-diam kalau tugasnya porting 1:1.
