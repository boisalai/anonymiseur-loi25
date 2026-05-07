# Cadre juridique — Anonymisation de décisions judiciaires québécoises

> **Document de référence** pour le projet `anonymiseur-loi25`.
>
> **Dernière mise à jour** : 7 mai 2026.
>
> **Auteur** : Claude Opus 4.7 (Anthropic), avec la direction éditoriale de [@boisalai](https://github.com/boisalai).
>
> ⚠️ **Vérification humaine requise** — Ce document a été rédigé par un agent conversationnel d'intelligence artificielle (Claude Opus 4.7) à partir de sources officielles québécoises et de doctrine juridique citée en bibliographie. Bien que les références aux textes législatifs et réglementaires aient été tirées de sources publiques vérifiables (LégisQuébec, CanLII, doctrine de cabinets reconnus), **le contenu n'a pas été révisé par un juriste qualifié au moment de la publication**. Les utilisateurs sont invités à :
>
> 1. **Vérifier les citations** des articles de loi auprès de [LégisQuébec](https://www.legisquebec.gouv.qc.ca) avant tout usage formel.
> 2. **Consulter un avocat ou un conseiller juridique** avant d'utiliser ce document comme fondement d'une décision opérationnelle ou contractuelle.
> 3. **Signaler toute imprécision** via une *issue* GitHub sur le [dépôt du projet](https://github.com/boisalai/anonymiseur-loi25/issues).
>
> Cette mise en garde reflète, dans la conception même de ce projet, le principe de supervision humaine prévu à l'**article 4 du Règlement sur l'anonymisation** : une intelligence artificielle, comme un outil, **propose** — l'humain compétent **dispose**.

---

## Table des matières

1. [Sommaire exécutif](#1-sommaire-exécutif)
2. [Cadre légal applicable](#2-cadre-légal-applicable)
3. [Distinction conceptuelle : anonymisation, dépersonnalisation, pseudonymisation](#3-distinction-conceptuelle)
4. [Les trois critères du Règlement (art. 5)](#4-les-trois-critères-du-règlement)
5. [Obligations procédurales (art. 3 à 9 du Règlement)](#5-obligations-procédurales)
6. [Spécificité des décisions judiciaires](#6-spécificité-des-décisions-judiciaires)
7. [Sanctions applicables](#7-sanctions-applicables)
8. [Positionnement honnête de l'outil](#8-positionnement-honnête-de-loutil)
9. [Sources et références](#9-sources-et-références)

---

## 1. Sommaire exécutif

Ce document expose le cadre juridique québécois applicable à l'anonymisation des renseignements personnels contenus dans les décisions judiciaires publiées sur des plateformes comme [CanLII](https://www.canlii.org) et [SOQUIJ](https://soquij.qc.ca).

**Objectif du projet** : développer un assistant logiciel permettant à une organisation (cabinet, ordre professionnel, entreprise, chercheur) d'**amorcer** un processus d'anonymisation conforme à la *Loi sur la protection des renseignements personnels dans le secteur privé*[^p391] (« **LPRPSP** ») et au *Règlement sur l'anonymisation des renseignements personnels*[^reglement] (« **Règlement** ») entré en vigueur le 30 mai 2024.

**Position du projet** : l'outil est un **assistant** à l'anonymisation, pas un **certificat** d'anonymisation. La conformité au sens de l'article 23 LPRPSP exige l'intervention d'une « personne compétente en la matière » (art. 4 du Règlement) et une analyse formelle des risques résiduels (art. 7). L'outil propose, l'humain dispose.

**Cadre légal pertinent** :

| Source | Référence | Portée |
|--------|-----------|--------|
| LPRPSP, art. 23 | RLRQ c P-39.1 | Secteur privé |
| LADOPRP, art. 73 | RLRQ c A-2.1 | Secteur public |
| Règlement sur l'anonymisation | RLRQ c A-2.1, r 0.1 | Secteurs privé et public, ordres professionnels |
| Code des professions | RLRQ c C-26 | Application aux ordres professionnels |

---

## 2. Cadre légal applicable

### 2.1. Article 23 LPRPSP — Secteur privé

L'article 23 de la *Loi sur la protection des renseignements personnels dans le secteur privé* a été refondu par la *Loi modernisant des dispositions législatives en matière de protection des renseignements personnels*[^loi25] (communément appelée **Loi 25**), sanctionnée le 22 septembre 2021. La modification de l'article 23 est entrée en vigueur le 22 septembre 2023.

> **Article 23 LPRPSP**
>
> Lorsque les fins auxquelles un renseignement personnel a été recueilli ou utilisé sont accomplies, la personne qui exploite une entreprise doit le détruire ou l'anonymiser pour l'utiliser à des fins sérieuses et légitimes, sous réserve d'un délai de conservation prévu par une loi.
>
> Pour l'application de la présente loi, un renseignement concernant une personne physique est anonymisé lorsqu'il est, en tout temps, raisonnable de prévoir dans les circonstances qu'il ne permet plus, de façon irréversible, d'identifier directement ou indirectement cette personne.
>
> Les renseignements anonymisés en vertu de la présente loi doivent l'être selon les meilleures pratiques généralement reconnues et selon les critères et modalités déterminés par règlement.

[Source officielle : LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/p-39.1).

### 2.2. Article 73 LADOPRP — Secteur public

Une disposition équivalente a été insérée dans la *Loi sur l'accès aux documents des organismes publics et sur la protection des renseignements personnels*[^a21] à l'article 73, applicable aux organismes publics (ministères, municipalités, établissements de santé, universités, etc.).

[Source officielle : LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/A-2.1).

### 2.3. Règlement sur l'anonymisation des renseignements personnels

Le Règlement, publié à la *Gazette officielle du Québec* le 15 mai 2024 et entré en vigueur le 30 mai 2024 (à l'exception de l'article 9 entré en vigueur le 1er janvier 2025), précise les critères et modalités du processus d'anonymisation. Il s'applique :

> **Article 1 du Règlement**
>
> Le présent règlement s'applique à tout organisme public visé à l'article 3 de la Loi sur l'accès aux documents des organismes publics et sur la protection des renseignements personnels (chapitre A-2.1), de même qu'à toute personne qui exploite une entreprise et qui est visée par la Loi sur la protection des renseignements personnels dans le secteur privé (chapitre P-39.1). Il s'applique également aux ordres professionnels, dans la mesure prévue par le Code des professions (chapitre C-26).

[Source officielle : LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/rc/A-2.1,%20r.%200.1).

### 2.4. Application aux ordres professionnels

L'article 1 du Règlement étend explicitement son application aux ordres professionnels. Cette précision a une portée pratique importante : la **Chambre des notaires du Québec**, le **Barreau du Québec** et les autres ordres professionnels (réglementés par le *Code des professions*[^c26]) sont assujettis aux mêmes obligations que les entreprises privées et les organismes publics.

---

## 3. Distinction conceptuelle

Le droit québécois reconnaît deux concepts distincts qui sont parfois confondus avec le vocabulaire européen ou fédéral.

### 3.1. Tableau comparatif

| Concept | Droit québécois (Loi 25) | Droit européen (RGPD) | Caractère | Renseignement personnel ? |
|---------|--------------------------|----------------------|-----------|---------------------------|
| **Anonymisation** | Anonymisation (art. 23) | Anonymisation | Irréversible | **Non** — exclu de la loi |
| **Procédé réversible** | Dépersonnalisation (art. 12) | Pseudonymisation | Réversible | **Oui** — reste assujetti |

### 3.2. Conséquences juridiques

La distinction n'est pas que terminologique : elle détermine si le renseignement reste ou non assujetti à la LPRPSP.

- **Renseignement anonymisé** : n'est plus un renseignement personnel; peut être utilisé, communiqué et conservé sans consentement, sous réserve du respect du Règlement.
- **Renseignement dépersonnalisé** : demeure un renseignement personnel; reste assujetti à la LPRPSP (notamment aux obligations de consentement, de finalité et de sécurité).

### 3.3. Pourquoi viser l'anonymisation

Pour le cas d'usage retenu (constitution d'un corpus de décisions judiciaires en vue d'entraîner ou d'évaluer un système d'IA), seule l'**anonymisation** au sens de l'article 23 LPRPSP permet de :

- conserver le corpus indéfiniment;
- le partager ou le publier;
- l'utiliser à des fins ultérieures différentes (recherche, fine-tuning, RAG, etc.);

sans que ces utilisations ne soient elles-mêmes assujetties à la LPRPSP.

---

## 4. Les trois critères du Règlement

L'article 5 du Règlement impose trois critères devant être considérés lors de l'analyse préliminaire des risques de réidentification.

### 4.1. Critère d'individualisation

**Définition fonctionnelle** : possibilité d'isoler les données qui identifient une personne dans un ensemble de données.

**Application aux décisions judiciaires** : un jugement contenant des éléments uniques (date précise d'un accident, montant exact d'une indemnité, profession atypique) permet de réindividualiser une partie même si son nom est masqué.

**Exemple** :
> « La demanderesse, ophtalmologiste exerçant à Baie-Saint-Paul, a perdu son emploi le 12 mars 2019. »

Même sans nom, cette phrase permet probablement d'identifier la personne (peu d'ophtalmologistes à Baie-Saint-Paul).

### 4.2. Critère de corrélation

**Définition fonctionnelle** : possibilité de relier deux ou plusieurs renseignements concernant la même personne, dans le même ensemble ou avec des sources externes.

**Application aux décisions judiciaires** : la corrélation entre une décision et :

- d'autres décisions impliquant les mêmes parties;
- des bases de données publiques (Registraire des entreprises, RDPRM, registre foncier);
- des publications médiatiques contemporaines de l'affaire;
- les réseaux sociaux des parties.

### 4.3. Critère d'inférence

**Définition fonctionnelle** : possibilité de déduire avec une probabilité significative la valeur d'un attribut à partir d'autres attributs.

**Application aux décisions judiciaires** : déduire l'identité d'une partie à partir d'éléments contextuels combinés (rôle professionnel + ville + année + situation familiale).

### 4.4. Synthèse

Les trois critères sont **cumulatifs** et **non exclusifs** : chacun crée un risque de réidentification distinct qui doit être évalué et atténué. Un outil d'anonymisation doit donc :

1. masquer les identifiants directs (Niveau 1);
2. masquer ou généraliser les identifiants indirects (Niveaux 2 et 3);
3. évaluer le risque de réidentification par inférence et corrélation (Niveau 4);
4. produire une trace d'audit documentant les choix d'atténuation.

---

## 5. Obligations procédurales

Les articles 3 à 9 du Règlement structurent un processus en huit étapes.

### 5.1. Établissement préalable des fins (art. 3)

Avant de débuter le processus, l'organisation doit établir et documenter les **fins sérieuses et légitimes** de l'anonymisation. Pour le projet `anonymiseur-loi25`, ces fins peuvent être :

- entraînement ou évaluation d'un modèle de langue spécialisé en droit québécois;
- recherche académique en informatique juridique;
- développement de produits commerciaux à partir d'un corpus de jurisprudence.

### 5.2. Supervision par une personne compétente (art. 4)

Le processus doit être réalisé sous la supervision d'une « personne compétente en la matière ». Le Règlement ne précise pas les qualifications, mais la doctrine considère qu'il s'agit d'une personne possédant des compétences à la fois en protection des renseignements personnels et en techniques d'anonymisation[^osler].

**Conséquence pour l'outil** : il propose, mais ne peut se substituer à la supervision humaine.

### 5.3. Retrait des identifiants directs (art. 5 al. 1)

L'organisation doit d'abord **retirer** tous les renseignements permettant d'identifier directement la personne :

- nom, prénom;
- adresse civique;
- numéro d'assurance sociale (NAS);
- numéro d'assurance maladie (RAMQ);
- numéro de téléphone, courriel personnel;
- numéro de compte bancaire, de carte de crédit;
- identifiants biométriques.

### 5.4. Analyse préliminaire des risques (art. 5 al. 2)

L'organisation doit ensuite effectuer une **analyse préliminaire** des risques de réidentification en considérant les trois critères (individualisation, corrélation, inférence) ainsi que les renseignements raisonnablement disponibles (espace public, bases de données ouvertes, etc.).

### 5.5. Choix des techniques (art. 6)

En fonction des risques identifiés, l'organisation doit établir les techniques d'anonymisation à utiliser, conformes aux **meilleures pratiques généralement reconnues**. Les techniques classiques incluent :

| Technique | Description |
|-----------|-------------|
| Suppression | Retrait pur et simple du renseignement |
| Généralisation | Remplacement par une catégorie plus large (ex. « 60 ans » → « plus de 50 ans ») |
| Permutation | Échange de valeurs entre individus différents |
| Bruit aléatoire | Ajout d'une perturbation statistique contrôlée |
| Confidentialité différentielle | Garantie mathématique formelle de non-réidentification |

### 5.6. Analyse finale des risques de réidentification (art. 7)

Après mise en œuvre des techniques, l'organisation doit effectuer une **seconde analyse** démontrant que les risques résiduels sont **très faibles**, en tenant compte notamment :

1. des fins de l'utilisation des renseignements anonymisés;
2. de la nature des renseignements;
3. des techniques utilisées;
4. des moyens raisonnablement disponibles pour identifier la personne.

Le Règlement précise qu'il n'est **pas nécessaire de démontrer un risque nul**, seulement un risque résiduel **très faible**.

### 5.7. Évaluation périodique (art. 8)

L'organisation doit périodiquement réévaluer les renseignements anonymisés pour s'assurer qu'ils le demeurent, notamment compte tenu des avancées technologiques (capacités accrues de modèles d'IA, nouvelles bases de données publiques, etc.).

### 5.8. Tenue de registre (art. 9)

Depuis le **1er janvier 2025**, l'organisation doit tenir un registre documentant le processus d'anonymisation : finalités, techniques utilisées, résultats des analyses de risques, dates des évaluations périodiques, etc.

---

## 6. Spécificité des décisions judiciaires

### 6.1. Statut juridique des décisions sur CanLII et SOQUIJ

Les décisions judiciaires québécoises sont publiées sur :

- [**CanLII**](https://www.canlii.org/fr/qc/) — accès libre et gratuit, opéré par la Fédération des ordres professionnels de juristes du Canada;
- [**SOQUIJ**](https://soquij.qc.ca) — éditeur officiel des décisions des tribunaux québécois.

Ces décisions sont des **documents publics**. Toutefois, leur publication ne soustrait pas les renseignements personnels qu'elles contiennent à la LPRPSP lorsqu'ils sont **collectés, utilisés ou communiqués** par une tierce partie (cabinet, chercheur, entreprise) dans un contexte couvert par la loi.

### 6.2. Anonymisation déjà effectuée par les tribunaux

Les tribunaux québécois appliquent leurs propres règles d'anonymisation, notamment :

- **chambre de la jeunesse** : anonymisation systématique (Loi sur la protection de la jeunesse, art. 83);
- **affaires familiales** : utilisation d'initiales pour les parties (Règles de pratique de la Cour supérieure);
- **victimes d'infractions sexuelles** : ordonnances de non-publication (Code criminel, art. 486.4).

Ces règles produisent des décisions **partiellement** anonymisées, mais ne couvrent ni :

- les noms des parties dans les autres matières (civil ordinaire, commercial, travail, etc.);
- les détails contextuels (adresses, employeurs, dates précises);
- les renseignements de santé ou financiers évoqués dans les motifs.

### 6.3. Renseignements personnels résiduels dans les décisions « publiques »

Une décision publiée peut contenir, en sus du nom des parties :

- adresses civiques;
- dates de naissance, NAS, numéros de compte;
- diagnostics médicaux, dossiers psychiatriques;
- antécédents judiciaires de tiers;
- noms d'enfants mineurs;
- renseignements financiers détaillés;
- éléments biométriques (description physique, photos parfois jointes en annexe).

### 6.4. Cas d'usage du projet : constitution de corpus pour entraînement IA

Le projet `anonymiseur-loi25` cible explicitement le cas d'usage suivant :

> Une personne souhaitant utiliser un corpus de jurisprudence québécoise pour **entraîner**, **affiner** ou **évaluer** un modèle de langue (LLM, embeddings, NER) doit s'assurer que ce corpus est anonymisé au sens de l'article 23 LPRPSP — sans quoi le modèle entraîné pourrait reproduire des renseignements personnels lors de l'inférence (phénomène de **mémorisation** documenté en apprentissage automatique).

L'outil sert d'**assistant** à cette anonymisation, en automatisant les étapes 5.3 (retrait des identifiants directs) et 5.5 (techniques d'atténuation) pour les volumes importants, tout en laissant à la « personne compétente » la responsabilité des étapes 5.1 (établissement des fins), 5.2 (supervision), 5.4 et 5.6 (analyses de risques) et 5.7-5.8 (évaluation et registre).

---

## 7. Sanctions applicables

### 7.1. Sanctions administratives pécuniaires

La LPRPSP prévoit des sanctions administratives pécuniaires (SAP) pouvant aller jusqu'à **10 000 000 $** ou **2 % du chiffre d'affaires mondial** de l'exercice précédent (art. 90.12 LPRPSP), pour les manquements aux obligations de protection des renseignements personnels.

### 7.2. Infractions pénales

Les infractions pénales peuvent atteindre **25 000 000 $** ou **4 % du chiffre d'affaires mondial** (art. 91 LPRPSP). Une infraction spécifique vise la **réidentification non autorisée** :

> Tente d'identifier une personne physique à partir de renseignements anonymisés ou dépersonnalisés sans autorisation préalable de la personne qui les détient.

Cette disposition a un effet direct sur la conception de l'outil : la **table de correspondance** utilisée pendant le traitement (avant retrait final) doit être détruite à la fin du processus, sous peine d'exposition juridique.

### 7.3. Responsabilité civile

L'article 93.1 LPRPSP prévoit en outre des **dommages-intérêts punitifs** d'un minimum de 1 000 $ en cas d'atteinte intentionnelle ou de faute lourde. La jurisprudence québécoise reconnaît également la responsabilité civile générale (1457 CcQ) pour la diffusion non autorisée de renseignements personnels.

---

## 8. Positionnement honnête de l'outil

### 8.1. Ce que `anonymiseur-loi25` prétend faire

- Identifier automatiquement les **identifiants directs** dans une décision judiciaire (noms de parties physiques, adresses, numéros de téléphone, courriels, NAS, dates de naissance, identifiants bancaires).
- Identifier les **identifiants indirects** principaux (lieux précis, employeurs, professions atypiques, dates spécifiques).
- Proposer des **techniques d'atténuation** différentes selon le type d'entité (suppression, généralisation, substitution).
- Préserver le **contenu juridiquement utile** : noms de juges, d'avocats, de tribunaux, de personnes morales, qualifications juridiques, ratio decidendi.
- Produire une **trace d'audit** structurée (JSON ou Markdown) listant les transformations appliquées.

### 8.2. Ce que `anonymiseur-loi25` NE fait PAS

- Il ne **garantit pas** la conformité au sens de l'article 23 LPRPSP : seule une analyse de risques formelle (art. 7 du Règlement), conduite par une personne compétente, peut établir cette conformité.
- Il ne **détecte pas tous** les risques d'inférence : un risque résiduel d'identification par croisement avec des sources externes demeure et doit être évalué humainement.
- Il ne **remplace pas** la « personne compétente en la matière » exigée à l'article 4 du Règlement.
- Il ne **gère pas** la tenue de registre exigée à l'article 9 (en vigueur depuis le 1er janvier 2025), bien qu'il en facilite la documentation.

### 8.3. Rôle de la supervision humaine

L'outil produit, pour chaque décision traitée :

1. un **document anonymisé proposé**;
2. un **rapport d'identification** listant les entités détectées et les transformations appliquées;
3. une **évaluation préliminaire** des risques résiduels (sur la base de règles heuristiques explicites).

La supervision humaine consiste à :

- réviser le rapport d'identification (faux positifs, faux négatifs);
- valider la pertinence des transformations;
- effectuer l'analyse de risques formelle exigée par l'article 7;
- décider du sort des risques résiduels (conserver, généraliser davantage, exclure la décision).

### 8.4. Avertissement légal

> L'utilisation de `anonymiseur-loi25` ne dispense pas l'utilisateur de ses obligations légales. L'auteur n'est ni avocat ni conseiller juridique de l'utilisateur. Toute utilisation à des fins autres que de démonstration ou de recherche personnelle doit être validée par un conseiller juridique compétent et par un responsable de la protection des renseignements personnels au sens de la LPRPSP.

---

## 9. Sources et références

### 9.1. Textes officiels

#### Législation québécoise

- *Loi sur la protection des renseignements personnels dans le secteur privé*, RLRQ c P-39.1 — [LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/p-39.1).
- *Loi sur l'accès aux documents des organismes publics et sur la protection des renseignements personnels*, RLRQ c A-2.1 — [LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/a-2.1).
- *Loi modernisant des dispositions législatives en matière de protection des renseignements personnels*, LQ 2021, c 25 (« Loi 25 ») — [CanLII](https://www.canlii.org/fr/qc/legis/loisa/lq-2021-c-25/derniere/lq-2021-c-25.html).
- *Code des professions*, RLRQ c C-26 — [LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/c-26).
- *Code civil du Québec*, art. 35 à 41 (vie privée), RLRQ c CCQ-1991 — [LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/lc/ccq-1991).

#### Réglementation québécoise

- *Règlement sur l'anonymisation des renseignements personnels*, RLRQ c A-2.1, r 0.1 — [LégisQuébec](https://www.legisquebec.gouv.qc.ca/fr/document/rc/A-2.1,%20r.%200.1).

### 9.2. Doctrine et commentaires

- Commission d'accès à l'information du Québec, [Principaux changements apportés par la Loi 25](https://www.cai.gouv.qc.ca/protection-renseignements-personnels/sujets-et-domaines-dinteret/principaux-changements-loi-25), section « Anonymisation ».
- Julie Uzan-Naulin et Jade Paquin-Robidoux, [« L'anonymisation des données sous la Loi 25 : le règlement québécois est adopté! »](https://www.fasken.com/fr/knowledge/2024/05/data-anonymization-under-law-25), Fasken, 29 mai 2024.
- Marc-Alexandre Hudon et al., [« Législation québécoise : entrée en vigueur du Règlement sur l'anonymisation »](https://carrefourrh.org/ressources/relations-travail/2024/05/anonymisation-renseignements-personnels-Quebec), 29 mai 2024.
- Osler, [« Les exigences du Québec en matière d'anonymisation un an plus tard »](https://www.osler.com/fr/articles/mises-%C3%A0-jour/exigences-quebec-anonymisation-lecons-questions-suspens-entreprises/), 8 mai 2025.
- McMillan, [« Anonymisation des renseignements personnels en vertu du droit québécois »](https://mcmillan.ca/fr/perspectives/publications/anonymisation-des-renseignements-personnels-en-vertu-du-droit-quebecois/), 13 juin 2024.

### 9.3. Sources internationales pertinentes

- Groupe de travail « Article 29 », *Avis 05/2014 sur les techniques d'anonymisation*, 10 avril 2014 (référence implicite du Règlement québécois pour les trois critères).
- Règlement (UE) 2016/679 (RGPD), art. 4(5) (définition de la pseudonymisation).

---

## Notes de bas de page

[^p391]: *Loi sur la protection des renseignements personnels dans le secteur privé*, RLRQ c P-39.1.

[^reglement]: *Règlement sur l'anonymisation des renseignements personnels*, RLRQ c A-2.1, r 0.1.

[^loi25]: *Loi modernisant des dispositions législatives en matière de protection des renseignements personnels*, LQ 2021, c 25, sanctionnée le 22 septembre 2021.

[^a21]: *Loi sur l'accès aux documents des organismes publics et sur la protection des renseignements personnels*, RLRQ c A-2.1.

[^c26]: *Code des professions*, RLRQ c C-26.

[^osler]: Osler, *Les exigences du Québec en matière d'anonymisation un an plus tard*, 8 mai 2025.

---

*Ce document fait partie du dépôt [`anonymiseur-loi25`](https://github.com/boisalai/anonymiseur-loi25). Il est mis à jour à mesure que la jurisprudence et les lignes directrices de la CAI évoluent.*
