libname myxl xlsx "/home/u64430364/sasuser.v94/returns_and_betas.xlsx";

/* Create a SAS dataset from Excel and add row numbers */
data asset_data;
   set myxl.Sheet1;
   RowNumData = _N_;   /* store row index (used to identify bonds) */
run;

proc optmodel;

   /* Sets */
   set <str> ASSETS;   /* all assets (tickers) */
   set <str> BONDS;    /* subset of assets (bond ETFs) */

   /* Parameters */
   num B = 100000;     /* total budget */
   num K = 15;         /* max number of selected assets */
   num L = 1000;       /* minimum investment if asset is chosen */
   num M = B;          /* big-M for linking constraint */

   num rf = 0.037;     /* risk-free rate (3.7%) */

   /* Asset Data */
   num r{ASSETS};      /* expected return of each asset */
   num beta{ASSETS};   /* beta of each asset */
   num rownum{ASSETS}; /* row number from Excel */

   /* Read Data */
   read data asset_data
        into ASSETS=[Ticker]          /* index assets by ticker */
        r='Expected Return'n          /* expected return column */
        beta=Beta                    /* beta column */
        rownum=RowNumData;           /* row numbers */

   /* Define bonds as rows 21–25 from Excel */
   BONDS = {a in ASSETS: rownum[a] >= 21 and rownum[a] <= 25};

   /* Debug prints */
   print r beta rownum;
   print {a in BONDS} rownum[a];

   /* Decision Variables */
   var x{ASSETS} >= 0;    /* amount invested in each asset */
   var xf >= 0;           /* amount in risk-free asset */
   var y{ASSETS} binary;  /* 1 if asset selected, 0 otherwise */

   /* Portfolio Metrics */
   /* portfolio return (as a percentage of total budget) */
   impvar PortReturn =
      (sum{a in ASSETS} r[a]*x[a] + rf*xf)/B;

   /* portfolio beta (weighted average risk) */
   impvar PortBeta =
      (sum{a in ASSETS} beta[a]*x[a])/B;

   /* Constraints */
  
   /* budget must be fully allocated */
   con Budget:
      sum{a in ASSETS} x[a] + xf = B;

   /* no more than 10% in any one asset */
   con Diversification{a in ASSETS}:
      x[a] <= 0.10*B;

   /* at least 20% in bonds */
   con BondAllocation:
      sum{a in BONDS} x[a] >= 0.20*B;

   /* limit number of assets selected */
   con Cardinality:
      sum{a in ASSETS} y[a] <= K;

   /* linking: if y[a]=0 then x[a]=0 */
   con Linking{a in ASSETS}:
      x[a] <= M*y[a];

   /* minimum investment if selected */
   con MinInvestment{a in ASSETS}:
      x[a] >= L*y[a];

   /* =======================
      Max return Model
   ======================= */
   max MaxReturnObj = PortReturn;
   solve with milp;

   num Rmax; /* maximum achievable return */
   num R0; /* set target return */

   Rmax = PortReturn.sol;   

   print x xf PortReturn PortBeta;

   /* =======================
      Min Beta Model
   ======================= */
   min MinBetaObj = PortBeta;
   solve with milp;

   num Bmin; /* minimum achievable beta */
   num B0; /* set target beta */
    
   Bmin = PortBeta.sol;

   print x xf PortReturn PortBeta;

         /* =======================
      Goal Programming with Multiple Target Scenarios
   ======================= */

   set WPOINTS = 1..9;
   set SCENARIOS = 1..3;

   num wR{WPOINTS};
   num wB{WPOINTS};

   num RetFactor{SCENARIOS};
   num BetaFactor{SCENARIOS};

   /* Scenario target settings */
   RetFactor[1] = 0.85;   BetaFactor[1] = 25; /* Baseline */
   RetFactor[2] = 0.98;   BetaFactor[2] = 25; /* Higher Return Target */
   RetFactor[3] = 0.85;   BetaFactor[3] = 2;  /* Tighter Beta Target */

   num i;
   num s;

   do i = 1 to 9;
      wR[i] = i * 0.1;
      wB[i] = 1 - wR[i];
   end;

   /* Deviation variables */
   var dR_minus >= 0;
   var dR_plus >= 0;
   var dB_minus >= 0;
   var dB_plus >= 0;

   /* Return goal */
   con ReturnGoal:
      PortReturn + dR_minus - dR_plus = R0;

   /* Beta goal */
   con BetaGoal:
      PortBeta + dB_minus - dB_plus = B0;

   num wi_R;
   num wi_B;

   min GoalObj = wi_R*dR_minus + wi_B*dB_plus;

   /* Store solutions */
   num SolReturn{SCENARIOS, WPOINTS};
   num SolBeta{SCENARIOS, WPOINTS};
   num SolRF{SCENARIOS, WPOINTS};
   num SolAssets{SCENARIOS, WPOINTS};
   num SolR0{SCENARIOS, WPOINTS};
   num SolB0{SCENARIOS, WPOINTS};

   do s = 1 to 3;

      /* Set scenario-specific targets */
      R0 = RetFactor[s] * Rmax;
      B0 = BetaFactor[s] * Bmin;

      do i = 1 to 9;

         wi_R = wR[i];
         wi_B = wB[i];

         solve with milp;

         SolReturn[s,i] = PortReturn.sol;
         SolBeta[s,i] = PortBeta.sol;
         SolRF[s,i] = xf.sol;
         SolAssets[s,i] = sum{a in ASSETS} y[a].sol;
         SolR0[s,i] = R0;
         SolB0[s,i] = B0;

      end;
   end;

   create data all_frontiers_raw from
      [Scenario p] = {s in SCENARIOS, p in WPOINTS}
      WeightReturn = wR[p]
      WeightBeta = wB[p]
      PortfolioReturn = SolReturn[Scenario,p]
      PortfolioBeta = SolBeta[Scenario,p]
      RiskFreeInvestment = SolRF[Scenario,p]
      NumberAssets = SolAssets[Scenario,p]
      TargetReturn = SolR0[Scenario,p]
      TargetBeta = SolB0[Scenario,p]
      ReturnTargetFactor = RetFactor[Scenario]
      BetaTargetFactor = BetaFactor[Scenario];

