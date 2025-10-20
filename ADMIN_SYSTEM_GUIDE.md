# 🎯 Système de Gestion Admin/Modérateur - FOTOL JAY

## 📋 Vue d'ensemble

Le système complet de gestion des rôles Admin/Modérateur a été implémenté avec toutes les fonctionnalités demandées.

---

## 🔐 Hiérarchie des Rôles

### 1. **SELLER (Vendeur)**
- Peut créer des produits
- Voit ses propres produits (Approuvés, En attente, Rejetés)
- Reçoit des notifications sur l'état de ses produits
- **NE PEUT PAS** accéder aux fonctions d'administration

### 2. **MODERATOR (Modérateur)**
- **Toutes les permissions du vendeur**
- Accès au tableau de bord admin
- Modération des produits (Approuver/Rejeter/Supprimer)
- Gestion des utilisateurs (Activer/Suspendre/Promouvoir VIP)
- **NE PEUT PAS** se supprimer lui-même

### 3. **ADMIN (Administrateur)**
- **Toutes les permissions du modérateur**
- Accès complet au système
- Peut promouvoir/rétrograder les rôles
- Gestion complète des utilisateurs

---

## 🗄️ Structure des Modèles

### User Model
```typescript
{
  id: String (UUID)
  email: String
  password: String (hashé)
  firstName: String
  lastName: String
  phone: String
  role: UserRole (SELLER | MODERATOR | ADMIN)
  isVip: Boolean
  isActive: Boolean
  createdAt: DateTime
  updatedAt: DateTime
}
```

### Product Model
```typescript
{
  id: String (UUID)
  title: String
  description: String
  status: ProductStatus (PENDING | APPROVED | REJECTED | EXPIRED)
  photos: Photo[]
  sellerId: String
  seller: User
  views: Number
  isVip: Boolean
  publishedAt: DateTime?
  createdAt: DateTime
  updatedAt: DateTime
}
```

---

## 🔌 API Endpoints Backend

### 📊 Tableau de Bord
```
GET /api/admin/dashboard/stats
```
**Authentification**: Requise (Admin/Moderator)

**Réponse**:
```json
{
  "products": {
    "total": 10,
    "pending": 3,
    "approved": 5,
    "rejected": 1,
    "expired": 1
  },
  "users": {
    "total": 15,
    "sellers": 12,
    "moderators": 2,
    "vipSellers": 3,
    "activeSellers": 10,
    "inactiveSellers": 2
  },
  "recentProducts": [...],
  "topSellers": [...]
}
```

---

### 📦 Gestion des Produits

#### Lister tous les produits (avec filtres)
```
GET /api/admin/products?status=PENDING&search=iPhone&page=1&limit=20
```

#### Approuver un produit
```
PATCH /api/admin/products/:id/approve
```

#### Rejeter un produit
```
PATCH /api/admin/products/:id/reject
Body: { "reason": "Photos de mauvaise qualité" }
```

#### Supprimer un produit
```
DELETE /api/admin/products/:id
```

---

### 👥 Gestion des Utilisateurs

#### Lister tous les utilisateurs (avec filtres)
```
GET /api/admin/users?role=SELLER&isActive=true&search=Diop&page=1&limit=20
```

#### Détails d'un utilisateur
```
GET /api/admin/users/:id
```

#### Activer/Suspendre un utilisateur
```
PATCH /api/admin/users/:id/status
Body: { "isActive": false }
```

#### Changer le rôle d'un utilisateur
```
PATCH /api/admin/users/:id/role
Body: { "role": "MODERATOR" }
```

#### Promouvoir/Rétrograder VIP
```
PATCH /api/admin/users/:id/vip
Body: { "isVip": true }
```

#### Supprimer un utilisateur
```
DELETE /api/admin/users/:id
```

---

## 📱 Écrans Flutter

### 1. **AdminDashboardScreen** (`admin_dashboard_screen.dart`)
**Page d'accueil de l'administration**

