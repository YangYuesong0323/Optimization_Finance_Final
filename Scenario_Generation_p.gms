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


Parameter
    foodreturn(t);
    
foodreturn(t)=IndexReturns('food',t);

FILE foodreturnHandle /"food.csv"/;

foodreturnHandle.pc = 5;
foodreturnHandle.pw = 1048;

PUT foodreturnHandle;

* Write the heading

PUT "return";

PUT /;

LOOP (t, PUT foodreturn(t), PUT /);

PUTCLOSE;


set
         scen /s1*s250/
         w    /w1*w4/
;

// outcomment next line, if you want to reseed the random number generator at each new run of the file
*execseed=gmillisec(jnow)

SCALAR randnum;

Parameter RetScenWeeks(i, scen, w);
Parameter RetScen(i, scen);


loop(scen,
         loop(w,
                 randnum = uniformint(1,335);
                 RetScenWeeks(i, scen,  w) = SUM(t$(ord(t)=randnum), IndexReturns(i, t)) ;
         );
         RetScen(i,scen) = prod(w, (1 + RetScenWeeks(i, scen, w ))) - 1;

);

Parameter foodScen(scen);
foodScen(scen)=RetScen('food', scen);

display foodScen;

FILE foodScenhandle /"foodscen.csv"/;

foodScenhandle.pc = 5;
foodScenhandle.pw = 1048;

PUT foodScenhandle;

* Write the heading

PUT "return";

PUT /;

LOOP (scen, PUT foodScen(scen), PUT /);


PUTCLOSE;

display RetScen;
// EXECUTE_UNLOAD 'FixedScenarios.gdx', scen, Assets, RetScen;
