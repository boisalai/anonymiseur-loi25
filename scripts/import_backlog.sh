#!/usr/bin/env bash
# scripts/import_backlog.sh
#
# Crée les étiquettes et les 42 issues du backlog dans le dépôt GitHub courant.
#
# Prérequis :
#   - gh CLI installé et authentifié (https://cli.github.com/)
#   - Exécuté depuis la racine du dépôt anonymiseur-loi25
#   - Permission d'écriture sur le dépôt
#
# Usage :
#   bash scripts/import_backlog.sh
#
# Idempotence :
#   - Les étiquettes existantes sont mises à jour (gh label create --force)
#   - Les issues sont toujours créées en double si le script est relancé.
#     Pour éviter les doublons, supprimer les issues précédentes ou commenter
#     les sections déjà importées.

set -euo pipefail

# -----------------------------------------------------------------------------
# Vérifications préalables
# -----------------------------------------------------------------------------

command -v gh >/dev/null 2>&1 || {
  echo "❌ gh CLI introuvable. Installer depuis https://cli.github.com/" >&2
  exit 1
}

gh auth status >/dev/null 2>&1 || {
  echo "❌ gh CLI non authentifié. Lancer 'gh auth login' d'abord." >&2
  exit 1
}

# Vérifier qu'on est dans un dépôt Git GitHub
gh repo view >/dev/null 2>&1 || {
  echo "❌ Pas dans un dépôt GitHub. Exécuter depuis la racine du dépôt." >&2
  exit 1
}

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "📦 Cible : $REPO"
echo

# -----------------------------------------------------------------------------
# 1. Création des étiquettes
# -----------------------------------------------------------------------------

echo "🏷️  Création des étiquettes..."

create_label() {
  local name=$1
  local color=$2
  local description=${3:-""}
  gh label create "$name" --color "$color" --description "$description" --force >/dev/null 2>&1 \
    && echo "  ✓ $name" \
    || echo "  ⚠ $name (échec)"
}

# Phases
create_label "phase:0-setup"    "808080" "Phase 0 : mise en place (mai 2026)"
create_label "phase:1-mvp"      "B3D9FF" "Phase 1 : MVP fonctionnel (juin 2026)"
create_label "phase:2-summer"   "0066CC" "Phase 2 : été intensif (juillet-août 2026)"
create_label "phase:3-polish"   "00CC66" "Phase 3 : polissage et publication (sept-oct 2026)"

# Types
create_label "type:doc"         "9933CC" "Documentation"
create_label "type:code"        "FF9933" "Code source"
create_label "type:test"        "FFCC00" "Tests"
create_label "type:infra"       "333333" "Infrastructure et tooling"
create_label "type:research"    "FF99CC" "Recherche et exploration"

# Priorités
create_label "priority:high"    "CC0000" "Priorité haute"
create_label "priority:medium"  "FF6600" "Priorité moyenne"
create_label "priority:low"     "CCCCCC" "Priorité basse"

# Domaines
create_label "area:ner"         "00CCCC" "Reconnaissance d'entités nommées"
create_label "area:llm"         "00CCCC" "Couche modèle de langue"
create_label "area:audit"       "00CCCC" "Trace d'audit"
create_label "area:risk"        "00CCCC" "Analyse de risques"
create_label "area:cli"         "00CCCC" "Interface en ligne de commande"
create_label "area:demo"        "00CCCC" "Démonstration et UI"

echo

# -----------------------------------------------------------------------------
# 2. Création des issues
# -----------------------------------------------------------------------------

echo "📝 Création des 42 issues du backlog..."
echo

create_issue() {
  local title=$1
  local labels=$2
  local body=$3
  gh issue create \
    --title "$title" \
    --label "$labels" \
    --body "$body" \
    >/dev/null \
    && echo "  ✓ $title" \
    || echo "  ⚠ $title (échec)"
}