**Fonctionnalités**:
- Statistiques en temps réel (produits, utilisateurs)
- Cartes interactives cliquables
- Navigation rapide vers modération et gestion utilisateurs
- Refresh automatique

**Accès**: Menu Profil → "Modération" (visible uniquement pour Admin/Moderator)

---

### 2. **AdminProductsScreen** (`admin_products_screen.dart`)
**Modération des produits**

**Fonctionnalités**:
- 4 onglets: Tous, En attente, Approuvés, Rejetés
- Recherche de produits
- Actions:
  - ✅ Approuver (pour produits en attente)
  - ❌ Rejeter avec raison (pour produits en attente)
  - 🗑️ Supprimer (pour tous)
- Affichage vendeur pour chaque produit
- Pull-to-refresh

**Navigation**: Dashboard → "Modérer produits" ou clic sur statistiques

---

### 3. **AdminUsersScreen** (`admin_users_screen.dart`)
**Gestion des utilisateurs**

**Fonctionnalités**:
- Filtres: Tous, Vendeurs, VIP, Actifs, Suspendus, Modérateurs
- Recherche d'utilisateurs
- Actions par utilisateur:
  - 🔒 Activer/Suspendre
  - ⭐ Promouvoir/Rétrograder VIP
  - 🗑️ Supprimer
- Affichage du nombre de produits par utilisateur
- Expansion pour voir détails

**Navigation**: Dashboard → "Gérer utilisateurs" ou clic sur statistiques

---

## 🔐 Sécurité et Restrictions

### Protection des Routes Backend
```typescript
// Middleware d'authentification + rôle
const requireAdmin = [authMiddleware, requireModerator];

// Toutes les routes /api/admin/* sont protégées
router.get('/admin/dashboard/stats', requireAdmin, ...);
router.patch('/admin/products/:id/approve', requireAdmin, ...);
router.delete('/admin/users/:id', requireAdmin, ...);
```

### Protection Frontend
- Icône "Modération" visible uniquement pour Admin/Moderator
- Navigation protégée côté client
- Vérification du rôle: `user?.isAdmin || user?.isModerator`

### Auto-protection
- Un admin ne peut pas se supprimer lui-même
- Vérification backend: `if (id === adminId) return 403`

---

## 📨 Système de Notifications

### Notifications automatiques envoyées aux vendeurs:

#### ✅ Produit Approuvé
```
"Votre annonce 'iPhone 14 Pro Max' a été approuvée et est maintenant visible."
```

#### ❌ Produit Rejeté
```
"Votre annonce 'Salon en cuir' a été rejetée. Raison: Photos de mauvaise qualité"
```

---

## 🎨 Design et UX

### Codes Couleurs
- 🟢 **Vert**: Approuvé, Actif, Succès
- 🟠 **Orange**: En attente, Suspension
- 🔴 **Rouge**: Rejeté, Erreur, Suppression
- 🟣 **Violet**: Modérateur
- 🟡 **Jaune**: VIP, Premium
- 🔵 **Bleu**: Vendeur, Info

### Badges et Chips
- Statut produit: Badge coloré avec icône
- Rôle utilisateur: Chip avec couleur distinctive
- VIP: Badge doré avec icône étoile

---

## 📊 Flux de Travail Complet

### 1. **Vendeur soumet un produit**
```
Vendeur → Formulaire → POST /api/products
↓
Produit créé avec status = PENDING
↓
Redirection vers "Mes produits" (onglet "En attente")
```

### 2. **Admin modère le produit**
```
Admin → Menu "Modération" → AdminDashboardScreen
↓
Clic "Modérer produits" → AdminProductsScreen (onglet "En attente")
↓
Sélectionne produit → Approuve ou Rejette
↓
Notification envoyée au vendeur
```

