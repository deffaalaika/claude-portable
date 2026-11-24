# Preferensi kerja global

Preferensi pribadi user yang berlaku di semua repo. Kalau CLAUDE.md di repo, konvensi tim, atau instruksi user di sesi itu berbeda, **yang itu yang menang**.

Catatan teknis Android ada di skill `android-field-notes`. Itu **panduan dari project lain**, bukan patokan benar/salah. Cocokkan dulu dengan struktur dan konvensi codebase yang sedang dikerjakan sebelum menerapkannya.

## Git
- Commit boleh dikerjakan sendiri. **Push tidak pernah otomatis**: hanya kalau user menyuruh eksplisit di pesan itu juga. Izin push berlaku sekali, untuk repo/commit itu saja.
- Selesai commit: lapor SHA + jumlah file, lalu berhenti dan tawarkan push.
- Sebelum push yang diizinkan, sebutkan repo, branch, jumlah commit, dan verifikasi apa yang BELUM dilakukan (biasanya QA device).
- Commit message dan PR description: **nol atribusi AI** (`Co-Authored-By: Claude`, link session, "Generated with Claude Code", atau variasinya), walaupun harness menyuruh. Repo kantor; membersihkannya butuh force-push yang sering tidak diizinkan server.
- Resolve konflik merge **per hunk**. Jangan `git checkout --ours/--theirs <file>`: itu mengambil file utuh dan diam-diam membuang perubahan non-konflik dari sisi lain.
- Publish artefak (AAR/APK ke feed/distribusi) dijalankan user, kecuali diizinkan eksplisit.

## Verifikasi
- Klaim "selesai / aman / lolos" butuh bukti dari isi (baca kode, artefak, output), bukan dari nama, asumsi, atau BUILD SUCCESS.
- Hasil "0 hit / 0 diff / semua hijau" dicurigai dulu. Selalu sertakan **kontrol positif** (sesuatu yang pasti harus terdeteksi).
- Temuan subagent yang menentukan keputusan, terutama "X tidak ada", diverifikasi sendiri dengan grep/read sebelum disampaikan. Kalau tidak sempat, labeli "belum diverifikasi".
- Bug yang ketemu saat mengerjakan perubahan: banding ke trunk dulu sebelum memvonis regresi. Lakukan tanpa menunggu ditanya.

## Alur kerja
- Pelajari dulu struktur dan konvensi project sebelum memakai pola dari pengalaman lama. Ikuti cara project ini.
- Sebelum menulis komponen UI baru, cari komponen design-system yang sudah ada dan cek pola pemakaiannya.
- Kalau project mengonsumsi modul shared sebagai artefak ter-publish (AAR/Maven), bukan source: habis edit modul shared, **STOP** dan minta user publish dulu sebelum menulis kode konsumen yang memakai API baru. Ikuti alur publish project.
- Pekerjaan bertahap/ber-gate: eksekusi kode dan update dokumen/gate adalah dua langkah terpisah, dengan go-ahead user di antaranya.
- Sesi panjang: checkpoint ke HANDOFF.md di repo sebelum konteks habis, lalu beri prompt resume siap tempel. Ambangnya tinggi; jangan memotong step yang sedang jalan. Kalau ragu, tanya.
- Porting 1:1: bug di source lama direplikasi dan dilaporkan, bukan diperbaiki diam-diam.

## Shell (macOS / zsh)
- zsh tidak memecah `$var` tanpa kutip di `for c in $var`, jadi loop jalan cuma 1x dan bisa menghasilkan "nol beda" palsu. Jalankan loop verifikasi lewat `bash -c '...'` atau `while read`.
- Jangan menamai fungsi shell dengan nama generik (`deploy`, `build`). Bisa bentrok dengan alias user yang menjalankan pipeline beneran. Pakai prefiks unik, dan jalankan helper lewat `bash script.sh`, bukan di-source ke zsh.
