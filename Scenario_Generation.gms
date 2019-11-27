$eolcom //
$INCLUDE "WorldIndices.inc"


Alias(Time,t);
set
         scen /s1*s250/
         m    /m1*m3/
;

// outcomment next line, if you want to reseed the random number generator at each new run of the file
*execseed=gmillisec(jnow)

SCALAR randnum;


Parameter RetScenMonths(i,scen,m);
Parameter RetScen(i, scen);


loop(scen,
         loop(m,
                 randnum = uniformint(1,154);
                 RetScenMonths(i, scen,  m) = SUM(t$(ord(t)=randnum), AssetReturns(i, t)) ;
         );
         RetScen(i,scen) = prod(m, (1 + RetScenMonths(i, scen,m ))) - 1;

);

display RetScen;
EXECUTE_UNLOAD 'RetScen250.gdx', scen, Assets, RetScen;