### 3. **Produit devient visible**
```
Status = APPROVED
↓
publishedAt = Date actuelle
↓
Apparaît dans la liste publique (ProductListScreen)
↓
Vendeur voit dans "Mes produits" (onglet "Approuvés")
```

---

## 🧪 Comptes de Test

### Admin
```
Email: admin@fotoljay.com
Password: admin123
Rôle: ADMIN
```

### Modérateur
```
Email: moderator@fotoljay.com
Password: moderator123
Rôle: MODERATOR
```

### Vendeurs
```
Email: amina.diop@email.com
Password: seller123
Rôle: SELLER (VIP)

Email: moussa.fall@email.com
Password: seller123
Rôle: SELLER

Email: fatou.sarr@email.com
Password: seller123
Rôle: SELLER
```

---

## 🚀 Comment Utiliser

### Pour les Vendeurs:
1. Connexion avec compte vendeur
2. Onglet "Vendre" → Ajouter produit
3. Attendre approbation admin
4. Consulter "Mes produits" pour voir le statut

### Pour les Admins/Modérateurs:
1. Connexion avec compte admin/moderator
2. Onglet "Profil" → Menu (⋮) → "Modération"
3. Accès au tableau de bord avec statistiques
4. Actions disponibles:
   - Modérer les produits en attente
   - Gérer les utilisateurs
   - Voir les statistiques en temps réel

---

## ✅ Fonctionnalités Implémentées

### Backend
- ✅ Contrôleur Admin complet (`admin.controller.ts`)
- ✅ Routes Admin protégées (`admin.routes.ts`)
- ✅ Middleware RBAC (Role-Based Access Control)
- ✅ Statistiques en temps réel
- ✅ Système de notifications automatiques
- ✅ Filtrage et pagination
- ✅ Recherche dans produits et utilisateurs

### Frontend
- ✅ Service Admin (`admin_service.dart`)
- ✅ Modèles mis à jour (User, Product)
- ✅ Écran tableau de bord (`admin_dashboard_screen.dart`)
- ✅ Écran modération produits (`admin_products_screen.dart`)
- ✅ Écran gestion utilisateurs (`admin_users_screen.dart`)
- ✅ Intégration dans HomeScreen
- ✅ Protection des routes par rôle
- ✅ UI/UX responsive et intuitive

### Sécurité
- ✅ Authentification JWT obligatoire
- ✅ Vérification des rôles côté backend
- ✅ Protection contre l'auto-suppression
- ✅ Validation des permissions à chaque requête

---

## 📝 Notes Importantes

1. **Les vendeurs ne peuvent PAS**:
   - Vendre des produits sans approbation admin
   - Accéder aux fonctions de modération
   - Voir les produits des autres vendeurs (sauf dans la liste publique)

2. **Les produits en PENDING**:
   - Ne sont PAS visibles publiquement
   - Visibles uniquement par le vendeur et les admins
   - Nécessitent approbation pour devenir publics

3. **Les admins peuvent**:
   - Tout faire (modération, gestion utilisateurs, suppression)
   - Promouvoir des vendeurs en modérateurs
   - Gérer les statuts VIP

4. **Workflow de modération**:
   - Vendeur → Soumet produit (PENDING)
   - Admin → Approuve (APPROVED) ou Rejette (REJECTED)
   - Si approuvé → Produit visible publiquement
   - Si rejeté → Vendeur notifié avec raison

---

## 🎉 Résultat Final

Vous disposez maintenant d'un système complet de marketplace avec:
- ✅ Gestion complète des rôles (SELLER, MODERATOR, ADMIN)
- ✅ Modération des produits avant publication
- ✅ Gestion des utilisateurs (activation, VIP, suppression)
- ✅ Tableau de bord admin avec statistiques temps réel
- ✅ Système de notifications automatiques
- ✅ Interface admin intuitive et professionnelle
- ✅ Sécurité renforcée avec RBAC

Le système est prêt à l'emploi ! 🚀
