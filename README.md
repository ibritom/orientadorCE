# orientadorCE

Taller de Prolog, CE-1106

Integrantes:
Iván Ignacio Brito Medina
Henry Perez Sequeira
Daniel Jose Espinoza Vega
Raymond Janfreed Araya Elizondo

## Descripción

OrientadorCE es un sistema de orientación vocacional desarrollado en Prolog para el curso **Paradigmas de Programación (CE-1106)**.

El programa busca identificar intereses expresados por el usuario y relacionarlos con diferentes profesiones almacenadas en una base de conocimientos.

El proyecto se divide principalmente en tres módulos:

- `BD.pl`: base de conocimientos.
- `BNF.pl`: gramática e interpretación de las respuestas.
- `Logic.pl`: lógica de recomendación e interacción con el usuario.

---

# Base de conocimientos

## Archivo `BD.pl`

El archivo `BD.pl` contiene la información utilizada por OrientadorCE para relacionar los intereses del usuario con diferentes profesiones.

La información se representa mediante hechos y listas de Prolog.

Este archivo contiene únicamente la base de conocimientos y algunos predicados auxiliares para verificar su consistencia. La lógica utilizada para seleccionar una profesión se mantiene separada en `Logic.pl`.

---

## Intereses

Los intereses reconocidos por el sistema se representan mediante hechos con la forma:

```prolog
interes(Interes).
```

Actualmente se utilizan los siguientes intereses:

```prolog
interes(matematicas).
interes(tecnologia).
interes(resolver_problemas).
interes(ciencia).
interes(ayudar_personas).
interes(escuchar).
interes(hablar).
interes(creatividad).
interes(naturaleza).
interes(liderazgo).
interes(escribir).
interes(trabajo_manual).
interes(salud).
interes(ensenar).
interes(negocios).
interes(trabajo_equipo).
```

Los identificadores internos se escriben como átomos en minúscula, sin espacios ni tildes.

---

## Etiquetas de los intereses

Para mostrar los intereses de una forma más natural al usuario se utiliza:

```prolog
etiqueta_interes(Interes, Texto).
```

Por ejemplo:

```prolog
etiqueta_interes(matematicas, 'las matemáticas').
etiqueta_interes(tecnologia, 'la tecnología').
etiqueta_interes(resolver_problemas, 'resolver problemas').
```

Esto permite separar el identificador utilizado internamente por Prolog del texto que se muestra al usuario.

---

## Preguntas

Cada interés posee una pregunta asociada.

La estructura utilizada es:

```prolog
pregunta(Interes, Pregunta).
```

Ejemplos:

```prolog
pregunta(matematicas, '¿Te gustan las matemáticas?').
pregunta(tecnologia, '¿Te gusta la tecnología?').
pregunta(resolver_problemas, '¿Te gusta resolver problemas?').
```

También se mantiene una lista con el orden en que pueden realizarse las preguntas:

```prolog
orden_preguntas([
    matematicas,
    tecnologia,
    resolver_problemas,
    ciencia,
    ayudar_personas,
    escuchar,
    hablar,
    creatividad,
    naturaleza,
    liderazgo,
    escribir,
    trabajo_manual,
    salud,
    ensenar,
    negocios,
    trabajo_equipo
]).
```

---

## Profesiones

Las profesiones disponibles se representan mediante:

```prolog
profesion(Profesion).
```

La base incluye actualmente las siguientes profesiones:

```prolog
profesion(ingenieria_en_computadores).
profesion(medicina).
profesion(psicologia).
profesion(administracion_de_empresas).
profesion(arquitectura).
profesion(educacion).
profesion(derecho).
profesion(biologia).
profesion(diseno_grafico).
profesion(enfermeria).
profesion(ingenieria_civil).
profesion(estadistica).
```

Cada profesión posee además un nombre legible para mostrar al usuario:

```prolog
nombre_profesion(ingenieria_en_computadores,
                 'Ingeniería en Computadores').

nombre_profesion(medicina, 'Medicina').

nombre_profesion(psicologia, 'Psicología').
```

---

## Afinidades

Las afinidades representan intereses o fortalezas que favorecen una determinada profesión.

