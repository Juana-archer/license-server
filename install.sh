#!/bin/bash
# install.sh - Installation automatique des outils Juana-archer
# Version simplifiée - Dépendances essentielles seulement

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     INSTALLATION OUTILS JUNIA-ARCHER   ║"
echo "║            VERSION SIMPLIFIÉE          ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[1;91m'
GREEN='\033[1;92m'
YELLOW='\033[1;93m'
CYAN='\033[1;96m'
WHITE='\033[1;97m'
RESET='\033[0m'

# Fonctions d'affichage
print_info() { echo -e "${CYAN}[ℹ️] $1${RESET}"; }
print_success() { echo -e "${GREEN}[✅] $1${RESET}"; }
print_warning() { echo -e "${YELLOW}[⚠️] $1${RESET}"; }
print_error() { echo -e "${RED}[❌] $1${RESET}"; }

# Vérifier Termux
if [ ! -d "/data/data/com.termux" ]; then
    print_error "Ce script doit être exécuté dans Termux!"
    exit 1
fi

print_info "Début de l'installation simplifiée..."
echo ""

# ÉTAPE 1: Mise à jour de Termux
print_info "ÉTAPE 1: Mise à jour de Termux..."
pkg update -y && pkg upgrade -y
print_success "Termux mis à jour"

# ÉTAPE 2: Installation des dépendances système
print_info "ÉTAPE 2: Installation des dépendances système..."
pkg install -y python git wget curl libsodium
print_success "Dépendances système installées"

# ÉTAPE 3: Configuration de libsodium
print_info "ÉTAPE 3: Configuration de libsodium..."
export SODIUM_INSTALL=system
print_success "Libsodium configuré"

# ÉTAPE 4: Installation des packages pip essentiels
print_info "ÉTAPE 4: Installation des packages Python..."

# Liste des packages à installer
PIP_PACKAGES=(
    "git+https://github.com/Juana-archer/install_tool.git"
    "pynacl"
    "termcolor"
    "pycryptodome"
    "requests"
    "colorama"
    "telethon"
)

# Installation de pip si nécessaire
if ! command -v pip3 &> /dev/null; then
    pip install --upgrade pip
fi

# Installer chaque package
for package in "${PIP_PACKAGES[@]}"; do
    print_info "Installation: $package"
    if pip install --quiet "$package"; then
        print_success "$package ✓"
    else
        print_error "Échec: $package"
        # Réessayer avec pip3
        pip3 install --quiet "$package" && print_success "$package ✓ (via pip3)" || print_error "Échec définitif: $package"
    fi
done

# ÉTAPE 5: Téléchargement des fichiers depuis votre dépôt
print_info "ÉTAPE 5: Téléchargement des fichiers..."
echo ""

# Dépôt GitHub
GITHUB_USER="Juana-archer"
GITHUB_REPO="dachery2-scripts"  # À changer selon votre dépôt
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/main"

# Liste des fichiers à télécharger
FILES_TO_DOWNLOAD=(
    "task.py"
    "r.py"
    "post.py"
    "task1.py"
)

# Créer un dossier pour les fichiers
INSTALL_DIR="$HOME/juana-tools"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Télécharger chaque fichier
DOWNLOADED=0
for file in "${FILES_TO_DOWNLOAD[@]}"; do
    print_info "Téléchargement: $file"
    if curl -s -o "$file" "$BASE_URL/$file"; then
        print_success "$file téléchargé"
        DOWNLOADED=$((DOWNLOADED + 1))
    else
        print_error "Impossible de télécharger $file"
    fi
done

# ÉTAPE 6: Rendre les fichiers exécutables
print_info "ÉTAPE 6: Configuration des permissions..."
for file in *.py; do
    if [ -f "$file" ]; then
        chmod +x "$file"
    fi
done
print_success "Permissions configurées"

# ÉTAPE 7: Création du script de lancement
print_info "ÉTAPE 7: Création des utilitaires..."

