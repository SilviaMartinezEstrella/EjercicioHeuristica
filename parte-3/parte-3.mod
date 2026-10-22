/*Parametros que viene en el .dat*/
param LADO;
param ALTURA;
param NUM_CAJAS;
param M;

/*SETS*/
set CAJAS:={1..NUM_CAJAS};
set FILAS:={1..LADO};
set COLUMNAS:={1..LADO};
set ALTURAS:={1..ALTURA};

/* Parámetro de prioridad de cada caja k */
param PRIORIDADES {k in CAJAS};
param PESOS {w in CAJAS};
param AGUANTES {y in CAJAS};

param M2 := (LADO-1) * (M-1); # M2 es un valor suficientemente grande para garantizar que la restricción de coste_celda_def se cumpla correctamente.

/*Variables de decision*/
var posicion_caja {k in CAJAS, i in FILAS, j in COLUMNAS, m in ALTURAS} binary;

/*Variables auxiliares*/
var coste_celda {i in FILAS, j in COLUMNAS, m in ALTURAS} >= 0;

/*F. Obj*/
minimize coste_medio: (sum{i in FILAS, j in COLUMNAS, m in ALTURAS} coste_celda[i,j,m]) / NUM_CAJAS;

/*Restriciones*/
/*Las cajas se deben disponer de un único plano sobre el pallet (no repeticiones)*/
s.t. No_repeticiones {k in CAJAS}: sum{i in FILAS} sum{j in COLUMNAS} sum{m in ALTURAS} posicion_caja[k,i,j,m] = 1;

/*Cada caja debe ubicarse por delante, respecto al punto de acceso, de aquellos que tienen menos prioridad que ella*/
s.t. Respetar_prioridades{i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS}: sum{k in CAJAS} posicion_caja[k,i+1,j,m]*PRIORIDADES[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m]*PRIORIDADES[k] + M*(1-sum{k in CAJAS} posicion_caja[k,i,j,m]);
/*LADO - 1 para que no de error en la ultima fila*/

/* Restricción para que en cada posición del pallet se coloque como máximo una caja */
s.t. Maximo_una_caja {i in FILAS, j in COLUMNAS, m in ALTURAS}: sum{k in CAJAS} posicion_caja[k,i,j,m] <= 1;

/* En una misma columna,la suma de los pesos de las cajas superiores no puede ser superior al aguante de las cajas inferiores */
s.t. Peso_maximo {i in FILAS, j in COLUMNAS, m in ALTURAS}:
    sum{m_prima in (m+1)..ALTURA} sum{k in CAJAS} posicion_caja[k,i,j,m_prima]*PESOS[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m]*AGUANTES[k]
;

/* Una vez haya una posición vacía, las posiciones de las filas siguientes también estarán vacías con prioridad infinita */
s.t. Prioridad_infinito {i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS}:
    sum{k in CAJAS} posicion_caja[k,i,j,m] <= sum{k in CAJAS} posicion_caja[k,i+1,j,m]
;

/*No pueden colocarse cajas sobre una posición vacía */
s.t. Cajas_sobre_vacio {i in FILAS, j in COLUMNAS, m in 1..(ALTURA-1)}:
    sum{k in CAJAS} posicion_caja[k,i,j,m+1] <= sum{k in CAJAS} posicion_caja[k,i,j,m]
;

/** Este es el coste que tiene cada celda, siendo el coste el sumatorio de las prioridades de las cajas en las filas anteriores. Con M2 nos aseguramos de que la restricción se cumpla para aquellas celdas que no tienen cajas */
s.t. Coste_celda_def {i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS}:
    sum{i_prima in (i+1)..LADO} sum{k in CAJAS} posicion_caja[k,i_prima,j,m]*PRIORIDADES[k] - M2*(1-sum{k in CAJAS} posicion_caja[k,i,j,m]) <= coste_celda[i,j,m]
    ;