#!/usr/bin/env node
'use strict';
/**
 * Mengisi koleksi `kantins` dan `menus` di Firestore dari seed_data.json.
 *
 * Pemakaian (dari folder tool/):
 *   node seed_firestore.js --dry-run --owner=<UID_PENJUAL>      # lihat rencana saja
 *   node seed_firestore.js --owner=<UID_PENJUAL>                # tulis ke Firestore
 *   node seed_firestore.js --owner:kantin-pusat=<UID1> --owner:kantin-fakultas-a=<UID2> --owner=<UID3>
 *
 * Opsi:
 *   --owner=<uid>          uid penjual (Authentication) pemilik semua kantin
 *   --owner:<kantinId>=<uid>  pemilik khusus satu kantin (menimpa --owner)
 *   --force                timpa dokumen yang sudah ada (default: dilewati)
 *   --dry-run              hanya tampilkan rencana, tidak butuh kunci akses
 *
 * Kunci akses: unduh service account (Firebase Console > Project settings >
 * Service accounts > Generate new private key), simpan sebagai
 * tool/serviceAccountKey.json (JANGAN di-commit; sudah ada di tool/.gitignore),
 * atau set GOOGLE_APPLICATION_CREDENTIALS ke path berkas tersebut.
 */
const fs = require('fs');
const path = require('path');

const argv = process.argv.slice(2);
const has = (name) => argv.includes(`--${name}`);

let ownerDefault = null;
const ownerPer = {};
for (const a of argv) {
  let m;
  if ((m = a.match(/^--owner=(.+)$/))) ownerDefault = m[1];
  else if ((m = a.match(/^--owner:([\w-]+)=(.+)$/))) ownerPer[m[1]] = m[2];
}
const dryRun = has('dry-run');
const force = has('force');

const data = JSON.parse(fs.readFileSync(path.join(__dirname, 'seed_data.json'), 'utf8'));
const ownerFor = (kantinId) => ownerPer[kantinId] || ownerDefault;

// Setiap kantin harus punya pemilik (kecuali dry-run).
const tanpaPemilik = data.kantins.filter((k) => !ownerFor(k.id)).map((k) => k.id);
if (tanpaPemilik.length && !dryRun) {
  console.error(`Pemilik belum diisi untuk: ${tanpaPemilik.join(', ')}`);
  console.error('Pakai --owner=<uid penjual> (lihat uid di Firebase Console > Authentication).');
  process.exit(1);
}

// Layar Kelola Menu saat ini hanya mengelola SATU kantin per penjual.
const jumlahPerPemilik = {};
for (const k of data.kantins) {
  const o = ownerFor(k.id) || '<OWNER_UID>';
  jumlahPerPemilik[o] = (jumlahPerPemilik[o] || 0) + 1;
}
if (Object.values(jumlahPerPemilik).some((n) => n > 1)) {
  console.warn('PERINGATAN: satu akun penjual memegang lebih dari satu kantin.');
  console.warn('Layar Kelola Menu hanya mengelola satu kantin per akun. Untuk demo, pakai satu akun penjual per kantin:');
  console.warn('  --owner:kantin-pusat=<UID1> --owner:kantin-fakultas-a=<UID2> --owner:kantin-fakultas-b=<UID3>\n');
}

const rencana = [
  ...data.kantins.map(({ id, ...f }) => ({ col: 'kantins', id, fields: { ...f, ownerUid: ownerFor(id) || '<OWNER_UID>' } })),
  ...data.menus.map(({ id, ...f }) => ({ col: 'menus', id, fields: f })),
];

if (dryRun) {
  console.log('DRY RUN - tidak ada yang ditulis.\n');
  for (const r of rencana) console.log(`${r.col}/${r.id}`, JSON.stringify(r.fields));
  console.log(`\nTotal ${rencana.length} dokumen (${data.kantins.length} kantins, ${data.menus.length} menus).`);
  process.exit(0);
}

const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error(`Kunci akses tidak ditemukan: ${keyPath}`);
  console.error('Unduh service account key dan simpan sebagai tool/serviceAccountKey.json.');
  process.exit(1);
}

const admin = require('firebase-admin');
admin.initializeApp({ credential: admin.credential.cert(JSON.parse(fs.readFileSync(keyPath, 'utf8'))) });
const db = admin.firestore();

(async () => {
  // Pastikan setiap pemilik adalah akun yang sudah mendaftar sebagai penjual.
  const uids = [...new Set(data.kantins.map((k) => ownerFor(k.id)))];
  for (const uid of uids) {
    const u = await db.collection('users').doc(uid).get();
    if (!u.exists) {
      console.error(`users/${uid} tidak ada. Daftarkan akun penjual lewat aplikasi dulu.`);
      process.exit(1);
    }
    if (u.data().role !== 'penjual') {
      console.error(`users/${uid} berperan "${u.data().role}", harus "penjual".`);
      process.exit(1);
    }
  }

  let ditulis = 0;
  let dilewati = 0;
  for (const r of rencana) {
    const ref = db.collection(r.col).doc(r.id);
    if (!force && (await ref.get()).exists) {
      console.log(`lewati  ${r.col}/${r.id} (sudah ada)`);
      dilewati++;
      continue;
    }
    await ref.set(r.fields);
    console.log(`tulis   ${r.col}/${r.id}`);
    ditulis++;
  }
  console.log(`\nSelesai: ${ditulis} ditulis, ${dilewati} dilewati.`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
