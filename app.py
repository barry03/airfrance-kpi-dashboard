import streamlit as st
import pandas as pd
import plotly.express as px
import matplotlib.pyplot as plt
import seaborn as sns

# Titre
st.title("Rapport de performance – Air France")
# Chargement des données exportées
df_d0 = pd.read_csv("data/kpi1_ponctualite_mensuelle.csv")
df_d0_global = pd.read_csv("data/kpi1_ponctualite_globale.csv")
df_kpi2 = pd.read_csv("data/kpi2_retard_moyen_par_avion.csv")
df_kpi3 = pd.read_csv("data/kpi3_causes_retard.csv")

# KPI 1 – Résumé global
st.subheader("Résumé global de la ponctualité D0")

# Extraction des valeurs
total_vols = df_d0_global['total_flights'].iloc[0]
vols_ponctuels = df_d0_global['on_time_flights'].iloc[0]
taux_ponctualite = df_d0_global['pct_on_time'].iloc[0]

col1, col2, col3 = st.columns(3)
col1.metric("Total vols", f"{total_vols:,}".replace(",", " "))
col2.metric("Vols ponctuels", f"{vols_ponctuels:,}".replace(",", " "))
col3.metric("Taux de ponctualité", f"{taux_ponctualite:.2f} %")


# KPI 1 – Ponctualité mensuelle
st.subheader("Évolution mensuelle de la ponctualité D0")

fig, ax = plt.subplots(figsize=(10, 4))

# Courbe avec points visibles
sns.lineplot(data=df_d0, x="mois", y="pct_on_time", marker="o", ax=ax)

# Ajout des valeurs sur les points
for x, y in zip(df_d0["mois"], df_d0["pct_on_time"]):
    ax.text(x, y + 0.5, f"{y:.1f}", ha='center', fontsize=8)

# Habillage du graphique
ax.set_ylabel("Ponctualité (%)")
ax.set_xlabel("Mois")
ax.set_title("Évolution mensuelle de la ponctualité D0")
ax.tick_params(axis='x', rotation=45)

st.pyplot(fig)


# KPI 2 – Retard moyen à l’arrivée par type d’avion
st.header("KPI 2 – Retard moyen à l’arrivée par type d’avion (matplotlib)")

# Convertion de la colonne si besoin
df_kpi2['AIRCRAFT_TYPE'] = df_kpi2['AIRCRAFT_TYPE'].astype(str)

# Bouton de filtrage
apply_filter = st.checkbox("Exclure les valeurs supérieures à 60 min", value=True)

# Application ou non du filtre
if apply_filter:
    df_filtered = df_kpi2[df_kpi2['avg_arrival_delay'] < 60]
else:
    df_filtered = df_kpi2

# Trie des données pour l'affichage
df_kpi2_sorted = df_filtered.sort_values("avg_arrival_delay", ascending=True)

# Création du graphique
fig, ax = plt.subplots(figsize=(8, 6))
sns.barplot(
    data=df_kpi2_sorted,
    x="avg_arrival_delay",
    y="AIRCRAFT_TYPE",
    ax=ax,
    color="#4a90e2"
)
# Ajout des valeurs sur les barres
for i, (delay, label) in enumerate(zip(df_kpi2_sorted['avg_arrival_delay'], df_kpi2_sorted['AIRCRAFT_TYPE'])):
    ax.text(delay + 0.3, i, f"{delay:.1f}", va='center')
ax.set_xlabel("Retard moyen (minutes)")
ax.set_ylabel("Type d'avion")
title_suffix = " (< 60 min)" if apply_filter else " (tous les vols)"
ax.set_title(f"Retard moyen par type d’avion{title_suffix}")

# Affichage dans Streamlit
st.pyplot(fig)


# KPI 3 – Causes principales de retard (si dispo)
if not df_kpi3.empty:
    st.header("KPI 3 – Top 3 causes de retard sur les vols nationaux")
    fig3 = px.bar(df_kpi3.sort_values("occurences", ascending=True),
                  x="occurences", y="libelle", orientation='h',
                  title="Top 3 causes de retard")
    st.plotly_chart(fig3)
else:
    st.info("Aucune donnée disponible sur les causes de retard des vols nationaux.")