#' Calculate catch rate and amount
#'
#' @param cutoff not sure
#' @param catchcat not sure
#' @param estimator not sure
#' @param do.null not sure
#' @description  FONCTION POUR CALCULER LES VOLUMES ET LES TAUX DE PRISES ACCIDENTELLES EN KG/TRAIT, KG/HR
#'       OU KG/NO.HOOKS. MJ NOTE: SINCE WE ARE USING THE ADJACENT YEARS (TEMPORAL STRATA) APPROACH TO FILL-IN
#'       THE GAPS THE "first.stratum" OPTION OF THE "do.null" FUNCTION COMPONENT IS NO LONGER VALID IN THIS
#'       CODE THE TERMS 'STRATUM' AND 'STRATA' REFER TO SPATIAL SUBDIVISIONS
#' @author Marie-Julie Roux
#' @export
mj_boot.a.cat.bycatch<-function(cutoff=50,catchcat="QMS",estimator="catch.per.tow",do.null="first.year"){

  d1<-julian(Sys.time())                      # time at start of run

  #single output list, DD 20190830
  output= list()

	# -------------------------------------------------------------
	# set up data format based on effort type
	if(estimator=="catch.per.tow")
		{
		obs.df<-obs.all.df[,c("fyear","vessel.key",catchcat,"stratum")]
		}

	if(estimator=="catch.per.duration")
		{
		obs.df<-obs.all.df[,c("fyear","vessel.key",catchcat,"stratum","duration")]
		obs.df<-obs.df[!is.na(obs.df$duration),]
		obs.df<-obs.df[!obs.df$duration==0,]
		}

	if(estimator=="catch.per.hook")
		{
		obs.df<-obs.all.df[,c("fyear","vessel.key",catchcat,"stratum","hooks.number")]
		obs.df<-obs.df[!is.na(obs.df$hooks.number),]
		obs.df<-obs.df[!obs.df$hooks.number==0,]
		}

# ----------------------------------------------------------------
	# set up variables
	lam.est<-function(x){
			df<-temp[x,]
			if(estimator=="catch.per.tow") 	    {return(sum(df[,catchcat])/nrow(df))}
			if(estimator=="catch.per.duration") {return(sum(df[,catchcat])/sum(df[,"duration"]))}
			if(estimator=="catch.per.hook")     {return(sum(df[,catchcat])/sum(df[,"hooks.number"]))}
			}

	strata.code<-levels(obs.df$stratum)
	n.strata<-length(strata.code)     #  number of strata (length(levels(obs.df$stratum))

 	# list of years and number of years (n.yrs)
	yrs<-dimnames(STRAT.eff)[[1]]
	n.yrs<-length(rownames(STRAT.eff))                                 #i.e. the total number of years

 	# create empty matrix for ANNUAL BYCATCH VOLUME ESTIMATES by category (number of years (n.yrs) and  x  5 ("PE(t)","95lo","95hi","var","cv") where PE = point estimate)
	#output$BYCATCH<-matrix(0,n.yrs,4,dimnames=list(dimnames(STRAT.eff)[[1]], c("PE(t)","95lo","95hi","var")))
	output$BYCATCH<-matrix(0,n.yrs,6,dimnames=list(dimnames(STRAT.eff)[[1]], c("RAW.PE(t)","PE(t)","95lo","95hi","var","cv")))

	# create empty array to hold ANNUAL BYCATCH RATES AND BYCATCH VOLUMES BY CATEGORY AND STRATA
	output$RATES<-array(0,c(dim(STRAT.eff)[[1]],dim(STRAT.eff)[[2]],11),dimnames=list(dimnames(STRAT.eff)[[1]]
		,dimnames(STRAT.eff)[[2]],c("mean","stdev","median","rates95lo","rates95hi","PE(s)","PE95lo","PE95hi","PEvar","PEmed","PEcv")))


# ----------------------------------------------------------------
	# CALCULATE OBSERVED BYCATCH RATE (eg KG/TOW) FOR EACH FISHING YEAR-AREA STRATA

	for(j in 1:n.yrs)
	{
		lambda<-matrix(numeric((n.strata+1)*1000),ncol=n.strata+1) # ANNUAL STRATA MATRIX
		rates<-numeric(0)

		for(k in 1:n.strata)
			{
	# SET THRESHOLDS FOR OBSERVER COVERAGE (ANNUAL NO. OF OBSERVED FISHING EVENTS)
		## Where there are insufficient records for each year-area stratum combination (e.g. < 25), use data from adjacent years
		## up to the maximum number of years in the analysis (or whatever the max number of temporal strata your are using)
		## do this until nrow(obs.df)>cutoff
			T0 <-obs.df[obs.df$stratum==strata.code[k] & obs.df$fyear==yrs[j],]
			T1 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-1)):(min(n.yrs,j+1))]),]
			T2 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-2)):(min(n.yrs,j+2))]),]
			T3 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-3)):(min(n.yrs,j+3))]),]
			T4 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-4)):(min(n.yrs,j+4))]),]
			T5 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-5)):(min(n.yrs,j+5))]),]
			T6 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-6)):(min(n.yrs,j+6))]),]
			T7 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-7)):(min(n.yrs,j+7))]),]
			T8 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-8)):(min(n.yrs,j+8))]),]
			T9 <-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-9)):(min(n.yrs,j+9))]),]
			T10<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-10)):(min(n.yrs,j+10))]),]
			T11<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-11)):(min(n.yrs,j+11))]),]
			#T12<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-12)):(min(n.yrs,j+12))]),]
			#T13<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-13)):(min(n.yrs,j+13))]),]
			#T14<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-14)):(min(n.yrs,j+14))]),]
			#T15<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-15)):(min(n.yrs,j+15))]),]
			#T16<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-16)):(min(n.yrs,j+16))]),]
			#T17<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-17)):(min(n.yrs,j+17))]),]
			#T18<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-18)):(min(n.yrs,j+18))]),]
			#T19<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-19)):(min(n.yrs,j+19))]),]
			#T20<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-20)):(min(n.yrs,j+20))]),]
			#T21<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-21)):(min(n.yrs,j+21))]),]
			#T22<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-22)):(min(n.yrs,j+22))]),]
			#T23<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-23)):(min(n.yrs,j+23))]),]
			#T24<-obs.df[obs.df$stratum==strata.code[k] & is.in(obs.df$fyear,yrs[(max(1,j-24)):(min(n.yrs,j+24))]),]

			temp<-if(nrow(T0)>cutoff) T0
			else if(nrow(T1)>cutoff) T1
			else if(nrow(T2)>cutoff) T2
			else if(nrow(T3)>cutoff) T3
			else if(nrow(T4)>cutoff) T4
			else if(nrow(T5)>cutoff) T5
			else if(nrow(T6)>cutoff) T6
			else if(nrow(T7)>cutoff) T7
			else if(nrow(T8)>cutoff) T8
			else if(nrow(T9)>cutoff) T9
			else if(nrow(T10)>cutoff) T10
			else if(nrow(T11)>cutoff) T11
			#else if(nrow(T12)>cutoff) T12
			#else if(nrow(T13)>cutoff) T13
			#else if(nrow(T14)>cutoff) T14
			#else if(nrow(T15)>cutoff) T15
			#else if(nrow(T16)>cutoff) T16
			#else if(nrow(T17)>cutoff) T17
			#else if(nrow(T18)>cutoff) T18
			#else if(nrow(T19)>cutoff) T19
			#else if(nrow(T20)>cutoff) T20
			#else if(nrow(T21)>cutoff) T21
			#else if(nrow(T22)>cutoff) T22
			#else if(nrow(T23)>cutoff) T23
			#else if(nrow(T24)>cutoff) T24

		# ------------------
		# MORE ADJUSTMENTS ARE REQUIRED IF FEWER THAN (CUTOFF) EFFORT WAS OBSERVED WITHIN A STRATUM OVER THE ENTIRE TIME SERIES
		# IN THIS CASE THE BYCATCH RATE IS CALCULATED USING RECORDS FROM ALL AREA STRATA IN A YEAR (temp2)
		# MJ REMOVED OPTION FOR do.null=="first.stratum" (NO LONGER MAKES SENSE WHEN POOLING FROM ADJACENT YEARS)
			temp2<-obs.df[obs.df$fyear==yrs[j],]
			#temp3<-obs.df[obs.df$stratum==strata.code[k],] # THIS ONE NO LONGER NECESSARY
			if(do.null=="first.year")   {temp<-if(nrow(temp) > cutoff) temp else if (nrow(temp2) > cutoff*2) temp2}  # null cell gets value from year
			#if(do.null=="first.stratum"){temp<-if(nrow(temp) > cutoff) temp else if (nrow(temp3) > cutoff*2) temp3 else temp2}  # null cell gets value from stratum
		    #to print problematic areas and samples sizes, if any
		    if(nrow(temp)<cutoff) print(paste("Number of observer records for",yrs[j],"less than cutoff (",nrow(temp),")"))

	# 'temp' IS THE OBSERVER DATAFRAME USED AS INPUT TO RANDOMISATION FUNCTION 'boot.effort.group' AND CORRESPONDS TO
	# OBSERVER BYCATCH DATA FOR A GIVEN YEAR AND SPATIAL STRATA

	# -----------------------------------------------------
	# CALCULATE AND RANDOMISE BYCATCH RATES BY GROUP (e.g., TRIP or VESSEL)
		# FUNCTION IS CURRENTLY SET TO RUN WITH ONLY FEW ITERATIONS (M=10) AND 'VESSEL' AS THE GROUP VARIABLE (with a tolerance threshold of 5%
		# on the effective no. of vessels in each spatial strata
		#(to ensure that variation in bootstrap samples matches sampling variation of observer data)
	if(estimator=="catch.per.tow") 	   {x<-mj_boot.effort.group(M=10,obs=temp,effort=1,group="vessel.key")}                # effort = 1 for catch/tow
	if(estimator=="catch.per.duration"){x<-mj_boot.effort.group(M=1000,obs=temp,effort="duration", group="vessel.key")}      # catch/dur estimator
	if(estimator=="catch.per.hook")    {x<-mj_boot.effort.group(M=1000,obs=temp,effort="hooks.number",group="vessel.key")}   # catch/hook estimator
	print(paste(rownames(STRAT.eff)[j],colnames(STRAT.eff)[k]))     #Print progress

	# ANNUAL MATRIX OF OBSERVED (AND RANDOMISED) BYCATCH RATIOS BY STRATA AND CATEGORY
	lambda[,k]<-sapply(x$samples,lam.est) 		# lam.est is the function to sum bycatch ratios by category across fishing events

	# CALCULATE OBSERVED (NOMINAL) BYCATCH RATES BY YEAR AND AREA STRATUM (BEFORE RANDOMISATION)
		# SUM OF SPECIES CATCH BY YEAR AND SPATIAL STRATA/TOTAL OBSERVED EFFORT BY YEAR AND AREA STRATA
		if(estimator=="catch.per.tow")     {rates<-c(rates,sum(temp[,catchcat])/nrow(temp))}
		if(estimator=="catch.per.duration"){rates<-c(rates,sum(temp[,catchcat])/temp[,"duration"])}
		if(estimator=="catch.per.hook")    {rates<-c(rates,sum(temp[,catchcat])/temp[,"hooks.number"])}
		}
	lambda[,k+1]<-apply(lambda[,c(1:k)],1,mean) #THE 8TH COLUMN IN THE MEAN RATE ACCROSS AREA STRATA


		#----------------------------
		#ADJUSTMENTS IF FEWER THAN (CUTOFF) OR WHERE NO EFFORT WAS OBSERVED WITHIN AN AREA STRATA OVER THE ENTIRE TIME SERIES
			# null cell gets value from year first (ANNUAL VALUE) then stratum
			if(do.null=="first.year")   {
			if(estimator=="catch.per.tow")     {rates<-c(rates,xt<-if(nrow(temp2) > cutoff*2) sum(temp2[,catchcat])/nrow(temp2))}            #else sum(temp3[,catchcat])/nrow(temp3))}
			if(estimator=="catch.per.duration"){rates<-c(rates,xt<-if(nrow(temp2) > cutoff*2) sum(temp2[,catchcat])/temp2[,"duration"])}     #else sum(temp3[,catchcat])/temp3[,"duration"])}
			if(estimator=="catch.per.hook")    {rates<-c(rates,xt<-if(nrow(temp2) > cutoff*2) sum(temp2[,catchcat])/temp2[,"hooks.number"])} #else sum(temp3[,catchcat])/temp3[,"hooks.number"])}
			}
			# THESE NO LONGER NECESSARY
			# null cell gets value from stratum
			#if(do.null=="first.stratum")   {
			#if(estimator=="catch.per.tow")      {rates<-c(rates,xt<-if(nrow(temp3) > cutoff*2) sum(temp3[,catchcat])/nrow(temp3)            else sum(temp2[,catchcat])/nrow(temp2))}
			#if(estimator=="catch.per.duration") {rates<-c(rates,xt<-if(nrow(temp3) > cutoff*2) sum(temp3[,catchcat])/temp3[,"duration"]     else sum(temp2[,catchcat])/temp2[,"duration"])}
			#if(estimator=="catch.per.hook")     {rates<-c(rates,xt<-if(nrow(temp3) > cutoff*2) sum(temp3[,catchcat])/temp3[,"hooks.number"] else sum(temp2[,catchcat])/temp2[,"hooks.number"])}
			#}

	#------------------------
	# ESTIMATE TOTAL BYCATCH VOLUME USING COMMERCIAL (UNOBSERVED) EFFORT
	# MULTIPLY OBS (and randomised) BYCATCH RATES BY TOTAL UNOBSERVED EFFORT IN EACH YEAR-AREA STRATUM (TT2)
	# lambda is the ANNUAL MATRIX OF OBS AND RANDOMISED BYCATCH RATIO BY AREA STRATA
	# TT IS THE EMPIRICAL DISTRIBUTION OF TOTAL BYCATCH (VOLUME) BY CATEGORY obtained by summing bootstrap estimates across all strata within a fishing year
	#TT<-apply(lambda, 1, function(x) sum(x*STRAT.eff[yrs[j],]))
	#TT2<-apply(lambda, 1, function(x) x*STRAT.eff[yrs[j],])         # excl. final col of STRAT.eff
	TT<-apply(lambda, 1, function(x) sum(x*STRAT.eff[yrs[j],]))
	TT2<-apply(lambda, 1, function(x) x*STRAT.eff[yrs[j],])
	CI<-quantile(TT,c(0.025,0.5,0.975))				# 95% CI
	CI2<-apply(TT2,1,function(x) quantile(x,c(0.025,0.5,0.975)))
	VAR2<-apply(TT2,1,function(x) var(x))


	# TOTAL BYCATCH VOLUME WITH PRECISION ESTIMATES
	# PE(t) is the median point estimate
	RAW<-sum(STRAT.eff[yrs[j],]*rates) # THIS IS THE OBSERVED (NON-RANDOMISED) RATIOS
	output$BYCATCH[yrs[j],"RAW.PE(t)"]<-round(RAW/1000)
	output$BYCATCH[yrs[j],"PE(t)"]<-round(CI[2]/1000)
	output$BYCATCH[yrs[j],"95lo"]<-round(CI[1]/1000)
	output$BYCATCH[yrs[j],"95hi"]<-round(CI[3]/1000)
	output$BYCATCH[yrs[j],"var"]<-round(var(TT/1000))
	output$BYCATCH[yrs[j],"cv"]<-round(100*(sqrt(output$BYCATCH[yrs[j],"var"])/output$BYCATCH[yrs[j],"PE(t)"]))

	# BYCATCH VOLUME BY SPATIAL STRATA WITH PRECISION ESTIMATES
	# PE(s) is the spatially-explicit median point estimate
	output$RATES[yrs[j],,"PE(s)"]<-round(CI2[2,]/1000)
	output$RATES[yrs[j],,"PE95lo"]<-round(CI2[1,]/1000)
	output$RATES[yrs[j],,"PE95hi"]<-round(CI2[3,]/1000)
	output$RATES[yrs[j],,"PEvar"]<-round(VAR2)
	output$RATES[yrs[j],,"PEmed"]<-round(CI2[2,])
	output$RATES[yrs[j],,"PEcv"]<-round(100*(sqrt(output$RATES[yrs[j],,"PEvar"])/output$RATES[yrs[j],,"PEmed"]))

	# BYCATCH RATES BY AREA STRATA WITH PRECISION ESTIMATES
	output$RATES[yrs[j],,"mean"]<-round(apply(lambda,2,mean),2)
	output$RATES[yrs[j],,"stdev"]<-round(apply(lambda,2,function(x) sqrt(var(x))),2)
	output$RATES[yrs[j],,"median"]<-round(apply(lambda,2,median),2)
	output$RATES[yrs[j],,"rates95lo"]<-round(apply(lambda,2,function(x) quantile(x,0.025)),2)
	output$RATES[yrs[j],,"rates95hi"]<-round(apply(lambda,2,function(x) quantile(x,0.975)),2)

	}
	d2<-julian(Sys.time())#time at end of run
	print(paste("elapsed time =",round((d2-d1)*1440,1)," m"))
	output
	}