# -----------------------------------------------------------------------------
# Phase 0 — Setup
# -----------------------------------------------------------------------------

echo "## Phase 0 — Setup"

create_issue \
  "Initialiser le projet Python avec uv" \
  "phase:0-setup,type:infra,priority:high" \
  "## Description

- Installer \`uv\` (https://docs.astral.sh/uv/)
- \`uv init\` à la racine du dépôt
- Configurer \`pyproject.toml\` avec les dépendances de base : \`litellm\`, \`pydantic\`, \`click\`, \`python-dotenv\`, \`pytest\`, \`ruff\`, \`mypy\`
- Ajouter \`pre-commit\` et configurer les hooks (ruff format, ruff check)

## Critères d'acceptation
- \`uv sync\` fonctionne sur une machine vierge
- \`pyproject.toml\` versionné

## Référence
PLAN.md issue #1"

create_issue \
  "Configurer .gitignore et .env.example" \
  "phase:0-setup,type:infra,priority:high" \
  "## Description
Créer les fichiers de configuration de base :
- \`.gitignore\` (Python + IDE + env)
- \`.env.example\` avec toutes les variables documentées
- \`.editorconfig\`

## Référence
PLAN.md issue #2"

create_issue \
  "Tester la connectivité oMLX local" \
  "phase:0-setup,type:infra,priority:high,area:llm" \
  "## Description
- Script \`scripts/test_omlx.py\` qui appelle Ministral via oMLX et imprime la réponse
- Documenter le démarrage du serveur dans \`docs/setup_omlx.md\`

## Critères d'acceptation
- Le script retourne une réponse cohérente du modèle local

## Référence
PLAN.md issue #3"

create_issue \
  "Premier appel LLM via LiteLLM" \
  "phase:0-setup,type:code,priority:high,area:llm" \
  "## Description
- \`src/llm_client.py\` minimal (classe \`LLMClient\` avec méthode \`complete()\`)
- Test unitaire qui fait un appel réel

## Référence
PLAN.md issue #4"

create_issue \
  "Configurer GitHub Actions (CI minimale)" \
  "phase:0-setup,type:infra,priority:medium" \
  "## Description
Workflow \`.github/workflows/ci.yml\` qui exécute :
- \`uv sync\`
- \`uv run ruff check\`
- \`uv run pytest\`

Sur push et pull request.

## Référence
PLAN.md issue #5"

create_issue \
  "Télécharger 10 décisions CanLII de référence" \
  "phase:0-setup,type:research,priority:high" \
  "## Description
- Choisir 10 décisions variées (civil, travail, famille avec parties majeures)
- Respecter les conditions d'utilisation de CanLII
- Stocker dans \`tests/data/decisions_test/\`
- Documenter chaque source (URL, date d'accès)

## Référence
PLAN.md issue #6"

create_issue \
  "Annoter manuellement les 10 décisions" \
  "phase:0-setup,type:research,priority:high" \
  "## Description
- Créer un fichier JSONL par décision avec entités annotées
- Format : \`{text, start, end, type, role}\`
- Rédiger \`tests/data/ANNOTATION_GUIDE.md\` pour reproductibilité

## Référence
PLAN.md issue #7"

create_issue \
  "Rédiger CLAUDE.md (instructions pour Claude Code)" \
  "phase:0-setup,type:doc,priority:medium" \
  "## Description
Décrire le projet, les conventions de code, les fichiers de référence, les commandes utiles. Sera lu par Claude Code à chaque session.

## Critères d'acceptation
- Moins de 200 lignes
- Importation des autres docs via \`@\` syntax

## Référence
PLAN.md issue #8"

create_issue \
  "Rédiger README.md initial" \
  "phase:0-setup,type:doc,priority:high" \
  "## Description
Page d'accueil du dépôt. Inclure :
- description du projet
- statut (en développement)
- liens vers les autres docs
- instructions de démarrage

## Référence
PLAN.md issue #9"

create_issue \
  "Rédiger LIMITATIONS.md initial" \
  "phase:0-setup,type:doc,priority:medium" \
  "## Description
Documenter explicitement ce que l'outil ne fait pas, les hypothèses, les avertissements légaux.

## Référence
PLAN.md issue #10"

# -----------------------------------------------------------------------------
# Phase 1 — MVP
# -----------------------------------------------------------------------------

echo
echo "## Phase 1 — MVP"

create_issue \
  "Implémenter ingestion HTML CanLII" \
  "phase:1-mvp,type:code,priority:high,area:cli" \
  "## Description
\`src/ingestion.py\` lit un fichier HTML CanLII et extrait :
- texte intégral
- métadonnées (cour, numéro, date, parties)

Sortie : modèle Pydantic \`Document\`.

## Référence
PLAN.md issue #11"

create_issue \
  "Implémenter ingestion TXT et PDF" \
  "phase:1-mvp,type:code,priority:medium,area:cli" \
  "## Description
Extension de \`ingestion.py\` pour :
- TXT (lecture directe)
- PDF (\`pdfplumber\`)

## Référence
PLAN.md issue #12"

create_issue \
  "Définir les modèles Pydantic métier" \
  "phase:1-mvp,type:code,priority:high" \
  "## Description
\`src/models.py\` avec :
- \`Document\`
- \`Entity\`, \`EntityType\`, \`EntityRole\`
- \`Transformation\`
- \`RiskAssessment\`
- \`AuditRecord\`

## Référence
PLAN.md issue #13"

create_issue \
  "Implémenter le NER règles déterministes" \
  "phase:1-mvp,type:code,priority:high,area:ner" \
  "## Description
\`src/ner.py::RuleBasedDetector\` avec regex pour :
- NAS
- RAMQ
- dates
- codes postaux
- téléphones
- courriels

Documentation des patterns dans le code.

## Référence
PLAN.md issue #14"

create_issue \
  "Tests unitaires NER règles" \
  "phase:1-mvp,type:test,priority:high,area:ner" \
  "## Description
50+ cas synthétiques couvrant les formats valides et invalides.

## Critère d'acceptation
F1 ≥ 0.95 sur identifiants directs synthétiques.

## Référence
PLAN.md issue #15"

create_issue \
  "Implémenter le pseudonymiseur cohérent" \
  "phase:1-mvp,type:code,priority:high" \
  "## Description
\`src/pseudonymizer.py::CoherentPseudonymizer\` avec :
- table de correspondance interne en RAM
- méthode \`reset()\` pour effacement

## Règle critique
La table ne doit jamais être persistée sur disque.

## Référence
PLAN.md issue #16"

create_issue \
  "Implémenter les profils A et B" \
  "phase:1-mvp,type:code,priority:medium" \
  "## Description
- Profil A : suppression marquée (\`[PARTIE_DEMANDERESSE]\`)
- Profil B : substitution lisible (\`Personne A\`)

Configurable via \`config.toml\`.

## Référence
PLAN.md issue #17"

create_issue \
  "Tests effacement table de correspondance" \
  "phase:1-mvp,type:test,priority:high" \
  "## Description
Tests vérifiant que :
- la table est vide après \`reset()\`
- \`reset()\` est appelée même en cas d'exception (try/finally)

## Référence
PLAN.md issue #18"

create_issue \
  "Pipeline d'orchestration MVP" \
  "phase:1-mvp,type:code,priority:high" \
  "## Description
\`src/pipeline.py\` orchestrant :
1. ingestion
2. NER règles
3. pseudonymisation
4. sortie

État immuable (dataclass frozen).

## Référence
PLAN.md issue #19"

create_issue \
  "Interface CLI avec Click" \
  "phase:1-mvp,type:code,priority:high,area:cli" \
  "## Description
Commande :
\`\`\`
anonymiseur process --input X --output Y --operator \"Nom Prénom\"
\`\`\`
- Aide complète
- Validation des arguments
- Argument \`--operator\` obligatoire (art. 4 du Règlement)

## Référence
PLAN.md issue #20"

create_issue \
  "Trace d'audit MVP (JSON)" \
  "phase:1-mvp,type:code,priority:medium,area:audit" \
  "## Description
\`AuditRecord\` minimal généré pour chaque traitement.
Validation Pydantic stricte.

## Référence
PLAN.md issue #21"

create_issue \
  "Tests d'intégration MVP" \
  "phase:1-mvp,type:test,priority:high" \
  "## Description
Tester le pipeline complet sur les 10 décisions de référence.
Snapshots de sortie pour régression.

## Référence
PLAN.md issue #22"

# -----------------------------------------------------------------------------
# Phase 2 — Été intensif
# -----------------------------------------------------------------------------

echo
echo "## Phase 2 — Été intensif"

create_issue \
  "Intégrer spaCy fr_core_news_lg" \
  "phase:2-summer,type:code,priority:medium,area:ner" \
  "## Description
\`src/ner.py::SpacyDetector\`.
Téléchargement automatique du modèle.
Benchmarks vs règles.

## Référence
PLAN.md issue #23"

create_issue \
  "Implémenter LLMDetector avec function calling" \
  "phase:2-summer,type:code,priority:high,area:ner,area:llm" \
  "## Description
Prompt structuré + Pydantic schema en \`tools\` LiteLLM.
Tests sur Ministral local et Claude Haiku 4.5.

## Référence
PLAN.md issue #24"

create_issue \
  "Notebook benchmark NER" \
  "phase:2-summer,type:research,priority:medium,area:ner" \
  "## Description
\`notebooks/benchmark_ner.ipynb\` comparant :
- règles
- spaCy
- LLM

Métriques détaillées par type d'entité.

## Référence
PLAN.md issue #25"

create_issue \
  "Implémenter classificateur de rôles" \
  "phase:2-summer,type:code,priority:high,area:ner,area:llm" \
  "## Description
\`src/role_classifier.py\` distinguant :
- party
- judge
- lawyer
- witness
- expert
- legal_entity
- etc.

## Critère d'acceptation
F1 ≥ 0.85 sur le jeu de référence.

## Référence
PLAN.md issue #26"

create_issue \
  "HybridDetector" \
  "phase:2-summer,type:code,priority:high,area:ner" \
  "## Description
Composition règles → spaCy → LLM avec déduplication.
Doit battre chaque détecteur individuel sur le jeu de référence.

## Référence
PLAN.md issue #27"

create_issue \
  "Analyse risques : critère d'individualisation" \
  "phase:2-summer,type:code,priority:high,area:risk" \
  "## Description
Heuristiques sur les attributs résiduels rares.
Documentation des choix dans le code.

## Référence
PLAN.md issue #28"

create_issue \
  "Analyse risques : critère de corrélation" \
  "phase:2-summer,type:code,priority:high,area:risk" \
  "## Description
Détection de référents externes :
- numéros de dossier judiciaire
- entreprises identifiables
- références à des affaires médiatisées

## Référence
PLAN.md issue #29"

create_issue \
  "Analyse risques : critère d'inférence" \
  "phase:2-summer,type:code,priority:high,area:risk,area:llm" \
  "## Description
Appel LLM avec prompt : « peux-tu inférer l'identité ? »
Score qualitatif {très faible, faible, moyen, élevé}.

## Référence
PLAN.md issue #30"

create_issue \
  "Trace d'audit complète" \
  "phase:2-summer,type:code,priority:high,area:audit" \
  "## Description
\`AuditRecord\` complet conforme au schéma art. 9 du Règlement.
Sortie JSON + Markdown.

## Référence
PLAN.md issue #31"

create_issue \
  "Application Gradio" \
  "phase:2-summer,type:code,priority:high,area:demo" \
  "## Description
\`gradio_app.py\` à la racine :
- champ texte pour coller une décision
- bouton « Anonymiser »
- visualisation côte-à-côte
- rapport de risques

## Référence
PLAN.md issue #32"

create_issue \
  "Déploiement Hugging Face Spaces" \
  "phase:2-summer,type:infra,priority:high,area:demo" \
  "## Description
- Configuration du Space
- Secrets API
- Badge dans le README
- URL publique communiquée

## Référence
PLAN.md issue #33"

create_issue \
  "Couverture de tests ≥ 80 %" \
  "phase:2-summer,type:test,priority:high" \
  "## Description
Compléter les tests jusqu'à atteindre la cible.
Configuration de \`coverage\` dans la CI.

## Référence
PLAN.md issue #34"

create_issue \
  "Notebook benchmark modèles" \
  "phase:2-summer,type:research,priority:medium,area:llm" \
  "## Description
\`notebooks/benchmark_models.ipynb\` comparant :
- Ministral 3 8B (local)
- Claude Haiku 4.5
- Claude Sonnet 4.6
- Claude Opus 4.7

Axes : précision, latence, coût.

## Référence
PLAN.md issue #35"

create_issue \
  "Notebook évaluation finale" \
  "phase:2-summer,type:research,priority:high" \
  "## Description
Métriques précision/rappel/F1 :
- par type d'entité
- par rôle
- sur le jeu de référence

## Référence
PLAN.md issue #36"

# -----------------------------------------------------------------------------
# Phase 3 — Polissage
# -----------------------------------------------------------------------------

echo
echo "## Phase 3 — Polissage"

create_issue \
  "Finaliser README avec captures" \
  "phase:3-polish,type:doc,priority:high" \
  "## Description
- Captures d'écran de la démo
- Badges
- Table des matières des docs
- Instructions claires

## Référence
PLAN.md issue #37"

create_issue \
  "Vidéo de démonstration" \
  "phase:3-polish,type:doc,priority:medium" \
  "## Description
5-7 minutes :
- présentation du projet
- démo Gradio
- exemple d'audit

Hébergement YouTube (non listé) ou GitHub.
Lien depuis README.

## Référence
PLAN.md issue #38"

create_issue \
  "Billet de blog technique" \
  "phase:3-polish,type:doc,priority:medium" \
  "## Description
1 500-2 000 mots.
Angle : pont droit + IA dans le contexte québécois.

## Référence
PLAN.md issue #39"

create_issue \
  "Publication LinkedIn et mise à jour CV" \
  "phase:3-polish,priority:medium" \
  "## Description
- Posts LinkedIn ciblés (cabinets, legaltechs)
- Mise à jour profil LinkedIn et CV
- Lien vers le portfolio

## Référence
PLAN.md issue #40"

create_issue \
  "Liste cibles de candidature" \
  "phase:3-polish,priority:high" \
  "## Description
- 10-15 cabinets/legaltechs québécois et canadiens prioritaires
- Personnes-ressources identifiées
- Plan d'approche personnalisé

## Référence
PLAN.md issue #41"

create_issue \
  "Démarches réseau et événements" \
  "phase:3-polish,priority:medium" \
  "## Description
- Barreau du Québec
- Chambre des notaires
- AQDIJ
- Événements legaltech

Présence active.

## Référence
PLAN.md issue #42"

# -----------------------------------------------------------------------------
# Récapitulatif
# -----------------------------------------------------------------------------

echo
echo "✅ Import terminé."
echo
echo "📊 Vérifier dans GitHub :"
echo "   https://github.com/$REPO/issues"
echo "   https://github.com/$REPO/labels"
echo
echo "💡 Prochaines étapes :"
echo "   1. Visiter le dépôt et vérifier que tout est bien créé"
echo "   2. Optionnellement, créer un GitHub Project pour organiser le backlog"
echo "   3. Commencer par l'issue #1 dans Claude Code"
