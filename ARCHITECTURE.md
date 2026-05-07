# Architecture — `anonymiseur-loi25`

> **Document technique** complétant [`CADRE_JURIDIQUE.md`](./CADRE_JURIDIQUE.md).
>
> **Dernière mise à jour** : 7 mai 2026.
>
> **Auteur** : Claude Opus 4.7 (Anthropic), avec la direction éditoriale de [@boisalai](https://github.com/boisalai).
>
> ⚠️ **Vérification humaine requise** — Ce document décrit une architecture proposée par un assistant d'IA. Les choix techniques doivent être validés à la lumière de l'expérience opérationnelle. Toute décision d'architecture qui impacte la sécurité, la conformité ou la performance en production doit être révisée par un ingénieur logiciel qualifié.

---

## Table des matières

1. [Principes directeurs](#1-principes-directeurs)
2. [Vue d'ensemble](#2-vue-densemble)
3. [Choix techniques justifiés](#3-choix-techniques-justifiés)
4. [Composants détaillés](#4-composants-détaillés)
5. [Flux de données](#5-flux-de-données)
6. [Stockage et persistance](#6-stockage-et-persistance)
7. [Tests et évaluation](#7-tests-et-évaluation)
8. [Sécurité et chiffrement](#8-sécurité-et-chiffrement)
9. [Déploiement](#9-déploiement)
10. [Décisions d'architecture reportées (ADR)](#10-décisions-darchitecture-reportées)

---

## 1. Principes directeurs

L'architecture du projet est gouvernée par cinq principes, chacun découlant d'une exigence du cadre juridique ou d'une bonne pratique de génie logiciel.

| Principe | Justification |
|---------|---------------|
| **Souveraineté des données** | Les renseignements personnels ne doivent jamais quitter la machine de l'utilisateur sans autorisation explicite. Tous les traitements par défaut sont locaux. |
| **Indépendance technologique** | Aucun couplage à un fournisseur de modèle unique. Tous les appels passent par une couche d'abstraction (LiteLLM). |
| **Traçabilité** | Chaque transformation appliquée est journalisée pour permettre la tenue de registre exigée à l'art. 9 du Règlement. |
| **Supervision humaine** | L'outil propose, l'humain dispose. Aucune décision irréversible n'est prise sans validation humaine explicite. |
| **Reproductibilité** | Mêmes entrées + même seed = mêmes sorties. Critique pour l'auditabilité et les tests. |

---

## 2. Vue d'ensemble

### 2.1. Architecture en couches

```
┌─────────────────────────────────────────────────────────────────┐
│                       INTERFACES UTILISATEUR                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌──────────────┐   │
│  │   CLI    │  │ Notebook │  │  Gradio    │  │  API REST    │   │
│  │  (Click) │  │ Jupyter  │  │  (démo)    │  │  (FastAPI)   │   │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘  └──────┬───────┘   │
└───────┼─────────────┼──────────────┼─────────────────┼──────────┘
        └─────────────┴──────────────┴─────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                       PIPELINE D'ORCHESTRATION                  │
│                            (pipeline.py)                        │
└─────┬───────────────────┬───────────────────┬───────────────────┘
      │                   │                   │
┌─────▼─────┐  ┌──────────▼─────────┐  ┌──────▼──────────────┐
│  PARSER   │  │   NER HYBRIDE      │  │ CLASSIFICATEUR DE   │
│  (input)  │  │ règles + LLM       │  │ RÔLES (juge, partie,│
│           │  │                    │  │ avocat, témoin)     │
└───────────┘  └─────────┬──────────┘  └──────────┬──────────┘
                         │                        │
                         └───────────┬────────────┘
                                     │
                          ┌──────────▼──────────┐
                          │   PSEUDONYMISEUR    │
                          │   COHÉRENT          │
                          └──────────┬──────────┘
                                     │
                  ┌──────────────────┼──────────────────┐
                  │                  │                  │
        ┌─────────▼────────┐ ┌───────▼────────┐ ┌──────▼──────┐
        │ ANALYSE RISQUES  │ │ GÉNÉRATEUR DE  │ │   SORTIES   │
        │ (3 critères)     │ │ TRACE D'AUDIT  │ │  multi-     │
        │                  │ │                │ │  format     │
        └──────────────────┘ └────────────────┘ └─────────────┘
                                     │
                       ┌─────────────▼─────────────┐
                       │   COUCHE D'ABSTRACTION    │
                       │        LiteLLM            │
                       └──┬──────────┬─────────┬───┘
                          │          │         │
                  ┌───────▼──┐ ┌─────▼──┐ ┌────▼────────┐
                  │  oMLX    │ │Claude  │ │  Azure      │
                  │  local   │ │API     │ │  Foundry    │
                  │(Ministral│ │(escala-│ │(optionnel)  │
                  │  3 8B)   │ │ tion)  │ │             │
                  └──────────┘ └────────┘ └─────────────┘
```

### 2.2. Pipeline en sept étapes

```
1. INGESTION         → Lecture du document source (HTML CanLII, TXT, PDF)
2. PARSING           → Extraction texte + métadonnées (parties, juge, date)
3. DÉTECTION         → NER hybride (règles + LLM) → liste d'entités candidates
4. CLASSIFICATION    → Attribution d'un rôle à chaque entité
5. TRANSFORMATION    → Application des techniques d'anonymisation
6. ANALYSE RISQUES   → Évaluation des trois critères (art. 5 du Règlement)
7. SORTIE            → Document anonymisé + trace d'audit + rapport
```

---

## 3. Choix techniques justifiés

### 3.1. Pourquoi LiteLLM (couche d'abstraction)

**Décision** : utiliser [LiteLLM](https://github.com/BerriAI/litellm) comme couche unique d'appel aux modèles de langue.

**Justification** :

- **Indépendance fournisseur** : permet de basculer entre oMLX local, API Anthropic, OpenAI, Azure Foundry sans modifier le code applicatif.
- **Format unique** : compatible OpenAI Chat Completions partout (Anthropic Messages API exposée derrière la même interface).
- **Routing et fallback** : permet d'escalader automatiquement du local au cloud si la confiance est insuffisante.
- **Suivi des coûts** : journalise les tokens consommés par modèle.
- **Tests en isolation** : facilite le mocking et les tests unitaires.

**Alternative rejetée** : utiliser directement les SDK natifs (`anthropic`, `openai`). Rejetée pour le couplage qu'elle introduit et la duplication de code adapter par fournisseur.

### 3.2. Pourquoi MLX local en priorité

**Décision** : oMLX (serveur OpenAI-compatible) avec Ministral-3-8B-Instruct-2512 comme modèle par défaut.

**Justification** :

- **Souveraineté** : les renseignements personnels ne quittent jamais la machine pour le traitement principal.
- **Coût marginal nul** : aucun frais d'API pour les itérations de développement.
- **Performance Apple Silicon** : MLX exploite la mémoire unifiée et le GPU Metal d'Apple, plus rapide que GGUF sur MacBook Pro M-series.
- **Capacités du modèle** : Ministral 3 8B offre 256k tokens de contexte, function calling natif, JSON output, multilingue avec support solide du français.
- **Empreinte mémoire** : ~5-6 Go en quantification 4-bit, compatible avec 16 Go de RAM unifiée.

**Escalade vers le cloud** : Claude Opus 4.7 ou Sonnet 4.6 via API Anthropic pour :

- les décisions longues (>100 000 tokens) où la qualité du raisonnement compte;
- les cas ambigus où le NER local hésite (confiance < seuil);
- la validation finale d'un échantillon de documents avant publication.

### 3.3. Pourquoi Python + `uv`

**Décision** : Python 3.12+ avec [`uv`](https://docs.astral.sh/uv/) comme gestionnaire de paquets et d'environnement.

**Justification** :

- **Écosystème NLP** : Python est l'écosystème de référence pour le traitement de texte (spaCy, HuggingFace, LangChain, LiteLLM, Pydantic).
- **`uv` vs `pip`+`venv`+`pyenv`** : `uv` est 10 à 100x plus rapide, gère Python lui-même, et utilise un fichier `pyproject.toml` standard.
- **Démonstration de modernité** : pour un portfolio en 2026, `uv` est devenu le standard chez les développeurs Python sérieux.

### 3.4. Pourquoi un NER hybride (règles + LLM)

**Décision** : pipeline de détection en cascade.

```
Étape A : Règles déterministes  →  Entités à haute confiance
Étape B : NER classique (spaCy) →  Entités à confiance moyenne
Étape C : LLM (Ministral)       →  Entités contextuelles + ambiguïtés
Étape D : Validation croisée    →  Réconciliation et déduplication
```

**Justification** :

| Type d'entité | Outil optimal | Pourquoi |
|--------------|--------------|----------|
| NAS, RAMQ, dates, codes postaux | Regex (règles) | Format strict, faux positifs minimes |
| Adresses civiques, téléphones | Regex + listes | Formats variés mais bornés |
| Noms de personnes physiques | spaCy `fr_core_news_lg` ou LLM | Nécessite NER statistique |
| Rôles (juge, partie, témoin) | LLM | Nécessite compréhension du contexte juridique |
| Risques d'inférence (combinaisons) | LLM | Raisonnement contextuel multi-attributs |

**Alternative rejetée** : LLM unique. Rejetée pour le coût (latence + tokens), le risque d'hallucinations sur des formats stricts (NAS), et la difficulté de garantir la reproductibilité.

### 3.5. Pourquoi Pydantic comme modèle de données

**Décision** : tous les types métier sont des modèles Pydantic v2.

**Justification** :

- **Validation automatique** : impossible d'instancier un objet `Entity` invalide.
- **Sérialisation JSON native** : `model.model_dump_json()` produit une trace d'audit conforme au schéma défini.
- **Documentation auto-générée** : les schémas JSON peuvent être exportés (utile pour API future).
- **Compatibilité LiteLLM/FastAPI** : ces deux librairies utilisent Pydantic comme standard.

### 3.6. Pourquoi un format de sortie multi-canal

**Décision** : produire trois sorties pour chaque traitement.

| Sortie | Usage | Format |
|--------|-------|--------|
| **Document anonymisé** | Texte propre, prêt à utiliser | TXT ou Markdown |
| **Document annoté** | Lecture humaine avec annotations visibles | Markdown enrichi |
| **Trace d'audit** | Conformité art. 9 du Règlement, débogage | JSON validé Pydantic |

---

## 4. Composants détaillés

### 4.1. Pipeline d'orchestration (`src/pipeline.py`)

Le pipeline orchestre les sept étapes décrites en section 2.2. Il est implémenté comme une suite de fonctions pures, chacune transformant un état immutable.

```python
@dataclass(frozen=True)
class PipelineState:
    raw_text: str
    metadata: DocumentMetadata
    entities: list[Entity] = field(default_factory=list)
    transformations: list[Transformation] = field(default_factory=list)
    risk_assessment: RiskAssessment | None = None
    output: AnonymizedDocument | None = None

def run_pipeline(source: Path, config: Config) -> PipelineState:
    state = ingest(source)
    state = parse(state)
    state = detect_entities(state, config.ner)
    state = classify_roles(state, config.classifier)
    state = transform(state, config.transformer)
    state = assess_risks(state, config.risk)
    state = render_output(state, config.output)
    return state
```

**Avantage de l'immutabilité** : facilite le débogage (chaque étape est un point d'inspection) et la reprise sur erreur.

### 4.2. Reconnaissance d'entités (`src/ner.py`)

#### 4.2.1. Structure

```python
class EntityDetector(Protocol):
    def detect(self, text: str) -> list[Entity]: ...

class RuleBasedDetector: ...      # regex + listes
class SpacyDetector: ...           # spaCy NER
class LLMDetector: ...             # via LiteLLM
class HybridDetector: ...          # composition des trois
```

#### 4.2.2. Règles déterministes (Niveau 1)

Patterns regex pour identifiants directs :

| Entité | Pattern (exemple) |
|--------|-------------------|
| NAS | `\b\d{3}[-\s]?\d{3}[-\s]?\d{3}\b` |
| RAMQ | `\b[A-Z]{4}\d{8}\b` |
| Date complète | `\b\d{1,2}\s+(janvier\|février\|...)\s+\d{4}\b` |
| Code postal | `\b[A-Z]\d[A-Z][\s-]?\d[A-Z]\d\b` |
| Téléphone QC | `\b(418\|438\|450\|514\|579\|581\|819\|873)[\s.-]?\d{3}[\s.-]?\d{4}\b` |
| Courriel | regex RFC 5322 |

#### 4.2.3. NER statistique (Niveau 2)

Modèle [`fr_core_news_lg`](https://spacy.io/models/fr) de spaCy pour entités nommées génériques (PER, LOC, ORG, MISC).

#### 4.2.4. NER contextuel (Niveau 3)

Prompt structuré envoyé au LLM via LiteLLM avec function calling pour garantir un JSON valide :

```python
SYSTEM_PROMPT = """Tu es un assistant spécialisé dans l'analyse de
décisions judiciaires québécoises. Identifie toutes les entités nommées
qui pourraient permettre l'identification d'une personne physique partie
au litige."""
```

Le LLM produit une liste d'entités structurée selon un schéma Pydantic, ce qui élimine les problèmes de parsing.

### 4.3. Classification des rôles (`src/role_classifier.py`)

Chaque personne physique détectée se voit attribuer un rôle :

| Rôle | Action par défaut |
|------|-------------------|
| `party` (partie au litige) | **Anonymiser** |
| `witness` (témoin civil) | **Anonymiser** |
| `victim` (victime) | **Anonymiser** (souvent déjà fait par la cour) |
| `minor` (mineur) | **Anonymiser obligatoirement** |
| `judge` (juge) | **Préserver** |
| `lawyer` (avocat·e) | **Préserver** |
| `expert` (témoin expert) | **Configurable** (préserver par défaut) |
| `legal_entity` (personne morale) | **Préserver** (hors champ Loi 25) |
| `public_official` (fonctionnaire dans l'exercice) | **Préserver** |

Le classificateur utilise le LLM avec un prompt qui inclut les indices contextuels (verbes d'action, position dans le document, sections « parties », « avocat·e·s », « décision », etc.).

### 4.4. Pseudonymiseur cohérent (`src/pseudonymizer.py`)

#### 4.4.1. Cohérence référentielle

Toutes les occurrences d'une même entité reçoivent le même remplacement dans un document. Une table de correspondance est maintenue **en mémoire uniquement** durant le traitement, jamais persistée.

```python
class CoherentPseudonymizer:
    def __init__(self, profile: AnonymizationProfile):
        self.profile = profile
        self._mapping: dict[str, str] = {}

    def replace(self, entity: Entity) -> str:
        key = self._canonical_form(entity)
        if key not in self._mapping:
            self._mapping[key] = self._generate_replacement(entity)
        return self._mapping[key]

    def reset(self) -> None:
        """Effacer la table à la fin du traitement (art. 23 al. 2 LPRPSP)."""
        self._mapping.clear()
```

#### 4.4.2. Profils d'anonymisation

Deux profils de remplacement sont fournis :

**Profil A — Suppression marquée**

```
Jean Tremblay  →  [PARTIE_DEMANDERESSE]
Marie Dubois   →  [PARTIE_DÉFENDERESSE]
123 rue Pie-IX →  [ADRESSE]
```

**Profil B — Substitution lisible**

```
Jean Tremblay  →  Personne A
Marie Dubois   →  Personne B
123 rue Pie-IX →  [adresse à Montréal]
```

Le profil est sélectionné par l'utilisateur selon le cas d'usage (corpus d'entraînement IA → A, lecture humaine → B).

#### 4.4.3. Suppression de la table de correspondance

Conformément au caractère **irréversible** exigé par l'article 23 al. 2 LPRPSP, la table de correspondance est :

1. maintenue en RAM uniquement pendant le traitement;
2. effacée explicitement (`mapping.clear()`) à la fin;
3. jamais écrite sur disque, ni dans la trace d'audit.

La trace d'audit consigne **uniquement** les types d'entités détectées et les techniques appliquées, jamais les valeurs originales.

### 4.5. Analyseur de risques de réidentification (`src/risk_analyzer.py`)

Implémentation des trois critères de l'article 5 du Règlement.

#### 4.5.1. Individualisation

Évalue si le document contient des combinaisons d'attributs uniques. Heuristique : nombre d'attributs résiduels × spécificité.

```python
def assess_individualization(doc: AnonymizedDocument) -> RiskScore:
    rare_attributes = count_rare_attributes(doc)
    # ex. profession atypique + ville de moins de 10 000 habitants
    return RiskScore(
        critère="individualisation",
        niveau=...,
        justification=...
    )
```

#### 4.5.2. Corrélation

Évalue le risque de croisement avec des sources externes raisonnablement disponibles. Pour le MVP, vérification de la présence de :

- noms d'entreprises identifiables;
- numéros de dossier judiciaire (qui permettent de retrouver le jugement original);
- références à des affaires médiatisées.

#### 4.5.3. Inférence

Évalue le risque qu'un attribut puisse être déduit. Approche LLM : « Étant donné le texte ci-dessous, peux-tu inférer l'identité, le sexe, l'âge, la profession ou le lieu d'origine de la partie principale ? »

#### 4.5.4. Score global

Chaque critère reçoit un score qualitatif `{très faible, faible, moyen, élevé}`. Le score global est le **maximum** des trois (principe de précaution).

**Important** : ce score est une **aide à la décision**, pas un certificat. L'article 7 du Règlement exige une analyse formelle conduite par une personne compétente.

### 4.6. Générateur de trace d'audit (`src/audit.py`)

Pour chaque document traité, génération d'un fichier JSON conforme à un schéma Pydantic strict.

```python
class AuditRecord(BaseModel):
    document_id: str  # hash SHA-256 du document source
    timestamp: datetime
    pipeline_version: str
    config: ConfigSnapshot
    entities_detected: list[EntitySummary]  # types et compteurs, sans valeurs
    transformations_applied: list[TransformationSummary]
    risk_assessment: RiskAssessment
    warnings: list[str]
    operator: str  # nom de la personne compétente (art. 4 du Règlement)
```

Le champ `operator` est **obligatoire** et doit être renseigné par l'utilisateur (par défaut, l'argument CLI `--operator "Nom Prénom"`).

### 4.7. Wrapper LiteLLM (`src/llm_client.py`)

Couche fine au-dessus de LiteLLM qui :

- centralise la configuration (modèle par défaut, base URL, clés);
- applique les retry exponentiels;
- journalise les coûts par appel;
- supporte le fallback automatique local → cloud.

```python
class LLMClient:
    def __init__(self, config: LLMConfig):
        self.primary = config.primary_model
        self.fallback = config.fallback_model

    def complete(self, messages: list[Message],
                 schema: type[BaseModel] | None = None) -> Any:
        try:
            return self._call(self.primary, messages, schema)
        except (TimeoutError, ContentFilterError):
            if self.fallback:
                return self._call(self.fallback, messages, schema)
            raise
```

---

## 5. Flux de données

### 5.1. Ingestion

Trois sources prises en charge :

| Source | Parser |
|--------|--------|
| HTML CanLII | BeautifulSoup + extraction des balises `.text` et `.metadata` |
| Texte brut (.txt) | Lecture directe |
| PDF | `pdfplumber` (texte sélectionnable) ou OCR via `pytesseract` (PDF scannés) |

### 5.2. Format pivot interne

Tous les documents sont convertis vers un format pivot Markdown enrichi :

```markdown
---
court: "Cour supérieure du Québec"
file_number: "500-17-..."
date: "2024-03-15"
parties:
  demandeur: "Jean Tremblay"
  defendeur: "Marie Dubois"
---

# Décision

[Texte intégral...]
```

Cela facilite le diff visuel avant/après anonymisation.

### 5.3. Sortie

Trois fichiers générés par document traité :

```
output/
├── decisions/
│   ├── 2024QCCS1234_anonymized.md
│   ├── 2024QCCS1234_annotated.md
│   └── 2024QCCS1234_audit.json
```

---

## 6. Stockage et persistance

### 6.1. Pas de base de données par défaut

Le MVP n'utilise pas de SGBD. Tous les artefacts sont des fichiers sur disque, ce qui :

- simplifie le déploiement;
- facilite les tests reproductibles;
- évite la persistance involontaire de renseignements personnels.

### 6.2. Cache des appels LLM (optionnel)

Pour le développement, un cache disque (`diskcache`) peut être activé. Il indexe les appels par hash du prompt complet et stocke uniquement la **réponse** (jamais le prompt en clair contenant des renseignements personnels).

**Avertissement** : ce cache doit être désactivé en production et son répertoire chiffré au repos si les prompts contiennent des renseignements personnels.

### 6.3. Configuration

Un fichier `config.toml` à la racine définit :

```toml
[ner]
detector = "hybrid"  # "rules", "spacy", "llm", "hybrid"
spacy_model = "fr_core_news_lg"
llm_confidence_threshold = 0.85

[anonymization]
profile = "B"  # "A" pour suppression, "B" pour substitution

[llm]
primary = "openai/ministral-3-8b"
primary_base_url = "http://127.0.0.1:8000/v1"
fallback = "anthropic/claude-opus-4-7"

[risk]
inference_check = true
correlation_check = true
individualization_threshold = "low"
```

---

## 7. Tests et évaluation

### 7.1. Stratégie de tests

| Niveau | Outil | Couverture cible |
|--------|-------|------------------|
| Unitaires | `pytest` | 80 % du code |
| Intégration | `pytest` + fixtures de décisions | Pipeline complet |
| Évaluation NER | Métriques précision/rappel/F1 sur jeu annoté | F1 ≥ 0.90 sur identifiants directs |
| Régression | Snapshots des sorties JSON | 100 % des décisions de référence |

### 7.2. Jeu de données de référence

Dossier `tests/data/decisions_test/` contenant 10 décisions CanLII réelles avec annotations manuelles (format JSONL) servant de vérité-terrain.

### 7.3. Évaluation comparative des modèles

Notebook `notebooks/benchmark_models.ipynb` qui compare :

- Ministral 3 8B (local)
- Claude Haiku 4.5 (cloud, économique)
- Claude Sonnet 4.6 (cloud, qualité)
- Claude Opus 4.7 (cloud, frontière)

Sur les axes : précision NER, latence, coût, faux positifs sur juges/avocats.

---

## 8. Sécurité et chiffrement

### 8.1. Données en transit

- Communications avec oMLX local : `http://127.0.0.1:8000` (loopback, pas de chiffrement requis).
- Communications avec API cloud : HTTPS obligatoire (par défaut LiteLLM).

### 8.2. Données au repos

- Fichiers d'entrée et de sortie : chiffrement disque OS (FileVault sur macOS, BitLocker sur Windows) recommandé.
- Cache LLM (si activé) : chiffrer le répertoire `~/.cache/anonymiseur-loi25/` avec `age` ou équivalent.

### 8.3. Secrets

- Clés API stockées dans `.env` (jamais commité).
- `.env.example` fourni avec les noms de variables sans valeurs.
- `.gitignore` bloque `.env`, `output/`, `*.audit.json` (par défaut).

### 8.4. Effacement de la table de correspondance

La méthode `pseudonymizer.reset()` est appelée systématiquement à la fin de chaque traitement, dans un bloc `try/finally`, pour garantir l'effacement même en cas d'erreur.

---

## 9. Déploiement

### 9.1. Local (cible principale)

```bash
# Installation
git clone https://github.com/boisalai/anonymiseur-loi25.git
cd anonymiseur-loi25
uv sync

# Démarrer le serveur MLX local (déjà installé)
oMLX serve --model Ministral-3-8B-Instruct-2512-4bit

# Utilisation CLI
uv run anonymiseur process \
  --input decisions/2024QCCS1234.html \
  --output output/ \
  --operator "Alain Boisvert"
```

### 9.2. Démo Gradio (pour le portfolio)

Application Gradio simple permettant de coller le texte d'une décision et de voir le résultat anonymisé en temps réel. Hébergeable sur Hugging Face Spaces (gratuit) pour démontrer aux recruteurs.

### 9.3. Azure (démonstration entreprise, optionnel)

Une variante de l'architecture peut être déployée sur Azure pour démontrer la maîtrise de l'environnement entreprise des grands cabinets canadiens :

- Conteneur Docker hébergé sur **Azure Container Apps**
- Modèles via **Azure AI Foundry** (Claude Opus 4.7)
- Stockage dans **Azure Blob Storage** (région Canada Central) pour la résidence des données
- Authentification via **Microsoft Entra ID**

Cette variante est documentée dans `docs/deployment_azure.md` (à venir).

---

## 10. Décisions d'architecture reportées

Quatre décisions ont été délibérément reportées pour ne pas alourdir le MVP. Elles sont documentées au format ADR (Architecture Decision Record) dans `docs/adr/`.

| ADR | Décision | Reportée à |
|-----|----------|------------|
| ADR-001 | Choix d'un store vectoriel (Chroma vs LanceDB vs Qdrant) | Phase 2 (RAG sur jurisprudence) |
| ADR-002 | Fine-tuning d'un modèle local sur corpus juridique QC | Phase 3 (après accumulation de données annotées) |
| ADR-003 | Intégration d'un modèle de confidentialité différentielle | Phase 4 (anonymisation statistique) |
| ADR-004 | Front-end web (React) au-delà de Gradio | Selon retour des recruteurs |

---

## Annexe — Structure du dépôt

```
anonymiseur-loi25/
├── README.md                    # Vitrine publique
├── CADRE_JURIDIQUE.md           # Cadre légal (ce projet)
├── ARCHITECTURE.md              # Ce document
├── PLAN.md                      # Jalons et avancement
├── LIMITATIONS.md               # Ce que l'outil ne fait PAS
├── CLAUDE.md                    # Instructions pour Claude Code
├── LICENSE                      # MIT
├── pyproject.toml               # Configuration uv
├── uv.lock                      # Verrouillage des dépendances
├── .env.example                 # Variables d'environnement (sans valeurs)
├── .gitignore
├── config.toml                  # Configuration applicative
├── src/
│   ├── __init__.py
│   ├── pipeline.py              # Orchestration
│   ├── ingestion.py             # Lecture des documents
│   ├── ner.py                   # Reconnaissance d'entités
│   ├── role_classifier.py       # Classification des rôles
│   ├── pseudonymizer.py         # Substitution cohérente
│   ├── risk_analyzer.py         # Analyse des trois critères
│   ├── audit.py                 # Génération de la trace d'audit
│   ├── llm_client.py            # Wrapper LiteLLM
│   ├── models.py                # Modèles Pydantic
│   ├── config.py                # Chargement de la configuration
│   └── cli.py                   # Interface en ligne de commande
├── tests/
│   ├── data/
│   │   ├── decisions_test/      # 10 décisions de référence
│   │   └── annotations/         # Vérité-terrain JSONL
│   ├── test_ner.py
│   ├── test_pseudonymizer.py
│   ├── test_risk_analyzer.py
│   └── test_pipeline.py
├── notebooks/
│   ├── exploration.ipynb        # Premiers tests
│   ├── benchmark_models.ipynb   # Comparaison Ministral / Claude
│   └── eval_metrics.ipynb       # Précision/rappel/F1
├── docs/
│   ├── adr/                     # Architecture Decision Records
│   │   ├── ADR-001-vector-store.md
│   │   ├── ADR-002-fine-tuning.md
│   │   ├── ADR-003-diff-privacy.md
│   │   └── ADR-004-frontend.md
│   ├── deployment_azure.md      # Variante Azure (à venir)
│   └── api.md                   # API REST (à venir)
├── examples/
│   ├── basic_usage.py
│   └── batch_processing.py
└── .github/
    ├── workflows/
    │   ├── tests.yml            # CI tests
    │   └── lint.yml             # ruff + mypy
    └── ISSUE_TEMPLATE/
        ├── bug_report.md
        └── feature_request.md
```

---

*Ce document fait partie du dépôt [`anonymiseur-loi25`](https://github.com/boisalai/anonymiseur-loi25). Il évolue avec l'implémentation; chaque décision d'architecture significative donne lieu à un ADR daté.*
