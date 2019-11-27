$TITLE Value at Risk and Conditional Value at Risk models
* VaR_CVaR.gms: Value at Risk and Conditional Value at Risk models.
$eolcom //
option optcr=0, reslim=120;

$INCLUDE "WorldIndices.inc"



SCALARS
        Budget        'Nominal investment budget'
        alpha         'Confidence level'
        MU_Target     'Target portfolio return'
        MIN_MU        'Minimum return in universe'
        MAX_MU        'Maximum return in universe'
;

Budget = 100.0;
alpha  = 0.99;

PARAMETERS
        pr(l)       'Scenario probability'
        P(i,l)      'Final values'
        EP(i)       'Expected final values'
;

pr(l) = 1.0 / CARD(l);

P(i,l) = 1 + AssetReturns ( i, l );

EP(i) = SUM(l, pr(l) * P(i,l));

MIN_MU = SMIN(i, EP(i));
MAX_MU = SMAX(i, EP(i));
display MIN_MU, MAX_MU, pr;

MU_TARGET = MIN_MU;
MU_TARGET = MAX_MU;
MU_TARGET = (MIN_MU+MAX_MU)/2;

scalar HighestLoss;
HighestLoss = Budget*(smax((i,l), P(i,l) )- smin((i,l), P(i,l)));
display HighestLoss;


//Complete the code from here


