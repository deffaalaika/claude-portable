# claude-portable

Preferensi kerja dan catatan lapangan Android untuk Claude Code, dikumpulkan dari pengalaman project sebelumnya.

## Sifatnya: panduan, bukan kiblat
Isi repo ini adalah **guidance**: daftar hal yang layak dicek dan pelajaran yang pernah berguna. Ini **bukan** standar benar/salah untuk project lain. Setiap codebase punya struktur, konvensi, dan proses sendiri. Kalau ada konflik, yang menang adalah instruksi user, keputusan tim, dan konvensi codebase yang sedang dikerjakan.

## Isi
- `CLAUDE.md` → preferensi kerja global (git, verifikasi, alur kerja, shell). Dipasang ke `~/.claude/CLAUDE.md`.
- `skills/android-field-notes/` → skill yang dirujuk saat kerja Android: verifikasi, Gradle/AAR, ABI Kotlin-Java, UI View/XML, Roborazzi, git/shell.

## Pasang
```bash
git clone <repo-ini> ~/claude-portable
bash ~/claude-portable/install.sh
```
Script ini tidak menimpa `~/.claude/CLAUDE.md` atau skill yang sudah ada. Setelah itu buka sesi Claude Code baru.

## Yang sengaja tidak ada di sini
Semua hal spesifik organisasi sebelumnya: nama repo/modul/package, arsitektur aplikasi, alur fitur, ID tiket, nama branch, detail registry/feed, mekanisme keamanan, kredensial, dan dokumen internal. Repo ini hanya berisi pengetahuan teknis umum tentang Android, Gradle, dan Kotlin.
