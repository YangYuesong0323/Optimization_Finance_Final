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
    foodreturn(t)
    globalreturn(t)
    japanreturn(t);
    
foodreturn(t)=IndexReturns('food',t);
globalreturn(t)=IndexReturns('GlobalME2_BO1',t);
japanreturn(t)=IndexReturns('JapanME1_BO3',t);

FILE foodreturnHandle /"food.csv"/;

foodreturnHandle.pc = 5;
foodreturnHandle.pw = 1048;

PUT foodreturnHandle;

* Write the heading

PUT "return";

PUT /;

LOOP (t, PUT foodreturn(t), PUT /);

PUTCLOSE;

FILE globalreturnHandle /"GlobalME2_BO1.csv"/;

globalreturnHandle.pc = 5;
globalreturnHandle.pw = 1048;

PUT globalreturnHandle;

* Write the heading

PUT "return";

PUT /;

LOOP (t, PUT globalreturn(t), PUT /);

PUTCLOSE;


FILE japanreturnHandle /"JapanME1_BO3.csv"/;

japanreturnHandle.pc = 5;
japanreturnHandle.pw = 1048;

PUT japanreturnHandle;

* Write the heading

PUT "return";

PUT /;

LOOP (t, PUT japanreturn(t), PUT /);

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

Parameter
foodScen(scen)
globalScen(scen)
japanScen(scen);

foodScen(scen)=RetScen('food', scen);
globalScen(scen)=RetScen('GlobalME2_BO1', scen);
japanScen(scen)=RetScen('JapanME1_BO3', scen);

FILE foodScenhandle /"foodscen.csv"/;

foodScenhandle.pc = 5;
foodScenhandle.pw = 1048;

PUT foodScenhandle;

* Write the heading

PUT "return";

PUT /;

LOOP (scen, PUT foodScen(scen), PUT /);

PUTCLOSE;


FILE globalScenhandle /"globalscen.csv"/;

globalScenhandle.pc = 5;
globalScenhandle.pw = 1048;

PUT globalScenhandle;

PUT "return";

PUT /;

LOOP (scen, PUT globalScen(scen), PUT /);

PUTCLOSE;


FILE japanScenhandle /"japanscen.csv"/;

japanScenhandle.pc = 5;
japanScenhandle.pw = 1048;

PUT japanScenhandle;

* Write the heading

PUT "return";

PUT /;

LOOP (scen, PUT japanScen(scen), PUT /);

PUTCLOSE;

display RetScen;
EXECUTE_UNLOAD 'FixedScenarios.gdx', scen, Asset, RetScen;