#' Calculate effort exerted in the by-catch fishery
#'
#' @param M number of bootstrapped estimates required
#' @param obs observer data frame (run iteratively for each year and area strata)
#' @param effort either a string giving name of effort variable in obs data frame OR if effort = 1 (default) then each row is a unit of effort  if effort a numerical vector of length = dim(obs)[1] then it is the effort
#' @param group logical for identifying to which (correlated) group belongs each individual fishing event (unit effort value) eg trip or vessel (If NULL no group quantities tracked, every row its own group. ###TBD)
#' @param G.tol level of tolerance in G.ef for accepting boot sample ( default +- 5%)
#' @return a list with components sample, N.ef, G.ef, obs.N.ef, obs.V.ef
#'      samples list of M vectors of row numbers of obs, one for each bootstrap
#'      groups list of M vectors of groups sampled, one vector for each bootstrap
#'      N.ef vector of length M giving the effective sample size (number of effort) for each sample
#'      G.ef vector of length M giving the effective number of groups (vessels) in each sample
#'      obs.G.ef scalar, the effective number of groups (vessels) in the obs df
#'      obs.N.ef scalar the effective number of rows (individual fishing events) in the obs df
#' @description  FONCTION POUR CALCULER LES VOLUMES ET LES TAUX DE PRISES ACCIDENTELLES EN KG/TRAIT, KG/HR
#'       OU KG/NO.HOOKS. MJ NOTE: SINCE WE ARE USING THE ADJACENT YEARS (TEMPORAL STRATA) APPROACH TO FILL-IN
#'       THE GAPS THE "first.stratum" OPTION OF THE "do.null" FUNCTION COMPONENT IS NO LONGER VALID IN THIS
#'       CODE THE TERMS 'STRATUM' AND 'STRATA' REFER TO SPATIAL SUBDIVISIONS
#' @author Marie-Julie Roux
#' @export
mj_boot.effort.group <-function(M, obs, effort = "dur2", group = "vesskey", G.tol = 0.05){

    n.case <- dim(obs)[1]   # total number of obs fishing events
    row.num <- 1:n.case     # numbering rows of obs fishing events

    if (is.numeric(effort)) {
        h <- if (length(effort) == n.case) effort else
            if (length(effort) == 1) rep(effort, n.case) else
                stop("effort a numeric vector of the wrong length")
    } else h <- obs[, effort]    	# h is the effort vector

    g <- factor(obs[, group])
    if (n.case == nlevels(g)) stop("number of vessels = number of rows")
    gp.lvls <- levels(g) 			# g is for groups (e.g. vessels)

    # constants for the obs data
    obs.h <- sum(h) # total effort
    ssh <- sum(h^2) # sum of squared (paired) effort
    obs.N.ef <- obs.h^2/ssh # total observed fishing effort
    obs.G.ef <- obs.h^2/(sum(tapply(h, g, sum)^2) - ssh) # total observed vessels, single and paired effort

    # rownums by group (list of observed fishing events for each vessel)
    gp.row.list <- tapply(row.num, g, function(x) x)
    # effort by group (list of individual effort quantity for each observed fishing event for each vessel)
    gp.eff.list <- tapply(h, g, function(x) x)

    # function to calculate the effective sample size for each group
    calc.N.ef <- function(h) {
        sum(h)^2/sum(h^2)
    }


    # set up output quantities
    sss <- list(NULL) #samples
    groups <- list(NULL)
    N.ef <- G.ef <- numeric(0)

    # run M sims
    for (m in 1:M) {
        G.rat <- 0
        while (G.rat < 1 - G.tol | G.rat > 1 + G.tol) {

             # setup initial values for running sums for the mth sample
             N.s <- h.s <- ssh <- ssg <- 0
             h.try <- ssh.try <- ssg.try <- 0

             s.s <- s.try <- numeric(0)

             while (N.s < obs.N.ef) {     # one run through for each group chosen
                 s.s <- c(s.s, s.try)
                 h.s <- h.s + h.try
                 ssh <- ssh + ssh.try
                 ssg <- ssg + ssg.try

                 # sample group then rows
                 gp.try <- sample(gp.lvls, 1)        # sample a group (vessel)
                 rr <- gp.row.list[[gp.try]]		 # bycatch data for that group
                 s.try <- sample(rr, length(rr), replace = TRUE)     # sample rows (fishing event) within a group

                 # next increments
                 temp <- h[s.try]                # efforts of sample
                 h.try <- sum(temp)
                 ssh.try <- sum(temp^2)
                 ssg.try <- h.try^2 - ssh.try

                 N.o <- N.s
                 N.s <- (h.s + h.try)^2/(ssh + ssh.try)
             }
             # tidy last sample component
             if (runif(1) < (obs.N.ef - N.o)/(N.s - N.o)) {
                 s.s <- c(s.s, s.try)
                 h.s <- h.s + h.try
                 ssh <- ssh + ssh.try
                 ssg <- ssg + ssg.try
             } else N.s <- N.o
             G.ef.try <- h.s^2/ssg
             G.rat <- ifelse(ssg <= 0, 0, G.ef.try/obs.G.ef)
#             G.rat <- G.ef.try/obs.G.ef
        }
        sss[[m]] <- s.s
        N.ef <- c(N.ef, N.s)
        G.ef <- c(G.ef, G.ef.try)
    }
#    return(list("samples" = sss, "groups" = groups, "N.ef" = N.ef, "G.ef" = G.ef,
#        "obs.N.ef" = obs.N.ef, "obs.G.ef" = obs.G.ef))
    return(list("samples" = sss, "obs.N.ef" = obs.N.ef, "obs.G.ef" = obs.G.ef))
}


#' find matches in values between two vectors
#'
#' @param x vector 1
#' @param y vector 2
#' @description find matches in values between two vectors
#' @author Marie-Julie Roux
#' @export
is.in<-function (x, y) {!is.na(match(x, y))}