quit;


/* Add readable scenario labels */
data all_frontiers;
   set all_frontiers_raw;
   length ScenarioLabel $30.;

   if Scenario = 1 then ScenarioLabel = "Baseline";
   else if Scenario = 2 then ScenarioLabel = "Higher Return Target";
   else if Scenario = 3 then ScenarioLabel = "Tighter Beta Target";
run;


/* Sort for clean plotting */
proc sort data=all_frontiers;
   by Scenario WeightReturn;
run;


/* Print combined frontier table */
proc print data=all_frontiers label noobs;
   var ScenarioLabel WeightReturn WeightBeta PortfolioBeta PortfolioReturn 
       RiskFreeInvestment NumberAssets TargetReturn TargetBeta;
   label
      ScenarioLabel = "Scenario"
      WeightReturn = "Return Weight"
      WeightBeta = "Beta Weight"
      PortfolioBeta = "Portfolio Beta"
      PortfolioReturn = "Portfolio Return"
      RiskFreeInvestment = "Risk-Free Investment"
      NumberAssets = "Number of Selected Assets"
      TargetReturn = "Target Return"
      TargetBeta = "Target Beta";
   title "Efficient Frontier Points under Different Target Settings";
run;


/* Plot all frontiers on same graph */
proc sgplot data=all_frontiers;
   scatter x=PortfolioBeta y=PortfolioReturn / group=ScenarioLabel markerattrs=(size=9);
   series x=PortfolioBeta y=PortfolioReturn / group=ScenarioLabel lineattrs=(thickness=2);
   xaxis label="Portfolio Beta";
   yaxis label="Portfolio Return";
   keylegend / location=inside position=topright;
   title "Return-Beta Frontiers under Different Target Settings";
run;