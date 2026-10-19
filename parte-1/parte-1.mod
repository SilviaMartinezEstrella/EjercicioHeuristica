/*Parametros que viene en el .dat*/
param LADO;
param NUM_CAJAS:=LADO^2;

/*SETS*/
set CAJAS:={1..NUM_CAJAS};
set FILAS:={1..LADO};
set COLUMNAS:={1..LADO};

/* Parámetro de prioridad de cada caja k */
param PRIORIDADES {k in CAJAS};

/*Variables de decision*/
var posicion_caja {k in CAJAS, i in FILAS, j in COLUMNAS} binary;

/*F. Obj*/
minimize coste_medio: (sum{i in FILAS}sum{j in COLUMNAS}sum{i_prima in (i+1)..LADO}sum{k in CAJAS}posicion_caja[k,i_prima,j]*PRIORIDADES[k])/NUM_CAJAS;

/*Restriciones*/
/*Las cajas se deben disponer de un único plano sobre el pallet (no repeticiones)*/
s.t. No_repeticiones {k in CAJAS}: sum{i in FILAS} sum{j in COLUMNAS} posicion_caja[k,i,j] = 1;

/*Cada caja debe ubicarse por delante, respecto al punto de acceso, de aquellos que tienen menos prioridad que ella*/
s.t. Respetar_prioridades{i in 1..(LADO-1), j in COLUMNAS}: sum{k in CAJAS} posicion_caja[k,i,j]*PRIORIDADES[k]<=sum{k in CAJAS} posicion_caja[k,i+1,j]*PRIORIDADES[k];
/*LADO - 1 para que no de error en la ultima fila*/

/*Ahora tenemos la restriccion de donde la segunda fila especifica la prioridad de cada una de las n cajas, con n = l2. Esto es, el pallet se rellena
siempre completamente. (pallet lleno)*/
s.t. Pallet_lleno {i in FILAS, j in COLUMNAS}: sum{k in CAJAS} posicion_caja[k,i,j] = 1;

