# Git & shell di workspace multi-repo

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## grep membaca branch yang sedang ter-checkout
Di workspace multi-repo, repo sering sedang ter-checkout di branch lain (release/hotfix) karena dipakai kerjaan paralel. `grep -r` → 0 → "sudah bersih" bisa salah total. Kasus nyata: 3 repo nyaris terlewat; yang menangkapnya adalah `dexdump` APK (biner masih memanggil API yang "sudah dicabut").
```bash
git -C <repo> rev-parse --abbrev-ref HEAD                       # cek dulu
git -C <repo> grep -n "<pola>" origin/<branch> -- '*.java' '*.kt'  # baca branch tanpa checkout
```
Untuk kerjaan yang berujung artefak, verifikasi biner (`javap -p -c`, `dexdump`) adalah pengaman terakhir.

## Merge trunk ke branch fitur/tim/staging
- Nama trunk bisa tidak seragam antar repo (`main`, `master`, atau nama custom), dan branch default bisa saja basi. Cek per repo.
- Konflik sering hanya label versi. Resolve **per hunk**. `git checkout --ours/--theirs <file>` mengambil file utuh dan membuang perubahan non-konflik. Kasus nyata: `compileSdk` diam-diam turun dari 36 ke 35.
- Label versi yang **tidak** konflik bisa ikut tertimpa nilai trunk. Cek label publish sebelum deploy.
- File yang di kedua sisi punya routing/refactor berbeda: mengambil hunk satu per satu bisa menghasilkan campuran yang tidak compile. Lebih aman ambil satu sisi utuh, lalu pasang ulang perubahan sisi lain secara sadar.
- Merge yang bersih secara teks bisa tetap menghapus import yang dibutuhkan. Build sebelum commit.
- Mencari commit milik branch sendiri saja: `git log origin/<branch> --not origin/<trunk>`.

## zsh
- `cand=$(...); for c in $cand` di zsh → **tidak ada word-split** → hanya 1 iterasi berisi seluruh string → tool gagal identik di kedua sisi → "nol beda" palsu. (`for c in $(cmd)` langsung tetap ter-split.) Jalankan loop verifikasi lewat `bash -c '...'` atau `while read`, dan selalu sertakan kontrol positif.
- Jangan mendefinisikan fungsi shell dengan nama yang mungkin sudah jadi alias user (`deploy`, `build`, ...). Di zsh, definisi fungsinya gagal dan yang terpanggil malah alias-nya. Pernah hampir menjalankan pipeline deploy beneran. Pakai prefiks unik, jalankan lewat `bash script.sh`.
- Kalau output menu pipeline/deploy tiba-tiba muncul: cek `ps` untuk proses fastlane/deploy dan `git status` repo terkait.
