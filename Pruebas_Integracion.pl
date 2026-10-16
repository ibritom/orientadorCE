:- encoding(utf8).
%% ==========================================================================
%% Pruebas_Integracion.pl -- Pruebas del programa integrado OrientadorCE
%% Paradigmas de Programación (CE1106)
%%
%% Ejecuta la conversación COMPLETA (Logic.pl + BNF.pl + BD.pl) alimentando
%% la entrada de la consola con respuestas simuladas, captura lo que el
%% programa imprime y verifica tanto el texto como las preferencias que
%% quedaron registradas.
%%
%% CÓMO EJECUTAR (desde la carpeta del proyecto):
%%     $ swipl -g ejecutar_pruebas_integracion -t halt Pruebas_Integracion.pl
%% o bien, con el script incluido:
%%     $ ./ejecutar_pruebas.sh
%%
%% El proceso termina con código 0 si todo pasa y 1 si algo falla.
%% ==========================================================================

:- ensure_loaded('Logic.pl').

:- dynamic resultado_caso/2.

%% --------------------------------------------------------------------------
%% Mecanismo: simular la consola
%% --------------------------------------------------------------------------

%% correr_conversacion(+Entradas, -Salida)
%%   Entradas: lista de líneas que "escribe" el usuario.
%%   Salida:   todo el texto que imprimió el programa (string).
correr_conversacion(Entradas, Salida) :-
    atomic_list_concat(Entradas, '\n', Cuerpo),
    atom_concat(Cuerpo, '\n', Texto),
    stream_property(Original, alias(user_input)),
    open_string(Texto, Simulada),
    setup_call_cleanup(
        set_stream(Simulada, alias(user_input)),
        with_output_to(string(Salida), iniciar),
        ( set_stream(Original, alias(user_input)),
          close(Simulada) )).

%% prefs_registradas(-Lista): preferencias guardadas, ordenadas.
prefs_registradas(Lista) :-
    findall(I-P, preferencia(I, P), L),
    sort(L, Lista).

%% --------------------------------------------------------------------------
%% Verificaciones (cada una se evalúa sobre Salida y el estado final)
%% --------------------------------------------------------------------------

verificar(contiene(Sub), Salida, _) :-
    sub_string(Salida, _, _, _, Sub).
verificar(no_contiene(Sub), Salida, _) :-
    \+ sub_string(Salida, _, _, _, Sub).
verificar(prefs(Esperadas), _, Prefs) :-
    msort(Esperadas, Ord),
    Prefs == Ord.
verificar(total_prefs(N), _, Prefs) :-
    length(Prefs, N).
verificar(sin_pref(I), _, Prefs) :-          % I = interés (átomo)
    \+ memberchk(I-_, Prefs).

%% --------------------------------------------------------------------------
%% Ejecución de un caso
%% --------------------------------------------------------------------------

%% caso(+Id, +Descripcion, +Entradas, +Verificaciones)

ejecutar_caso(Id) :-
    caso(Id, Desc, Entradas, Verifs),
    format("~n=== ~w: ~w ===~n", [Id, Desc]),
    correr_conversacion(Entradas, Salida),
    prefs_registradas(Prefs),
    findall(V,
            (   member(V, Verifs),
                (   verificar(V, Salida, Prefs)
                ->  format("  [OK]    ~w~n", [V]), fail
                ;   format("  [FALLA] ~w~n", [V])
                )
            ),
            Fallidas),
    (   Fallidas == []
    ->  assertz(resultado_caso(Id, ok)),
        format("  => ~w: PASA~n", [Id])
    ;   assertz(resultado_caso(Id, falla)),
        format("  Preferencias registradas: ~w~n", [Prefs]),
        format("  --- Salida del programa ---~n~w~n  ---------------------------~n",
               [Salida])
    ).

%% --------------------------------------------------------------------------
%% LOS CINCO CASOS DE PRUEBA PRINCIPALES
%% --------------------------------------------------------------------------

%% Caso 1: preferencias positivas → una única recomendación con justificación.
caso(caso1, 'Recomendación única (Ingeniería en Computadores)',
     [ "Me gusta la tecnología",
       "Me gustan las matemáticas",
       "Me gusta resolver problemas" ],
     [ contiene("Ingeniería en Computadores"),
       contiene("la tecnología, las matemáticas y resolver problemas"),
       no_contiene("Descarté"),
       prefs([tecnologia-pos, matematicas-pos, resolver_problemas-pos]) ]).

%% Caso 2: una preferencia negativa DESCARTA una profesión que de otro modo
%% sería candidata (Medicina tendría ciencia + resolver problemas).
caso(caso2, 'Una preferencia negativa descarta una profesión',
     [ "Me gusta la ciencia",
       "Me gusta resolver problemas",
       "No me gusta ayudar a las personas" ],
     [ contiene("Descarté Medicina"),
       contiene("ayudar a las personas"),
       no_contiene("recomiendo Medicina"),
       no_contiene("- Medicina"),
       prefs([ciencia-pos, resolver_problemas-pos, ayudar_personas-neg]) ]).

