/*Parametros que viene en el .dat*/
param LADO;
param ALTURA;
param NUM_CAJAS:=LADO^2*ALTURA;


/*SETS*/
set CAJAS:={1..NUM_CAJAS};
set FILAS:={1..LADO};
set COLUMNAS:={1..LADO};
set ALTURAS:={1..ALTURA};

/* Parámetro de prioridad de cada caja k */
param PRIORIDADES {k in CAJAS};
param PESOS {w in CAJAS};
param AGUANTES {y in CAJAS};

/*Variables de decision*/
var posicion_caja {k in CAJAS, i in FILAS, j in COLUMNAS, m in ALTURAS} binary;

/*F. Obj*/
minimize coste_medio: (sum{i in 1..(LADO-1)}sum{j in COLUMNAS}sum{m in ALTURAS}sum{i_prima in (i+1)..LADO}sum{k in CAJAS} posicion_caja[k,i_prima,j,m]*PRIORIDADES[k])/NUM_CAJAS;

/*Restriciones*/
/*Las cajas se deben disponer de un único plano sobre el pallet (no repeticiones)*/
s.t. No_repeticiones {k in CAJAS}: sum{i in FILAS} sum{j in COLUMNAS} sum{m in ALTURAS} posicion_caja[k,i,j,m] = 1;

/*Cada caja debe ubicarse por delante, respecto al punto de acceso, de aquellos que tienen menos prioridad que ella*/
s.t. Respetar_prioridades{i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS}: sum{k in CAJAS} posicion_caja[k,i+1,j,m]*PRIORIDADES[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m]*PRIORIDADES[k];
/*LADO - 1 para que no de error en la ultima fila*/

/*Ahora tenemos la restriccion de donde la segunda fila especifica la prioridad de cada una de las n cajas, con n = l2. Esto es, el pallet se rellena
siempre completamente. (pallet lleno)*/
s.t. Pallet_lleno {i in FILAS, j in COLUMNAS, m in ALTURAS}: sum{k in CAJAS} posicion_caja[k,i,j,m] = 1;


/* En una misma columna,la suma de los pesos de las cajas superiores no puede ser superior al aguante de las cajas inferiores */
s.t. peso_maximo {i in FILAS, j in COLUMNAS, m in ALTURAS}:
    sum{m_prima in (m+1)..(ALTURA)} sum{k in CAJAS} posicion_caja[k,i,j,m_prima]*PESOS[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m]*AGUANTES[k];