Se utiliza la estructura:

```prolog
afinidades(Profesion, ListaDeIntereses).
```

Por ejemplo:

```prolog
afinidades(
    ingenieria_en_computadores,
    [tecnologia, matematicas, resolver_problemas, ciencia]
).
```

Esto indica que los siguientes intereses favorecen la recomendación de Ingeniería en Computadores:

- tecnología;
- matemáticas;
- resolución de problemas;
- ciencia.

Otro ejemplo:

```prolog
afinidades(
    medicina,
    [ciencia, ayudar_personas, salud, resolver_problemas]
).
```

Si el usuario expresa de manera positiva intereses contenidos en estas listas, el motor de recomendación puede utilizarlos como coincidencias a favor de una profesión.

---

## Incompatibilidades

Cada profesión también posee una lista de intereses considerados esenciales.

La estructura utilizada es:

```prolog
incompatibles(Profesion, ListaDeIntereses).
```

Por ejemplo:

```prolog
incompatibles(
    ingenieria_en_computadores,
    [tecnologia, resolver_problemas]
).
```

Si el usuario rechaza alguno de estos intereses, la profesión puede ser descartada por el motor de recomendación.

Otro ejemplo:

```prolog
incompatibles(
    medicina,
    [ayudar_personas, salud]
).
```

En este caso, una respuesta negativa hacia `ayudar_personas` o `salud` representa una incompatibilidad importante con Medicina.

---

## Mínimo de coincidencias

La base establece un número mínimo de afinidades positivas necesarias para que una profesión pueda considerarse como recomendación.

```prolog
minimo_coincidencias(2).
```

Por lo tanto, una única coincidencia no es suficiente para recomendar una profesión.

---

## Predicados auxiliares

La base incluye algunos predicados que simplifican las consultas desde `Logic.pl`.

### Consultar una afinidad

```prolog
afinidad(P, I) :-
    afinidades(P, L),
    member(I, L).
```

Ejemplo:

```prolog
?- afinidad(ingenieria_en_computadores, tecnologia).
```

Resultado:

```prolog
true.
```

### Consultar una incompatibilidad

```prolog
incompatible_si_rechaza(P, I) :-
    incompatibles(P, L),
    member(I, L).
```

Ejemplo:

```prolog
?- incompatible_si_rechaza(medicina, salud).
```

Resultado:

```prolog
true.
```

---

## Verificación de la base

El predicado:

```prolog
verificar_bd.
```

permite comprobar que la base de conocimientos sea consistente.

Entre otras cosas, verifica que:

- existan al menos diez profesiones;
- cada profesión tenga un nombre;
- cada profesión tenga afinidades;
- cada profesión tenga incompatibilidades;
- los intereses utilizados sean válidos;
- las listas no contengan elementos repetidos;
- las incompatibilidades pertenezcan también a las afinidades de la profesión;
- todos los intereses tengan una pregunta y una etiqueta.

Para probar la base:

```prolog
?- ['BD.pl'].
?- verificar_bd.
```

Si la información es válida, se muestra un mensaje indicando que la base es correcta.

---

# Gramática e interpretación

## Archivo `BNF.pl`

El archivo `BNF.pl` se encarga de interpretar las respuestas escritas por el usuario.

El objetivo es convertir una frase en una representación que pueda ser utilizada posteriormente por `Logic.pl`.

Las preferencias se representan mediante:

```prolog
pref(Interes, Polaridad)
```

donde la polaridad puede ser:

```prolog
pos
```

para una preferencia positiva, o:

```prolog
neg
```

para una preferencia negativa.

Por ejemplo:

```prolog
pref(tecnologia, pos).
```

indica que el usuario expresó una preferencia positiva hacia la tecnología.

Mientras que:

```prolog
pref(matematicas, neg).
```

indica rechazo hacia las matemáticas.

---

## Gramática BNF

La estructura general de las frases reconocidas se define mediante la siguiente gramática:

