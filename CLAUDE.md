# CLAUDE.md — Instructions pour Claude Code

> Ce fichier est lu automatiquement par Claude Code au démarrage de chaque session.
> Il oriente le comportement de Claude Code sur ce dépôt.

## Contexte

`anonymiseur-loi25` est un assistant logiciel d'**anonymisation de décisions judiciaires québécoises** au sens de la *Loi 25* (Québec) et de son *Règlement sur l'anonymisation* (entré en vigueur le 30 mai 2024).

C'est un projet de **portfolio droit + IA** réalisé par [@boisalai](https://github.com/boisalai), juriste en formation à l'Université Laval avec un parcours en gestion des TI et en intelligence artificielle. Cible : grands cabinets nationaux et legaltechs.

**Documents de référence** (à consulter avant toute modification structurante) :

- @CADRE_JURIDIQUE.md — cadre légal applicable (articles cités intégralement)
- @ARCHITECTURE.md — décisions techniques et leur justification juridique
- @PLAN.md — jalons hebdomadaires et backlog
- @LIMITATIONS.md — ce que l'outil ne fait PAS

## Stack technique

- **Python 3.12+** géré par [`uv`](https://docs.astral.sh/uv/)
- **LiteLLM** pour l'abstraction des modèles (jamais d'appel direct aux SDK fournisseurs)
- **oMLX local** comme modèle par défaut (Ministral-3-8B-Instruct-2512, port 8000)
- **Anthropic API** comme fallback (Claude Opus 4.7, Sonnet 4.6, Haiku 4.5)
- **Pydantic v2** pour tous les modèles métier
- **Click** pour la CLI
- **pytest** + **ruff** + **mypy** pour les tests et le linting

## Commandes essentielles

```bash
# Installation et synchronisation des dépendances
uv sync

# Démarrer le serveur MLX local (dans un autre terminal)
oMLX serve --model Ministral-3-8B-Instruct-2512-4bit

# Tests
uv run pytest                    # tous les tests
uv run pytest tests/test_ner.py  # un seul fichier
uv run pytest -k "pseudonym"     # par mot-clé

# Linting et type-checking
uv run ruff check .
uv run ruff format .
uv run mypy src/

# Application CLI
uv run anonymiseur process --input X --output Y --operator "Nom Prénom"
```

## Conventions de code

- **Langue de l'interface utilisateur** : **français québécois** (messages CLI, docstrings publiques, README).
- **Langue des commentaires de code** : français pour la logique métier, anglais pour les conventions techniques (TODO, FIXME, NOTE).
- **Style de code** : géré par `ruff` (configuration dans `pyproject.toml`). Ne pas discuter de style — laisser le linter trancher.
- **Imports** : groupés (stdlib, third-party, local), triés par `ruff`.
- **Type hints** : obligatoires sur toutes les fonctions publiques. `mypy --strict` doit passer.

## Règles critiques (priorité absolue)

Ces règles découlent directement du cadre juridique. **Ne jamais les contourner.**

### 1. Pas de persistance des renseignements personnels

- La table de correspondance du `CoherentPseudonymizer` est **maintenue en RAM uniquement**.
- `pseudonymizer.reset()` doit être appelée dans un bloc `try/finally` à la fin de chaque traitement.
- Les valeurs originales des entités **ne doivent jamais** apparaître dans la trace d'audit (`AuditRecord`), seulement les types et les compteurs.

### 2. Champ `operator` obligatoire

- Toute commande de traitement exige un argument `--operator "Nom Prénom"` (art. 4 du Règlement : « personne compétente »).
- Refuser le traitement si ce champ est vide ou contient des caractères de remplissage (« anonyme », « test », etc.).

### 3. Préservation des rôles professionnels

- Juges, avocats, tribunaux, personnes morales : **toujours préservés** par défaut.
- En cas de doute sur le rôle d'une personne, **préférer la préservation à l'anonymisation** (un faux positif sur un juge est moins grave qu'un faux négatif sur une partie).

### 4. Sécurité des secrets

- **Jamais** commit `.env`, `*.audit.json` (sauf ceux du jeu de tests synthétiques), ni de fichier contenant des renseignements personnels réels.
- Vérifier `.gitignore` avant chaque commit qui ajoute un nouveau type de fichier.

## Workflow Git

- Branches : `main` (stable) et branches de fonctionnalités `feature/issue-NN-courte-description`.
- Commits : format [Conventional Commits](https://www.conventionalcommits.org) en français.
  - Exemples : `feat(ner): ajouter le détecteur basé sur des règles`, `fix(audit): corriger la sérialisation des dates`, `docs(cadre): préciser l'art. 9 du Règlement`.
- PR : titre = description du changement, corps = lien vers l'issue, capture d'écran si UI.
- CI doit être verte avant fusion.

## Comportements à privilégier

- **Avant d'écrire du code** : vérifier que la fonctionnalité a une issue dans `PLAN.md` ou GitHub. Sinon, en proposer une.
- **Avant de modifier l'architecture** : relire la section pertinente de `@ARCHITECTURE.md`. Si la modification est significative, créer un ADR dans `docs/adr/`.
- **Avant d'ajouter une dépendance** : justifier dans le commit, vérifier la licence, vérifier la maintenance active.
- **Tests d'abord** quand c'est raisonnable (TDD light) : pour le NER et l'analyse de risques, écrire le cas de test annoté avant l'implémentation.
- **Petits commits fréquents** plutôt qu'un gros commit final.

## Comportements à éviter

- **Ne pas inventer** d'articles de loi ou de jurisprudence. Si une source manque, signaler que la vérification humaine est requise.
- **Ne pas paraphraser** un article de loi cité — toujours utiliser le texte officiel de [LégisQuébec](https://www.legisquebec.gouv.qc.ca).
- **Ne pas utiliser** de SDK fournisseur directement (`anthropic`, `openai`) — passer par LiteLLM.
- **Ne pas écrire** de code de style — laisser `ruff format` gérer.
- **Ne pas créer** de fichiers de test contenant des renseignements personnels réels — utiliser des données synthétiques ou des décisions publiques déjà anonymisées par les tribunaux.

## En cas de doute

- Sur le **droit** : signaler explicitement et renvoyer à `@CADRE_JURIDIQUE.md`. Ne pas spéculer.
- Sur l'**architecture** : signaler et renvoyer à `@ARCHITECTURE.md`. Si vraiment ambigu, créer un ADR.
- Sur le **périmètre** : signaler et renvoyer à `@PLAN.md`. Si la tâche n'est pas dans le plan, demander à l'utilisateur avant de commencer.

## Format des réponses

L'utilisateur préfère :

- des réponses **brèves, précises, pédagogiques**, en **français**;
- du **Markdown** structuré (titres, listes, tableaux quand pertinent);
- pas de référence ajoutée de mémoire — seulement ce qui est vérifiable;
- pour le droit, **toujours chercher le texte officiel** des articles plutôt que paraphraser.

---

*Ce fichier doit rester sous 200 lignes. Pour des instructions ponctuelles ou des workflows spécifiques, créer un Skill dans `.claude/skills/` plutôt que d'allonger ce fichier.*
