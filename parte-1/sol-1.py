import os
import sys

archivo_entrada = sys.argv[1]
archivo_salida = sys.argv[2]

ruta = os.path.join(os.path.dirname(__file__), archivo_entrada)

with open(ruta, "r", encoding="utf-8") as f:
    cont = f.read()
    lineas =cont.split("\n")
    
print(lineas)
Lado = lineas[0]
Prioridades = lineas[1].split()

print(Lado)
print(Prioridades)

with open(archivo_salida, "w", encoding="utf-8") as f:
    f.write("data;\n\n")

    f.write("param LADO := " + " ".join(Lado) + ";\n\n")

    f.write("param PRIORIDADES := "  + "\n")
    k = 1
    for i in Prioridades:
        if k == len(Prioridades):
            f.write(str(k) + "\t\t" + str(i)  + ";\n")
        else:
            f.write(str(k) + "\t\t" + str(i)  + "\n")
            k = k+1

    