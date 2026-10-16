#!/usr/bin/env bash
# Ejecuta TODAS las pruebas del proyecto. Código de salida 0 = todo correcto.
# Uso:  ./ejecutar_pruebas.sh
cd "$(dirname "$0")" || exit 1

# string_lower/2 de SWI-Prolog depende de la configuración regional: sin UTF-8,
# "TECNOLOGÍA" no se pasa a minúsculas. Se fuerza una configuración UTF-8.
case "${LC_ALL:-${LANG:-}}" in
  *UTF-8*|*utf8*|*UTF8*) ;;
  *) export LC_ALL=C.UTF-8 ;;
esac
fallo=0

echo "##### 1/3  Verificación de la base de conocimientos (BD.pl) #####"
swipl -q -g "verificar_bd" -t halt BD.pl || fallo=1

echo; echo "##### 2/3  Pruebas de la gramática (BNF.pl) #####"
salida=$(swipl -q -g ejecutar_pruebas -t halt Pruebas_BNF.pl 2>&1)
echo "$salida"
echo "$salida" | grep -q "ERROR" && fallo=1

echo; echo "##### 3/3  Pruebas de integración (Logic.pl + BNF.pl + BD.pl) #####"
swipl -q -g ejecutar_pruebas_integracion -t halt Pruebas_Integracion.pl || fallo=1

echo
[ $fallo -eq 0 ] && echo "RESULTADO FINAL: TODO CORRECTO" || echo "RESULTADO FINAL: HAY FALLAS"
exit $fallo
