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
    ## 2003 11319 8484 955  44  104  702 1499  7341   0  18
    ## 2004  7645 7969 863  97  483  925  955 12803   0  16
    ## 2005  8833 5058 637  31 2516  420  720  3461   0  20
    ## 2006  6487 5034 654  18   49 1321  736  9870   0  15
    ## 2007  6211 3151 584  61   34  878  736  6504   0   9
    ## 2008  5880 4580 381 353   34 1025  405  3884  45  18
    ## 2009  6418 4866 305 149   12  848  544  2139 114  29
    ## 2010  7018 7976 442 347   10  571  438  4027   0  14
    ## 2011  4717 4265 604 160    6  626  548  4339   0  15
    ## 2012  3724 4788 499 220  114  316  468  4504  27   4
    ## 2013  6064 5906 737 381  165  734  857  7626  21  27

    VOLt_cv

    ##      JAV RAT SQU ETB  JMA SND LDO SWA COL SBK
    ## 2003  12   9  24  61   66  17  14  28 NaN  30
    ## 2004  11  23  14  15  106  32   9  10 NaN  27
    ## 2005  12  30  14  74  110  20  15   5 NaN  32
    ## 2006  15  13  11  76   18  11   9  15 NaN  49
    ## 2007  18   6  15  68  117  16  26  14 NaN  48
    ## 2008  10  20  14  48   63  10   6  18  78  22
    ## 2009   8  21  10  22 2126  15  16   9  58  36
    ## 2010  13  11  12  36   26  18  11  26 NaN  47
    ## 2011  10  12  11  25  155  32   8  11 NaN  26
    ## 2012  12  17  12  13   35  15  11  11  86  25
    ## 2013   9   9  14  17   43  23   7  33  64  25

    VOLt_95hi

    ##        JAV   RAT  SQU ETB  JMA  SND  LDO   SWA COL SBK
    ## 2003 13474 10165 1527  81  231  893 1652 11767   0  25
    ## 2004  9422 10958 1046 113 1593 1531 1152 15019   0  22
    ## 2005 10364  8442  750  82 9198  546  821  3681   0  32
    ## 2006  8056  5804  784  57   60 1628  809 11190   0  26
    ## 2007  8892  3429  784 152  129 1188 1087  8668   2  19
    ## 2008  6646  6060  518 578   77 1179  458  5282 124  26
    ## 2009  7171  7372  342 208  626 1049  692  2396 173  51
    ## 2010  9257  9874  513 517   13  728  519  6136   0  35
    ## 2011  5405  4854  787 243   27 1098  585  5540   0  24
    ## 2012  4618  5843  550 258  198  338  564  5145  85   7
    ## 2013  6673  6896 1043 560  325 1029  947 14535  40  37

    VOLt_95lo

    ##       JAV  RAT SQU ETB JMA  SND LDO   SWA COL SBK
    ## 2003 8390 7663 807   0  34  522 921  4646   0  10
    ## 2004 6361 6013 713  68 191  627 874 10656   0   9
    ## 2005 6554 2903 474   7  27  319 460  3216   0  12
    ## 2006 4587 3671 568   9  36 1080 597  6640   0   3
    ## 2007 5293 2850 466  23  20  681 438  5281   0   4
    ## 2008 4923 2722 333 130  13  834 351  2835   4  12
    ## 2009 5559 4381 241  87   2  661 365  1887   0  20
    ## 2010 5349 6524 357 126   4  390 344  2802   0  10
    ## 2011 3670 2889 554  94   1  502 462  3722   0   9
    ## 2012 3311 3214 367 165  48  194 380  3686   0   3
    ## 2013 5148 5140 707 321 100  519 730  5574   0  16

