/**
 * Migração administrativa única dos perfis existentes.
 * Executar SOMENTE com Application Default Credentials de um administrador
 * autorizado do projeto anicard-battle. Nunca commitar credenciais.
 *
 * Por padrão apenas mostra o plano; use --apply para efetivar.
 */
import { applicationDefault, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const projectId = process.env.GOOGLE_CLOUD_PROJECT || 'anicard-battle';
const apply = process.argv.includes('--apply');

initializeApp({ credential: applicationDefault(), projectId });
const db = getFirestore();

function onlyPublicData(privateData) {
  const d = privateData || {};
  return {
    nomeUsuario: typeof d.nomeUsuario === 'string' && d.nomeUsuario.trim()
      ? d.nomeUsuario : 'Jogador',
    trofeus: Number.isInteger(d.trofeus) ? d.trofeus : 0,
    avatarIcon: typeof d.avatarIcon === 'string'
      ? d.avatarIcon : 'assets/images/AniCard Icon.png',
    cartasEquipadas: Array.isArray(d.cartasEquipadas) ? d.cartasEquipadas : [],
    cosmeticosEquipados: d.cosmeticosEquipados && typeof d.cosmeticosEquipados === 'object'
      && !Array.isArray(d.cosmeticosEquipados)
      ? d.cosmeticosEquipados : {},
  };
}

const snapshot = await db.collection('users').get();
console.log(`Projeto: ${projectId}; usuários encontrados: ${snapshot.size}; modo: ${apply ? 'APLICAR' : 'SIMULAÇÃO'}`);

if (!apply) {
  console.log('Nenhuma gravação feita. Para migrar, execute novamente com --apply.');
  process.exit(0);
}

let batch = db.batch();
let pending = 0;
let migrated = 0;
for (const doc of snapshot.docs) {
  batch.set(db.collection('publicProfiles').doc(doc.id), onlyPublicData(doc.data()), { merge: true });
  pending++;
  if (pending === 400) {
    await batch.commit();
    migrated += pending;
    console.log(`Migrados ${migrated}/${snapshot.size}`);
    batch = db.batch();
    pending = 0;
  }
}
if (pending > 0) {
  await batch.commit();
  migrated += pending;
}
console.log(`Concluído: ${migrated} perfis migrados. Nenhum campo de e-mail é copiado.`);
