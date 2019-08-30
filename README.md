Bootstrapped by-catch estimates
===============================

Marie-Julie Roux
----------------

30 August 2019

Installation
------------

    devtools::install_github("iml-assess/bycatchboostrap")
    library(bycatchbootstrap)

INFORMATIONS REQUISES:
----------------------

1.  CATEGORIES DE BYCATCH (spx)
2.  DONNEES OBSERVATEURS (obs.all.df)
3.  DONNEES EFFORT COMMERCIAL (STRAT.eff)

### 1. CATEGORIES DE BYCATCH (spx):

ESPECES OU GROUPES D’ESPECES POUR LESQUELLES NOUS VOULONS COMPTABILISER
LES TAUX DE CAPTURE ET ESTIMER LE VOLUME DES PRISES ACCIDENTELLES; A
DEFINIR SELON LES INTERETS, LA RESOLUTION TAXONOMIQUE DISPONIBLE OU
SOUHAITEE, ETC. ICI J’UTILISE UNE LISTE DE 10 ESPECES COMMERCIALES ET
NON-COMMERCIALE (CHACUNE REPRESENTEE PAR UN CODE DE 3-LETTRES)

    unique(spx)

    ##  [1] "JAV" "RAT" "SQU" "ETB" "JMA" "SND" "LDO" "SWA" "COL" "SBK"

### DONNEES OBSERVATEURS (obs.all.df)

    head(obs.all.df,5)

    ##       fyear vessel.key JAV RAT SQU ETB JMA  SND LDO  SWA COL SBK stratum
    ## 50505  2003       5933   0 500   0   0   0 1000   0   94   0   0    CHAT
    ## 50506  2003       5933 150 250  26   0   0    0  51  385   0   0    CHAT
    ## 50507  2003       5933 524  79 143   0   0    0 745 1540   0   0    CHAT
    ## 50508  2003       5933 400 249   7   0   0    0 224 1054   0   0    CHAT
    ## 50509  2003       5933 565 108  26   0   0    0  21 3717   0   0    CHAT

DONNEES D’OBSERVATEURS POUR UNE FLOTILLE DONNEE (EX. ENSEMBLE DES
BATEAUX OPERANT AVEC UN ENGIN DE PECHE DE TYPE X ET CIBLANT L’ESPECE
COMMERCIALE Y) LIGNES = EVENEMENTS DE PECHE OBSERVES (UNE LIGNE= UN
EVENEMENT DE PECHE) COLONNES = STRATES TEMPORELLES (fyear), IDENTIFIANT
BATEAU (vessel.key), BYCATCH (kg) PAR CATEGORIE, STRATES SPATIALES
(stratum) (ici il s’agit des prises (en kg) de 10 especes accessoires
sur 11 ans dans 7 strates spatiales pour une flotille comprenant 74
bateaux) (un evenement de peche (une ligne) correspond ici a un trait de
chalut)

### DONNEES DE LA PECHE COMMERCIALE (STRAT.eff)

    STRAT.eff

    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL      
    ## 2003    4997    3445 3886 9776 5007  550 1689 29350
    ## 2004    5123    2405 3965 8146 3570  246 1275 24730
    ## 2005    2859    2055 2879 5877 2256  512  858 17296
    ## 2006    2379    2447 1871 5145 1797  376  700 14715
    ## 2007    1835    1425 2074 5431 2245  258  595 13863
    ## 2008     957    1805 1764 4987 2052  225  753 12543
    ## 2009     988    1444 1882 4461 1750  171  644 11340
    ## 2010    1505    1417 1718 4438 1870  132  898 11978
    ## 2011    1895    1938 1563 4082 1682  294  915 12369
    ## 2012    2019    1923 1700 4333 1703  320  920 12918
    ## 2013    2326    1756 1902 4201 2129  194  993 13501

EFFORT COMMERCIAL DANS CHAQUE STRATE (TEMPORELLE ET SPATIALE) LIGNES =
STRATE TEMPORELLE (fyear) COLONNES = STRATES SPATIALES (LES MEMES QUE
‘STRATUM’ DANS LES DONNEES D’OBSERVATEURS) \# IMPORTANT QUE CE SOIT
EXACTEMENT LES MEMES!! VALEURS = SOMME DE L’EFFORT DE PECHE DANS CHAQUE
STRATE (ici il s’agit du nombre de traits de chalut dans 7 strates
spatiales sur une periode de 11 ans) IMPORTANT: LA DERNIERE COLONNE
(SOMMES ANNUELLES) DOIT ETRE INCLUSE!!!

Run an example based on the NZ data
-----------------------------------

MATRICES DE RESULTATS - VOLUME ANNUEL DES PRISES ACCIDENTELLES PAR
ESPECE, POUR L’ENSEMBLE DE LA PECHE (VOLt)

    VOLt<-matrix(nrow=length(unique(row.names(STRAT.eff))),ncol=length(spx),dimnames=list(rownames(STRAT.eff),spx))
    VOLt_95lo<-VOLt # SELECTIONNER MESURE(S) DE PRECISION 
    VOLt_95hi<-VOLt
    VOLt_cv <-VOLt
    VOLt

    ##      JAV RAT SQU ETB JMA SND LDO SWA COL SBK
    ## 2003  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2004  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2005  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2006  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2007  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2008  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2009  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2010  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2011  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2012  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
    ## 2013  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA

LISTES DE RESULTATS - VOLUMES ANNUELS DES PRISES ACCIDENTELLES PAR
ESPECE PAR STRATE SPATIALE (VOLs)

    VOLs <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'PE(s)')))
    VOLs_cv <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'PEcv')))
    VOLs_95lo <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'PE95lo')))
    VOLs_95hi <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'PE95hi')))
    VOLs

    ## , , JAVPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , RATPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SQUPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , ETBPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , JMAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SNDPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , LDOPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SWAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , COLPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SBKPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0

LISTES DE RESULTATS - TAUX DE PRISES ACCIDENTELLES ANNUELS PAR ESPECE
PAR STRATE SPATIALE (AVEC MESURES DE PRECISION)

    RATES.median <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'median')))
    RATES.95lo <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'rates95lo')))
    RATES.95hi <-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],length(spx)),dimnames=list(dimnames(STRAT.eff)[[1]],dimnames(STRAT.eff)[[2]],paste0(spx,'rates95hi')))
    RATES.median

    ## , , JAVmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , RATmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SQUmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , ETBmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , JMAmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SNDmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , LDOmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SWAmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , COLmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SBKmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    0    0    0    0 0
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0

### ESTIMATION EN BOUCLE PAR CATEGORIE DE BYCATCH

TERMES A SPECIFIER: ‘cutoff’ est le seuil (no. minimal) d’observations
dans les strates utilise pour l’analyse un examen des donnees
d’observateur par strate (temporelles et spatiale) permettra de bien
definir ‘cutoff’ en-dessous du cutoff, les donnees seront aggregees
d’abord dans le temps, puis spatialement. ‘catchcat’ est la categorie de
bycatch ‘estimator’ est le type d’effort de peche (prises par trait, par
heure ou par no. d’hamecons) ‘do.null’ concerne l’aggregation des
donnees lorsque le nombre d’observations est inferieur au cutoff.
‘first.year’ est la seule option pour ‘do.null’ dans cette version du
code

NOTE: POUR CET EXEMPLE, LA FONCTION ‘mj\_boot.effort.group’ A
L’INTERIEUR DE LA FONCTION GENERALE EST SPECIFIEE POUR RANDOMISER LES
BATEAUX (group=‘vessel.key’) AVEC UN SEUIL DE TOLERANCE DE 5% POUR LE
NOMBRE EFFECTIF DE BATEAUX DANS CHAQUE STRATE (G.tot=0.05) ET POUR
N’EFFECTUER QUE 10 RANDOMISATIONS (M=10)

    for(i in 1:length(spx)){
      mjbootout= mj_boot.a.cat.bycatch(cutoff=25,catchcat=spx[i],estimator="catch.per.tow",do.null="first.year")
      print(paste(spx[i],"done",sep=" "))
      VOLt[,spx[i]]<-mjbootout$BYCATCH[,"PE(t)"]
      VOLt_95lo[,spx[i]]<-mjbootout$BYCATCH[,"95lo"]
      VOLt_95hi[,spx[i]]<-mjbootout$BYCATCH[,"95hi"]
      VOLt_cv[,spx[i]]<-mjbootout$BYCATCH[,"cv"]
      name<-paste0(spx[i],'median')
      tmp <- mjbootout$RATES[,,'median']
      RATES.median[,,name] <-tmp
      name.i<-paste0(spx[i],'rates95lo')
      tmp.i <- mjbootout$RATES[,,'rates95lo']
      RATES.95lo[,,name.i] <-tmp.i
      name.ii<-paste0(spx[i],'rates95hi')
      tmp.ii <- mjbootout$RATES[,,'rates95hi']
      RATES.95hi[,,name.ii] <-tmp.ii
      name.iii<-paste0(spx[i],'PE(s)')
      tmp.iii <- mjbootout$RATES[,,'PE(s)']
      VOLs[,,name.iii] <-tmp.iii
      name.iv<-paste0(spx[i],'PE95lo')
      tmp.iv <- mjbootout$RATES[,,'PE95lo']
      VOLs_95lo[,,name.iv] <-tmp.iv
      name.v<-paste0(spx[i],'PE95hi')
      tmp.v <- mjbootout$RATES[,,'PE95hi']
      VOLs_95hi[,,name.v] <-tmp.v
      name.vi<-paste0(spx[i],'PEcv')
      tmp.vi <- mjbootout$RATES[,,'PEcv']
      VOLs_cv[,,name.vi] <-tmp.vi
      }

