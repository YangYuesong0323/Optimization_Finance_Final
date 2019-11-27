$eolcom //

Sets
    Asset
    Date
;
    
Alias(Asset, i);
Alias(Date, t);

Parameter
    IndexReturns(i,t);
    

$GDXIN Data
$LOAD Asset Date IndexReturns
$GDXIN


set
         scen /s1*s250/
         w    /w1*w4/
         period(t) /3-1-2005, 31-1-2005/
;

// outcomment next line, if you want to reseed the random number generator at each new run of the file
*execseed=gmillisec(jnow)

SCALAR randnum, counter;
counter = -4;

Parameter RetScenWeeks(i, scen, w);
Parameter RetScen(period, i, scen);

loop(period,
        counter=counter + 4;
        loop(scen,
             loop(w,
                     randnum = uniformint(1+counter, 335+counter);
                     RetScenWeeks(i, scen,  w) = SUM(t$(ord(t)=randnum), IndexReturns(i, t)) ;
             );
             RetScen(period, i,scen) = prod(w, (1 + RetScenWeeks(i, scen, w ))) - 1;
        )
);

display RetScen;
EXECUTE_UNLOAD 'RollingScenarios.gdx', scen, Asset, RetScen;