```text
<frase> ::= <frase_positiva>
          | <frase_negativa>

<frase_positiva> ::= <inicio_positivo> <interes>

<frase_negativa> ::= <inicio_negativo> <interes>

<inicio_positivo> ::= "me gusta"
                    | "me gustan"
                    | "me interesa"
                    | "me interesan"
                    | "disfruto"
                    | "prefiero"
                    | "me atrae"
                    | "me atraen"

<inicio_negativo> ::= "no me gusta"
                    | "no me gustan"
                    | "no me interesa"
                    | "no me interesan"
                    | "no disfruto"
                    | "no prefiero"
                    | "no me atrae"
                    | "no me atraen"

<interes> ::= <matematicas>
            | <tecnologia>
            | <resolver_problemas>
            | <ciencia>
            | <ayudar_personas>
            | <escuchar>
            | <hablar>
            | <creatividad>
            | <naturaleza>
            | <liderazgo>
            | <escribir>
            | <trabajo_manual>
            | <salud>
            | <ensenar>
            | <negocios>
            | <trabajo_equipo>
```

---

## Implementación con DCG

La gramática se implementa utilizando **DCG (Definite Clause Grammars)**.

Las reglas principales son:

```prolog
frase(pref(Interes, pos)) -->
    inicio_positivo,
    interes_frase(Interes),
    { interes(Interes) }.

frase(pref(Interes, neg)) -->
    inicio_negativo,
    interes_frase(Interes),
    { interes(Interes) }.
```

La primera regla reconoce frases afirmativas y la segunda reconoce frases negativas.

Ejemplos de inicios positivos:

```prolog
inicio_positivo --> [me, gusta].
inicio_positivo --> [me, gustan].
inicio_positivo --> [me, interesa].
inicio_positivo --> [prefiero].
```

Ejemplos negativos:

```prolog
inicio_negativo --> [no, me, gusta].
inicio_negativo --> [no, me, gustan].
inicio_negativo --> [no, me, interesa].
inicio_negativo --> [no, prefiero].
```

---

## Identificación de intereses

Cada expresión escrita por el usuario se relaciona con uno de los identificadores utilizados en `BD.pl`.

Por ejemplo:

```prolog
interes_frase(tecnologia) -->
    [la, tecnologia].

interes_frase(resolver_problemas) -->
    [resolver, problemas].

interes_frase(ayudar_personas) -->
    [ayudar, a, las, personas].

interes_frase(trabajo_equipo) -->
    [trabajar, en, equipo].
```

De esta manera:

```text
"me gusta la tecnologia"
```

puede convertirse en:

```prolog
pref(tecnologia, pos).
```

---

## Normalización de la entrada

Antes de analizar la frase se normaliza el texto.

La normalización permite:

- convertir el texto a minúscula;
- eliminar signos básicos de puntuación;
- dividir la frase en palabras.

Por ejemplo:

```text
"Me gusta la tecnologia."
```

se convierte en:

```prolog
[me, gusta, la, tecnologia]
```

Esta lista puede ser procesada posteriormente por las reglas DCG.

---

## Frases afirmativas

Ejemplos válidos:

```text
Me gustan las matematicas
Me gusta la tecnologia
Me interesa la ciencia
Disfruto escribir
Prefiero trabajar en equipo
Me atrae la creatividad
```

Ejemplo:

```prolog
?- interpretar_frase("Me gusta la tecnologia", R).
```

Resultado:

```prolog
R = pref(tecnologia, pos).
```

---

## Frases negativas

Ejemplos válidos:

```text
No me gustan las matematicas
No me gusta la tecnologia
No me interesa la salud
No disfruto hablar en publico
No prefiero trabajar en equipo
```

Ejemplo:

```prolog
?- interpretar_frase("No me interesa la salud", R).
```

Resultado:

```prolog
R = pref(salud, neg).
```

---

## Respuestas cortas

El intérprete también puede procesar respuestas como:

```text
si
```

o:

```text
no
```

cuando el sistema ya conoce el interés sobre el cual está preguntando.

Por ejemplo:

```prolog
?- interpretar_respuesta("si", tecnologia, R).
```

Resultado:

```prolog
R = pref(tecnologia, pos).
```

Para una respuesta negativa:

```prolog
?- interpretar_respuesta("no", salud, R).
```

Resultado:

```prolog
R = pref(salud, neg).
```