CHECK RESULTS VOLUME TOTAL ANNUEL PAR CATEGORIE

    VOLt

    ##        JAV  RAT SQU ETB  JMA  SND  LDO   SWA COL SBK
    ## 2003 10325 8645 955  43  117  770 1371  7274   0  11
    ## 2004  7921 8314 860  64  803  802  967 11549   0  15
    ## 2005  7868 4511 540  42 2053  463  794  3442   0  21
    ## 2006  6453 4376 661  26   44 1263  733  8871   0  14
    ## 2007  6814 3053 766  72   25  918  720  6496   0   7
    ## 2008  5663 4240 413 432   39 1083  402  3960  43  21
    ## 2009  6324 5302 278 135  321  948  460  2151  49  29
    ## 2010  7544 6242 447 346    9  506  491  4545   0  16
    ## 2011  4702 3972 526 160    6  596  493  3822   0  11
    ## 2012  3525 5065 504 225   86  337  468  4307  23   4
    ## 2013  5665 5966 843 369  152  794  848  8008   3  29

    VOLt_cv

    ##      JAV RAT SQU ETB JMA SND LDO SWA COL SBK
    ## 2003   9  14  20  77  43  35  15  29 NaN  47
    ## 2004   7  19  20  67  61  22   5  16 NaN  31
    ## 2005  17  33  15  56 110   9  12  11 NaN  42
    ## 2006   6  20  10  40  26  14   9  10 NaN  45
    ## 2007  12  16   9  43 195  14  14  15 NaN  35
    ## 2008   7  18  15  46  52  17   7  21  58  28
    ## 2009  11  23  14  25  69  15   7  14 147  32
    ## 2010  13  14  17  59  51  15  12  17 NaN  27
    ## 2011   9  10  19  25 206  25   9  12 NaN  40
    ## 2012   8  14  14  34  40  11  11  19  77  25
    ## 2013   7  11  11  15  50  23  14  15 265  23

    VOLt_95hi

    ##        JAV   RAT  SQU ETB  JMA  SND  LDO   SWA COL SBK
    ## 2003 11725 10960 1250 128  253 1552 1848 12620   0  20
    ## 2004  9122 10013 1313 136 1527 1071 1050 15270   0  26
    ## 2005 10822  7653  694 100 7441  516 1011  3691   0  37
    ## 2006  7226  6598  718  45   65 1641  802 10263   0  28
    ## 2007  8196  4084  826 137  184 1142  887  8288   2  11
    ## 2008  6240  5332  462 743   73 1276  447  5518 102  25
    ## 2009  7308  8241  362 174  733 1148  540  2419 203  48
    ## 2010  9108  8381  552 699   20  644  577  5765   0  26
    ## 2011  5707  4693  695 236   33  908  582  4552   0  18
    ## 2012  4073  6400  570 335  186  384  582  5530  53   6
    ## 2013  6356  7297 1008 497  333 1106 1175 10126  27  39

    VOLt_95lo

    ##       JAV  RAT SQU ETB JMA SND  LDO  SWA COL SBK
    ## 2003 9315 6886 588   8  67 560 1179 5501   0   4
    ## 2004 7478 4958 659   6  98 621  901 8314   0   9
    ## 2005 6377 2755 451  23 134 382  683 2507   0   9
    ## 2006 6116 3691 531  11  26 976  551 7115   0   7
    ## 2007 5444 2266 612  34  14 705  584 4371   0   4
    ## 2008 5123 2784 291 135  12 816  358 2478  24  10
    ## 2009 5284 4117 239  64   3 654  427 1269   0  15
    ## 2010 5671 5296 291 107   5 379  372 3661   0  11
    ## 2011 4295 3392 392 121   0 377  406 3082   0   3
    ## 2012 3205 3767 362  48  58 268  412 2493   0   3
    ## 2013 5092 5040 673 312  55 563  757 6297   0  16

