#!/usr/bin/env node

/**
 * Script de test pour l'approbation de produits par l'admin
 * Usage: node test-approval.js
 */

const API_URL = 'http://localhost:3000/api';

// Couleurs console
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

async function testApproval() {
  console.log(`${colors.cyan}╔════════════════════════════════════════╗${colors.reset}`);
  console.log(`${colors.cyan}║   Test d'Approbation Produit - ADMIN  ║${colors.reset}`);
  console.log(`${colors.cyan}╚════════════════════════════════════════╝${colors.reset}\n`);

  let token = null;
  let productId = null;

  try {
    // Étape 1: Connexion Admin
    console.log(`${colors.blue}📝 Étape 1: Connexion Admin${colors.reset}`);
    const loginResponse = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: 'admin@fotoljay.com',
        password: 'admin123',
      }),
    });

    if (!loginResponse.ok) {
      const error = await loginResponse.json();
      throw new Error(`Login failed: ${JSON.stringify(error)}`);
    }

    // Récupérer le cookie ou token
    const setCookieHeader = loginResponse.headers.get('set-cookie');
    if (setCookieHeader) {
      // Extraire le token du cookie
      const match = setCookieHeader.match(/token=([^;]+)/);
      if (match) {
        token = match[1];
        console.log(`${colors.green}✅ Connexion réussie (token extrait du cookie)${colors.reset}`);
      }
    } else {
      // Vérifier si le token est dans le body
      const loginData = await loginResponse.json();
      if (loginData.token) {
        token = loginData.token;
        console.log(`${colors.green}✅ Connexion réussie (token dans body)${colors.reset}`);
      }
    }

    if (!token) {
      throw new Error('Token non trouvé dans la réponse');
    }

    console.log(`Token: ${token.substring(0, 20)}...\n`);

    // Étape 2: Récupérer les produits en attente
    console.log(`${colors.blue}📝 Étape 2: Récupérer produits en attente${colors.reset}`);
    const pendingResponse = await fetch(`${API_URL}/products/moderation/pending`, {
      headers: {
        'Cookie': `token=${token}`,
        'Authorization': `Bearer ${token}`,
      },
    });

    if (!pendingResponse.ok) {
      const error = await pendingResponse.json();
      throw new Error(`Fetch pending failed: ${JSON.stringify(error)}`);
    }

    const pendingData = await pendingResponse.json();
    const pendingProducts = pendingData.products || pendingData;

    console.log(`${colors.green}✅ Produits en attente récupérés: ${pendingProducts.length}${colors.reset}`);

    if (pendingProducts.length === 0) {
      console.log(`${colors.yellow}⚠️  Aucun produit en attente${colors.reset}`);
      console.log(`${colors.yellow}Créons un produit en attente pour le test...${colors.reset}\n`);
      return;
    }

    // Afficher les produits en attente
    console.log('\nProduits en attente:');
    pendingProducts.forEach((p, i) => {
      console.log(`  ${i + 1}. [${p.id}] ${p.title} - Status: ${p.status}`);
    });

    productId = pendingProducts[0].id;
    console.log(`\n${colors.cyan}Sélection du produit: ${productId}${colors.reset}\n`);

    // Étape 3: Approuver le produit
    console.log(`${colors.blue}📝 Étape 3: Approuver le produit${colors.reset}`);
    const approveResponse = await fetch(`${API_URL}/products/${productId}/approve`, {
      method: 'POST',
      headers: {
        'Cookie': `token=${token}`,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    if (!approveResponse.ok) {
      const error = await approveResponse.json();
      throw new Error(`Approval failed: ${JSON.stringify(error)}`);
    }

    const approvedProduct = await approveResponse.json();
    console.log(`${colors.green}✅ Produit approuvé avec succès!${colors.reset}`);
    console.log(`   ID: ${approvedProduct.id}`);
    console.log(`   Titre: ${approvedProduct.title}`);
    console.log(`   Status: ${approvedProduct.status}`);
    console.log(`   Publié le: ${approvedProduct.publishedAt}`);

    console.log(`\n${colors.green}╔════════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.green}║        TEST RÉUSSI ✅                  ║${colors.reset}`);
    console.log(`${colors.green}╚════════════════════════════════════════╝${colors.reset}`);

  } catch (error) {
    console.log(`\n${colors.red}╔════════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.red}║        TEST ÉCHOUÉ ❌                  ║${colors.reset}`);
    console.log(`${colors.red}╚════════════════════════════════════════╝${colors.reset}`);
    console.error(`${colors.red}Erreur: ${error.message}${colors.reset}`);
    console.error(error);
  }
}

// Exécuter le test
testApproval();