VOLUME ANNUEL PAR STRATE SPATIALE PAR CATEGORIE

    VOLs

    ## , , JAVPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      69     172    0 5396  963   18  258 4352
    ## 2004      86     213    0 3793  324    5  157 2881
    ## 2005     124     105    1 4017 1037    5   65 3407
    ## 2006      78     347    0 2860  256   91  166 2716
    ## 2007      58      85    3 3129  404   59  111 2456
    ## 2008       9     186    6 2770  578   16  137 2141
    ## 2009      14     393    0 2959  475   25   79 2431
    ## 2010      15     102   13 3712  459   13  156 2522
    ## 2011      20     320    0 1982  302   39   79 1946
    ## 2012      24     158    3 1677  272   18  129 1531
    ## 2013      52     417    5 2163  438   60  132 2857
    ## 
    ## , , RATPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      39     164    2 3997  426   17  419 3570
    ## 2004      25     119    3 4154  200    8  285 3177
    ## 2005      14      96    2 2591  215    8  111 1900
    ## 2006      13     200    0 2535   58   77  134 2076
    ## 2007      21     117   10 1165  138   39  128 1523
    ## 2008       7     201   17 2119  142   10  215 1701
    ## 2009       7     307    6 2657  123   17   56 1723
    ## 2010       4     102   49 3244  349   18  741 3247
    ## 2011      14     194    3 1640  235   46  189 1873
    ## 2012      19     112   43 1612  170   28  462 2218
    ## 2013      32     319   59 2173  285   27  416 2669
    ## 
    ## , , SQUPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      35     182    1   42  201   13    9 503
    ## 2004      65     198    2   76   32    3    3 466
    ## 2005      18     111    3   62  106    4    4 328
    ## 2006       6     145    0   58   55   20   12 363
    ## 2007      35      93    2   27   45   14    4 344
    ## 2008       8      48    1   39   47   13    2 229
    ## 2009      16       9    1   17   34   12    1 200
    ## 2010      23      26    1   57   81    7   11 246
    ## 2011      21      86    0   30  109   18    3 333
    ## 2012      33      85    1   22   53   16    2 287
    ## 2013      26     132    1   20   70   23    7 468
    ## 
    ## , , ETBPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    0   24    0    0  20
    ## 2004       1       4    0   41    7    0    0  34
    ## 2005       0       0    0    0   15    0    0  16
    ## 2006       0       0    0    6    3    0    0   7
    ## 2007       0       0    0   38    3    1    1  22
    ## 2008       0       0    1  137   59    1    2 131
    ## 2009       0       0    0   19   55    1    0  69
    ## 2010       0       0    0   68  123    1    1 153
    ## 2011       0       0    0   66   21    1    4  66
    ## 2012       0       0    0   65   52    1    0  94
    ## 2013       1       8    7  141   61    2    2 159
    ## 
    ## , , JMAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      37       3    5    1    0    0    2   52
    ## 2004     271       2    1    0    0    0    0  208
    ## 2005      26       4  582    1    0    0    2 1166
    ## 2006      26       0    0    1    0    0    0   23
    ## 2007       8       0    2    0    0    0    0   18
    ## 2008       5       1    2    6    0    0    0   15
    ## 2009       4       0    0    0    0    0    0    7
    ## 2010       0       0    4    1    0    0    0    5
    ## 2011       1       1    0    0    0    0    0    3
    ## 2012       3       0   44    1    0    0    4   59
    ## 2013      46       0   40    0    0    0    3   83
    ## 
    ## , , SNDPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       4      17    0  198    4    9   66 377
    ## 2004       4      16    1  300    0   17   36 545
    ## 2005       2       5   11  212    2    1   17 174
    ## 2006       2      47    0  288    6   98   41 854
    ## 2007       5      25    3  119    4   52   35 615
    ## 2008       2      28   10  423    6   19   45 458
    ## 2009       1      63    1  257    2   12   71 463
    ## 2010       1       4   21  141    2    7   72 316
    ## 2011       1      64    0  187    2   11   62 309
    ## 2012       0       9    1   86    2   10   17 159
    ## 2013       2      46    1  185    5   28   21 448
    ## 
    ## , , LDOPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      45     133    0  689   29    2   12 588
    ## 2004      22      80    0  437   25    1    7 385
    ## 2005       5      64    0  355   15    2    5 272
    ## 2006      13     147    0  213   13    9    6 316
    ## 2007       6      51    0  333   17    6    4 275
    ## 2008       6      69    0  123   16    4    4 182
    ## 2009      15      90    0  175   11    5    2 254
    ## 2010       9      34    1  169   11    2   15 182
    ## 2011      15     117    0  149   12    5    5 237
    ## 2012       7      53    0  189    9    1   16 186
    ## 2013      35     154    0  248   12    7    5 386
    ## 
    ## , , SWAPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     364     456    1 1601  140  144  436 3992
    ## 2004     518     939    0 3881  567  134  112 6615
    ## 2005      88     699   60  998   37    8   27 1527
    ## 2006     103     493    0 1743  349  296  766 6077
    ## 2007     141     482   13 1249  479  144  265 3918
    ## 2008      42     316   11 1655   67   33   98 1666
    ## 2009     118     104    0  769  155   17   13  912
    ## 2010      99     169    4 2245  132   15    9 1406
    ## 2011     138     567   35 1408  201   33   19 1790
    ## 2012      91     318  105 1116   79   41  473 2312
    ## 2013      76     307  206  906  664   95  825 4451
    ## 
    ## , , COLPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    0    0    0    0  0
    ## 2004       0       0    0    0    0    0    0  0
    ## 2005       0       0    0    0    0    0    0  0
    ## 2006       0       0    0    0    0    0    0  0
    ## 2007       0       0    0    0    0    0    0  0
    ## 2008       0       0    0   33    0    0    0 12
    ## 2009       0       0    0   84    0    0    0 30
    ## 2010       0       0    0    0    0    0    0  0
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       0       0    0   19    0    0    0  8
    ## 2013       0       7    0    2    0    0    0 10
    ## 
    ## , , SBKPE(s)
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0   10    1    0    0  6
    ## 2004       0       0    0    7    0    0    1  6
    ## 2005       0       0    0   12    1    0    0  7
    ## 2006       0       4    0    4    0    0    0  6
    ## 2007       0       0    0    5    0    0    0  3
    ## 2008       0       6    0    4    0    0    0  8
    ## 2009       0       9    0    2    4    0    0 14
    ## 2010       0       0    0    7    0    0    1  6
    ## 2011       0       2    0    7    1    0    0  5
    ## 2012       0       0    0    2    1    0    0  2
    ## 2013       0       1    0   14    1    0    0 10

    VOLs_95hi

    ## , , JAVPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      83     205    0 7190 1074   92  362 4872
    ## 2004     118     350    0 4512  902    8  227 3767
    ## 2005     167     238    3 5183 1612    7  144 3833
    ## 2006     103     685    0 3468  458  121  227 3428
    ## 2007      71     226    8 4946  525   69  149 3223
    ## 2008      13     246   16 3051  854   28  216 2491
    ## 2009      20     586    2 3665  566   50  122 2844
    ## 2010      21     250   19 5634  819   20  272 3069
    ## 2011      28     785    0 2313  359   60  149 2187
    ## 2012      29     252    3 2084  361   22  232 1828
    ## 2013      67     524    7 2517  523   97  198 3096
    ## 
    ## , , RATPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      58     198    9 5313  503   34  584 3889
    ## 2004      39     209    4 6559  383   10  340 3972
    ## 2005      23     129    5 5240  270   13  198 2834
    ## 2006      20     255    2 2999  109   98  167 2334
    ## 2007      52     214   14 1305  173   82  190 1759
    ## 2008      10     333   34 3323  169   16  265 2150
    ## 2009       9     407   13 4319  143   41   63 2539
    ## 2010       5     122   68 4682  437   38 1100 3925
    ## 2011      21     312    4 2093  397   70  307 2132
    ## 2012      25     173   55 1925  289   43  931 3025
    ## 2013      38     419   76 2476  321   63  522 3147
    ## 
    ## , , SQUPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      48     246    1   55  484   18   10 782
    ## 2004     108     279    4  112   50    5    4 584
    ## 2005      29     145    4   91  132    5    5 385
    ## 2006       9     173    0  103   68   24   25 423
    ## 2007      40     153    2   59   95   19    9 463
    ## 2008      10      66    1   55  103   16    3 287
    ## 2009      25      15    1   32   47   17    2 239
    ## 2010      33      38    2   72   94   11   17 306
    ## 2011      33     117    1   47  171   22    5 437
    ## 2012      38     123    1   46   77   22    4 308
    ## 2013      30     190    1   25  144   40   13 666
    ## 
    ## , , ETBPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    3   44    0    4  37
    ## 2004       3      17    0   65   14    0    0  49
    ## 2005       0       0    0    0   39    0    0  43
    ## 2006       0       2    0   16   19    0    0  28
    ## 2007       3       0    0   97    4    1    2  48
    ## 2008       1       0    3  314  108    1    4 187
    ## 2009       0       0    0   32   87    2    0  94
    ## 2010       0       0    0  132  224    1    3 230
    ## 2011       0       0    0  131   28    1    8  88
    ## 2012       0       0    0  113   79    2    1 113
    ## 2013       2      11   11  245   72    4    7 224
    ## 
    ## , , JMAPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     109       6   10    2    0    0    5  110
    ## 2004     933       3    2    0    0    4    0  654
    ## 2005      44      36 2229    2    0    0 2351 6806
    ## 2006      31       0    0    1    0    0    0   28
    ## 2007      14       0    3   81    0    0    0   39
    ## 2008      11       3    3   43    0    0    0   32
    ## 2009     237       0    0    0    0    0    0  389
    ## 2010       1       0    6    1    0    0    0    6
    ## 2011       4       1    0   15    0    0    0   10
    ## 2012       5       0   81    7    0    0    6  105
    ## 2013      94       0   99    1    0    0    5  159
    ## 
    ## , , SNDPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003       8      29    0  308    6   25  156  538
    ## 2004       9      31    3  478    1   62   66 1102
    ## 2005       4       9   16  314    2    1   28  221
    ## 2006       6      80    0  326   18  122   76 1048
    ## 2007       8      38    5  440    5   71   51  756
    ## 2008       3      32   19  536    9   35   54  578
    ## 2009       1      98    1  333    3   17  102  553
    ## 2010       1      15   29  199    5   12  121  423
    ## 2011       1     134    0  232    3   16  215  636
    ## 2012       0      57    5  151    3   13   43  196
    ## 2013       3      55    1  232    9   56   39  727
    ## 
    ## , , LDOPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      66     183    0  817   39    7   18 643
    ## 2004      60      93    0  566   35    2   11 452
    ## 2005       7      89    0  448   24    5   12 309
    ## 2006      23     177    0  307   26   12    7 342
    ## 2007      11     127    0  594   21    6    7 394
    ## 2008       9      81    0  143   31    5    5 207
    ## 2009      24      96    0  267   13    7    3 311
    ## 2010      11      52    2  220   21    3   28 214
    ## 2011      24     137    0  183   22    8   13 269
    ## 2012       8     100    0  269   11    2   34 222
    ## 2013      44     180    1  329   17    9    7 455
    ## 
    ## , , SWAPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     468     692    1 2716  269  609  757 7645
    ## 2004     738    1278    0 4924 1564  269  190 8195
    ## 2005     123     774   91 1280   98   12   74 1648
    ## 2006     179     640    1 2769  665  491 1162 6832
    ## 2007     207     552   25 1762 1001  222  678 5396
    ## 2008      58     493   18 2911  139   47  239 1871
    ## 2009     131     150    2  997  223   24   35 1118
    ## 2010     134     229    8 3501  256   46   17 2096
    ## 2011     223     650   82 2271  329   96   42 2165
    ## 2012     106     416  197 1625  246   68  728 2724
    ## 2013     113     348  392 1060  936  181 3198 9138
    ## 
    ## , , COLPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    0    0    0    0  0
    ## 2004       0       0    0    0    0    0    0  0
    ## 2005       0       0    0    0    0    0    0  0
    ## 2006       0       0    0    0    0    0    0  0
    ## 2007       0       0    0    0    0    0    0  1
    ## 2008       0       0    0   90    0    0    1 33
    ## 2009       0       0    0  127    0    0    0 46
    ## 2010       0       0    0    0    0    0    0  0
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       0       0    0   60    0    0    0 26
    ## 2013       0      18    0    6    0    0    0 21
    ## 
    ## , , SBKPE95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0   13    2    0    2 10
    ## 2004       0       0    0   14    2    0    2  9
    ## 2005       0       0    0   22    4    0    0 10
    ## 2006       1      10    0    7    1    0    0 11
    ## 2007       0       1    0   13    1    0    0  6
    ## 2008       0       7    0   11    1    0    0  9
    ## 2009       0      16    0    3   10    0    0 26
    ## 2010       0       3    0   15    1    0    2 14
    ## 2011       0       3    0   14    1    0    0  8
    ## 2012       0       1    0    3    1    0    0  3
    ## 2013       0       1    0   22    2    0    1 12

    VOLs_95lo

    ## , , JAVPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      34     137    0 3951  700    1  168 3145
    ## 2004      62      62    0 3247  115    2  105 2426
    ## 2005      84      61    0 2638  502    2   10 2624
    ## 2006      41     103    0 1812   91   47   84 2111
    ## 2007      34      18    0 2061  298   37   92 2204
    ## 2008       8     115    0 2076  387    9   99 1854
    ## 2009      10     239    0 2451  273   11   16 2204
    ## 2010      10      42    1 2723   92    7   97 1941
    ## 2011      11      56    0 1744  202   24   24 1402
    ## 2012      15     113    2 1242  202   11   82 1293
    ## 2013      39     349    3 1669  203   36   63 2208
    ## 
    ## , , RATPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003      21     132    0 3145  360    2  260 3083
    ## 2004      14      96    3 2636   35    4  185 2432
    ## 2005       3      59    0 1147  145    2   82 1269
    ## 2006       7      97    0 1795   38   32   81 1516
    ## 2007       3      44    7  984   97   24   85 1328
    ## 2008       4     166    4 1196   95    7  132 1093
    ## 2009       5     234    3 2269   89    6   46 1588
    ## 2010       2      60   39 1838  101    2  520 3032
    ## 2011       8     129    0 1107  185    7  105 1188
    ## 2012      14      74   26 1140  102   19  153 1488
    ## 2013      17     200   40 1655  190   12  280 2289
    ## 
    ## , , SQUPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      24     156    1   24   50    6    3 443
    ## 2004      35     152    1   56   22    1    1 385
    ## 2005      16      52    2   36   80    2    1 236
    ## 2006       5     116    0   27   34   15    2 307
    ## 2007      26      48    1   20   29   11    2 290
    ## 2008       7      34    1   28   21   11    2 208
    ## 2009      10       7    1   10   27    9    1 163
    ## 2010      16      13    0   36   30    2    4 202
    ## 2011       7      65    0   22   88   11    1 306
    ## 2012      26      54    1    6   40    7    0 196
    ## 2013      20      84    0   13   50   12    6 410
    ## 
    ## , , ETBPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       0    0    0    0    0    0   0
    ## 2004       0       0    0   30    0    0    0  25
    ## 2005       0       0    0    0    4    0    0   4
    ## 2006       0       0    0    3    1    0    0   3
    ## 2007       0       0    0    9    2    0    0  10
    ## 2008       0       0    0   29   38    0    0  53
    ## 2009       0       0    0   16   28    0    0  39
    ## 2010       0       0    0   45   11    0    0  49
    ## 2011       0       0    0   22   18    0    2  45
    ## 2012       0       0    0   40   29    0    0  69
    ## 2013       1       5    4   85   46    0    0 133
    ## 
    ## , , JMAPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       5       1    2    0    0    0    0 19
    ## 2004     105       1    1    0    0    0    0 82
    ## 2005      11       0    3    0    0    0    0 12
    ## 2006      18       0    0    0    0    0    0 17
    ## 2007       6       0    0    0    0    0    0 10
    ## 2008       1       0    0    2    0    0    0  6
    ## 2009       1       0    0    0    0    0    0  2
    ## 2010       0       0    1    0    0    0    0  2
    ## 2011       0       0    0    0    0    0    0  0
    ## 2012       2       0   12    0    0    0    2 26
    ## 2013       1       0   16    0    0    0    1 52
    ## 
    ## , , SNDPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003       0       4    0   94    3    0   15 248
    ## 2004       0       4    0  235    0    4   11 297
    ## 2005       1       4    6  148    0    0   10 128
    ## 2006       1      21    0  236    2   66   25 630
    ## 2007       3      12    2   55    2   39   24 512
    ## 2008       1      20    5  360    3    8   36 336
    ## 2009       0      41    0  123    2    8   44 383
    ## 2010       0       1   12  101    1    6   23 198
    ## 2011       0       5    0  153    1    8    0 234
    ## 2012       0       3    0   43    0    8    1 113
    ## 2013       1      28    0  128    4    3   12 246
    ## 
    ## , , LDOPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003      17     103    0  341   18    0    8 390
    ## 2004       8      68    0  361    9    1    5 353
    ## 2005       3      42    0  204   13    0    1 183
    ## 2006       5     139    0  123   11    5    2 274
    ## 2007       2      42    0  145    8    4    2 203
    ## 2008       4      65    0  101    7    3    2 158
    ## 2009       7      62    0   86    7    2    1 182
    ## 2010       4      21    0  126    4    1   10 146
    ## 2011       7      77    0  116    8    3    1 203
    ## 2012       5      42    0  154    8    1    4 151
    ## 2013      28     114    0  179    6    5    2 349
    ## 
    ## , , SWAPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003     302     337    0  574   40   76  121 2529
    ## 2004     362     705    0 2990   14    4   38 4859
    ## 2005      53     459   13  844   26    4   11 1397
    ## 2006      44     377    0 1356  232  139  250 3654
    ## 2007      95     374    2  657  260   57   24 2562
    ## 2008      38     221    8 1019   46   15   43 1285
    ## 2009      96      84    0  616   71   10    6  832
    ## 2010      78     138    2 1134   26    9    5 1158
    ## 2011      84     312   10 1120  102   14   11 1614
    ## 2012      59     266   16  845   19   11   50 1539
    ## 2013      53     271  116  633  119   20  604 3478
    ## 
    ## , , COLPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL  
    ## 2003       0       0    0    0    0    0    0 0
    ## 2004       0       0    0    0    0    0    0 0
    ## 2005       0       0    0    0    0    0    0 0
    ## 2006       0       0    0    0    0    0    0 0
    ## 2007       0       0    0    0    0    0    0 0
    ## 2008       0       0    0    2    0    0    0 1
    ## 2009       0       0    0    0    0    0    0 0
    ## 2010       0       0    0    0    0    0    0 0
    ## 2011       0       0    0    0    0    0    0 0
    ## 2012       0       0    0    0    0    0    0 0
    ## 2013       0       0    0    0    0    0    0 0
    ## 
    ## , , SBKPE95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003       0       0    0    3    1    0    0  4
    ## 2004       0       0    0    4    0    0    0  3
    ## 2005       0       0    0    6    1    0    0  4
    ## 2006       0       0    0    2    0    0    0  1
    ## 2007       0       0    0    1    0    0    0  2
    ## 2008       0       4    0    1    0    0    0  5
    ## 2009       0       7    0    0    1    0    0 10
    ## 2010       0       0    0    4    0    0    0  4
    ## 2011       0       0    0    3    0    0    0  4
    ## 2012       0       0    0    1    0    0    0  1
    ## 2013       0       0    0    7    1    0    0  6

    VOLs_cv

    ## , , JAVPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      24      12  244   17   12  161   22 12
    ## 2004      19      40  NaN   12   71   48   23 12
    ## 2005      19      63   91   18   27   31   52 11
    ## 2006      24      51  NaN   19   43   22   25 14
    ## 2007      18      73   96   27   20   18   16 14
    ## 2008      20      20   74   11   22   37   22 10
    ## 2009      23      28  109   13   18   51   40  7
    ## 2010      22      61   35   19   41   33   32 11
    ## 2011      22      62  NaN    9   16   26   41 12
    ## 2012      22      26   11   15   20   21   34 12
    ## 2013      17      13   31   12   21   32   28 10
    ## 
    ## , , RATPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      24      13  127   17   11   52   23  7
    ## 2004      29      31   17   30   48   27   17 18
    ## 2005      36      21   69   42   16   39   30 23
    ## 2006      28      21  167   16   37   29   19 12
    ## 2007      77      45   25    8   18   51   21  8
    ## 2008      29      23   55   29   14   27   21 17
    ## 2009      20      17   41   26   11   62    8 19
    ## 2010      30      22   18   21   28   55   26 11
    ## 2011      32      27   42   18   26   38   33 13
    ## 2012      18      27   22   12   32   21   58 24
    ## 2013      20      18   21   13   15   50   20 10
    ## 
    ## , , SQUPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      23      14   23   22   61   34   28 22
    ## 2004      35      22   34   20   29   43   26 15
    ## 2005      22      29   23   25   15   19   35 14
    ## 2006      18      13   39   39   21   15   59 11
    ## 2007      12      31   14   46   56   16   43 15
    ## 2008      13      22   45   18   57   16   21 11
    ## 2009      24      23   23   36   16   22   57 12
    ## 2010      22      26   82   20   30   40   32 13
    ## 2011      38      16   47   28   25   24   33 11
    ## 2012      11      31   18   49   20   25   66 12
    ## 2013      11      23   14   19   39   35   29 17
    ## 
    ## , , ETBPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003     NaN     NaN  NaN 1669   64  NaN  Inf  62
    ## 2004     107     120  187   28   66   55  NaN  22
    ## 2005     NaN     NaN  NaN  NaN   75  NaN  NaN  75
    ## 2006     259     160  NaN   61  178  NaN  NaN 100
    ## 2007     178     248  Inf   76   29   61   83  58
    ## 2008     108     NaN  188   87   33   78   67  37
    ## 2009      42      64  NaN   26   31  104  183  24
    ## 2010     119      70  NaN   35   55   46  134  39
    ## 2011      69     119  NaN   43   15   42   36  19
    ## 2012     NaN     170   62   32   31   47  317  15
    ## 2013      46      25   29   29   15   46   84  16
    ## 
    ## , , JMAPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS  NULL     
    ## 2003      97      41   56   59  NaN   69    60   61
    ## 2004     113      73   29  116  370  389   105  100
    ## 2005      34     275  167   75  NaN   77 40763  166
    ## 2006      18      85  NaN   77  NaN  NaN   186   18
    ## 2007      32      75   52 6669  NaN  NaN    80   57
    ## 2008      60      93   65  232  196  NaN    36   50
    ## 2009    2299     NaN   63  NaN  NaN  NaN    76 2224
    ## 2010      86     182   34   59  NaN  NaN   116   27
    ## 2011     116      66   97 6912  NaN  NaN   NaN  110
    ## 2012      34      59   42  190   68  NaN    33   35
    ## 2013      68     235   60   85   56  NaN    36   40
    ## 
    ## , , SNDPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      47      39   71   31   27   85   67 23
    ## 2004      67      47   76   21   86  114   44 50
    ## 2005      49      39   26   26   39   19   33 17
    ## 2006      80      44  110   10   78   17   36 14
    ## 2007      27      36   33   90   33   19   21 12
    ## 2008      48      13   40   13   26   35   12 14
    ## 2009      51      31   37   25   17   25   25 12
    ## 2010      43     115   20   19   53   27   38 21
    ## 2011      47      61  NaN   14   34   25  124 45
    ## 2012      73     188  122   42   44   17   71 16
    ## 2013      22      22   62   16   24   58   38 34
    ## 
    ## , , LDOPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      39      19  Inf   19   20   88   25 12
    ## 2004      74       9  NaN   12   28   34   23  7
    ## 2005      20      23  NaN   22   25   66   65 13
    ## 2006      38       7  Inf   25   35   23   38  7
    ## 2007      43      51  119   38   23   12   34 23
    ## 2008      25       8   33   11   50   12   21  7
    ## 2009      36      12  101   30   16   30   25 13
    ## 2010      21      25   34   20   46   31   34 10
    ## 2011      40      16  138   12   39   26   59  9
    ## 2012      13      31   32   18   10   39   52 12
    ## 2013      14      12   31   17   34   22   31  8
    ## 
    ## , , SWAPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003      14      21   51   42   49  127   40 38
    ## 2004      21      18   96   15  102   57   40 15
    ## 2005      25      14   41   15   56   32   62  5
    ## 2006      41      15   90   24   42   32   37 17
    ## 2007      22      12   63   28   40   33   66 18
    ## 2008      14      22   27   37   37   30   64 11
    ## 2009       8      22  745   13   33   25   60 10
    ## 2010      17      14   44   32   54   70   41 23
    ## 2011      30      16   69   29   36   62   57 10
    ## 2012      17      13   42   22  109   38   47 17
    ## 2013      21       7   37   16   40   45   93 37
    ## 
    ## , , COLPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL    
    ## 2003     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2004     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2005     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2006     NaN     NaN  NaN   83  NaN  NaN  NaN  84
    ## 2007     NaN     NaN  NaN  NaN  NaN  NaN   74  74
    ## 2008     NaN      50  NaN   79  210  NaN   66  75
    ## 2009     NaN     NaN  NaN   58  NaN  NaN  NaN  58
    ## 2010     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2011     NaN     NaN  NaN  NaN  NaN  NaN  NaN NaN
    ## 2012     NaN     NaN  NaN   86  NaN  NaN  NaN  86
    ## 2013      75      82  NaN  126  NaN  NaN  NaN  66
    ## 
    ## , , SBKPEcv
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL   
    ## 2003     NaN     267  Inf   34   53  NaN  134 35
    ## 2004     167      70   98   50  159  NaN   86 25
    ## 2005     NaN     122  NaN   43   53  NaN  NaN 25
    ## 2006      85      77  NaN   41  131  NaN   64 51
    ## 2007      60     276  NaN   67  112  NaN   36 42
    ## 2008     Inf      14  NaN   74   66  NaN   46 14
    ## 2009     102      33  NaN   51   74   84   59 37
    ## 2010     NaN     212  NaN   39   77  Inf   82 51
    ## 2011      89      54  NaN   44   51  Inf  105 26
    ## 2012     NaN      47  NaN   40   38  NaN   63 25
    ## 2013     148      43   60   33   41  NaN   74 22