VOLUME ANNUEL PAR STRATE SPATIALE PAR CATEGORIE

    VOLs

    ## , , JAVPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      64     146    0 4923  882   19  246 3930
    ## 2004      79     196    0 4106  371    5  172 3106
    ## 2005     106     109    1 3174 1124    5   57 3190
    ## 2006      68     242    0 2930  279   90  158 2814
    ## 2007      47     134    0 3602  280   48  119 2575
    ## 2008       9     206    3 2533  571   15  132 2129
    ## 2009      17     374    1 3039  402   30   88 2418
    ## 2010      14     120   12 3834  494   13  192 2853
    ## 2011      20     327    0 2177  250   23   74 1813
    ## 2012      24     174    3 1519  238   21   90 1409
    ## 2013      50     397    4 2052  360   56  138 2648
    ## 
    ## , , RATPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      42     179    3 4080  414   16  382 3473
    ## 2004      22     124    3 4449  222    6  210 3161
    ## 2005      13      82    2 2428  171    8  114 1761
    ## 2006      11     145    0 2126  114   52  133 1805
    ## 2007      31     186   10 1264  122   23  112 1353
    ## 2008       6     214   17 1984  112   10  208 1587
    ## 2009       8     318    6 2833  138   26   53 1906
    ## 2010       3      96   43 2799  195   22  550 2660
    ## 2011      14     222    3 1562  253   42  162 1764
    ## 2012      13     115   33 1618  196   23  666 2480
    ## 2013      27     294   51 2280  265   34  400 2687
    ## 
    ## , , SQUPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      30     197    1   37  167    6    7 503
    ## 2004      65     221    2   79   32    4    3 463
    ## 2005      23      81    3   56   99    3    2 272
    ## 2006       8     136    0   48   52   23   10 368
    ## 2007      24     124    2   40   87   15    5 446
    ## 2008       9      59    1   40   54   11    2 236
    ## 2009      16       8    1   19   35   11    1 185
    ## 2010      27      23    1   49   61    7    8 241
    ## 2011      20      73    0   29   96   14    3 288
    ## 2012      35      82    1   21   53   12    3 271
    ## 2013      21     151    1   17   88   25    8 529
    ## 
    ## , , ETBPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    1   19    0    2  22
    ## 2004       1       0    0   35    5    0    0  24
    ## 2005       0       0    0    0   20    0    0  22
    ## 2006       0       0    0    8    4    0    0  10
    ## 2007       1       0    0   41    2    0    1  27
    ## 2008       0       0    0  243   56    1    2 136
    ## 2009       0       0    0   15   54    0    0  60
    ## 2010       0       0    0   62  122    0    2 153
    ## 2011       0       0    0   58   27    1    6  69
    ## 2012       0       0    0   88   42    1    0  90
    ## 2013       1       7    6  132   58    2    1 162
    ## 
    ## , , JMAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      46       4    4    1    0    0    3  59
    ## 2004     459       2    2    0    0    0    0 338
    ## 2005      27       3  711    1    0    0    4 953
    ## 2006      23       0    0    0    0    0    0  21
    ## 2007       9       0    2    0    0    0    0  13
    ## 2008       4       1    2   14    0    0    0  17
    ## 2009     121       0    0    0    0    0    0 199
    ## 2010       0       0    4    1    0    0    0   4
    ## 2011       1       0    0    0    0    0    0   3
    ## 2012       4       0   28    1    0    0    4  46
    ## 2013      33       0   38    0    0    0    3  75
    ## 
    ## , , SNDPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       4      14    0  204    4   16   81 451
    ## 2004       1      15    1  288    1   10   36 411
    ## 2005       2       5    9  241    2    1   14 179
    ## 2006       5      47    0  250    9   91   46 788
    ## 2007       5      23    2  165    4   56   26 639
    ## 2008       2      28   12  440    6   20   45 479
    ## 2009       1      52    0  295    2   17   70 508
    ## 2010       0       6   22  143    3    5   60 271
    ## 2011       1      48    0  175    2   12   50 307
    ## 2012       0      10    2  119    2   10   18 167
    ## 2013       2      41    1  199    6   33   19 487
    ## 
    ## , , LDOPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      27     125    0  658   33    3   15 535
    ## 2004      26      82    0  441   21    1   10 398
    ## 2005       5      60    0  386   17    2    9 299
    ## 2006      11     149    0  240   13    7    6 310
    ## 2007       7      83    0  282   17    5    4 308
    ## 2008       6      70    0  128   11    4    5 180
    ## 2009      14      78    0  134   10    5    2 222
    ## 2010       8      38    1  227   13    2   10 199
    ## 2011      15     113    0  128   14    3    6 219
    ## 2012       6      57    0  198    9    1   20 191
    ## 2013      32     154    0  242   12    7    4 395
    ## 
    ## , , SWAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     370     454    1 1323  198  218  433 4282
    ## 2004     512     957    0 3777  801  106   77 5575
    ## 2005      87     672   33  926   48    9   18 1532
    ## 2006      94     507    0 2055  412  255  590 4893
    ## 2007     134     420   22 1233  484  177  229 3591
    ## 2008      44     293   11 1585   82   29  133 1684
    ## 2009     140     114    0  769  163   14   14  943
    ## 2010      91     183    4 2401  174   18    9 1741
    ## 2011     152     495   32 1245  184   33   25 1625
    ## 2012      94     339   63 1236   74   49  302 1967
    ## 2013      79     311  238  928  379   69 1279 4674
    ## 
    ## , , COLPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    0    0    0    0  0
    ## 2004       0       0    0    0    0    0    0  0
    ## 2005       0       0    0    0    0    0    0  0
    ## 2006       0       0    0    0    0    0    0  0
    ## 2007       0       0    0    0    0    0    0  0
    ## 2008       0       0    0   31    0    0    0 12
    ## 2009       0       0    0   36    0    0    0 13
    ## 2010       0       0    0    0    0    0    0  0
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       0       0    0   16    0    0    0  7
    ## 2013       0       0    0    1    0    0    0  1
    ## 
    ## , , SBKPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    5    1    0    0  4
    ## 2004       0       0    0    9    1    0    0  6
    ## 2005       0       0    0   12    2    0    0  7
    ## 2006       0       4    0    3    0    0    0  6
    ## 2007       0       0    0    3    1    0    0  2
    ## 2008       0       6    0    4    0    0    0  9
    ## 2009       0       9    0    2    3    0    0 15
    ## 2010       0       1    0    8    1    0    1  6
    ## 2011       0       1    0    4    1    0    0  5
    ## 2012       0       0    0    2    0    0    0  2
    ## 2013       0       1    0   16    1    0    0 10

    VOLs_95hi

    ## , , JAVPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      98     207    0 6022 1084   41  279 4386
    ## 2004     117     321    0 4832  766    9  227 3425
    ## 2005     173     254    2 5745 1659   11  159 4204
    ## 2006      85     993    0 3411  329  110  325 3163
    ## 2007      80     274   14 4553  542   62  154 3067
    ## 2008      11     267   17 3179  828   32  159 2346
    ## 2009      20     454    2 3461  621   42  103 2778
    ## 2010      16     192   16 5323 1003   27  325 3112
    ## 2011      27     652    0 2473  332   43  200 2341
    ## 2012      33     191    3 1980  326   30  162 1574
    ## 2013      59     484    6 2663  570   75  199 2867
    ## 
    ## , , RATPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      63     222    7 5826  543   35  603 4334
    ## 2004      37     172    6 5737  390   10  319 3605
    ## 2005      19     150    6 4790  283   13  154 2570
    ## 2006      25     292    2 3557  201  129  155 2604
    ## 2007      40     279   20 1468  169   53  184 2065
    ## 2008       8     252   29 2840  171   14  241 1940
    ## 2009      10     354   14 4925  171   44   61 2736
    ## 2010       4     146   71 3941  472   30  609 3424
    ## 2011      25     331    4 1955  350   84  256 2133
    ## 2012      22     162   44 2302  247   57  823 2960
    ## 2013      41     375   88 2817  325   48  602 3262
    ## 
    ## , , SQUPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      55     230    2   54  382   15    9 627
    ## 2004      88     356    3   96   49    6    4 740
    ## 2005      27     133    4   85  127    5    5 350
    ## 2006      10     205    1   63   81   30   20 419
    ## 2007      34     154    3   63  109   19   12 489
    ## 2008      10      80    2   56   66   15    3 267
    ## 2009      24      12    1   30   46   15    1 243
    ## 2010      30      38    1   80   96   12   16 329
    ## 2011      27     126    1   34  151   26    5 404
    ## 2012      47     112    1   37   69   26    5 345
    ## 2013      33     189    1   30  128   42   11 672
    ## 
    ## , , ETBPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    2   65    0    5  60
    ## 2004       3      21    1   68   15    0    0  61
    ## 2005       0       0    0    0   48    0    0  52
    ## 2006       0       1    0   14   16    0    0  22
    ## 2007       1       0    0   88    6    2    2  44
    ## 2008       1       0    4  464   90    2    5 227
    ## 2009       0       0    0   33   69    1    0  82
    ## 2010       0       0    0  137  315    1    6 324
    ## 2011       0       0    0  107   32    1   10  97
    ## 2012       0       0    0  145   87    3    1 144
    ## 2013       2      11   12  211   76    3    5 198
    ## 
    ## , , JMAPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     122      13    8    1    0    0    5  119
    ## 2004     896       5    2    0    0    4    0  627
    ## 2005      57      23 2858    3    0    0 1175 4423
    ## 2006      35       0    0    1    0    0    0   31
    ## 2007      14       0    4  119    0    0    0   55
    ## 2008      17       7    4   36    0    0    0   39
    ## 2009     277       0    0    0    0    0    0  455
    ## 2010       1       0    9    1    0    0    0   10
    ## 2011       5       1    0   16    0    0    0   12
    ## 2012       8       0   76    7    0    0    8   98
    ## 2013      94       0   77    1    0    0    5  160
    ## 
    ## , , SNDPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      10      17    0  526    9   31  181  809
    ## 2004       5      37    2  516    2   39   55  755
    ## 2005       4      10   17  313    5    1   36  221
    ## 2006      10      72    1  370   12  139   59 1102
    ## 2007       8      35    5  256    7   81   41  817
    ## 2008       2      40   26  587    9   44   57  663
    ## 2009       1      75    1  364    3   25  126  626
    ## 2010       1      18   35  182    4    8   70  347
    ## 2011       1     101    0  258    4   14  131  479
    ## 2012       0      46    4  167    3   14   46  199
    ## 2013       3      61    1  236    9   60   26  779
    ## 
    ## , , LDOPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      58     152    0  908   41    8   19 713
    ## 2004      36     104    0  492   43    2   16 431
    ## 2005       6      74    0  567   24    4   11 361
    ## 2006      17     165    0  263   18   11    9 335
    ## 2007      10     123    0  474   31    6    8 335
    ## 2008       8      74    0  148   27    5    5 194
    ## 2009      20      91    0  179   13    7    3 247
    ## 2010      11      62    2  289   21    3   21 230
    ## 2011      24     139    0  148   26    6   14 257
    ## 2012       8      86    0  216   10    2   34 244
    ## 2013      41     199    1  413   19    9    9 514
    ## 
    ## , , SWAPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     496     756    2 2967  356  446  747 7733
    ## 2004     629    1273    0 5494 1523  209  203 8339
    ## 2005     125     804   58 1285   90   15   31 1653
    ## 2006     140     594    0 2723  452  587  825 6155
    ## 2007     211     574   29 1752  899  251  481 4866
    ## 2008      56     399   16 2810  170   38  231 2065
    ## 2009     150     149    1  923  274   23   42 1068
    ## 2010     129     233   10 3253  443   37   13 2031
    ## 2011     271     642   93 1475  386   81   47 2133
    ## 2012     127     376  176 1987  138  120  704 2742
    ## 2013      94     438  449 1089  538  152 2015 6038
    ## 
    ## , , COLPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    0    0    0    0  0
    ## 2004       0       0    0    0    0    0    0  0
    ## 2005       0       0    0    0    0    0    0  0
    ## 2006       0       0    0    0    0    0    0  0
    ## 2007       0       0    0    0    0    0    0  1
    ## 2008       0       0    0   73    0    0    1 28
    ## 2009       0       0    0  149    0    0    0 54
    ## 2010       0       0    0    0    0    0    0  0
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       0       0    0   37    0    0    0 16
    ## 2013       1      12    0    2    0    0    0 14
    ## 
    ## , , SBKPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       1    0   12    3    0    2  7
    ## 2004       0       0    0   13    2    0    1 10
    ## 2005       0       0    0   24    3    0    0 12
    ## 2006       2       9    0    7    1    0    0 11
    ## 2007       0       0    0    7    2    0    0  4
    ## 2008       0      10    0   10    0    0    0 11
    ## 2009       0      17    0    9   11    0    0 25
    ## 2010       0       2    0   13    1    0    1 10
    ## 2011       0       4    0   11    2    0    0  6
    ## 2012       0       0    0    3    1    0    0  2
    ## 2013       0       1    0   24    2    0    1 13

    VOLs_95lo

    ## , , JAVPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      39     102    0 4473  799    0  201 3438
    ## 2004      50     162    0 3225  167    2  125 2764
    ## 2005      91      63    0 2330  282    3   19 2532
    ## 2006      41     100    0 2387   79   68  113 2500
    ## 2007      20      26    0 2311   94   29   92 2291
    ## 2008       8     153    0 2175  433   11   96 1886
    ## 2009      10     256    0 2300  276   15   37 1947
    ## 2010      11      35    9 3319  159    7   90 1944
    ## 2011      13     225    0 1798  228    6   47 1617
    ## 2012      16     104    2 1357  177   11   33 1251
    ## 2013      39     338    2 1689  218   39   18 2356
    ## 
    ## , , RATPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      20     140    0 2680  366    1  326 2962
    ## 2004       8     101    2 2445   80    2  123 1965
    ## 2005      10      53    0 1220   71    4   45 1169
    ## 2006       7      89    0 1713   38   42  103 1562
    ## 2007      10      32    7  826   75   14   89 1141
    ## 2008       4     150    4 1033   60    8   99 1209
    ## 2009       5     276    1 2052   96    9   35 1557
    ## 2010       1      32   39 2083   73    9  237 1965
    ## 2011       8     112    1 1324  104   11  140 1344
    ## 2012       9      91   25 1311  136   18  367 1751
    ## 2013      19     240   34 1359   96   12  202 2205
    ## 
    ## , , SQUPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      22     149    1   28   43    2    5 312
    ## 2004      36     132    1   65   16    1    1 352
    ## 2005      16      53    1   49   83    2    1 224
    ## 2006       6     122    0   23   19   17    2 302
    ## 2007      18      99    1   30   38   12    2 369
    ## 2008       7       7    1   27   31    7    2 167
    ## 2009      13       6    0   11   28    7    0 152
    ## 2010      17      18    0   28   29    3    3 157
    ## 2011       8      33    0   18   62    7    2 222
    ## 2012      31      60    1    3   32   10    1 201
    ## 2013      15      98    0   11   27   15    6 423
    ## 
    ## , , ETBPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    0    0    0    1   5
    ## 2004       0       0    0    0    0    0    0   5
    ## 2005       0       0    0    0   11    0    0  12
    ## 2006       0       0    0    3    2    0    0   5
    ## 2007       0       0    0   16    0    0    0  13
    ## 2008       0       0    0   28   25    0    0  57
    ## 2009       0       0    0   12   20    0    0  31
    ## 2010       0       0    0   50   11    0    0  42
    ## 2011       0       0    0   32   20    0    3  57
    ## 2012       0       0    0   28    2    0    0  17
    ## 2013       1       4    4  105   54    0    0 132
    ## 
    ## , , JMAPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      27       1    1    0    0    0    1 33
    ## 2004      45       0    1    0    0    0    0 43
    ## 2005      15       0    3    0    0    0    0 70
    ## 2006      13       0    0    0    0    0    0 12
    ## 2007       4       0    1    0    0    0    0  7
    ## 2008       1       0    0    0    0    0    0  6
    ## 2009       1       0    0    0    0    0    0  2
    ## 2010       0       0    2    0    0    0    0  3
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       1       0   18    0    0    0    4 31
    ## 2013       1       0   14    0    0    0    1 29
    ## 
    ## , , SNDPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       2       5    0   70    0    6   37 326
    ## 2004       0       3    0  183    0    1   23 274
    ## 2005       1       4    2  198    1    0    9 147
    ## 2006       2      21    0  180    4   64    6 616
    ## 2007       2       7    2   68    3   40   16 467
    ## 2008       1      22    3  319    3    6   36 334
    ## 2009       0      40    0  152    2   11   38 392
    ## 2010       0       1   19  111    1    4   28 201
    ## 2011       0      12    0  117    0    9   16 177
    ## 2012       0       3    1   40    1    8    0 143
    ## 2013       1      29    0  128    4   13    9 333
    ## 
    ## , , LDOPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      10      89    0  485   20    0    8 436
    ## 2004      11      64    0  387   10    1    4 362
    ## 2005       4      43    0  347   13    0    3 258
    ## 2006       5     120    0  139    7    6    3 255
    ## 2007       5      37    0  138   10    4    2 277
    ## 2008       3      52    0  112    5    3    3 162
    ## 2009       8      61    0  109    8    3    1 200
    ## 2010       5      22    1  159    4    1    9 155
    ## 2011       6      95    0   80   10    1    2 186
    ## 2012       5      42    0  153    8    1    6 173
    ## 2013      29     116    0  178    9    2    0 346
    ## 
    ## , , SWAPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     276     377    0  605   53  103  231 3256
    ## 2004     311     365    0 2653   45    2   43 3562
    ## 2005      50     422   14  684   27    6    8 1098
    ## 2006      44     360    0 1732  226  143   70 3733
    ## 2007      66     346    2 1057  174   80   81 2275
    ## 2008      35     243    0  735   65   15   63 1093
    ## 2009      88      64    0  285   85    8    4  621
    ## 2010      70     156    3 1871   99    9    5 1300
    ## 2011     105     403    5  658  104   20   12 1433
    ## 2012      80     246    3  552   15   22   48 1262
    ## 2013      42     249   66  435  188   34  664 3674
    ## 
    ## , , COLPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0   16    0    0    0 7
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SBKPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    1    0    0    0 1
    ## 2004       0       0    0    5    0    0    0 3
    ## 2005       0       0    0    3    1    0    0 4
    ## 2006       0       0    0    1    0    0    0 3
    ## 2007       0       0    0    2    0    0    0 1
    ## 2008       0       4    0    1    0    0    0 5
    ## 2009       0       6    0    0    1    0    0 8
    ## 2010       0       0    0    5    0    0    0 3
    ## 2011       0       0    0    1    0    0    0 1
    ## 2012       0       0    0    1    0    0    0 1
    ## 2013       0       0    0    7    1    0    0 7

    VOLs_cv

    ## , , JAVPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      23      18  159   13    9   65   10  8
    ## 2004      25      27  NaN   11   49   45   19  6
    ## 2005      25      68   95   30   35   57   72 16
    ## 2006      19     108  NaN   10   31   15   38  8
    ## 2007      33      54 1262   17   48   20   14  9
    ## 2008      10      17  218   11   18   39   13  6
    ## 2009      21      20   56   12   26   27   27 11
    ## 2010      14      36   21   16   45   45   36 12
    ## 2011      19      40  NaN    8   14   54   56 12
    ## 2012      21      16   12   14   20   26   42  7
    ## 2013      12      11   31   13   28   21   35  6
    ## 
    ## , , RATPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      29      12   79   20   12   77   25 12
    ## 2004      44      18   34   22   39   37   29 17
    ## 2005      22      30  101   44   40   31   25 26
    ## 2006      52      42  240   26   47   63   13 18
    ## 2007      27      42   40   13   21   58   29 21
    ## 2008      22      13   44   29   35   20   19 13
    ## 2009      16       9   65   30   12   40   13 19
    ## 2010      26      32   22   22   63   29   24 13
    ## 2011      36      29   30   11   31   43   21 12
    ## 2012      35      20   19   17   18   50   25 16
    ## 2013      25      13   33   18   24   32   28 10
    ## 
    ## , , SQUPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      32      14   33   22   58   66   18 18
    ## 2004      29      31   19   13   41   38   26 23
    ## 2005      15      37   31   19   15   26   53 16
    ## 2006      13      18   50   28   38   18   48 12
    ## 2007      18      14   40   23   23   12   52  9
    ## 2008       9      34   57   22   23   21   12 15
    ## 2009      24      23   28   32   18   23   46 16
    ## 2010      17      29   35   30   40   40   38 20
    ## 2011      28      34   52   18   29   46   22 22
    ## 2012      13      22   23   46   22   51   41 17
    ## 2013      27      19   21   33   38   38   17 15
    ## 
    ## , , ETBPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003     NaN     NaN  NaN   72   92  NaN   66 71
    ## 2004      73     Inf   69   67   74   68  NaN 69
    ## 2005     NaN     NaN  NaN  NaN   55  NaN  NaN 55
    ## 2006     106     265  NaN   44  116  NaN  NaN 54
    ## 2007      47     126  Inf   54   80  139   97 35
    ## 2008      89     NaN  265   58   37   49   75 42
    ## 2009      39      54  NaN   44   31   83  Inf 26
    ## 2010      99      52  NaN   46   91   54  102 65
    ## 2011      81      87  NaN   50   14   38   42 17
    ## 2012     NaN      84   96   35   56   74  104 37
    ## 2013      30      40   49   27   13   51  129 13
    ## 
    ## , , JMAPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA PUYS  NULL    
    ## 2003      59      92   64    52  NaN   83    36  40
    ## 2004      64      87   21   299  344  534    49  59
    ## 2005      42     254  132    74  NaN   64 10866 148
    ## 2006      26      31  NaN    44  NaN  NaN    97  26
    ## 2007      30     110   51 16396  NaN  NaN    63 105
    ## 2008     123     157   75    80  Inf  NaN    73  54
    ## 2009      69     NaN   44   NaN  NaN  NaN    78  69
    ## 2010      55     142   58    44  NaN  NaN    60  52
    ## 2011     195      71   54 16951  NaN  NaN   NaN 142
    ## 2012      58      74   58   253  Inf  NaN    29  39
    ## 2013      93     161   52    69   89  NaN    37  48
    ## 
    ## , , SNDPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      55      33   62   62   63   45   48 29
    ## 2004     200      63   53   33   57  106   27 33
    ## 2005      34      31   56   13   53   41   56 11
    ## 2006      63      32  294   21   33   23   39 17
    ## 2007      36      40   40   32   37   26   28 17
    ## 2008      29      22   49   20   27   57   12 22
    ## 2009      19      24   73   21   14   26   36 13
    ## 2010     101      95   23   14   33   25   25 18
    ## 2011      41      57  NaN   26   50   14   89 30
    ## 2012      93     156   65   29   22   20   75 10
    ## 2013      26      23   81   20   29   44   31 32
    ## 
    ## , , LDOPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      50      17  111   19   22   78   24 14
    ## 2004      32      13  NaN    7   47   32   40  6
    ## 2005      16      17  NaN   18   20   51   26 10
    ## 2006      36       8   87   15   23   19   30  6
    ## 2007      21      33   54   39   34   13   38  5
    ## 2008      24      11   44    9   53   16   13  6
    ## 2009      27      12  339   14   16   17   18  7
    ## 2010      24      29   31   17   39   31   40 12
    ## 2011      35      14   60   19   32   36   56  8
    ## 2012      18      23   32   11    7   22   49 13
    ## 2013      12      16   18   28   30   25   61 12
    ## 
    ## , , SWAPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      17      25   59   54   45   52   34 32
    ## 2004      19      25  100   21   61   63   73 22
    ## 2005      24      16   39   20   46   31   49 11
    ## 2006      30      11   43   15   17   54   34 15
    ## 2007      30      17   39   18   41   25   48 19
    ## 2008      12      17   40   37   40   29   36 16
    ## 2009      17      24  136   22   40   34   72 12
    ## 2010      19      13   61   20   54   39   31 14
    ## 2011      34      14   92   21   46   68   43 14
    ## 2012      15      11   76   37   63   52   58 22
    ## 2013      22      17   54   20   30   56   34 18
    ## 
    ## , , COLPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2004     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2005     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2006     NaN     NaN  NaN  Inf  NaN  NaN  NaN Inf
    ## 2007     NaN     NaN  NaN  NaN  NaN  NaN  203 204
    ## 2008     NaN      78  NaN   60   87  NaN   50  56
    ## 2009     NaN     NaN  NaN  146  NaN  NaN  NaN 146
    ## 2010     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2011     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2012     NaN     NaN  NaN   78  NaN  NaN  NaN  78
    ## 2013     227     Inf  NaN   68  NaN  NaN  NaN 385
    ## 
    ## , , SBKPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003     NaN     257  Inf   78   69  NaN  154 45
    ## 2004     145      78  110   29   92  NaN   43 31
    ## 2005     NaN     245  NaN   55   37  NaN  NaN 37
    ## 2006     819      60  NaN   55   69  NaN   53 46
    ## 2007      51     105  NaN   45   92  NaN   74 37
    ## 2008     166      31  NaN   77   55  NaN   33 25
    ## 2009     109      34  NaN  146  149  Inf   70 32
    ## 2010     NaN     105  NaN   36   61  Inf   51 27
    ## 2011      84      79  NaN  100  111  Inf  Inf 29
    ## 2012     NaN      52  NaN   30   66  NaN   59 21
    ## 2013      50      39   33   31   36  NaN   55 21

