# Gradle, AAR, dan artefak

> Panduan dari project sebelumnya, bukan patokan. Cocokkan dulu dengan codebase sekarang; kalau beda, konvensi project ini yang menang.

## Konsumen makan AAR, bukan source
Kalau modul dikonsumsi lewat Maven (versi di-pin di `versions.gradle` / `libs.versions.toml`), edit source modul shared **tidak terlihat** di konsumen sampai dipublish dan versinya di-bump. Urutannya:
1. Edit modul shared.
2. STOP, beri user perintah publish.
3. Tunggu konfirmasi bahwa sudah dipublish + versi barunya.
4. Bump versi di konsumen.
5. Baru tulis call site yang memakai API baru, lalu build.

Urutan publish: sync (`./gradlew --refresh-dependencies :<module>:dependencies`) → build + publish lewat task Gradle repo itu → unduh ulang dari remote dan verifikasi.

## Build gagal tapi AAR ada = AAR basi
Kasus nyata: `assembleRelease` gagal, padahal `xxx-release.aar` ada dengan timestamp baru. Isinya resource LAMA. `mvn deploy` BUILD SUCCESS, metadata remote naik, semuanya hijau, tapi fix-nya tidak pernah sampai. Beda ukurannya cuma 14 byte.
1. Hapus AAR, lalu build ulang.
2. Periksa isi sesuai jenis perubahan:
   ```bash
   unzip -p <aar> R.txt | grep <resource>              # tabel simbol yang dibaca konsumen
   unzip -p <aar> res/values/values.xml | grep <name>   # nilai string
   unzip -p <aar> classes.jar > /tmp/c.jar && javap -p -c -cp /tmp/c.jar <fqcn> | grep <method>
   ```
3. Kontrol positif: simbol yang seharusnya tidak berubah harus tetap ada.
4. Setelah publish, **unduh ulang dari remote** dan periksa isinya. `maven-metadata.xml` yang naik tidak membuktikan isinya benar.

## Versi
- **Feed rilis biasanya immutable.** Publish ulang ke versi yang sudah ada tidak bisa. Kalau isinya salah, satu-satunya jalan adalah naik versi. Sebelum publish, cek koordinat target 404 dulu. Kalau sudah 200, bandingkan isinya (md5 `.class`).
- **Jangan republish SNAPSHOT dengan isi beda tanpa naik versi.** Cache Gradle bisa menyimpan 2 AAR beda isi di folder versi yang sama; konsumen terlihat menunjuk versi "benar", compile sukses, lalu crash di runtime. Kalau terpaksa: `--refresh-dependencies` di **semua** konsumen.
- Label SNAPSHOT bisa kalah resolusi melawan versi numerik `1.x` → perlu force di parent.
- Ganti signature API publik di SDK → republish **semua** modul konsumen, termasuk repo di luar scope proyek. Cari konsumen dengan grep nama simbol ke seluruh workspace.
- Gate yang benar-benar menangkap ABI basi: disassemble call site.
  ```bash
  javap -p -c <konsumen.class> | grep "<Class>.invoke"
  dexdump -d classes*.dex | grep "<Class>;.invoke:(Ljava/lang/String;)"   # versi lama harus NOL
  ```
  `strings` di DEX tidak cukup, karena tidak menunjukkan signature method.

## Force resolution per flavor
- Aturan force di `resolutionStrategy` dicocokkan dengan `group:name`, **tanpa versi**. Jadi `1.1.8` dan `1.1.8-staging` dianggap modul yang sama dan tidak diselaraskan kecuali di-force per flavor (map versi yang di-key dengan `configuration.name`).
- Gejalanya: `:app` dan modul lain resolve ke versi berbeda, dan IDE menampilkan dua AAR modul yang sama. APK tetap jadi, tapi bisa mengambil artefak yang salah.
- Verifikasi `dependencyInsight` di **setiap** modul yang mengonsumsi, untuk configuration flavor yang relevan. Hasilnya harus sama.
- Mencari split versi: hitung `group:artifact:VERSION` final yang berbeda. Kalau versinya ikut di-collapse, split `1.1.8` vs `1.1.8-staging` tersembunyi.

## Resource ketimpa diam-diam
- Resource dengan nama sama dari beberapa modul/AAR **di-overwrite** saat merge; yang menang adalah yang terakhir di urutan merge. **AGP tidak memberi warning.**
- Kasus nyata: `androidx.compose.ui` **1.8.0** menambah string `default_error_message` ("Invalid input"). Modul yang punya nama sama kalah, dan semua pesan error generiknya berubah wording. Tidak ada crash, build hijau. Pemicunya kenaikan versi transitif (activity-compose menarik compose.ui 1.8).
- Diagnosis: `aapt2 dump resources <apk> | grep <name>`, karena nilai di APK adalah kebenaran runtime. Cari pelakunya dengan menyapu semua AAR:
  ```bash
  find ~/.gradle/caches/modules-2/files-2.1 -name "*.aar" | while read a; do
    unzip -p "$a" res/values/values.xml 2>/dev/null | grep -q 'name="<res>"' && echo "HIT: $a"; done
  ```
  Kontrol positif: modul sendiri harus ikut tertangkap.
- Pencegahan: **resource modul selalu diberi prefix nama modul.** Nama generik (`error`, `title`, `default_error_message`) adalah ranjau. Setelah rename, verifikasi `R.txt` di AAR.
- Resource dari dependency `implementation` (mis. `sdp`) tidak terlihat oleh konsumen → `AAPT: resource dimen/... not found`. Pakai `api` atau deklarasikan langsung.

## Lain-lain
- Merge yang bersih secara teks bisa tetap menghapus import yang dibutuhkan. Selalu build sebelum commit.
- Build branch lama gagal 401/403 ke registry → curigai kredensial yang basi. Suplai kredensial lewat `-P<prop>=...` / `~/.gradle/gradle.properties` sesuai cara project, jangan mengedit file repo. Jangan mengeksplorasi token lain tanpa izin.