TAUX DE PRISE ACCIDENTELLE PAR STRATE SPATIALE PAR CATEGORIE

    RATES.median 

    ## , , JAVmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003   13.79   49.90 0.01 551.95 192.33  33.17 152.83 148.29
    ## 2004   16.70   88.65 0.00 465.64  90.62  18.92 123.20 116.50
    ## 2005   43.38   51.22 0.32 683.45 459.67   9.89  76.05 196.98
    ## 2006   32.72  141.70 0.00 555.91 142.69 243.28 237.20 184.59
    ## 2007   31.82   59.75 1.30 576.17 179.80 226.99 186.68 177.14
    ## 2008    8.97  102.79 3.39 555.44 281.64  69.27 181.99 170.72
    ## 2009   14.40  272.13 0.25 663.35 271.65 146.64 123.02 214.39
    ## 2010    9.64   71.96 7.43 836.32 245.36  99.37 174.17 210.55
    ## 2011   10.61  165.19 0.00 485.56 179.61 132.21  86.05 157.31
    ## 2012   11.73   82.07 1.49 387.04 159.63  57.70 139.91 118.51
    ## 2013   22.32  237.46 2.49 514.79 205.84 308.42 132.64 211.59
    ## 
    ## , , RATmedian
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003    7.73   47.55  0.56 408.87  85.18  31.75 248.12 121.64
    ## 2004    4.81   49.55  0.78 509.94  55.89  33.02 223.36 128.46
    ## 2005    5.03   46.51  0.79 440.86  95.42  15.36 129.30 109.84
    ## 2006    5.42   81.63  0.19 492.68  32.00 203.77 190.98 141.10
    ## 2007   11.29   82.40  4.73 214.44  61.48 150.35 214.97 109.86
    ## 2008    6.93  111.54  9.80 424.88  69.07  42.55 286.18 135.63
    ## 2009    6.69  212.82  3.43 595.51  70.11  98.62  87.28 151.97
    ## 2010    2.43   72.20 28.41 730.91 186.75 133.10 825.24 271.07
    ## 2011    7.63  100.22  1.64 401.79 139.65 155.39 206.68 151.45
    ## 2012    9.57   58.37 25.44 372.05  99.73  88.87 502.46 171.72
    ## 2013   13.79  181.77 31.27 517.24 133.78 137.10 418.80 197.68
    ## 
    ## , , SQUmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA   PUYS  NULL      
    ## 2003    7.06   52.69 0.27  4.34 40.12  23.15  5.14 17.12
    ## 2004   12.68   82.37 0.52  9.29  9.03  12.94  2.66 18.84
    ## 2005    6.22   53.87 1.01 10.57 46.83   7.31  5.11 18.94
    ## 2006    2.65   59.08 0.18 11.30 30.82  52.17 17.08 24.70
    ## 2007   19.25   65.58 0.94  4.98 20.05  55.09  7.33 24.82
    ## 2008    8.31   26.72 0.39  7.85 22.92  57.27  2.93 18.29
    ## 2009   15.71    6.50 0.43  3.84 19.60  71.37  1.27 17.66
    ## 2010   15.16   18.40 0.35 12.85 43.07  49.67 12.17 20.56
    ## 2011   10.90   44.59 0.19  7.37 64.74  61.05  3.32 26.89
    ## 2012   16.54   44.02 0.51  5.11 31.00  48.77  1.89 22.24
    ## 2013   11.10   75.29 0.30  4.65 32.65 116.55  7.42 34.64
    ## 
    ## , , ETBmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA  PUYS NULL      
    ## 2003    0.00    0.00 0.00  0.01  4.73  0.00 0.00  0.68
    ## 2004    0.20    1.72 0.02  5.01  2.03  0.78 0.00  1.37
    ## 2005    0.00    0.00 0.00  0.00  6.54  0.00 0.00  0.93
    ## 2006    0.02    0.15 0.00  1.21  1.63  0.00 0.00  0.46
    ## 2007    0.24    0.03 0.00  6.98  1.15  2.30 1.34  1.58
    ## 2008    0.27    0.00 0.36 27.54 28.79  2.41 2.28 10.41
    ## 2009    0.10    0.13 0.00  4.33 31.68  2.93 0.02  6.06
    ## 2010    0.04    0.14 0.00 15.32 65.63  5.58 1.01 12.80
    ## 2011    0.04    0.04 0.00 16.06 12.25  2.43 4.71  5.30
    ## 2012    0.00    0.01 0.10 14.96 30.36  2.61 0.08  7.31
    ## 2013    0.62    4.27 3.90 33.50 28.52 12.21 2.30 11.77
    ## 
    ## , , JMAmedian
    ## 
    ##      WCSI.MW WCSI.BT   CSTR CHAT SUBA PUYS NULL      
    ## 2003    7.36    1.01   1.32 0.11 0.00 0.18 1.41  1.76
    ## 2004   52.80    0.63   0.34 0.01 0.00 1.16 0.10  8.40
    ## 2005    9.09    1.98 202.10 0.16 0.00 0.37 2.02 67.40
    ## 2006   10.88    0.05   0.00 0.10 0.00 0.00 0.01  1.57
    ## 2007    4.58    0.09   0.98 0.09 0.00 0.00 0.12  1.29
    ## 2008    5.11    0.72   1.07 1.20 0.01 0.00 0.28  1.21
    ## 2009    4.25    0.00   0.11 0.00 0.00 0.00 0.05  0.63
    ## 2010    0.23    0.01   2.36 0.14 0.00 0.00 0.05  0.42
    ## 2011    0.53    0.27   0.04 0.02 0.00 0.00 0.00  0.22
    ## 2012    1.62    0.09  26.15 0.24 0.01 0.00 3.95  4.60
    ## 2013   19.68    0.01  21.13 0.07 0.06 0.00 2.82  6.11
    ## 
    ## , , SNDmedian
    ## 
    ##      WCSI.MW WCSI.BT  CSTR  CHAT SUBA   PUYS   NULL      
    ## 2003    0.89    4.86  0.06 20.28 0.81  17.13  39.13 12.86
    ## 2004    0.79    6.72  0.26 36.83 0.14  70.26  27.91 22.03
    ## 2005    0.57    2.56  3.88 36.11 0.73   1.67  19.61 10.08
    ## 2006    1.04   19.12  0.08 56.02 3.23 261.77  57.97 58.02
    ## 2007    2.96   17.32  1.59 21.85 1.65 201.79  58.78 44.33
    ## 2008    1.58   15.56  5.46 84.75 2.96  85.53  59.90 36.49
    ## 2009    0.75   43.42  0.40 57.67 1.19  70.50 110.52 40.80
    ## 2010    0.42    2.69 12.33 31.68 1.16  50.03  80.05 26.37
    ## 2011    0.35   32.95  0.00 45.76 1.20  37.21  67.64 24.96
    ## 2012    0.06    4.43  0.71 19.74 0.90  31.89  18.20 12.29
    ## 2013    0.87   25.92  0.43 43.96 2.55 143.14  21.51 33.17
    ## 
    ## , , LDOmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA  PUYS  NULL      
    ## 2003    9.04   38.52 0.00 70.51 5.72  4.35  7.17 20.03
    ## 2004    4.22   33.18 0.00 53.62 6.88  5.89  5.83 15.57
    ## 2005    1.76   30.90 0.00 60.49 6.80  3.46  6.36 15.74
    ## 2006    5.62   59.98 0.00 41.48 7.32 23.11  8.34 21.48
    ## 2007    3.32   35.58 0.04 61.26 7.48 21.94  6.56 19.85
    ## 2008    6.05   38.09 0.07 24.63 7.81 18.27  5.11 14.49
    ## 2009   15.36   62.46 0.01 39.23 6.10 28.03  3.32 22.40
    ## 2010    5.84   23.98 0.58 38.17 6.01 12.27 16.77 15.19
    ## 2011    8.03   60.54 0.02 36.58 6.94 16.83  5.83 19.17
    ## 2012    3.24   27.32 0.07 43.67 5.42  4.51 17.14 14.44
    ## 2013   15.08   87.81 0.17 59.05 5.60 34.56  5.23 28.62
    ## 
    ## , , SWAmedian
    ## 
    ##      WCSI.MW WCSI.BT   CSTR   CHAT   SUBA   PUYS    NULL       
    ## 2003   72.82  132.50   0.18 163.73  27.97 261.58  258.09 136.03
    ## 2004  101.05  390.33   0.03 476.39 158.85 544.95   87.72 267.50
    ## 2005   30.70  340.18  20.78 169.82  16.37  15.54   31.79  88.29
    ## 2006   43.50  201.36   0.11 338.86 194.20 787.57 1093.94 412.96
    ## 2007   76.60  338.34   6.03 230.04 213.41 558.18  445.68 282.65
    ## 2008   44.26  175.13   6.29 331.91  32.46 148.38  130.20 132.80
    ## 2009  119.25   72.03   0.04 172.41  88.78  98.83   19.64  80.39
    ## 2010   65.66  119.16   2.47 505.95  70.63 110.10   10.11 117.35
    ## 2011   72.62  292.54  22.66 344.94 119.65 112.62   20.94 144.69
    ## 2012   44.85  165.49  61.75 257.48  46.20 129.17  514.66 178.99
    ## 2013   32.54  174.97 108.33 215.70 311.66 490.70  830.98 329.70
    ## 
    ## , , COLmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2004    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2005    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2006    0.00    0.00    0  0.02 0.00    0 0.00 0.00
    ## 2007    0.00    0.00    0  0.00 0.00    0 0.18 0.03
    ## 2008    0.00    0.05    0  6.53 0.03    0 0.29 0.98
    ## 2009    0.00    0.00    0 18.76 0.00    0 0.00 2.68
    ## 2010    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2011    0.00    0.00    0  0.00 0.00    0 0.00 0.00
    ## 2012    0.00    0.00    0  4.37 0.00    0 0.00 0.62
    ## 2013    0.05    4.14    0  0.37 0.00    0 0.00 0.77
    ## 
    ## , , SBKmedian
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.02 0.00 1.00 0.20  0.0 0.22 0.20
    ## 2004    0.00    0.03 0.01 0.88 0.10  0.0 0.40 0.24
    ## 2005    0.00    0.00 0.00 1.99 0.65  0.0 0.00 0.40
    ## 2006    0.09    1.75 0.00 0.73 0.16  0.0 0.15 0.43
    ## 2007    0.01    0.05 0.00 0.89 0.19  0.0 0.13 0.20
    ## 2008    0.00    3.10 0.00 0.83 0.19  0.0 0.12 0.62
    ## 2009    0.03    6.35 0.00 0.38 2.46  0.3 0.16 1.27
    ## 2010    0.00    0.29 0.00 1.66 0.21  0.0 0.83 0.47
    ## 2011    0.06    0.80 0.00 1.59 0.44  0.0 0.03 0.43
    ## 2012    0.00    0.14 0.00 0.37 0.33  0.0 0.06 0.13
    ## 2013    0.01    0.45 0.04 3.36 0.59  0.0 0.26 0.72

    RATES.95hi

    ## , , JAVrates95hi
    ## 
    ##      WCSI.MW WCSI.BT  CSTR    CHAT   SUBA   PUYS   NULL       
    ## 2003   16.57   59.42  0.05  735.49 214.41 166.67 214.27 165.99
    ## 2004   23.06  145.52  0.00  553.91 252.61  33.12 178.37 152.31
    ## 2005   58.35  115.99  1.20  881.95 714.74  13.69 167.34 221.58
    ## 2006   43.22  279.93  0.00  674.10 254.60 321.67 323.60 232.93
    ## 2007   38.75  158.50  3.99  910.69 233.80 266.56 251.07 232.47
    ## 2008   13.06  136.51  9.05  611.85 416.27 123.69 287.09 198.61
    ## 2009   20.10  405.97  0.86  821.49 323.32 293.55 189.50 250.83
    ## 2010   13.84  176.62 10.95 1269.45 438.19 152.30 302.59 256.24
    ## 2011   14.84  405.20  0.00  566.53 213.55 203.64 163.05 176.83
    ## 2012   14.53  131.22  1.76  480.89 211.88  69.98 252.53 141.50
    ## 2013   28.70  298.46  3.92  599.23 245.88 501.82 199.20 229.34
    ## 
    ## , , RATrates95hi
    ## 
    ##      WCSI.MW WCSI.BT  CSTR    CHAT   SUBA   PUYS    NULL       
    ## 2003   11.63   57.61  2.36  543.45 100.46  62.21  345.94 132.49
    ## 2004    7.66   86.85  1.09  805.22 107.25  42.65  267.04 160.63
    ## 2005    7.91   62.59  1.83  891.58 119.52  25.51  231.00 163.88
    ## 2006    8.44  104.18  0.91  582.83  60.92 261.29  239.17 158.58
    ## 2007   28.30  150.13  6.72  240.30  77.07 318.08  318.56 126.91
    ## 2008   10.46  184.28 19.24  666.39  82.14  69.12  351.39 171.38
    ## 2009    8.88  281.84  7.06  968.21  81.89 237.67   97.67 223.93
    ## 2010    3.22   86.02 39.49 1054.95 233.56 287.59 1224.64 327.72
    ## 2011   11.29  161.08  2.53  512.77 235.95 239.77  336.05 172.37
    ## 2012   12.17   90.18 32.42  444.38 169.50 133.08 1011.81 234.14
    ## 2013   16.47  238.82 39.81  589.37 150.86 326.01  525.71 233.09
    ## 
    ## , , SQUrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT   SUBA   PUYS  NULL      
    ## 2003    9.65   71.55 0.34  5.63  96.75  33.57  5.95 26.63
    ## 2004   21.15  116.21 0.94 13.73  14.13  21.77  3.20 23.60
    ## 2005   10.21   70.34 1.44 15.55  58.34   9.00  6.29 22.25
    ## 2006    3.93   70.90 0.26 19.96  38.08  65.00 35.89 28.77
    ## 2007   21.61  107.03 1.04 10.79  42.38  72.56 15.04 33.39
    ## 2008   10.77   36.38 0.80 11.07  50.13  72.97  3.85 22.92
    ## 2009   25.56   10.62 0.69  7.20  26.65  97.57  3.56 21.09
    ## 2010   22.19   26.50 1.08 16.33  50.43  82.08 18.72 25.52
    ## 2011   17.57   60.37 0.35 11.51 101.57  76.21  5.13 35.30
    ## 2012   18.74   64.19 0.78 10.55  44.95  69.11  4.60 23.80
    ## 2013   12.90  108.13 0.41  6.03  67.79 205.49 12.81 49.35
    ## 
    ## , , ETBrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT   SUBA  PUYS NULL      
    ## 2003    0.00    0.00 0.00  0.31   8.83  0.00 2.39  1.26
    ## 2004    0.67    7.03 0.09  8.01   3.83  1.16 0.00  1.97
    ## 2005    0.00    0.00 0.00  0.00  17.34  0.00 0.00  2.48
    ## 2006    0.17    0.75 0.00  3.17  10.58  0.00 0.00  1.87
    ## 2007    1.56    0.21 0.02 17.84   1.90  4.60 3.29  3.48
    ## 2008    1.05    0.00 1.96 62.93  52.58  6.25 4.72 14.94
    ## 2009    0.17    0.31 0.00  7.27  49.89 10.15 0.16  8.31
    ## 2010    0.12    0.28 0.00 29.72 119.81  8.99 3.43 19.21
    ## 2011    0.08    0.14 0.00 32.15  16.44  3.67 9.10  7.12
    ## 2012    0.00    0.07 0.23 26.10  46.28  4.72 0.81  8.74
    ## 2013    1.07    6.00 5.81 58.26  33.95 20.81 7.53 16.60
    ## 
    ## , , JMArates95hi
    ## 
    ##      WCSI.MW WCSI.BT   CSTR  CHAT SUBA  PUYS    NULL       
    ## 2003   21.88    1.65   2.61  0.18 0.00  0.35    2.78   3.75
    ## 2004  182.22    1.42   0.53  0.04 0.02 15.06    0.29  26.45
    ## 2005   15.36   17.40 774.25  0.32 0.00  0.75 2739.78 393.51
    ## 2006   13.08    0.13   0.00  0.24 0.00  0.00    0.07   1.92
    ## 2007    7.63    0.19   1.67 14.93 0.00  0.00    0.32   2.82
    ## 2008   11.45    1.74   1.98  8.59 0.04  0.00    0.43   2.55
    ## 2009  239.85    0.00   0.22  0.00 0.00  0.00    0.11  34.27
    ## 2010    0.77    0.07   3.28  0.33 0.00  0.00    0.17   0.52
    ## 2011    1.97    0.62   0.11  3.75 0.00  0.00    0.00   0.78
    ## 2012    2.67    0.17  47.90  1.58 0.01  0.00    6.65   8.13
    ## 2013   40.56    0.04  51.98  0.20 0.11  0.00    4.71  11.75
    ## 
    ## , , SNDrates95hi
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT SUBA   PUYS   NULL      
    ## 2003    1.60    8.36  0.12  31.46 1.30  46.04  92.50 18.33
    ## 2004    1.75   12.76  0.75  58.72 0.42 252.19  51.87 44.54
    ## 2005    1.33    4.50  5.65  53.48 1.08   1.92  33.00 12.78
    ## 2006    2.64   32.58  0.23  63.39 9.88 325.55 108.63 71.24
    ## 2007    4.46   26.38  2.65  81.06 2.40 273.32  86.09 54.55
    ## 2008    3.36   17.85 10.52 107.53 4.30 157.06  72.33 46.07
    ## 2009    1.51   67.80  0.70  74.69 1.49  97.64 158.07 48.79
    ## 2010    0.82   10.62 17.09  44.91 2.57  87.62 134.87 35.27
    ## 2011    0.75   69.02  0.00  56.76 1.94  53.01 234.67 51.40
    ## 2012    0.13   29.48  2.65  34.75 1.82  40.39  47.00 15.15
    ## 2013    1.27   31.20  0.69  55.27 4.01 289.99  39.55 53.83
    ## 
    ## , , LDOrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR   CHAT  SUBA  PUYS  NULL      
    ## 2003   13.14   53.21 0.04  83.60  7.74 13.19 10.61 21.92
    ## 2004   11.69   38.67 0.00  69.46  9.82 10.06  8.45 18.29
    ## 2005    2.38   43.37 0.00  76.20 10.62  9.75 13.57 17.86
    ## 2006    9.86   72.33 0.11  59.69 14.66 31.12 10.64 23.27
    ## 2007    6.11   89.15 0.19 109.43  9.40 24.33 11.30 28.41
    ## 2008    9.10   44.71 0.10  28.72 15.12 21.91  7.07 16.54
    ## 2009   24.59   66.82 0.02  59.81  7.47 41.75  4.69 27.41
    ## 2010    7.44   36.43 0.88  49.50 11.28 20.08 30.89 17.85
    ## 2011   12.44   70.61 0.11  44.91 12.95 26.01 14.60 21.79
    ## 2012    4.08   51.87 0.11  62.14  6.60  7.66 37.25 17.20
    ## 2013   19.10  102.75 0.30  78.30  8.07 48.20  7.02 33.72
    ## 
    ## , , SWArates95hi
    ## 
    ##      WCSI.MW WCSI.BT   CSTR   CHAT   SUBA    PUYS    NULL       
    ## 2003   93.57  200.85   0.38 277.79  53.80 1107.53  448.45 260.48
    ## 2004  144.12  531.46   0.10 604.50 438.03 1092.68  149.41 331.38
    ## 2005   43.05  376.51  31.66 217.74  43.52   23.86   86.80  95.30
    ## 2006   75.30  261.62   0.28 538.14 370.13 1306.45 1660.28 464.27
    ## 2007  112.86  387.23  12.16 324.44 445.72  862.12 1138.76 389.21
    ## 2008   60.64  273.21  10.20 583.76  67.75  208.75  317.84 149.17
    ## 2009  132.96  103.79   0.98 223.40 127.69  140.76   54.82  98.56
    ## 2010   89.09  161.96   4.88 788.98 136.77  349.70   19.26 175.03
    ## 2011  117.59  335.57  52.51 556.39 195.44  326.59   45.41 175.07
    ## 2012   52.36  216.39 115.94 375.04 144.30  211.41  791.21 210.91
    ## 2013   48.61  198.40 205.91 252.31 439.87  932.44 3220.74 676.86
    ## 
    ## , , COLrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00    0  0.00  0.0    0 0.00 0.00
    ## 2004    0.00    0.00    0  0.00  0.0    0 0.00 0.00
    ## 2005    0.00    0.00    0  0.00  0.0    0 0.00 0.00
    ## 2006    0.00    0.00    0  0.05  0.0    0 0.00 0.01
    ## 2007    0.00    0.00    0  0.00  0.0    0 0.58 0.08
    ## 2008    0.00    0.08    0 18.12  0.2    0 0.72 2.64
    ## 2009    0.00    0.00    0 28.44  0.0    0 0.00 4.06
    ## 2010    0.00    0.00    0  0.00  0.0    0 0.00 0.00
    ## 2011    0.00    0.00    0  0.00  0.0    0 0.00 0.00
    ## 2012    0.00    0.00    0 13.84  0.0    0 0.00 1.98
    ## 2013    0.11   10.37    0  1.33  0.0    0 0.00 1.53
    ## 
    ## , , SBKrates95hi
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.11 0.03 1.35 0.48 0.00 0.92 0.34
    ## 2004    0.02    0.08 0.02 1.77 0.49 0.00 1.41 0.36
    ## 2005    0.00    0.02 0.00 3.70 1.55 0.00 0.00 0.56
    ## 2006    0.23    3.99 0.00 1.30 0.68 0.00 0.39 0.75
    ## 2007    0.02    0.37 0.00 2.42 0.66 0.00 0.22 0.41
    ## 2008    0.00    3.80 0.00 2.30 0.46 0.00 0.26 0.75
    ## 2009    0.09   10.74 0.00 0.58 5.83 0.64 0.34 2.28
    ## 2010    0.00    1.93 0.00 3.36 0.55 0.32 2.68 1.17
    ## 2011    0.16    1.32 0.00 3.32 0.67 0.92 0.08 0.66
    ## 2012    0.00    0.27 0.00 0.79 0.56 0.00 0.16 0.20
    ## 2013    0.05    0.74 0.09 5.31 1.05 0.00 0.78 0.92

    RATES.95lo

    ## , , JAVrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003    6.84   39.86 0.00 404.13 139.85   1.02  99.48 107.16
    ## 2004   12.19   25.79 0.00 398.62  32.10   6.36  82.48  98.11
    ## 2005   29.24   29.81 0.08 448.79 222.47   3.15  12.09 151.73
    ## 2006   17.38   42.19 0.00 352.11  50.57 125.80 119.73 143.47
    ## 2007   18.61   12.70 0.01 379.40 132.69 144.80 153.87 158.97
    ## 2008    8.02   63.55 0.17 416.19 188.66  40.00 131.00 147.85
    ## 2009   10.21  165.46 0.00 549.52 156.25  63.16  25.19 194.37
    ## 2010    6.71   29.38 0.48 613.61  49.00  51.48 107.60 162.01
    ## 2011    5.56   29.14 0.00 427.35 120.00  80.95  26.27 113.31
    ## 2012    7.20   58.83 1.26 286.52 118.86  34.21  89.56 100.10
    ## 2013   16.95  198.96 1.52 397.30  95.42 186.74  63.05 163.54
    ## 
    ## , , RATrates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT   SUBA  PUYS   NULL       
    ## 2003    4.26   38.27  0.01 321.66  71.84  3.77 154.18 105.04
    ## 2004    2.75   39.72  0.67 323.64   9.89 17.06 144.99  98.33
    ## 2005    1.07   28.50  0.02 195.17  64.49  3.88  95.56  73.35
    ## 2006    3.03   39.80  0.00 348.92  21.28 84.06 116.03 103.03
    ## 2007    1.73   31.12  3.15 181.23  43.22 91.39 142.59  95.77
    ## 2008    4.13   91.75  2.31 239.77  46.49 32.41 175.62  87.16
    ## 2009    4.85  162.14  1.79 508.60  50.65 33.82  71.24 140.04
    ## 2010    1.16   42.60 22.69 414.24  54.14 18.62 579.41 253.15
    ## 2011    4.16   66.51  0.16 271.21 109.74 22.26 114.87  96.06
    ## 2012    7.10   38.52 15.31 263.05  59.82 57.95 166.03 115.17
    ## 2013    7.40  114.15 20.98 393.93  89.14 61.98 281.82 169.55
    ## 
    ## , , SQUrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT  SUBA  PUYS NULL      
    ## 2003    4.73   45.39 0.15 2.43 10.09 10.32 1.57 15.09
    ## 2004    6.82   63.33 0.35 6.93  6.17  4.48 1.04 15.55
    ## 2005    5.76   25.38 0.55 6.10 35.50  4.85 1.59 13.64
    ## 2006    2.25   47.21 0.03 5.25 18.87 40.43 3.33 20.87
    ## 2007   14.14   33.65 0.66 3.69 12.89 43.14 2.70 20.89
    ## 2008    7.65   18.66 0.29 5.70 10.10 48.12 2.06 16.56
    ## 2009   10.09    5.18 0.31 2.19 15.69 53.04 0.92 14.41
    ## 2010   10.89    9.04 0.09 8.19 16.01 14.58 4.76 16.86
    ## 2011    3.85   33.32 0.07 5.37 52.30 36.03 1.33 24.72
    ## 2012   13.06   28.02 0.44 1.33 23.74 22.67 0.42 15.20
    ## 2013    8.53   47.83 0.24 3.18 23.68 59.70 6.07 30.34
    ## 
    ## , , ETBrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT  SUBA PUYS NULL     
    ## 2003    0.00    0.00 0.00  0.00  0.00 0.00 0.00 0.00
    ## 2004    0.00    0.00 0.00  3.66  0.00 0.00 0.00 1.03
    ## 2005    0.00    0.00 0.00  0.00  1.55 0.00 0.00 0.22
    ## 2006    0.00    0.00 0.00  0.66  0.41 0.00 0.00 0.22
    ## 2007    0.01    0.00 0.00  1.69  0.67 0.00 0.00 0.73
    ## 2008    0.02    0.00 0.00  5.75 18.68 0.00 0.25 4.19
    ## 2009    0.03    0.07 0.00  3.61 16.08 0.00 0.00 3.42
    ## 2010    0.01    0.00 0.00 10.22  5.79 0.34 0.00 4.08
    ## 2011    0.00    0.00 0.00  5.39 10.97 0.62 2.23 3.67
    ## 2012    0.00    0.00 0.04  9.34 17.00 0.98 0.00 5.35
    ## 2013    0.34    2.67 1.98 20.23 21.68 0.22 0.45 9.85
    ## 
    ## , , JMArates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    1.00    0.26 0.39 0.01 0.00 0.00 0.17 0.65
    ## 2004   20.55    0.21 0.24 0.00 0.00 0.65 0.00 3.31
    ## 2005    4.02    0.00 0.94 0.00 0.00 0.00 0.00 0.72
    ## 2006    7.57    0.00 0.00 0.00 0.00 0.00 0.00 1.13
    ## 2007    3.39    0.00 0.04 0.00 0.00 0.00 0.03 0.74
    ## 2008    1.00    0.00 0.12 0.31 0.00 0.00 0.14 0.50
    ## 2009    0.73    0.00 0.00 0.00 0.00 0.00 0.00 0.13
    ## 2010    0.03    0.00 0.48 0.05 0.00 0.00 0.00 0.15
    ## 2011    0.20    0.00 0.00 0.00 0.00 0.00 0.00 0.04
    ## 2012    1.13    0.02 6.95 0.02 0.00 0.00 2.39 1.98
    ## 2013    0.43    0.00 8.25 0.02 0.02 0.00 1.47 3.86
    ## 
    ## , , SNDrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA   PUYS  NULL      
    ## 2003    0.06    1.16 0.00  9.60 0.57   0.00  8.98  8.45
    ## 2004    0.05    1.55 0.02 28.91 0.00  14.85  8.59 12.00
    ## 2005    0.40    1.88 2.21 25.14 0.22   0.92 11.91  7.39
    ## 2006    0.39    8.48 0.00 45.79 1.24 174.73 35.10 42.82
    ## 2007    1.70    8.07 1.14 10.20 0.76 150.91 39.81 36.92
    ## 2008    0.83   11.35 2.84 72.23 1.54  35.00 47.33 26.82
    ## 2009    0.29   28.54 0.22 27.52 0.90  44.06 68.60 33.73
    ## 2010    0.24    0.46 6.92 22.65 0.70  42.43 25.73 16.49
    ## 2011    0.15    2.56 0.00 37.52 0.55  25.99  0.33 18.95
    ## 2012    0.00    1.69 0.29 10.02 0.22  23.74  1.21  8.74
    ## 2013    0.59   16.18 0.00 30.40 1.73  17.37 11.81 18.20
    ## 
    ## , , LDOrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR  CHAT SUBA  PUYS  NULL      
    ## 2003    3.43   29.77 0.00 34.92 3.55  0.17  4.93 13.27
    ## 2004    1.60   28.37 0.00 44.35 2.59  2.69  3.67 14.28
    ## 2005    1.10   20.28 0.00 34.70 5.90  0.64  1.29 10.57
    ## 2006    2.28   57.01 0.00 23.96 6.22 13.27  2.49 18.59
    ## 2007    1.24   29.62 0.03 26.65 3.47 15.72  3.36 14.63
    ## 2008    3.86   36.10 0.03 20.23 3.18 14.12  3.10 12.60
    ## 2009    6.83   42.84 0.00 19.17 4.19 11.55  1.40 16.09
    ## 2010    2.93   15.01 0.25 28.44 2.17  5.51 11.54 12.17
    ## 2011    3.60   39.91 0.00 28.49 4.61 10.32  1.58 16.38
    ## 2012    2.60   22.01 0.03 35.47 4.62  3.23  4.81 11.68
    ## 2013   12.02   65.07 0.08 42.60 2.59 24.77  1.76 25.88
    ## 
    ## , , SWArates95lo
    ## 
    ##      WCSI.MW WCSI.BT  CSTR   CHAT   SUBA   PUYS   NULL       
    ## 2003   60.43   97.70  0.06  58.74   7.90 137.86  71.60  86.16
    ## 2004   70.74  292.97  0.00 367.11   3.88  18.24  30.18 196.49
    ## 2005   18.67  223.14  4.43 143.60  11.65   7.75  12.82  80.79
    ## 2006   18.60  153.88  0.00 263.47 128.86 368.78 356.58 248.31
    ## 2007   51.52  262.56  0.86 120.90 115.96 219.04  41.07 184.78
    ## 2008   39.73  122.23  4.43 204.32  22.39  65.06  57.19 102.47
    ## 2009   97.65   58.03  0.00 138.12  40.51  59.69   9.60  73.39
    ## 2010   51.65   97.20  0.99 255.51  13.94  70.33   5.31  96.64
    ## 2011   44.23  160.97  6.15 274.40  60.58  49.24  12.23 130.47
    ## 2012   29.20  138.22  9.47 195.02  11.02  34.66  54.40 119.16
    ## 2013   22.63  154.49 61.24 150.57  56.02 102.13 608.66 257.58
    ## 
    ## , , COLrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003       0       0    0 0.00    0    0 0.00 0.00
    ## 2004       0       0    0 0.00    0    0 0.00 0.00
    ## 2005       0       0    0 0.00    0    0 0.00 0.00
    ## 2006       0       0    0 0.00    0    0 0.00 0.00
    ## 2007       0       0    0 0.00    0    0 0.14 0.02
    ## 2008       0       0    0 0.46    0    0 0.00 0.12
    ## 2009       0       0    0 0.00    0    0 0.00 0.00
    ## 2010       0       0    0 0.00    0    0 0.00 0.00
    ## 2011       0       0    0 0.00    0    0 0.00 0.00
    ## 2012       0       0    0 0.00    0    0 0.00 0.00
    ## 2013       0       0    0 0.00    0    0 0.00 0.01
    ## 
    ## , , SBKrates95lo
    ## 
    ##      WCSI.MW WCSI.BT CSTR CHAT SUBA PUYS NULL     
    ## 2003    0.00    0.00 0.00 0.33 0.11    0 0.02 0.14
    ## 2004    0.00    0.01 0.00 0.49 0.00    0 0.03 0.14
    ## 2005    0.00    0.00 0.00 1.08 0.23    0 0.00 0.22
    ## 2006    0.01    0.12 0.00 0.30 0.00    0 0.04 0.08
    ## 2007    0.00    0.00 0.00 0.18 0.06    0 0.09 0.13
    ## 2008    0.00    2.37 0.00 0.20 0.01    0 0.09 0.43
    ## 2009    0.01    4.62 0.00 0.03 0.36    0 0.00 0.91
    ## 2010    0.00    0.00 0.00 0.81 0.01    0 0.00 0.31
    ## 2011    0.00    0.01 0.00 0.70 0.08    0 0.00 0.29
    ## 2012    0.00    0.06 0.00 0.30 0.14    0 0.03 0.10
    ## 2013    0.00    0.21 0.02 1.61 0.25    0 0.05 0.46
