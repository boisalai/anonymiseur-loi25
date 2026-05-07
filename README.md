# anonymiseur-loi25

> **Assistant d'anonymisation de décisions judiciaires québécoises** conforme à la *[Loi 25](https://www.legisquebec.gouv.qc.ca/fr/document/lc/p-39.1)* et au *[Règlement sur l'anonymisation des renseignements personnels](https://www.legisquebec.gouv.qc.ca/fr/document/rc/A-2.1,%20r.%200.1)* (entré en vigueur le 30 mai 2024).

[![Statut](https://img.shields.io/badge/statut-en_d%C3%A9veloppement-orange)](./PLAN.md)
[![Licence](https://img.shields.io/badge/licence-MIT-blue)](./LICENSE)
[![Python](https://img.shields.io/badge/python-3.12%2B-blue)](https://www.python.org/)
[![Code style: ruff](https://img.shields.io/badge/style-ruff-000000)](https://docs.astral.sh/ruff/)
[![Cadre légal](https://img.shields.io/badge/loi-25%20(QC)-purple)](./CADRE_JURIDIQUE.md)

---

## En bref

L'utilisation d'un corpus de décisions judiciaires québécoises pour entraîner, affiner ou évaluer un modèle de langue (LLM) soulève une obligation juridique précise : ces décisions, bien que publiques, contiennent souvent des renseignements personnels qui restent assujettis à la **Loi sur la protection des renseignements personnels dans le secteur privé** (RLRQ c P-39.1). L'article 23 de cette loi exige une **anonymisation irréversible** lorsque ces renseignements sont conservés au-delà de leur finalité initiale.

`anonymiseur-loi25` est un assistant logiciel qui automatise les étapes techniques de ce processus tout en préservant le rôle central de la **« personne compétente en la matière »** prévu à l'article 4 du Règlement.

---

## Pour les juristes

### Pourquoi ce projet existe

Trois constats juridiques motivent ce projet :

1. **Les décisions publiées sur CanLII et SOQUIJ contiennent des renseignements personnels résiduels** — adresses, numéros de dossiers, employeurs précis, dates et lieux qui permettent l'identification indirecte malgré une anonymisation partielle par les tribunaux.

2. **L'utilisation de ces décisions pour entraîner un modèle d'IA constitue un traitement assujetti à la Loi 25** lorsqu'il est effectué par une entreprise ou un ordre professionnel québécois.

3. **Le Règlement sur l'anonymisation, entré en vigueur le 30 mai 2024, impose un processus structuré** en huit étapes (art. 3 à 9), incluant l'analyse des trois critères d'individualisation, de corrélation et d'inférence.

### Ce que l'outil fait

- Identifie automatiquement les **identifiants directs** (noms de parties physiques, adresses, numéros de téléphone, courriels, NAS, dates de naissance, identifiants bancaires).
- Identifie les **identifiants indirects** principaux (lieux précis, employeurs, professions atypiques, dates spécifiques).
- Distingue les **rôles juridiques** : préserve les juges, avocats, tribunaux et personnes morales (qui ne sont pas couverts par la Loi 25); anonymise les parties physiques, témoins civils, victimes.
- Produit une **trace d'audit** structurée conforme aux exigences de l'article 9 du Règlement.
- Évalue les **risques résiduels de réidentification** selon les trois critères de l'article 5.

### Ce que l'outil ne fait pas

- Il ne **garantit pas** la conformité au sens de l'article 23 LPRPSP : seule une analyse de risques formelle (art. 7), conduite par une personne compétente, peut établir cette conformité.
- Il ne **remplace pas** la « personne compétente en la matière » exigée à l'article 4 du Règlement.
- Il ne **détecte pas tous** les risques d'inférence par croisement avec des sources externes (publications médiatiques, registres publics, réseaux sociaux).

Voir [LIMITATIONS.md](./LIMITATIONS.md) pour la liste exhaustive.

### Documentation juridique

L'analyse complète du cadre légal applicable se trouve dans [`CADRE_JURIDIQUE.md`](./CADRE_JURIDIQUE.md), incluant :

- texte intégral de l'article 23 LPRPSP et des articles 1 à 9 du Règlement;
- distinction conceptuelle entre anonymisation, dépersonnalisation et pseudonymisation (RGPD);
- application aux ordres professionnels (Code des professions);
- analyse des sanctions applicables (jusqu'à 25 M$ ou 4 % du chiffre d'affaires mondial);
- bibliographie des sources officielles et de la doctrine pertinente.

---

## Pour les développeurs

### Architecture

```
┌─────────────────────────────────────────────────┐
│   CLI / Notebook / Gradio / API REST            │
└──────────────────┬──────────────────────────────┘
                   │
         ┌─────────▼─────────┐
         │  PIPELINE (7 étapes)│
         └─────────┬─────────┘
                   │
   ┌───────────────┼───────────────┐
   ▼               ▼               ▼
NER hybride   Classificateur   Pseudonymiseur
(règles +     de rôles         cohérent
 spaCy +      (LLM)            (intra-doc,
 LLM)                          réinitialisable)
   │               │               │
   └───────────────┼───────────────┘
                   ▼
         ┌─────────────────────┐
         │  Analyse de risques │
         │  (3 critères, art.5)│
         └─────────────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │  LiteLLM (abstraction)
         └──┬───────┬──────────┘
            │       │
       oMLX local  Anthropic API
       (Ministral) (Opus 4.7,
                    Sonnet 4.6,
                    Haiku 4.5)
```

L'architecture détaillée et la justification de chaque choix technique se trouvent dans [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### Stack technique

| Composant | Choix | Pourquoi |
|-----------|-------|----------|
| Langage | Python 3.12+ | Écosystème NLP de référence |
| Gestion paquets | [`uv`](https://docs.astral.sh/uv/) | Vitesse, standard 2026 |
| Abstraction LLM | [LiteLLM](https://github.com/BerriAI/litellm) | Indépendance fournisseur |
| Modèle local | [Ministral 3 8B Instruct](https://huggingface.co/mistralai/Ministral-3-8B-Instruct-2512) via oMLX | Souveraineté, multilingue, function calling natif |
| Modèles cloud | Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5 | Escalade pour cas complexes |
| Modèles métier | [Pydantic v2](https://docs.pydantic.dev) | Validation + sérialisation JSON |
| NER classique | [spaCy](https://spacy.io) `fr_core_news_lg` | Banc d'essai et fallback |
| CLI | [Click](https://click.palletsprojects.com) | Standard mature |
| Démo | [Gradio](https://www.gradio.app) | Interface rapide pour HF Spaces |
| Tests | `pytest`, `ruff`, `mypy` | Qualité de code |

### Démarrage rapide

```bash
# Cloner et installer
git clone https://github.com/boisalai/anonymiseur-loi25.git
cd anonymiseur-loi25
uv sync

# Démarrer le serveur MLX local (terminal séparé)
oMLX serve --model Ministral-3-8B-Instruct-2512-4bit

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec votre clé Anthropic (optionnelle, pour fallback)

# Traiter une décision
uv run anonymiseur process \
  --input chemin/vers/decision.html \
  --output sortie/ \
  --operator "Nom Prénom"
```

### Sortie produite

Pour chaque décision traitée, trois fichiers sont générés :

```
sortie/
├── 2024QCCS1234_anonymized.md   # Document anonymisé
├── 2024QCCS1234_annotated.md    # Version annotée (lecture humaine)
└── 2024QCCS1234_audit.json      # Trace d'audit (art. 9 du Règlement)
```

### Tests et évaluation

```bash
uv run pytest                    # Suite complète
uv run pytest --cov=src          # Avec couverture
uv run ruff check .              # Linting
uv run mypy src/                 # Vérification de types
```

Cibles de qualité (fin de phase 2, août 2026) :

- Couverture de tests : **≥ 80 %**
- F1 sur identifiants directs : **≥ 0.95**
- F1 sur classification de rôles : **≥ 0.85**

---

## État du projet

| Phase | Période | Statut |
|-------|---------|--------|
| 0 — Documents fondateurs et environnement | Mai 2026 | 🔄 En cours |
| 1 — MVP fonctionnel (règles déterministes) | Juin 2026 | ⬜ À venir |
| 2 — Été intensif (LLM, classification, démo) | Juillet – Août 2026 | ⬜ À venir |
| 3 — Polissage et publication | Septembre – Octobre 2026 | ⬜ À venir |

Plan détaillé et backlog GitHub dans [`PLAN.md`](./PLAN.md).

---

## Documents de référence

| Document | Contenu |
|----------|---------|
| [`CADRE_JURIDIQUE.md`](./CADRE_JURIDIQUE.md) | Cadre légal applicable (Loi 25, Règlement, Code des professions) |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | Décisions techniques justifiées |
| [`PLAN.md`](./PLAN.md) | Jalons hebdomadaires et backlog de 42 issues |
| [`LIMITATIONS.md`](./LIMITATIONS.md) | Ce que l'outil ne fait PAS |
| [`CLAUDE.md`](./CLAUDE.md) | Instructions pour Claude Code |

---

## Contexte du projet

Ce projet fait partie d'un **portfolio d'applications IA appliquées au droit québécois** développé par [@boisalai](https://github.com/boisalai), juriste en formation à l'Université Laval, ex-gestionnaire au gouvernement du Québec, MBA en gestion des TI et DESS en intelligence artificielle, administrateur à la Chambre des notaires du Québec.

L'objectif est de démontrer une **double compétence droit + IA** centrée sur les particularités du contexte québécois (français, jurisprudence locale, cadre normatif provincial) à destination des grands cabinets nationaux et des legaltechs.

Autres projets prévus dans le portfolio :

- RAG sur jurisprudence québécoise (CanLII / SOQUIJ)
- Analyseur d'actes notariés (extraction de clauses, vérification de forme)
- Extracteur de tests jurisprudentiels (ratio decidendi, test *Oakes*, test *Hunter*)
- Projet phare à définir

---

## Contribuer

Ce dépôt est principalement un projet de portfolio personnel, mais les contributions sont bienvenues, particulièrement :

- **Signalement d'imprécisions juridiques** dans `CADRE_JURIDIQUE.md` (ouvrir une *issue* avec étiquette `type:doc`)
- **Décisions de référence** annotées (compléter `tests/data/decisions_test/`)
- **Améliorations du NER** sur des cas problématiques (joindre la décision et le résultat attendu)

Voir les [issues ouvertes](https://github.com/boisalai/anonymiseur-loi25/issues) pour les tâches en cours.

---

## Licence

[MIT](./LICENSE) — voir le fichier `LICENSE` pour le texte complet.

L'utilisation du logiciel est libre, mais elle ne dispense pas l'utilisateur de ses obligations légales en matière de protection des renseignements personnels. **Aucune garantie de conformité à la Loi 25 n'est offerte.**

---

## Crédits

Auteur principal : [@boisalai](https://github.com/boisalai)

La première version des documents fondateurs (`CADRE_JURIDIQUE.md`, `ARCHITECTURE.md`, `PLAN.md`, `CLAUDE.md`, `README.md`) a été co-rédigée avec **Claude Opus 4.7** ([Anthropic](https://www.anthropic.com)) selon une approche transparente où chaque document indique son auteur et la nécessité d'une vérification humaine, conformément aux principes de supervision humaine prévus à l'article 4 du *Règlement sur l'anonymisation des renseignements personnels*.

Sources officielles consultées : [LégisQuébec](https://www.legisquebec.gouv.qc.ca), [CanLII](https://www.canlii.org), [Commission d'accès à l'information du Québec](https://www.cai.gouv.qc.ca).

---

*Dernière mise à jour : 7 mai 2026.*