---

## Frases no reconocidas

Cuando una frase no coincide con ninguna regla de la gramática se retorna:

```prolog
no_reconocida
```

Por ejemplo:

```prolog
?- interpretar_frase("Quiero ser millonario", R).
```

Resultado:

```prolog
R = no_reconocida.
```

Una frase no reconocida no debe registrarse como una preferencia.

Esto permite que el programa solicite al usuario reformular su respuesta.

---

## Pruebas de la gramática

Los casos de prueba se encuentran en:

```text
Pruebas_BNF.pl
```

Para ejecutarlos:

```prolog
?- ['Pruebas_BNF.pl'].
?- ejecutar_pruebas.
```

Algunos casos considerados son:

| Entrada | Resultado esperado |
|---|---|
| `Me gustan las matematicas` | `pref(matematicas,pos)` |
| `No me gusta la tecnologia` | `pref(tecnologia,neg)` |
| `Me interesa ayudar a las personas` | `pref(ayudar_personas,pos)` |
| `No disfruto hablar en publico` | `pref(hablar,neg)` |
| `Prefiero trabajar en equipo` | `pref(trabajo_equipo,pos)` |
| `Me gusta resolver problemas` | `pref(resolver_problemas,pos)` |
| `Quiero ser millonario` | `no_reconocida` |
| `Los perros son bonitos` | `no_reconocida` |

---

# Integración

El flujo general de información entre los módulos es:

```text
Usuario
   |
   v
BNF.pl
   |
   | pref(Interes, Polaridad)
   v
Logic.pl
   |
   | consulta
   v
BD.pl
   |
   v
Recomendación
```

`BNF.pl` interpreta la entrada del usuario.

`BD.pl` contiene los conocimientos sobre intereses y profesiones.

`Logic.pl` utiliza ambas partes para determinar qué profesiones coinciden con las preferencias ingresadas.

---

# Estructura del proyecto

```text
orientadorCE/
│
├── BD.pl                  # Base de conocimientos
├── BNF.pl                 # Gramática (DCG) e interpretación de frases
├── Logic.pl               # Motor de recomendación + conversación en consola
├── Pruebas_BNF.pl         # Pruebas unitarias de la gramática
├── Pruebas_Integracion.pl # Pruebas de la conversación completa
├── ejecutar_pruebas.sh    # Ejecuta TODAS las pruebas con un solo comando
├── .gitignore
└── README.md
```

---

# Ejecución

Para cargar la base de conocimientos:

```prolog
?- ['BD.pl'].
```

Para comprobarla:

```prolog
?- verificar_bd.
```

Para cargar la gramática:

```prolog
?- ['BNF.pl'].
```

Ejemplo de interpretación:

```prolog
?- interpretar_frase("Me gusta la tecnologia", R).
```

Resultado:

```prolog
R = pref(tecnologia, pos).
```

Para ejecutar las pruebas de la gramática:

```prolog
?- ['Pruebas_BNF.pl'].
?- ejecutar_pruebas.
```

---

# Conversación en consola e integración

## Cómo ejecutar el programa

```
$ swipl Logic.pl
?- iniciar.
```

`Logic.pl` carga `BD.pl` y `BNF.pl` automáticamente. También puede usarse
`?- orientadorCE.` (alias de `iniciar`). Para salir en cualquier momento se
escribe `salir`.

## Flujo de la conversación

1. El sistema saluda y hace una pregunta abierta (`¿Qué te gusta?`).
2. La respuesta se interpreta con `interpretar_frase/2` de `BNF.pl`.
3. Se continúan haciendo las preguntas de `orden_preguntas/1` (`BD.pl`),
   saltando los intereses que el usuario ya mencionó, hasta reunir
   `num_preferencias/1` preferencias (3 por defecto).
4. Se aplica el motor de recomendación y se muestra el resultado.

Si una frase no se reconoce, el programa **no registra nada**, pide reformular y
vuelve a leer. Las respuestas sueltas "sí"/"no" tampoco se aceptan: el sistema
exige frases completas. Si el usuario cambia de opinión sobre un interés, la
última respuesta reemplaza a la anterior.

