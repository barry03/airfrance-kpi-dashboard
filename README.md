# airfrance-kpi-dashboard

Dashboard interactif développé pour visualiser les KPI de ponctualité à partir des données de vols fournies dans le cadre du processus de recrutement Air France.

## Objectifs

Le projet vise à analyser les données opérationnelles de vols (fichiers CSV et JSON fournis) et restituer les KPI suivants :

- **KPI 1** : Taux de ponctualité au départ (D0)
- **KPI 2** : Retard moyen à l’arrivée par type d’avion
- **KPI 3** : Principales causes de retard sur les vols nationaux

## Structure du projet

```bash
airfrance-kpi-dashboard/
├── app.py                    # Application Streamlit principale
├── extraction_kpis.sql       # Requêtes SQL utilisées pour produire les KPI
├── requirements.txt          # Dépendances Python (dont streamlit, pandas...)
├── data/                     # Fichiers CSV extraits de la base DuckDB
│   ├── kpi1_ponctualite_globale.csv
│   ├── kpi1_ponctualite_mensuelle.csv
│   ├── kpi2_retard_moyen_par_avion.csv
│   └── kpi3_causes_retard.csv
├── docs/
│   ├── instructions_airfrance.docx     # Consignes officielles reçues
│   └── dashboard_export.pdf            # Résultat visuel final
└── .gitignore               # Fichiers à ignorer (.DS_Store, .vscode, etc.)
```

## Outils utilisés

-  Streamlit (dashboard)

-  Pandas / Plotly / Seaborn (analyse & visualisation)

-  DuckDB (traitement SQL local)

-  DBeaver (interface pour requêtes SQL)


## Lancement du dashboard localement

1-  Cloner le dépôt

```bash
git clone git@github.com:barry03/airfrance-kpi-dashboard.git
cd airfrance-kpi-dashboard
```

2-  Créer un environnement Python
```bash
python3 -m venv venv
source venv/bin/activate
```

2-  Installer les dépendances
```bash
pip install -r requirements.txt
```

4-  Lancer Streamlit
```bash
streamlit run app.py
```

##  Déploiement en ligne

Le dashboard est aussi disponible via Streamlit Cloud :

## 🌐 Accès en ligne au dashboard

Le dashboard interactif est disponible en ligne via Streamlit Cloud :

[https://airfrance-kpi-dashboard-p3tp2nkxp3lxbefpjthikv.streamlit.app](https://airfrance-kpi-dashboard-p3tp2nkxp3lxbefpjthikv.streamlit.app)


##  Auteur

Projet réalisé par Djoulde Barry dans le cadre d’un processus de recrutement chez Air France.