# Créer un script pour lancer tous les outils
cat > launch-all.sh << 'EOF'
#!/bin/bash
echo "🚀 Outils Juana-archer - Menu principal"
echo "======================================="
echo ""
echo "Fichiers disponibles:"
echo "---------------------"
ls *.py 2>/dev/null | cat -n
echo ""
echo "Usage: python [fichier].py"
echo "Exemple: python task.py"
echo ""
EOF

chmod +x launch-all.sh

# Créer un alias pour chaque script
for file in *.py; do
    if [ -f "$file" ]; then
        script_name="${file%.py}"
        cat > "run-$script_name.sh" << EOF
#!/bin/bash
python3 "$file"
EOF
        chmod +x "run-$script_name.sh"
    fi
done

# ÉTAPE 8: Vérification finale
print_info "ÉTAPE 8: Vérification finale..."

echo ""
print_success "📊 RÉSUMÉ DE L'INSTALLATION:"
echo "┌─────────────────────────────────────┐"
echo "│ ✅ Termux mis à jour                │"
echo "│ ✅ Dépendances système installées   │"
echo "│ ✅ Libsodium configuré              │"
echo "│ ✅ Packages Python installés:       │"
echo "│    • pynacl                         │"
echo "│    • termcolor                      │"
echo "│    • pycryptodome                   │"
echo "│    • install_tool                   │"
echo "│ ✅ Fichiers téléchargés: $DOWNLOADED/4    │"
echo "│ ✅ Dossier: $INSTALL_DIR   │"
echo "└─────────────────────────────────────┘"

# ÉTAPE 9: Instructions finales
echo ""
print_success "🎉 INSTALLATION TERMINÉE !"
echo ""
echo "╔════════════════════════════════════════╗"
echo "║         COMMENT UTILISER              ║"
echo "╠════════════════════════════════════════╣"
echo "║ 📂 Votre dossier:                     ║"
echo "║   cd $INSTALL_DIR           ║"
echo "║                                      ║"
echo "║ 🚀 Lancer un script:                 ║"
echo "║   python3 task.py                    ║"
echo "║   python3 r.py                       ║"
echo "║   python3 post.py                    ║"
echo "║   python3 task1.py                   ║"
echo "║                                      ║"
echo "║ 📋 Voir tous les fichiers:           ║"
echo "║   ./launch-all.sh                    ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🔧 DEPENDANCES INSTALLÉES:"
echo "   • libsodium (pkg)"
echo "   • pynacl (pip)"
echo "   • termcolor (pip)"
echo "   • pycryptodome (pip)"
echo "   • install_tool (depuis GitHub)"
echo ""
echo "📁 FICHIERS DISPONIBLES:"
cd "$INSTALL_DIR" && ls -la *.py
echo ""
echo "💡 ASTUCE: Ajoutez ceci à ~/.bashrc pour un accès rapide:"
echo "   alias juana='cd $INSTALL_DIR && ./launch-all.sh'"
echo ""

# Proposer de tester l'installation
read -p "Voulez-vous tester l'installation? (o/n): " test_choice
if [[ $test_choice == "o" || $test_choice == "O" ]]; then
    echo ""
    print_info "Test en cours..."
    echo "--------------------------------"
    
    # Tester pip packages
    echo "Vérification des packages Python:"
    python3 -c "import nacl; print('✅ pynacl fonctionnel')" 2>/dev/null || echo "❌ pynacl problème"
    python3 -c "import termcolor; print('✅ termcolor fonctionnel')" 2>/dev/null || echo "❌ termcolor problème"
    python3 -c "import Crypto; print('✅ pycryptodome fonctionnel')" 2>/dev/null || echo "❌ pycryptodome problème"
    
    # Tester les fichiers téléchargés
    echo ""
    echo "Fichiers présents:"
    cd "$INSTALL_DIR" && ls *.py
    
    print_success "Test terminé!"
fi

echo ""
print_success "✅ Installation complétée avec succès!"
echo "📞 GitHub: https://github.com/Juana-archer"