## Criterio de recomendación

1. Una profesión se **descarta** si el usuario rechazó algún interés de su
   lista `incompatibles/2`.
2. Las no descartadas se puntúan con el número de intereses **afirmados** que
   están en sus `afinidades/2`.
3. Es **candidata** si su puntaje es al menos `minimo_coincidencias/1` (2).
4. Se recomiendan las candidatas de **mayor puntaje** (varias si hay empate);
   si no hay ninguna, se informa que no hay coincidencias.

## Ejemplo de sesión

```
OrientadorCE: Hola. Estoy aquí para ayudarte a explorar opciones profesionales. ¿Qué te gusta?
Usuario: Me gusta la ciencia
OrientadorCE: ¿Te gustan las matemáticas?
Usuario: Quiero ser millonario
OrientadorCE: No logré entender tu respuesta. ¿Puedes reformularla?
              (Ejemplos: "Me gusta la tecnología", "No me gusta la tecnología")
Usuario: No me gusta ayudar a las personas
OrientadorCE: ¿Te gusta la tecnología?
Usuario: Me gusta resolver problemas
OrientadorCE: Según tus preferencias, te recomiendo cualquiera de estas opciones:
              - Ingeniería en Computadores (coincide con resolver problemas y la ciencia)
              - Biología (coincide con la ciencia y resolver problemas)
              - Estadística (coincide con la ciencia y resolver problemas)
              Descarté Medicina porque indicaste que no te gusta ayudar a las personas.
```

---

# Pruebas

Todas las pruebas se ejecutan con un solo comando:

```
$ ./ejecutar_pruebas.sh
```

Termina con código 0 si todo pasa y 1 si algo falla. Ejecuta, en orden:

1. `verificar_bd` (consistencia de `BD.pl`);
2. `Pruebas_BNF.pl` (12 pruebas de la gramática);
3. `Pruebas_Integracion.pl` (conversación completa).

`Pruebas_Integracion.pl` simula la consola con respuestas predefinidas, captura
lo que imprime el programa y revisa tanto el texto como las preferencias que
quedaron registradas. También se puede ejecutar por separado:

```
$ swipl -g ejecutar_pruebas_integracion -t halt Pruebas_Integracion.pl
```

| Caso | Entradas del usuario | Qué verifica |
| ---- | -------------------- | ------------ |
| 1 | tecnología, matemáticas, resolver problemas (todas positivas) | Una única recomendación: Ingeniería en Computadores, con su justificación |
| 2 | ciencia (+), resolver problemas (+), ayudar a las personas (−) | Medicina queda **descartada** y se explica por qué |
| 3 | resolver problemas, ciencia, escribir (+) | **Empate**: se listan varias profesiones |
| 4 | naturaleza (+), matemáticas (−), tecnología (−) | **Sin coincidencias** suficientes |
| 5 | "Quiero ser millonario", "Los perros son bonitos", "asdfgh qwerty" y luego 3 frases válidas | Las frases desconocidas **no se registran**; se pide reformular; quedan exactamente 3 preferencias |

Casos adicionales: respuestas "sí"/"no" sueltas, `salir`, fin de entrada (EOF),
cambio de opinión, y normalización de mayúsculas, tildes y puntuación. Además se
prueba directamente que `interpretar_respuesta/2` rechaza frases vacías,
incompletas o sin interés reconocible.

## Nota sobre tildes y configuración regional

`Logic.pl` fuerza UTF-8 en la consola, de modo que escribir tildes y "ñ" funciona
en cualquier sistema. Sin embargo, `string_lower/2` de SWI-Prolog depende de la
configuración regional: en un sistema Linux **sin** locale UTF-8, una vocal
acentuada en MAYÚSCULA ("TECNOLOGÍA") no se convierte a minúscula. Por eso
`ejecutar_pruebas.sh` fija `LC_ALL=C.UTF-8` cuando hace falta.

---

# Resultados de los cinco casos de prueba (esperado vs. obtenido)

Resultados obtenidos con SWI-Prolog 9.0.4 ejecutando la conversación real
(`./ejecutar_pruebas.sh`). Las respuestas del usuario se indican entre comillas.

