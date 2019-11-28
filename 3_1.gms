$TITLE Value at Risk and Conditional Value at Risk models
* VaR_CVaR.gms: Value at Risk and Conditional Value at Risk models.
$eolcom //
option optcr=0, reslim=120;

SET
         scen
         Asset
;
ALIAS(Asset,i);
ALIAS(scen, s);

PARAMETER
         RetScen(i, s)
;

$GDXIN FixedScenarios
$LOAD Asset, scen, RetScen
$GDXIN



SCALARS
        Budget        'Nominal investment budget'
        alpha         'Confidence level'
        Lambda        'Risk aversion parameter'
        CVaRLim       'CVaR limit'
        ExpRetLim     'Expected Return Limit'
;

Budget = 100000;
alpha  = 0.95;
CVaRLim = Budget*10;
ExpRetLim = -100000;

PARAMETERS
        pr(s)       'Scenario probability'
        P(i,s)      'Final values'
        EP(i)       'Expected final values'
;

pr(s) = 1.0 / CARD(s);


P(i,s) = 1 + RetScen( i, s );


EP(i) = SUM(s, pr(s) * P(i,s));


POSITIVE VARIABLES
         x(i)            'Holdings of assets in monetary units (not proportions)'
         VaRDev(s)       'Measures of the deviation from the VaR'
         x_0(i)          'Holdings for the flat cost regime'
         x_1(i)          'Holdings for the linear cost regime'
;
VARIABLES
         losses(s)       'The scenario loss function'
         VaR             'The alpha Value-at-Risk'
         CVaR            'The alpha Conditional Value-at-Risk'
         ExpectedReturn  'Expected return of the portfolio'
         obj             'objective function value'
;

BINARY VARIABLE
    Y(i)          'Indicator variable for assets included in the portfolio';

PARAMETER
    xlow(i)    'lower bound for active variables' ;

// In case short sales are allowed these bounds must be set properly.
xlow(i) = 0.0;
x.up(i) = 1.0;

SCALARS
  NominalFlatCost 'fixed transaction cost'  /20/
  OwnInvestment   'Investors own money'     /100000/
;

SCALARS
  FlatCost 'Normalized fixed transaction cost' / 0.0002 /
  PropCost 'Normalized proportional transaction cost' / 0.001 /;

x_0.UP(i) = 0.2;

EQUATIONS
         BudgetCon       'Equation defining the budget constraint'
         ReturnCon       'Equation defining the portfolio expected return'
         LossDefCon(s)   'Equation defining the losses'
         VaRDevCon(s)    'Equation defining the VaRDev variable'
         CVaRDefCon      'Equation defining the CVaR'
         ObjectivFunc    'lambda formulation of the MeanCVaR model'
         CVaRLimCon      'Constraint limiting the CVaR'
         ReturnLimCon    'Constraint on a minimum expected return'
         HoldingCon(i)   'Constraint defining the holdings'
         FlatCostBounds(i)    'Upper bounds for flat transaction fee'
         LinCostBounds(i)     'Upper bonds for linear transaction fee'
;



EQUATIONS
    ReturnDefWithCost    'Equation defining the portfolio return with cost'

;


ReturnDefWithCost..       PortReturn =e= SUM(i, ( ExpectedReturns(i)*x_0(i) - FlatCost*Y(i) ) ) +
                          SUM(i, (ExpectedReturns(i) - PropCost)*x_1(i));


MODEL MeanVarWithCost /ReturnDefWithCost, VarDef, HoldingCon, NormalCon, FlatCostBounds, LinCostBounds, ObjDef/;

*--Objective------

*--s.t.-----------
BudgetCon ..             sum(i, x(i)) =E= Budget;

ReturnCon ..             ExpectedReturn =E= sum(i, EP(i)*x(i));

LossDefCon(s) ..         Losses(s) =E= -1*sum(i, P(i, s)*x(i) );

VaRDevCon(s) ..          VaRDev(s) =G= Losses(s) - VaR;

CVaRDefCon ..            CVaR =E= VaR + (sum(s, pr(s)*VarDev(s) ) )/(1 - alpha);

ObjectivFunc ..          Obj =E= (1-lambda)*ExpectedReturn - lambda*CVaR;

CVaRLimCon ..            CVaR =L= CVaRLim;

ReturnLimCon ..          ExpectedReturn =G= ExpRetLim;

HoldingCon(i)..           x(i) =e= x_0(i) + x_1(i);

FlatCostBounds(i)..       x_0(i) =l= x_0.up(i) * Y(i);

LinCostBounds(i)..        x_1(i) =l= Y(i);



*--Models-----------

//Let's build an equal weight portfolio first,
//by fixing the X values to be eqaully weighted:
X.fx(i) = Budget/card(i);
display X.l;


MODEL CVaRModel 'The Conditional Value-at-Risk Model' /BudgetCon, ReturnCon, LossDefCon, VaRDevCon,CVaRDefCon, ObjectivFunc, CVaRLimCon, ReturnLimCon/;



*------------CVaR----------------------
//We need both terms in the objective function to be under control in order for the model to calculate mean return and CVaR values correctly:
lambda = 0.999;
SOLVE CVaRModel Maximizing OBJ Using LP;


DISPLAY X.l, ExpectedReturn.l, VaR.L, CVaR.L;


Parameters
    MuTarget,
    CVaRTarget,
    BestCase,
    WorstCase
;

//Now we use the expected return and the CVaR of the equal weight strategy as target benchmarks in the CVaR model
MuTarget = ExpectedReturn.l;
CVaRTarget = CVaR.L;
display MuTarget, CVaRTarget;

//The next two lines are used to free the X variable again
X.lo(i) = 0;
X.up(i) = Budget*10;


//Let's minimize CVaR with the target return from the equal weight portfolio
ExpRetLim = Mutarget;
display ExpRetLim;

Lambda = 1;
CVaRLim = CVaRLim;
SOLVE CVaRModel Maximizing OBJ Using LP;
display X.l, ExpectedReturn.l, CVaR.l;


//Let's maximize expected return with the target CVaR from the equal weight portfolio
CVaRLim = CVaRtarget;

Lambda = 0;
ExpRetLim = -100;
SOLVE CVaRModel Maximizing OBJ Using LP;
display X.l, ExpectedReturn.l, CVaR.l;



