%% Caso 3: empate → se muestran varias profesiones con el mismo puntaje máximo.
caso(caso3, 'Empate: varias recomendaciones',
     [ "Me gusta resolver problemas",
       "Me gusta la ciencia",
       "Me gusta escribir" ],
     [ contiene("cualquiera de estas opciones"),
       contiene("Biología"),
       contiene("Estadística"),
       prefs([resolver_problemas-pos, ciencia-pos, escribir-pos]) ]).

%% Caso 4: ninguna profesión alcanza el mínimo de coincidencias.
caso(caso4, 'Sin coincidencias suficientes',
     [ "Me gusta la naturaleza",
       "No me gustan las matemáticas",
       "No me gusta la tecnología" ],
     [ contiene("no dispongo de una recomendación"),
       no_contiene("te recomiendo"),
       prefs([naturaleza-pos, matematicas-neg, tecnologia-neg]) ]).

%% Caso 5: frases desconocidas NO se registran; el programa pide reformular
%% y la conversación continúa con normalidad.
caso(caso5, 'Frases desconocidas no se registran como preferencias',
     [ "Quiero ser millonario",
       "Los perros son bonitos",
       "asdfgh qwerty",
       "Me gusta la tecnología",
       "Me gustan las matemáticas",
       "Me gusta resolver problemas" ],
     [ contiene("No logré entender tu respuesta"),
       contiene("Ingeniería en Computadores"),
       total_prefs(3),
       sin_pref(millonario),
       sin_pref(perros),
       prefs([tecnologia-pos, matematicas-pos, resolver_problemas-pos]) ]).

%% --------------------------------------------------------------------------
%% CASOS ADICIONALES (robustez)
%% --------------------------------------------------------------------------

%% Extra A: "sí"/"no" sueltos NO se aceptan (el enunciado exige frases).
caso(extraA, 'Respuestas "sí"/"no" sueltas no se registran',
     [ "sí",
       "no",
       "Me gusta la tecnología",
       "Me gustan las matemáticas",
       "Me gusta resolver problemas" ],
     [ contiene("No logré entender tu respuesta"),
       total_prefs(3),
       prefs([tecnologia-pos, matematicas-pos, resolver_problemas-pos]) ]).

%% Extra B: escribir "salir" termina la conversación sin recomendar.
caso(extraB, 'El usuario escribe "salir"',
     [ "Me gusta la tecnología",
       "salir" ],
     [ contiene("Conversación finalizada"),
       no_contiene("te recomiendo"),
       prefs([tecnologia-pos]) ]).

%% Extra C: fin de entrada (EOF) también termina limpiamente.
caso(extraC, 'Fin de entrada (EOF) sin colgarse',
     [ ],
     [ contiene("Conversación finalizada"),
       total_prefs(0) ]).

%% Extra D: cambiar de opinión sobre el mismo interés reemplaza la preferencia.
caso(extraD, 'Cambio de opinión: la última respuesta prevalece',
     [ "Me gusta la tecnología",
       "No me gusta la tecnología",
       "Me gustan las matemáticas",
       "Me gusta la ciencia",
       "Me gusta resolver problemas" ],
     [ prefs([tecnologia-neg, matematicas-pos, ciencia-pos]),
       total_prefs(3) ]).

%% Extra E: tildes, mayúsculas y puntuación se normalizan.
caso(extraE, 'Mayúsculas, tildes y puntuación',
     [ "ME GUSTA LA TECNOLOGÍA!!!",
       "  me   gustan las matemáticas.  ",
       "Me gusta resolver problemas?" ],
     [ contiene("Ingeniería en Computadores"),
       prefs([tecnologia-pos, matematicas-pos, resolver_problemas-pos]) ]).

%% --------------------------------------------------------------------------
%% PRUEBA DIRECTA del adaptador: no_reconocida nunca es una preferencia
%% --------------------------------------------------------------------------

prueba_adaptador :-
    format("~n=== adaptador: frases desconocidas ===~n"),
    Frases = ["Quiero ser millonario", "Los perros son bonitos", "", "   ",
              "me gusta", "me gusta volar", "no", "si"],
    forall(member(F, Frases),
           (   interpretar_respuesta(F, P)
           ->  format("  [FALLA] ~q fue aceptada como ~w~n", [F, P]),
               assertz(resultado_caso(adaptador, falla))
           ;   format("  [OK]    ~q rechazada~n", [F])
           )),
    (   resultado_caso(adaptador, falla)
    ->  true
    ;   assertz(resultado_caso(adaptador, ok)),
        format("  => adaptador: PASA~n")
    ).

%% --------------------------------------------------------------------------
%% Punto de entrada
%% --------------------------------------------------------------------------

ejecutar_pruebas_integracion :-
    retractall(resultado_caso(_, _)),
    forall(member(C, [caso1, caso2, caso3, caso4, caso5,
                      extraA, extraB, extraC, extraD, extraE]),
           ejecutar_caso(C)),
    prueba_adaptador,
    findall(C, resultado_caso(C, falla), Fallas),
    findall(C, resultado_caso(C, ok), Oks),
    length(Oks, NOk),
    length(Fallas, NF),
    format("~n==========================================~n"),
    format("RESUMEN: ~w pasan, ~w fallan.~n", [NOk, NF]),
    (   Fallas == []
    ->  format("TODAS LAS PRUEBAS PASARON.~n"), halt(0)
    ;   format("Fallaron: ~w~n", [Fallas]), halt(1)
    ).
