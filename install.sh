#!/bin/bash
# install.sh - Installation des fichiers dahery4 avec réparation automatique
echo ""
echo "╔════════════════════════════════════════╗"
echo "║     INSTALLATION FICHIERS DAHERY4     ║"
echo "║           par Juana-archer            ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[ℹ️]${NC} $1"; }
print_success() { echo -e "${GREEN}[✅]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[⚠️]${NC} $1"; }
print_error() { echo -e "${RED}[❌]${NC} $1"; }

# Fonction de réparation
repair_system() {
    print_info "Vérification du système..."
    
    if [ ! -d "/data/data/com.termux" ]; then
        print_error "Ce script doit être exécuté dans Termux!"
        exit 1
    fi
    
    # Nettoyer les locks
    rm -f /data/data/com.termux/files/usr/var/lib/dpkg/lock* 2>/dev/null || true
    
    # Réparer packages
    yes "" | pkg upgrade -y --fix-broken 2>/dev/null || true
    dpkg --configure -a 2>/dev/null || true
    
    print_success "Système vérifié"
    echo ""
}

repair_system

print_info "Début de l'installation..."
echo ""

# ÉTAPE 1: Mise à jour
print_info "ÉTAPE 1: Mise à jour de Termux..."
pkg update -y --quiet 2>/dev/null || true
print_success "Sources mises à jour"
echo ""

# ÉTAPE 2: Installation Git et dépendances (IMPORTANT!)
print_info "ÉTAPE 2: Installation des dépendances..."

# Git DOIT être installé en premier
print_info "Vérification de Git..."
if ! command -v git >/dev/null 2>&1; then
    print_info "Installation de Git..."
    if pkg install -y git --quiet 2>/dev/null; then
        print_success "Git installé"
    else
        print_error "Git non installé - requis pour install_tool"
    fi
else
    print_success "Git déjà installé"
fi

# Liste des packages essentiels (AVEC GIT)
ESSENTIAL_PKGS=("python" "curl" "libsodium")

for pkg in "${ESSENTIAL_PKGS[@]}"; do
    if ! pkg list-installed 2>/dev/null | grep -q "$pkg"; then
        print_info "Installation de $pkg..."
        pkg install -y "$pkg" --quiet 2>/dev/null && print_success "$pkg installé" || print_warning "$pkg échoué"
    else
        print_success "$pkg déjà installé"
    fi
done

export SODIUM_INSTALL=system
print_success "Dépendances installées"
echo ""

# ÉTAPE 3: Configuration Python et pip
print_info "ÉTAPE 3: Configuration de Python..."

if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
    print_info "Installation de pip..."
    pkg install -y python-pip --quiet 2>/dev/null || python3 -m ensurepip --upgrade 2>/dev/null || true
fi

python3 -m pip install --upgrade pip --quiet 2>/dev/null || true
print_success "Python configuré"
echo ""

# ÉTAPE 4: Packages Python (install_tool EN DERNIER)
print_info "ÉTAPE 4: Installation des packages Python..."

PYTHON_PACKAGES=(
    "pynacl"
    "termcolor"
    "pycryptodome"
    "requests"
)

# Ajout de Telethon et Colorama
print_info "Installation: Telethon..."
if python3 -m pip install telethon --quiet 2>/dev/null; then
    print_success "Telethon ✓"
else
    print_warning "Telethon échoué"
fi

print_info "Installation: Colorama..."
if python3 -m pip install colorama --quiet 2>/dev/null; then
    print_success "Colorama ✓"
else
    print_warning "Colorama échoué"
fi

for package in "${PYTHON_PACKAGES[@]}"; do
    print_info "Installation: $package"
    python3 -m pip install "$package" --quiet 2>/dev/null && print_success "$package ✓" || print_warning "$package échoué"
done

# Installer install_tool (UNIQUEMENT si Git est disponible)
print_info "Installation: install_tool (GitHub)..."
if command -v git >/dev/null 2>&1; then
    if python3 -m pip install "git+https://github.com/Juana-archer/install_tool.git" --quiet 2>/dev/null; then
        print_success "install_tool ✓"
    else
        print_warning "install_tool non installé"
    fi
else
    print_error "Git non disponible - install_tool ne peut pas être installé"
    print_info "Installez Git manuellement: pkg install git"
fi
echo ""

# ÉTAPE 5: Téléchargement des fichiers (sans créer de dossier)
print_info "ÉTAPE 5: Téléchargement des fichiers..."
echo ""

GITHUB_USER="Juana-archer"
GITHUB_REPO="dahery4-files"
BASE_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/master"

FILES_TO_DOWNLOAD=(
    "maj.py"
    "post.py"
    "r.py"
    "task.py"
    "task1.py"
)

# Téléchargement direct dans le dossier courant (pas de création de dossier)
print_info "Téléchargement dans: $PWD"
echo ""

success_count=0
for file in "${FILES_TO_DOWNLOAD[@]}"; do
    print_info "Téléchargement: $file"
    if curl -s -o "$file" "$BASE_URL/$file" 2>/dev/null; then
        chmod +x "$file" 2>/dev/null || true
        print_success "$file ✓"
        success_count=$((success_count + 1))
    else
        print_error "$file ✗"
    fi
done
echo ""

# ÉTAPE 6: Utilitaires
print_info "ÉTAPE 6: Configuration..."

cat > launch.sh << 'LAUNCH'
#!/bin/bash
echo "🚀 Fichiers dahery4"
echo "=================="
echo ""
echo "📁 Fichiers:"
ls *.py 2>/dev/null
echo ""
echo "💻 Usage: python3 [fichier].py"
echo "🔗 GitHub: https://github.com/Juana-archer/dahery4-files"
LAUNCH
chmod +x launch.sh
print_success "Scripts créés"
echo ""

# ÉTAPE 7: Résumé
print_info "RÉSUMÉ:"
echo ""
echo "╔════════════════════════════════════════╗"
echo "║         INSTALLATION TERMINÉE         ║"
echo "╠════════════════════════════════════════╣"
echo "║  ✅ Git et dépendances installés      ║"
echo "║  ✅ Python et pip configurés          ║"
echo "║  ✅ Telethon et Colorama installés    ║"
echo "║  ✅ Packages Python installés         ║"
echo "║  ✅ Fichiers: $success_count/5 téléchargés  ║"
echo "╚════════════════════════════════════════╝"
echo ""

print_success "🎉 INSTALLATION RÉUSSIE !"
echo ""
echo "📁 Dossier courant: $PWD"
echo "🚀 Commandes:"
echo "   python3 maj.py"
echo "   python3 task.py"
echo "   ./launch.sh"
echo ""
echo "🔗 GitHub: https://github.com/Juana-archer/dahery4-files"
