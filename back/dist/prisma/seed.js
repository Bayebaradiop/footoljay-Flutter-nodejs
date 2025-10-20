"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Début du seeding...');
    // Nettoyer les données existantes (optionnel)
    await prisma.photo.deleteMany();
    await prisma.product.deleteMany();
    await prisma.notification.deleteMany();
    await prisma.user.deleteMany();
    console.log('🗑️  Données existantes supprimées');
    // === CRÉATION DES UTILISATEURS ===
    const hashedPassword = await bcrypt.hash('admin123', 12);
    const hashedPasswordMod = await bcrypt.hash('moderator123', 12);
    const hashedPasswordSeller = await bcrypt.hash('seller123', 12);
    // Créer un utilisateur admin
    const admin = await prisma.user.create({
        data: {
            email: 'admin@fotoljay.com',
            password: hashedPassword,
            firstName: 'Admin',
            lastName: 'FOTOLJAY',
            role: 'ADMIN',
            phone: '+221771234567',
        },
    });
    // Créer un utilisateur modérateur
    const moderator = await prisma.user.create({
        data: {
            email: 'moderator@fotoljay.com',
            password: hashedPasswordMod,
            firstName: 'Moderator',
            lastName: 'FOTOLJAY',
            role: 'MODERATOR',
            phone: '+221772345678',
        },
    });
    // Créer des vendeurs
    const seller1 = await prisma.user.create({
        data: {
            email: 'amina.diop@email.com',
            password: hashedPasswordSeller,
            firstName: 'Amina',
            lastName: 'Diop',
            role: 'SELLER',
            phone: '+221773456789',
            isVip: true,
        },
    });
    const seller2 = await prisma.user.create({
        data: {
            email: 'moussa.fall@email.com',
            password: hashedPasswordSeller,
            firstName: 'Moussa',
            lastName: 'Fall',
            role: 'SELLER',
            phone: '+221774567890',
        },
    });
    const seller3 = await prisma.user.create({
        data: {
            email: 'fatou.sarr@email.com',
            password: hashedPasswordSeller,
            firstName: 'Fatou',
            lastName: 'Sarr',
            role: 'SELLER',
            phone: '+221775678901',
        },
    });
    console.log('✅ Utilisateurs créés avec succès');
    // === CRÉATION DES PRODUITS AVEC PHOTOS ===
    // Produit 1: Téléphone (VIP - Approuvé)
    const product1 = await prisma.product.create({
        data: {
            title: 'iPhone 14 Pro Max 256GB - Excellent état',
            description: `iPhone 14 Pro Max en excellent état, utilisé seulement 6 mois.
      
Caractéristiques:
- Capacité: 256GB
- Couleur: Violet foncé
- État: Excellent (9/10)
- Batterie: 95% de santé
- Avec boîte d'origine et chargeur
- Facture disponible
- Débloqué tous opérateurs

Prix légèrement négociable. Possibilité de test avant achat.
Contact: WhatsApp ou appel direct.`,
            status: 'APPROVED',
            views: 145,
            isVip: true,
            sellerId: seller1.id,
            publishedAt: new Date(),
        },
    });
    // Photos pour iPhone
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?q=80&w=1000',
                publicId: 'products/iphone14_front',
                isPrimary: true,
                productId: product1.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1591337676887-a217a6970a8a?q=80&w=1000',
                publicId: 'products/iphone14_back',
                isPrimary: false,
                productId: product1.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1592286927505-1def25115558?q=80&w=1000',
                publicId: 'products/iphone14_box',
                isPrimary: false,
                productId: product1.id,
            },
        ],
    });
    // Produit 2: Voiture (Approuvé)
    const product2 = await prisma.product.create({
        data: {
            title: 'Toyota Corolla 2019 - Automatique',
            description: `Toyota Corolla 2019 en très bon état, première main.

Détails du véhicule:
- Année: 2019
- Kilométrage: 45,000 km
- Transmission: Automatique
- Carburant: Essence
- Couleur: Blanc nacré
- Climatisation fonctionnelle
- Vitres électriques
- Carnet d'entretien à jour
- Contrôle technique OK
- Assurance à jour

Véhicule très bien entretenu, révisions faites chez Toyota.
Prix: 8,500,000 FCFA (négociable)`,
            status: 'APPROVED',
            views: 89,
            isVip: false,
            sellerId: seller2.id,
            publishedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // Il y a 2 jours
        },
    });
    // Photos pour Toyota
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1550355291-bbee04a92027?q=80&w=1000',
                publicId: 'products/toyota_exterior',
                isPrimary: true,
                productId: product2.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?q=80&w=1000',
                publicId: 'products/toyota_interior',
                isPrimary: false,
                productId: product2.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?q=80&w=1000',
                publicId: 'products/toyota_dashboard',
                isPrimary: false,
                productId: product2.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1000',
                publicId: 'products/toyota_engine',
                isPrimary: false,
                productId: product2.id,
            },
        ],
    });
    // Produit 3: Appartement (En attente)
    const product3 = await prisma.product.create({
        data: {
            title: 'Appartement F4 meublé - Almadies',
            description: `Bel appartement F4 entièrement meublé aux Almadies, vue mer.

Caractéristiques:
- Surface: 120 m²
- 3 chambres climatisées
- 2 salles de bain
- Grand salon/salle à manger
- Cuisine équipée (frigo, gazinière, micro-ondes)
- Balcon avec vue mer
- Parking sécurisé
- Gardiennage 24h/24
- Proche plages et restaurants

Loyer: 450,000 FCFA/mois
Caution: 2 mois de loyer
Disponible immédiatement`,
            status: 'PENDING',
            views: 23,
            isVip: false,
            sellerId: seller3.id,
        },
    });
    // Photos pour appartement
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000',
                publicId: 'products/apartment_living',
                isPrimary: true,
                productId: product3.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1540518614846-7eded433c457?q=80&w=1000',
                publicId: 'products/apartment_bedroom',
                isPrimary: false,
                productId: product3.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1556911220-bff31c812dba?q=80&w=1000',
                publicId: 'products/apartment_kitchen',
                isPrimary: false,
                productId: product3.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1600585152915-d208bec867a1?q=80&w=1000',
                publicId: 'products/apartment_balcony',
                isPrimary: false,
                productId: product3.id,
            },
        ],
    });
    // Produit 4: Électroménager (VIP - Approuvé)
    const product4 = await prisma.product.create({
        data: {
            title: 'Réfrigérateur Samsung 500L - Neuf sous garantie',
            description: `Réfrigérateur Samsung 500 litres, neuf, jamais utilisé.

Spécifications:
- Marque: Samsung
- Capacité: 500 litres
- Type: Side by Side
- Couleur: Inox
- Classe énergétique: A++
- Distributeur d'eau et glaçons
- Écran digital
- Garantie constructeur: 2 ans
- Facture d'achat disponible

Cause de vente: déménagement à l'étranger
Prix d'achat: 850,000 FCFA
Prix de vente: 650,000 FCFA (ferme)`,
            status: 'APPROVED',
            views: 67,
            isVip: true,
            sellerId: seller1.id,
            publishedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // Il y a 1 jour
        },
    });
    // Photos pour réfrigérateur
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?q=80&w=1000',
                publicId: 'products/fridge_front',
                isPrimary: true,
                productId: product4.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1610701596061-2ecf227e85b2?q=80&w=1000',
                publicId: 'products/fridge_interior',
                isPrimary: false,
                productId: product4.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?q=80&w=1000',
                publicId: 'products/fridge_warranty',
                isPrimary: false,
                productId: product4.id,
            },
        ],
    });
    // Produit 5: Mobilier (Rejeté - pour exemple)
    const product5 = await prisma.product.create({
        data: {
            title: 'Salon complet en cuir - Occasion',
            description: `Salon 3+2+1 en cuir véritable, couleur marron.
      
État correct, quelques traces d'usure normales.
Prix négociable.`,
            status: 'REJECTED',
            views: 12,
            isVip: false,
            sellerId: seller2.id,
        },
    });
    // Photos pour salon
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=1000',
                publicId: 'products/sofa_set',
                isPrimary: true,
                productId: product5.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?q=80&w=1000',
                publicId: 'products/sofa_set_detail',
                isPrimary: false,
                productId: product5.id,
            },
        ],
    });
    // Produit 6: Ordinateur portable (Approuvé)
    const product6 = await prisma.product.create({
        data: {
            title: 'MacBook Pro 16" 2021 - M1 Pro - 16Go RAM - 512 Go SSD',
            description: `MacBook Pro 16 pouces en excellent état, très peu utilisé.

Caractéristiques:
- Processeur: Apple M1 Pro
- RAM: 16Go
- Stockage: SSD 512Go
- Écran: 16 pouces Liquid Retina XDR
- Clavier: AZERTY français
- Couleur: Gris sidéral
- Cycle de batterie: 34 cycles seulement
- Achat: novembre 2021
- Garantie Apple Care+ jusqu'à novembre 2024

Prix ferme: 1,850,000 FCFA
Livré avec boîte d'origine, chargeur et facture.`,
            status: 'APPROVED',
            views: 118,
            isVip: true,
            sellerId: seller2.id,
            publishedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // Il y a 5 jours
        },
    });
    // Photos pour MacBook
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?q=80&w=1000',
                publicId: 'products/macbook_main',
                isPrimary: true,
                productId: product6.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1531492746076-161ca9bcad58?q=80&w=1000',
                publicId: 'products/macbook_keyboard',
                isPrimary: false,
                productId: product6.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?q=80&w=1000',
                publicId: 'products/macbook_side',
                isPrimary: false,
                productId: product6.id,
            },
        ],
    });
    // Produit 7: Télévision (Approuvé)
    const product7 = await prisma.product.create({
        data: {
            title: 'Smart TV Samsung QLED 65" - 4K UHD - Comme neuve',
            description: `Téléviseur Samsung QLED 65 pouces (165cm) acheté il y a 3 mois.

Caractéristiques:
- Taille d'écran: 65 pouces (165cm)
- Résolution: 4K Ultra HD
- Technologie: QLED
- Smart TV: Oui (Tizen)
- HDR: Oui
- Connectique: 4x HDMI, 2x USB, WiFi, Bluetooth
- Son: 40W, 2.1 canaux
- Année: 2023

Raison de la vente: Déménagement dans un logement plus petit
État: Comme neuf, toujours avec protection d'écran
Facture et garantie: Disponibles (garantie 2 ans)

Prix: 950,000 FCFA (prix d'achat: 1,200,000 FCFA)`,
            status: 'APPROVED',
            views: 73,
            isVip: false,
            sellerId: seller3.id,
            publishedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // Il y a 3 jours
        },
    });
    // Photos pour TV
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?q=80&w=1000',
                publicId: 'products/tv_main',
                isPrimary: true,
                productId: product7.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1588508065123-287b28e013da?q=80&w=1000',
                publicId: 'products/tv_side',
                isPrimary: false,
                productId: product7.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1577979749830-f1d742b96791?q=80&w=1000',
                publicId: 'products/tv_interface',
                isPrimary: false,
                productId: product7.id,
            },
        ],
    });
    // Produit 8: Vélo (Pending)
    const product8 = await prisma.product.create({
        data: {
            title: 'VTT Décathlon Rockrider - Excellent état',
            description: `Vélo tout-terrain Décathlon Rockrider ST520 en excellent état.

Caractéristiques:
- Marque: Décathlon Rockrider
- Modèle: ST520
- Taille cadre: M (pour 1m70-1m80)
- Vitesses: 27 vitesses Shimano
- Freins: Freins à disque hydrauliques
- Suspension: Avant
- Pneus: 27.5 pouces
- Accessoires inclus: Porte-bidon, béquille, garde-boue

Utilisé seulement 5-6 fois sur terrain plat, pratiquement neuf.
Prix d'achat: 250,000 FCFA
Prix de vente: 180,000 FCFA`,
            status: 'PENDING',
            views: 5,
            isVip: false,
            sellerId: seller1.id,
        },
    });
    // Photos pour Vélo
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?q=80&w=1000',
                publicId: 'products/bike_main',
                isPrimary: true,
                productId: product8.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1485965373059-f7c1c5e72cfd?q=80&w=1000',
                publicId: 'products/bike_wheel',
                isPrimary: false,
                productId: product8.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1511994298241-608e28f14fde?q=80&w=1000',
                publicId: 'products/bike_handlebars',
                isPrimary: false,
                productId: product8.id,
            },
        ],
    });
    // Produit 9: Appareil photo (Approuvé, VIP)
    const product9 = await prisma.product.create({
        data: {
            title: 'Canon EOS 5D Mark IV - Boîtier + Objectifs',
            description: `Appareil photo Canon EOS 5D Mark IV avec accessoires, parfait état.

Contenu:
- Boîtier Canon EOS 5D Mark IV (moins de 15,000 déclenchements)
- Objectif Canon 24-70mm f/2.8L II USM
- Objectif Canon 50mm f/1.4 USM
- 3 batteries (dont 2 originales Canon)
- Chargeur
- 2 cartes mémoire 64GB
- Sac de transport professionnel
- Trépied Manfrotto

Matériel de professionnel, toujours bien entretenu, révisé chez Canon il y a 3 mois.
Vendu pour passage au système mirrorless.

Prix: 1,450,000 FCFA (valeur à neuf: plus de 3,000,000 FCFA)
Prix ferme, pas d'échange.`,
            status: 'APPROVED',
            views: 93,
            isVip: true,
            sellerId: seller2.id,
            publishedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Il y a 7 jours
        },
    });
    // Photos pour appareil photo
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000',
                publicId: 'products/camera_main',
                isPrimary: true,
                productId: product9.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1510127034890-ba27508e9f1c?q=80&w=1000',
                publicId: 'products/camera_lens',
                isPrimary: false,
                productId: product9.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1542567455-cd733f23fbb1?q=80&w=1000',
                publicId: 'products/camera_kit',
                isPrimary: false,
                productId: product9.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?q=80&w=1000',
                publicId: 'products/camera_tripod',
                isPrimary: false,
                productId: product9.id,
            },
        ],
    });
    // Produit 10: Montre (Approved)
    const product10 = await prisma.product.create({
        data: {
            title: 'Montre Rolex Submariner Date - Authentique',
            description: `Rolex Submariner Date authentique, référence 116610LN.

Détails:
- Modèle: Submariner Date
- Référence: 116610LN
- Année: 2019
- Diamètre: 40mm
- Mouvement: Automatique
- Matière: Acier inoxydable
- Bracelet: Oyster
- État: Excellent (porté occasionnellement)
- Complet: Boîte, papiers, garantie, maillons supplémentaires

Montre achetée chez un concessionnaire officiel Rolex, entièrement authentique avec tous les documents.
Légères traces d'usage au niveau du bracelet, état global excellent.

Prix: 8,500,000 FCFA`,
            status: 'APPROVED',
            views: 127,
            isVip: true,
            sellerId: seller3.id,
            publishedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000), // Il y a 10 jours
        },
    });
    // Photos pour montre
    await prisma.photo.createMany({
        data: [
            {
                url: 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?q=80&w=1000',
                publicId: 'products/watch_main',
                isPrimary: true,
                productId: product10.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?q=80&w=1000',
                publicId: 'products/watch_side',
                isPrimary: false,
                productId: product10.id,
            },
            {
                url: 'https://images.unsplash.com/photo-1548171915-00a233909414?q=80&w=1000',
                publicId: 'products/watch_box',
                isPrimary: false,
                productId: product10.id,
            },
        ],
    });
    console.log('✅ Produits et photos créés avec succès');
    // === CRÉATION DE NOTIFICATIONS ===
    await prisma.notification.createMany({
        data: [
            {
                type: 'PRODUCT_APPROVED',
                message: 'Votre annonce "iPhone 14 Pro Max 256GB" a été approuvée et est maintenant visible.',
                userId: seller1.id,
                recipientEmail: seller1.email,
                productId: product1.id,
                sent: true,
                sentAt: new Date(),
            },
            {
                type: 'PRODUCT_APPROVED',
                message: 'Votre annonce "Toyota Corolla 2019" a été approuvée et est maintenant visible.',
                userId: seller2.id,
                recipientEmail: seller2.email,
                productId: product2.id,
                sent: true,
                sentAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
            },
            {
                type: 'PRODUCT_REJECTED',
                message: 'Votre annonce "Salon complet en cuir" a été rejetée. Raison: Photos de mauvaise qualité. Veuillez republier avec de meilleures photos.',
                userId: seller2.id,
                recipientEmail: seller2.email,
                productId: product5.id,
                sent: true,
                sentAt: new Date(Date.now() - 1 * 60 * 60 * 1000),
            },
        ],
    });
    console.log('✅ Notifications créées avec succès');
    console.log('\n📋 RÉSUMÉ DU SEEDING:');
    console.log('====================');
    console.log('👥 Utilisateurs créés:');
    console.log('  • Admin: admin@fotoljay.com / admin123');
    console.log('  • Moderator: moderator@fotoljay.com / moderator123');
    console.log('  • Vendeur VIP: amina.diop@email.com / seller123');
    console.log('  • Vendeur: moussa.fall@email.com / seller123');
    console.log('  • Vendeur: fatou.sarr@email.com / seller123');
    console.log('\n📦 Produits créés:');
    console.log('  • iPhone 14 Pro Max (VIP, Approuvé) - 3 photos');
    console.log('  • Toyota Corolla 2019 (Approuvé) - 4 photos');
    console.log('  • Appartement F4 Almadies (En attente) - 4 photos');
    console.log('  • Réfrigérateur Samsung (VIP, Approuvé) - 3 photos');
    console.log('  • Salon en cuir (Rejeté) - 1 photo');
    console.log('  • MacBook Pro 16" (VIP, Approuvé) - 3 photos');
    console.log('  • Smart TV Samsung QLED 65" (Approuvé) - 3 photos');
    console.log('  • VTT Décathlon Rockrider (En attente) - 3 photos');
    console.log('  • Canon EOS 5D Mark IV (VIP, Approuvé) - 4 photos');
    console.log('  • Montre Rolex Submariner (VIP, Approuvé) - 3 photos');
    console.log('\n🔔 Notifications créées: 3');
    console.log('\n📸 Total photos: 31');
}
main()
    .catch((e) => {
    console.error(e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map