| Caso | Respuestas del usuario | Resultado esperado | Resultado obtenido | Estado |
| ---- | ---------------------- | ------------------ | ------------------ | ------ |
| 1 | "Me gusta la tecnología", "Me gustan las matemáticas", "Me gusta resolver problemas" | Una sola recomendación: Ingeniería en Computadores | `te recomiendo Ingeniería en Computadores (Coincide con tu interés en la tecnología, las matemáticas y resolver problemas.)` | Pasa |
| 2 | "Me gusta la ciencia", "Me gusta resolver problemas", "No me gusta ayudar a las personas" | Medicina descartada y explicada; no aparece entre las recomendaciones | Recomienda Ingeniería en Computadores, Biología y Estadística, y agrega `Descarté Medicina porque indicaste que no te gusta ayudar a las personas.` | Pasa |
| 3 | "Me gusta resolver problemas", "Me gusta la ciencia", "Me gusta escribir" | Empate: varias profesiones con el mismo puntaje máximo | `cualquiera de estas opciones:` Biología y Estadística (3 coincidencias cada una) | Pasa |
| 4 | "Me gusta la naturaleza", "No me gustan las matemáticas", "No me gusta la tecnología" | Ninguna profesión alcanza el mínimo de 2 coincidencias | `Lo siento, con esas preferencias no dispongo de una recomendación compatible.` | Pasa |
| 5 | "Quiero ser millonario", "Los perros son bonitos", "asdfgh qwerty" y luego 3 frases válidas | Las 3 frases desconocidas no se registran; se pide reformular cada vez; al final quedan exactamente 3 preferencias | Tres veces `No logré entender tu respuesta. ¿Puedes reformularla?`; luego recomienda Ingeniería en Computadores; preferencias registradas: `tecnologia-pos, matematicas-pos, resolver_problemas-pos` | Pasa |

---

# Limitaciones conocidas

- **Gramática rígida:** solo se reconoce una preferencia por frase y con los
  verbos de la BNF. Frases como "Me gusta la tecnología y las matemáticas",
  "Amo la ciencia" o "Odio escribir" se consideran no reconocidas.
- **Variantes limitadas por interés:** cada interés admite solo las
  expresiones listadas en `BNF.pl` (por ejemplo, `escribir` solo se reconoce
  como "escribir").
- **Respuestas "sí"/"no" sueltas:** `BNF.pl` las interpreta, pero `Logic.pl`
  las rechaza a propósito para exigir frases completas.
- **Si el usuario no se explica, la conversación no avanza:** el programa insiste
  hasta entender la respuesta; la única salida es escribir `salir`.
- **Recomendación simple:** el puntaje cuenta coincidencias sin ponderarlas, y
  solo se consideran 12 profesiones y 16 intereses. Se recopilan 3 preferencias
  (`num_preferencias/1`), por lo que la recomendación puede cambiar si se
  pregunta por más.
- **Mayúsculas con tildes y configuración regional:** en sistemas sin locale
  UTF-8, una vocal acentuada en mayúscula ("TECNOLOGÍA") no se normaliza (ver
  nota en la sección *Pruebas*).
- **Entornos probados:** solo SWI-Prolog 9.0.4 en Linux; no se probó en Windows
  ni macOS.

---

# Aportes de cada integrante

Según el historial de commits del repositorio (completar o corregir si el
reparto real fue distinto):

| Integrante | Aporte |
| ---------- | ------ |
| Iván Brito (`ibritom`) | Base de conocimientos `BD.pl` (intereses, preguntas, profesiones, afinidades, incompatibilidades, `verificar_bd`) . Creó el repositorio. |
| Raymond Araya (`Raymond0124`) | Pruebas de la gramática (`BNF.pl`) y gramática DCG e interpretación en `BNF.pl`. Hizo la primera versión del README. |
| Henry Perez (`Henry-05`) | Motor de recomendación y presentación del resultado(`Logic.pl`). |
| Daniel Espinoza (`Daniel-Espinoza-2121`) | Flujo de conversación en consola, integrar todo, verificación de frases desconocidas, casos de prueba. (`Logic.pl`) |

---
