/*Parametros que viene en el .dat*/
param LADO;
param ALTURA;
param NUM_CAJAS;
param P;
param M;

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

param M2 := (LADO-1) * (M-1); # M2 es un valor suficientemente grande para garantizar que la restricción de coste_celda_def se cumpla correctamente.

/*Variables de decision*/
var posicion_caja {k in CAJAS, i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS} binary;

/*Variables auxiliares*/
var coste_celda {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS} >= 0;

/*Variable sobre la existencia de los pallets*/
var existe_pallet {q in PALLETS} binary;

/*F. Obj*/
minimize coste_medio: (sum{i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS} coste_celda[i,j,m,q]) + sum{q in PALLETS} P*existe_pallet[q];

/*Restriciones*/
/*Las cajas se deben disponer de un único plano sobre el pallet (no repeticiones)*/
s.t. No_repeticiones {k in CAJAS}: sum{i in FILAS} sum{j in COLUMNAS} sum{m in ALTURAS} sum{q in PALLETS} posicion_caja[k,i,j,m,q] = 1;

/*Cada caja debe ubicarse por delante, respecto al punto de acceso, de aquellos que tienen menos prioridad que ella*/
s.t. Respetar_prioridades{i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS, q in PALLETS}: sum{k in CAJAS} posicion_caja[k,i+1,j,m,q]*PRIORIDADES[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m,q]*PRIORIDADES[k] + M*(1-sum{k in CAJAS} posicion_caja[k,i,j,m,q]);
/*LADO - 1 para que no de error en la ultima fila*/

/* Restricción para que en cada posición del pallet se coloque como máximo una caja */
s.t. Maximo_una_caja {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS}: sum{k in CAJAS} posicion_caja[k,i,j,m,q] <= 1;

/* En una misma columna,la suma de los pesos de las cajas superiores no puede ser superior al aguante de las cajas inferiores */
s.t. Peso_maximo {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{m_prima in (m+1)..ALTURA} sum{k in CAJAS} posicion_caja[k,i,j,m_prima,q]*PESOS[k] <= sum{k in CAJAS} posicion_caja[k,i,j,m,q]*AGUANTES[k]
;

/* Una vez haya una posición vacía, las posiciones de las filas siguientes también estarán vacías por la prioridad infinita */
s.t. Prioridad_infinito {i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{k in CAJAS} posicion_caja[k,i,j,m,q] <= sum{k in CAJAS} posicion_caja[k,i+1,j,m,q]
;

/*No pueden haber de cajas sobre una posición vacía*/
s.t. Cajas_sobre_vacio {i in FILAS, j in COLUMNAS, m in 1..(ALTURA-1), q in PALLETS}:
    sum{k in CAJAS} posicion_caja[k,i,j,m+1,q] <= sum{k in CAJAS} posicion_caja[k,i,j,m,q]
;

/*Coste de los espacio vacíos es 0*/
s.t. Coste_celda_def {i in 1..(LADO-1), j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{i_prima in (i+1)..LADO} sum{k in CAJAS} posicion_caja[k,i_prima,j,m,q]*PRIORIDADES[k] - M2*(1-sum{k in CAJAS} posicion_caja[k,i,j,m,q]) <= coste_celda[i,j,m,q]
    ;

/*Se usa los pallets en orden */
s.t. Orden_pallets {q in 1..(NUM_CAJAS-1)}:
     existe_pallet[q+1] >= existe_pallet[q];

/* Si hay alguna caja en el pallet q entonces el pallet existe*/
s.t. Pallet_existe_def {i in FILAS, j in COLUMNAS, m in ALTURAS, q in PALLETS}:
    sum{k in CAJAS} posicion_caja[k,i,j,m,q] <= existe_pallet[q];