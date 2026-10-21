/*Parametros que viene en el .dat*/
param LADO;
param NUM_CAJAS;
param ALTURA;
param P;

/*SETS*/
set CAJAS:={1..NUM_CAJAS};
set FILAS:={1..LADO};
set COLUMNAS:={1..LADO};
set ALTURAS:={1..ALTURA};
set PALLETS:={1..NUM_CAJAS};

/* Parámetro de prioridad de cada caja k */
param PRIORIDADES {k in CAJAS};
param PESOS {w in CAJAS};
param AGUANTES {y in CAJAS};

/*Variables de decision*/
var posicion_caja {k in CAJAS, i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS} binary;

/* Variable sobre la existencia de los pallets */
var existe_pallet {q in PALLETS};

/*F. Obj*/
minimize coste: (sum{i in FILAS}sum{j in COLUMNAS}sum{i_prima in (i+1)..LADO}sum{k in CAJAS}sum{m in ALTURAS}sum{q in PALLETS} posicion_caja[k,i_prima,j,m, q]*PRIORIDADES[k]) + sum{q in PALLETS} P*existe_pallet[q];

/*Restriciones*/
/*Las cajas se deben disponer de un único plano sobre el pallet (no repeticiones)*/
s.t. No_repeticiones {k in CAJAS}:sum{q in PALLETS} sum{i in FILAS} sum{j in COLUMNAS} sum{m in ALTURAS} posicion_caja[k,i,j,m, q] = 1;

/*Cada caja debe ubicarse por delante, respecto al punto de acceso, de aquellos que tienen menos prioridad que ella*/
s.t. Respetar_prioridades{i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS, q in PALLETS}: sum{k in CAJAS} posicion_caja[k,i,j,m, q]*PRIORIDADES[k]<=sum{k in CAJAS} posicion_caja[k,i+1,j,m,q]*PRIORIDADES[k];
/*LADO - 1 para que no de error en la ultima fila*/


/* En una misma columna,la suma de los pesos de las cajas superiores no puede ser superior al aguante de las cajas inferiores */
s.t. peso_maximo {i in FILAS, j in COLUMNAS, k in CAJAS, m in ALTURAS, q in PALLETS}:
    sum{m_prima in (m+1)..ALTURA} sum{k in CAJAS} posicion_caja[k,i,j,m_prima, q] <= AGUANTES[k]
;


/* No ùeden disponerse de cajas sobre una posición vacía, las posiciones vacías tienen un aguante igual a 0, pero si puede haber otras posiciones vacías sobre ellas */
s.t. cajas_sobre_vacio {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{m_prima in (m+1)..ALTURA : sum{k in CAJAS}  posicion_caja[k,i,j,m, q] == 0 }sum{k in CAJAS} posicion_caja[k,i,j,m_prima, q] == 0
;


s.t. prioridad_infinito {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{i_prima in (i+1)..LADO : sum{k in CAJAS}  posicion_caja[k,i,j,m, q] == 0 }sum{k in CAJAS} posicion_caja[k,i_prima,j,m, q] == 0
;