TAUX DE PRISE ACCIDENTELLE PAR STRATE SPATIALE PAR CATEGORIE

    RATES.median 

    ## , , JAVmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003   12.77   42.35 0.01 503.63 176.13  33.70 145.73 133.91
    ## 2004   15.35   81.34 0.00 504.04 103.98  21.95 134.86 125.62
    ## 2005   37.24   53.12 0.20 540.13 498.37   8.86  66.72 184.42
    ## 2006   28.48   99.01 0.00 569.47 155.32 240.19 225.03 191.21
    ## 2007   25.40   94.07 0.16 663.25 124.68 187.69 200.08 185.76
    ## 2008    9.51  114.13 1.79 507.96 278.37  66.39 174.98 169.71
    ## 2009   16.82  258.88 0.72 681.20 229.49 175.76 135.94 213.27
    ## 2010    9.43   84.54 6.74 863.83 264.43 100.26 214.16 238.20
    ## 2011   10.38  168.69 0.00 533.37 148.76  77.97  81.05 146.60
    ## 2012   11.88   90.29 1.57 350.66 139.96  64.39  98.11 109.09
    ## 2013   21.47  226.19 1.96 488.55 169.30 290.20 138.56 196.10
    ## 
    ## , , RATmedian
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003    8.49   51.89  0.68 417.40  82.75  28.25 226.43 118.34
    ## 2004    4.20   51.42  0.85 546.11  62.31  24.90 164.33 127.84
    ## 2005    4.63   39.72  0.63 413.07  75.87  16.11 133.38 101.82
    ## 2006    4.76   59.36  0.18 413.19  63.61 138.68 189.73 122.64
    ## 2007   17.06  130.81  4.64 232.71  54.53  90.01 188.41  97.57
    ## 2008    5.88  118.73  9.83 397.86  54.71  43.66 276.54 126.55
    ## 2009    8.14  219.95  3.13 635.07  78.72 151.70  82.77 168.12
    ## 2010    2.11   67.65 24.82 630.75 104.28 165.24 612.80 222.05
    ## 2011    7.56  114.62  1.62 382.65 150.33 143.59 176.75 142.61
    ## 2012    6.50   59.94 19.46 373.42 114.83  71.68 723.96 191.94
    ## 2013   11.54  167.42 26.94 542.65 124.61 173.60 402.35 199.02
    ## 
    ## , , SQUmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA   PUYS  NULL      
    ## 2003    5.94   57.11 0.27  3.81 33.29  11.34  4.22 17.12
    ## 2004   12.69   92.10 0.57  9.68  8.89  14.38  2.25 18.72
    ## 2005    7.94   39.24 1.05  9.53 43.94   6.42  2.86 15.73
    ## 2006    3.39   55.45 0.24  9.34 29.17  60.19 14.68 25.03
    ## 2007   13.23   86.98 0.81  7.39 38.80  57.28  8.26 32.17
    ## 2008    8.98   32.61 0.50  8.11 26.15  50.16  3.11 18.79
    ## 2009   16.61    5.81 0.41  4.20 20.25  63.08  1.13 16.30
    ## 2010   17.83   16.16 0.36 11.07 32.52  56.20  9.21 20.13
    ## 2011   10.34   37.63 0.20  6.99 57.33  48.60  3.62 23.31
    ## 2012   17.35   42.41 0.50  4.85 31.20  37.85  2.73 20.98
    ## 2013    9.09   86.05 0.31  4.14 41.21 128.42  8.37 39.16
    ## 
    ## , , ETBmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA PUYS NULL      
    ## 2003    0.00    0.00 0.00  0.10  3.79 0.00 1.12  0.74
    ## 2004    0.24    0.00 0.06  4.25  1.43 0.94 0.00  0.96
    ## 2005    0.00    0.00 0.00  0.00  8.99 0.00 0.00  1.28
    ## 2006    0.04    0.04 0.00  1.60  2.46 0.00 0.00  0.71
    ## 2007    0.39    0.04 0.00  7.55  0.90 1.57 1.13  1.92
    ## 2008    0.41    0.00 0.26 48.77 27.21 4.81 2.08 10.82
    ## 2009    0.13    0.12 0.00  3.41 30.68 2.75 0.00  5.32
    ## 2010    0.03    0.13 0.00 13.88 65.26 3.29 1.89 12.79
    ## 2011    0.05    0.06 0.00 14.21 15.89 3.36 6.08  5.62
    ## 2012    0.00    0.02 0.08 20.24 24.73 3.64 0.23  6.98
    ## 2013    0.52    3.71 2.91 31.36 27.23 9.85 1.25 12.03
    ## 
    ## , , JMAmedian
    ## 
    ##      WCSI.MW WCSI.BT   CSTR CHAT SUBA PUYS NULL      
    ## 2003    9.27    1.08   1.08 0.07 0.00 0.15 1.90  1.99
    ## 2004   89.63    0.66   0.41 0.01 0.00 1.09 0.19 13.66
    ## 2005    9.41    1.55 246.98 0.22 0.00 0.37 4.77 55.07
    ## 2006    9.64    0.05   0.00 0.08 0.00 0.00 0.03  1.40
    ## 2007    5.10    0.06   0.93 0.04 0.00 0.00 0.12  0.93
    ## 2008    3.80    0.74   0.94 2.72 0.00 0.00 0.28  1.39
    ## 2009  122.85    0.00   0.07 0.00 0.00 0.00 0.06 17.57
    ## 2010    0.19    0.02   2.16 0.14 0.00 0.00 0.09  0.36
    ## 2011    0.52    0.15   0.04 0.01 0.00 0.00 0.00  0.24
    ## 2012    1.74    0.10  16.54 0.19 0.00 0.00 4.66  3.60
    ## 2013   14.00    0.00  20.07 0.07 0.05 0.00 3.07  5.55
    ## 
    ## , , SNDmedian
    ## 
    ##      WCSI.MW WCSI.BT  CSTR  CHAT SUBA   PUYS   NULL      
    ## 2003    0.78    4.13  0.06 20.85 0.90  28.64  47.78 15.36
    ## 2004    0.18    6.37  0.27 35.41 0.36  41.23  28.26 16.64
    ## 2005    0.87    2.64  3.28 41.06 0.92   1.53  16.54 10.37
    ## 2006    1.97   19.13  0.04 48.50 5.00 241.49  65.14 53.52
    ## 2007    2.77   15.96  1.20 30.37 1.66 218.14  44.40 46.08
    ## 2008    1.68   15.34  7.00 88.17 3.15  89.97  60.09 38.18
    ## 2009    0.71   35.88  0.25 66.19 1.28  97.19 108.56 44.77
    ## 2010    0.28    4.03 12.88 32.33 1.59  39.84  66.35 22.66
    ## 2011    0.28   24.70  0.00 42.99 1.07  39.41  54.46 24.82
    ## 2012    0.05    5.35  0.97 27.57 1.21  30.22  19.05 12.90
    ## 2013    0.80   23.58  0.35 47.43 2.72 170.59  19.25 36.06
    ## 
    ## , , LDOmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA  PUYS  NULL      
    ## 2003    5.39   36.25 0.01 67.30 6.51  4.86  8.89 18.23
    ## 2004    5.03   34.17 0.00 54.17 5.74  4.77  7.80 16.10
    ## 2005    1.69   29.11 0.00 65.75 7.39  3.81 10.91 17.31
    ## 2006    4.47   61.05 0.03 46.62 7.37 19.84  9.13 21.07
    ## 2007    3.74   58.21 0.07 51.96 7.50 20.49  6.95 22.23
    ## 2008    6.11   39.01 0.06 25.66 5.56 17.36  6.31 14.31
    ## 2009   13.72   53.73 0.00 30.10 5.83 30.09  3.24 19.55
    ## 2010    5.11   26.58 0.53 51.06 6.84 13.83 11.27 16.59
    ## 2011    8.15   58.22 0.05 31.43 8.12 11.45  6.35 17.70
    ## 2012    2.87   29.82 0.06 45.65 5.29  4.41 21.28 14.82
    ## 2013   13.86   87.60 0.22 57.60 5.49 36.58  4.07 29.24
    ## 
    ## , , SWAmedian
    ## 
    ##      WCSI.MW WCSI.BT   CSTR   CHAT   SUBA   PUYS    NULL       
    ## 2003   74.06  131.74   0.18 135.33  39.55 397.06  256.17 145.88
    ## 2004   99.87  397.77   0.03 463.66 224.28 431.88   60.76 225.45
    ## 2005   30.44  326.90  11.37 157.57  21.10  16.73   20.99  88.59
    ## 2006   39.63  207.34   0.17 399.48 229.36 678.30  842.34 332.54
    ## 2007   72.79  294.63  10.57 226.99 215.80 687.12  384.17 259.03
    ## 2008   45.85  162.37   6.15 317.90  40.14 126.77  176.69 134.27
    ## 2009  141.88   79.01   0.09 172.31  93.08  80.24   21.99  83.15
    ## 2010   60.27  128.98   2.40 541.09  93.11 132.65    9.74 145.37
    ## 2011   80.41  255.67  20.41 304.91 109.18 111.51   27.74 131.37
    ## 2012   46.75  176.33  36.90 285.19  43.61 151.79  328.10 152.23
    ## 2013   34.13  177.23 125.10 220.82 177.91 356.47 1288.37 346.17
    ## 
    ## , , COLmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2004    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2005    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2006    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2007    0.00    0.00    0 0.00 0.00    0  0.1 0.01
    ## 2008    0.00    0.04    0 6.16 0.06    0  0.6 0.94
    ## 2009    0.00    0.00    0 8.07 0.00    0  0.0 1.15
    ## 2010    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2011    0.00    0.00    0 0.00 0.00    0  0.0 0.00
    ## 2012    0.00    0.00    0 3.67 0.00    0  0.0 0.52
    ## 2013    0.03    0.00    0 0.31 0.00    0  0.0 0.08
    ## 
    ## , , SBKmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.02 0.00 0.46 0.22    0 0.16 0.14
    ## 2004    0.00    0.02 0.01 1.05 0.20    0 0.37 0.23
    ## 2005    0.00    0.00 0.00 1.96 0.75    0 0.00 0.41
    ## 2006    0.02    1.64 0.00 0.67 0.28    0 0.24 0.39
    ## 2007    0.01    0.10 0.00 0.60 0.32    0 0.11 0.17
    ## 2008    0.00    3.28 0.00 0.86 0.11    0 0.16 0.69
    ## 2009    0.02    6.39 0.00 0.36 1.53    0 0.16 1.29
    ## 2010    0.00    0.51 0.00 1.73 0.27    0 0.84 0.50
    ## 2011    0.07    0.70 0.00 0.90 0.31    0 0.00 0.38
    ## 2012    0.00    0.13 0.00 0.42 0.23    0 0.06 0.13
    ## 2013    0.01    0.41 0.05 3.72 0.58    0 0.33 0.74

    RATES.95hi

    ## , , JAVrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR    CHAT   SUBA   PUYS   NULL       
    ## 2003   19.62   60.22 0.03  616.01 216.48  74.06 165.16 149.45
    ## 2004   22.83  133.65 0.00  593.21 214.53  37.84 178.00 138.48
    ## 2005   60.49  123.73 0.54  977.49 735.44  21.03 185.66 243.04
    ## 2006   35.56  405.67 0.00  663.01 183.07 292.18 464.02 214.96
    ## 2007   43.70  192.59 6.52  838.26 241.21 239.59 258.83 221.24
    ## 2008   11.45  147.74 9.83  637.43 403.34 140.62 211.80 187.01
    ## 2009   20.45  314.40 1.29  775.77 355.05 247.80 160.54 244.95
    ## 2010   10.73  135.84 9.35 1199.40 536.61 202.10 362.39 259.82
    ## 2011   14.49  336.36 0.00  605.75 197.50 145.62 218.49 189.25
    ## 2012   16.59   99.45 1.74  456.92 191.53  93.89 176.38 121.83
    ## 2013   25.29  275.83 3.32  633.89 267.88 386.47 200.53 212.36
    ## 
    ## , , RATrates95hi
    ## 
    ##      WCSI.MW WCSI.BT  CSTR    CHAT   SUBA   PUYS   NULL       
    ## 2003   12.60   64.34  1.91  595.95 108.52  64.50 356.89 147.66
    ## 2004    7.23   71.48  1.48  704.22 109.29  40.56 250.04 145.76
    ## 2005    6.55   72.85  1.94  815.03 125.42  25.20 179.15 148.57
    ## 2006   10.65  119.24  1.22  691.29 111.68 343.39 222.14 176.97
    ## 2007   22.07  195.64  9.51  270.39  75.25 204.10 309.91 148.97
    ## 2008    8.14  139.65 16.30  569.50  83.21  63.19 320.51 154.69
    ## 2009    9.78  245.19  7.55 1103.96  97.82 254.43  94.02 241.24
    ## 2010    2.93  103.13 41.11  888.02 252.52 226.05 678.09 285.86
    ## 2011   12.95  170.87  2.57  478.84 208.24 284.68 280.00 172.47
    ## 2012   11.00   84.41 25.88  531.37 145.18 176.92 894.35 229.17
    ## 2013   17.53  213.35 46.22  670.49 152.67 248.29 606.00 241.60
    ## 
    ## , , SQUrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA   PUYS  NULL      
    ## 2003   11.11   66.65 0.42  5.54 76.23  27.29  5.22 21.36
    ## 2004   17.09  148.15 0.75 11.78 13.68  23.00  3.20 29.93
    ## 2005    9.34   64.81 1.52 14.49 56.30   9.56  6.22 20.21
    ## 2006    4.19   83.84 0.42 12.19 45.10  78.65 28.17 28.49
    ## 2007   18.55  108.32 1.57 11.64 48.64  72.74 20.09 35.25
    ## 2008   10.89   44.31 1.31 11.28 32.13  68.56  3.60 21.29
    ## 2009   24.62    8.64 0.58  6.83 26.06  90.41  1.79 21.45
    ## 2010   20.05   27.05 0.42 18.12 51.59  89.97 17.35 27.46
    ## 2011   14.29   65.08 0.39  8.42 89.53  90.06  5.28 32.69
    ## 2012   23.24   58.17 0.78  8.65 40.23  81.59  5.61 26.67
    ## 2013   14.01  107.77 0.44  7.18 60.03 215.86 10.62 49.79
    ## 
    ## , , ETBrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT   SUBA  PUYS  NULL      
    ## 2003    0.00    0.00 0.00  0.18  13.01  0.00  3.21  2.04
    ## 2004    0.59    8.54 0.15  8.41   4.08  1.85  0.00  2.45
    ## 2005    0.00    0.00 0.00  0.00  21.12  0.00  0.00  3.02
    ## 2006    0.12    0.32 0.00  2.81   8.81  0.00  0.00  1.48
    ## 2007    0.53    0.19 0.01 16.12   2.60  7.55  3.60  3.18
    ## 2008    1.19    0.00 2.18 93.10  43.81  7.09  6.06 18.11
    ## 2009    0.20    0.21 0.00  7.38  39.18  7.17  0.02  7.27
    ## 2010    0.10    0.22 0.00 30.96 168.49  6.40  6.17 27.03
    ## 2011    0.13    0.16 0.00 26.15  18.93  4.25 11.10  7.82
    ## 2012    0.00    0.06 0.23 33.47  51.16  9.80  0.78 11.12
    ## 2013    0.81    6.36 6.09 50.30  35.69 17.34  4.83 14.66
    ## 
    ## , , JMArates95hi
    ## 
    ##      WCSI.MW WCSI.BT   CSTR  CHAT SUBA  PUYS    NULL       
    ## 2003   24.38    3.84   2.19  0.14 0.00  0.32    3.13   4.07
    ## 2004  174.81    1.96   0.49  0.05 0.02 15.36    0.29  25.34
    ## 2005   19.83   11.12 992.84  0.53 0.00  0.75 1369.89 255.73
    ## 2006   14.54    0.08   0.00  0.10 0.00  0.00    0.09   2.08
    ## 2007    7.48    0.21   1.75 21.93 0.00  0.00    0.28   3.94
    ## 2008   17.40    3.79   2.27  7.20 0.04  0.00    0.64   3.11
    ## 2009  280.83    0.00   0.15  0.00 0.00  0.00    0.13  40.13
    ## 2010    0.37    0.09   4.97  0.28 0.00  0.00    0.21   0.81
    ## 2011    2.56    0.30   0.06  3.83 0.00  0.00    0.00   0.95
    ## 2012    4.02    0.23  44.90  1.51 0.01  0.00    8.44   7.58
    ## 2013   40.28    0.03  40.71  0.19 0.14  0.00    4.95  11.86
    ## 
    ## , , SNDrates95hi
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT SUBA   PUYS   NULL      
    ## 2003    1.92    4.93  0.13  53.84 1.84  57.04 107.05 27.58
    ## 2004    1.03   15.37  0.44  63.35 0.65 160.13  43.05 30.54
    ## 2005    1.46    4.87  6.06  53.22 2.15   2.85  42.04 12.79
    ## 2006    4.37   29.42  0.35  71.84 6.87 369.73  84.86 74.90
    ## 2007    4.43   24.89  2.45  47.14 3.23 312.75  69.09 58.91
    ## 2008    2.60   22.42 14.89 117.61 4.17 197.62  76.21 52.84
    ## 2009    0.85   52.08  0.74  81.55 1.62 147.06 194.91 55.23
    ## 2010    0.95   12.56 20.48  40.96 2.25  61.97  77.85 28.99
    ## 2011    0.50   52.23  0.00  63.12 2.27  46.94 143.44 38.69
    ## 2012    0.13   23.96  2.35  38.64 1.65  43.15  50.25 15.43
    ## 2013    1.11   34.56  0.78  56.08 4.18 308.47  25.90 57.67
    ## 
    ## , , LDOrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA  PUYS  NULL      
    ## 2003   11.63   44.14 0.02 92.88  8.18 14.71 11.24 24.28
    ## 2004    7.05   43.16 0.00 60.43 12.15  7.24 12.90 17.42
    ## 2005    2.12   36.14 0.00 96.55 10.47  7.78 13.31 20.85
    ## 2006    7.35   67.24 0.08 51.12  9.83 28.12 13.34 22.79
    ## 2007    5.19   86.10 0.16 87.33 13.68 23.60 14.01 24.14
    ## 2008    8.17   40.98 0.10 29.61 12.98 23.41  7.13 15.48
    ## 2009   20.11   62.91 0.03 40.04  7.35 39.29  4.02 21.80
    ## 2010    7.13   43.82 0.88 65.20 10.97 21.62 22.87 19.24
    ## 2011   12.88   71.74 0.09 36.21 15.43 19.04 15.53 20.81
    ## 2012    4.21   44.49 0.10 49.84  5.97  5.92 36.85 18.88
    ## 2013   17.65  113.30 0.28 98.42  8.84 45.02  8.68 38.04
    ## 
    ## , , SWArates95hi
    ## 
    ##      WCSI.MW WCSI.BT   CSTR   CHAT   SUBA    PUYS    NULL       
    ## 2003   99.22  219.32   0.43 303.47  71.06  810.19  442.03 263.48
    ## 2004  122.70  529.46   0.09 674.42 426.67  850.53  159.34 337.22
    ## 2005   43.67  391.37  20.28 218.57  39.86   29.19   36.23  95.60
    ## 2006   58.96  242.83   0.24 529.32 251.31 1560.41 1179.21 418.27
    ## 2007  114.72  402.54  14.04 322.68 400.40  974.47  807.77 350.98
    ## 2008   58.06  220.81   8.85 563.47  82.74  167.12  307.43 164.65
    ## 2009  152.29  102.92   0.38 206.88 156.31  132.70   65.11  94.20
    ## 2010   86.02  164.23   5.98 732.92 237.10  279.09   15.00 169.57
    ## 2011  142.96  331.31  59.79 361.34 229.41  276.55   51.67 172.46
    ## 2012   63.14  195.63 103.31 458.61  81.12  374.25  765.22 212.23
    ## 2013   40.37  249.63 236.13 259.14 252.61  785.88 2028.94 447.21
    ## 
    ## , , COLrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2004    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2005    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2006    0.00    0.00    0  0.04 0.00    0 0.00 0.01
    ## 2007    0.00    0.00    0  0.00 0.00    0 0.65 0.09
    ## 2008    0.00    0.10    0 14.69 0.14    0 1.07 2.20
    ## 2009    0.00    0.00    0 33.37 0.00    0 0.00 4.77
    ## 2010    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2011    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2012    0.00    0.00    0  8.58 0.00    0 0.00 1.23
    ## 2013    0.24    6.65    0  0.53 0.00    0 0.00 1.01
    ## 
    ## , , SBKrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.17 0.02 1.18 0.54 0.00 0.91 0.25
    ## 2004    0.01    0.07 0.03 1.62 0.51 0.00 0.71 0.40
    ## 2005    0.00    0.01 0.00 4.04 1.13 0.00 0.00 0.67
    ## 2006    0.66    3.49 0.00 1.45 0.60 0.00 0.48 0.78
    ## 2007    0.02    0.30 0.00 1.24 0.92 0.00 0.28 0.31
    ## 2008    0.01    5.49 0.00 1.92 0.20 0.00 0.23 0.89
    ## 2009    0.07   11.85 0.00 1.95 6.23 0.86 0.41 2.17
    ## 2010    0.00    1.57 0.00 2.92 0.50 0.32 1.40 0.82
    ## 2011    0.18    1.93 0.00 2.66 1.07 0.55 0.05 0.48
    ## 2012    0.00    0.24 0.00 0.67 0.54 0.00 0.13 0.18
    ## 2013    0.02    0.81 0.07 5.80 0.95 0.00 0.56 0.96

    RATES.95lo

    ## , , JAVrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003    7.74   29.63 0.00 457.60 159.56   0.00 119.16 117.15
    ## 2004    9.69   67.45 0.00 395.93  46.92   9.03  98.23 111.77
    ## 2005   31.94   30.65 0.00 396.45 124.94   4.92  21.74 146.38
    ## 2006   17.39   41.06 0.00 463.97  44.18 180.12 161.73 169.87
    ## 2007   10.93   18.11 0.01 425.49  41.92 112.41 154.61 165.29
    ## 2008    7.96   84.72 0.17 436.22 210.92  48.56 127.91 150.34
    ## 2009    9.88  177.19 0.09 515.63 157.69  89.73  56.90 171.69
    ## 2010    7.16   24.51 5.15 747.86  85.25  54.16  99.79 162.33
    ## 2011    6.77  116.22 0.00 440.52 135.33  18.97  50.87 130.76
    ## 2012    8.00   54.11 1.07 313.14 103.67  33.69  35.41  96.86
    ## 2013   16.70  192.38 1.29 401.96 102.58 200.19  17.75 174.53
    ## 
    ## , , RATrates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT  SUBA   PUYS   NULL       
    ## 2003    3.93   40.49  0.12 274.18 73.12   1.64 192.88 100.91
    ## 2004    1.60   41.96  0.50 300.20 22.54   7.94  96.77  79.45
    ## 2005    3.59   25.89  0.04 207.56 31.39   8.73  52.89  67.60
    ## 2006    2.99   36.45  0.00 332.97 21.19 112.84 147.67 106.14
    ## 2007    5.21   22.50  3.21 152.06 33.36  55.14 149.91  82.31
    ## 2008    4.31   82.87  2.53 207.07 29.24  33.75 130.85  96.41
    ## 2009    5.37  190.83  0.55 459.99 55.00  50.83  54.16 137.26
    ## 2010    0.72   22.49 22.45 469.43 38.89  68.18 264.04 164.02
    ## 2011    4.46   57.54  0.72 324.24 61.75  35.86 152.64 108.69
    ## 2012    4.54   47.50 14.82 302.50 80.02  56.08 399.00 135.57
    ## 2013    8.19  136.54 18.11 323.52 45.13  62.91 203.69 163.29
    ## 
    ## , , SQUrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT  SUBA  PUYS NULL      
    ## 2003    4.36   43.19 0.13 2.88  8.60  3.90 2.67 10.62
    ## 2004    7.01   55.08 0.34 7.97  4.51  2.91 1.02 14.21
    ## 2005    5.47   25.92 0.46 8.27 36.64  4.12 1.60 12.98
    ## 2006    2.66   50.05 0.04 4.41 10.62 45.35 3.28 20.51
    ## 2007    9.73   69.44 0.53 5.45 16.80 48.42 3.63 26.64
    ## 2008    7.60    3.99 0.31 5.33 15.26 29.89 2.25 13.33
    ## 2009   13.51    4.23 0.24 2.46 16.26 43.21 0.09 13.38
    ## 2010   11.20   12.94 0.08 6.37 15.48 22.57 3.44 13.09
    ## 2011    4.21   16.99 0.04 4.37 37.13 25.07 2.38 17.91
    ## 2012   15.19   31.16 0.43 0.69 18.54 31.31 1.53 15.56
    ## 2013    6.29   55.62 0.21 2.63 12.87 77.18 5.54 31.34
    ## 
    ## , , ETBrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA PUYS NULL     
    ## 2003    0.00    0.00 0.00  0.00  0.00 0.00 0.73 0.16
    ## 2004    0.00    0.00 0.00  0.00  0.00 0.00 0.00 0.20
    ## 2005    0.00    0.00 0.00  0.00  4.82 0.00 0.00 0.69
    ## 2006    0.00    0.00 0.00  0.54  0.93 0.00 0.00 0.31
    ## 2007    0.00    0.00 0.00  2.95  0.03 0.00 0.26 0.97
    ## 2008    0.04    0.00 0.00  5.55 12.40 0.84 0.26 4.56
    ## 2009    0.00    0.02 0.00  2.70 11.58 0.00 0.00 2.72
    ## 2010    0.00    0.00 0.00 11.38  5.72 1.22 0.00 3.52
    ## 2011    0.00    0.00 0.00  7.77 11.69 0.27 3.77 4.65
    ## 2012    0.00    0.00 0.00  6.53  0.93 0.92 0.00 1.31
    ## 2013    0.34    2.17 1.97 24.89 25.17 0.10 0.12 9.79
    ## 
    ## , , JMArates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR CHAT SUBA PUYS NULL     
    ## 2003    5.47    0.35  0.27 0.03    0    0 0.75 1.11
    ## 2004    8.76    0.03  0.23 0.00    0    0 0.00 1.73
    ## 2005    5.37    0.02  1.15 0.00    0    0 0.00 4.04
    ## 2006    5.64    0.02  0.00 0.00    0    0 0.00 0.82
    ## 2007    2.29    0.00  0.27 0.00    0    0 0.01 0.51
    ## 2008    1.04    0.01  0.12 0.02    0    0 0.00 0.51
    ## 2009    1.20    0.00  0.04 0.00    0    0 0.00 0.18
    ## 2010    0.00    0.00  1.12 0.05    0    0 0.02 0.22
    ## 2011    0.11    0.01  0.00 0.00    0    0 0.00 0.02
    ## 2012    0.73    0.00 10.48 0.01    0    0 3.84 2.44
    ## 2013    0.45    0.00  7.19 0.03    0    0 1.22 2.12
    ## 
    ## , , SNDrates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR  CHAT SUBA   PUYS  NULL      
    ## 2003    0.46    1.36  0.00  7.21 0.02  10.17 21.84 11.12
    ## 2004    0.02    1.21  0.05 22.51 0.06   4.44 18.07 11.10
    ## 2005    0.31    1.90  0.85 33.66 0.53   0.59 10.54  8.51
    ## 2006    0.78    8.49  0.00 34.98 2.20 170.37  8.99 41.83
    ## 2007    1.13    4.82  0.74 12.47 1.15 155.09 27.67 33.65
    ## 2008    0.81   12.46  1.95 64.01 1.66  27.28 47.78 26.67
    ## 2009    0.39   28.00  0.05 34.00 0.98  62.17 59.00 34.57
    ## 2010    0.15    0.80 11.24 25.04 0.70  30.67 30.81 16.79
    ## 2011    0.11    6.00  0.00 28.55 0.17  30.40 17.69 14.34
    ## 2012    0.00    1.39  0.31  9.25 0.86  23.87  0.30 11.07
    ## 2013    0.52   16.60  0.00 30.49 1.87  67.37  8.60 24.64
    ## 
    ## , , LDOrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA  PUYS NULL      
    ## 2003    2.03   25.91 0.00 49.59 4.08  0.43 4.60 14.85
    ## 2004    2.10   26.48 0.00 47.49 2.92  2.76 3.03 14.63
    ## 2005    1.24   20.78 0.00 58.97 5.63  0.59 3.40 14.92
    ## 2006    2.09   49.16 0.00 26.96 3.75 15.76 4.41 17.36
    ## 2007    2.70   25.89 0.03 25.42 4.59 14.98 3.47 20.00
    ## 2008    3.20   28.68 0.03 22.46 2.62 14.50 4.46 12.91
    ## 2009    8.11   42.55 0.00 24.53 4.34 20.31 1.79 17.65
    ## 2010    3.39   15.42 0.31 35.75 2.23  8.80 9.66 12.92
    ## 2011    3.14   49.27 0.00 19.61 5.89  2.38 1.77 15.04
    ## 2012    2.25   21.86 0.03 35.20 4.49  3.02 6.50 13.42
    ## 2013   12.46   65.97 0.16 42.41 4.12 12.79 0.40 25.66
    ## 
    ## , , SWArates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003   55.26  109.51  0.05  61.91  10.50 186.52 136.83 110.95
    ## 2004   60.62  151.61  0.00 325.64  12.55   7.91  33.67 144.04
    ## 2005   17.64  205.43  4.96 116.41  12.09  11.08   9.40  63.48
    ## 2006   18.55  147.04  0.03 336.69 125.57 380.57  99.58 253.71
    ## 2007   35.97  242.79  0.75 194.63  77.29 308.90 135.59 164.08
    ## 2008   36.54  134.45  0.09 147.41  31.64  65.81  83.48  87.17
    ## 2009   88.88   44.29  0.00  63.80  48.60  43.88   5.92  54.77
    ## 2010   46.74  109.88  1.91 421.60  52.72  68.03   5.63 108.50
    ## 2011   55.59  207.87  3.47 161.19  61.82  66.90  13.13 115.86
    ## 2012   39.50  128.13  1.79 127.40   8.78  69.62  52.28  97.72
    ## 2013   17.98  141.78 34.50 103.45  88.35 173.28 668.99 272.14
    ## 
    ## , , COLrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003       0       0    0 0.00    0    0 0.00 0.00
    ## 2004       0       0    0 0.00    0    0 0.00 0.00
    ## 2005       0       0    0 0.00    0    0 0.00 0.00
    ## 2006       0       0    0 0.00    0    0 0.00 0.00
    ## 2007       0       0    0 0.00    0    0 0.00 0.00
    ## 2008       0       0    0 3.19    0    0 0.14 0.56
    ## 2009       0       0    0 0.00    0    0 0.00 0.00
    ## 2010       0       0    0 0.00    0    0 0.00 0.00
    ## 2011       0       0    0 0.00    0    0 0.00 0.00
    ## 2012       0       0    0 0.00    0    0 0.00 0.00
    ## 2013       0       0    0 0.00    0    0 0.00 0.00
    ## 
    ## , , SBKrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00 0.00 0.12 0.05    0 0.00 0.05
    ## 2004    0.00    0.02 0.00 0.64 0.00    0 0.23 0.14
    ## 2005    0.00    0.00 0.00 0.43 0.24    0 0.00 0.22
    ## 2006    0.01    0.17 0.00 0.26 0.00    0 0.00 0.19
    ## 2007    0.00    0.00 0.00 0.32 0.03    0 0.02 0.10
    ## 2008    0.00    2.25 0.00 0.11 0.02    0 0.07 0.38
    ## 2009    0.01    3.85 0.00 0.05 0.29    0 0.02 0.69
    ## 2010    0.00    0.00 0.00 1.05 0.02    0 0.00 0.26
    ## 2011    0.00    0.00 0.00 0.27 0.05    0 0.00 0.10
    ## 2012    0.00    0.02 0.00 0.26 0.04    0 0.00 0.09
    ## 2013    0.00    0.27 0.02 1.59 0.25    0 0.06 0.48
