:- encoding(utf8).

:- consult('BNF.pl').

% ============================================================
% Casos de prueba para la gramática de OrientadorCE
% ============================================================

prueba(1,
       "Me gustan las matematicas",
       pref(matematicas, pos)).

prueba(2,
       "No me gusta la tecnologia",
       pref(tecnologia, neg)).

prueba(3,
       "Me interesa ayudar a las personas",
       pref(ayudar_personas, pos)).

prueba(4,
       "No disfruto hablar en publico",
       pref(hablar, neg)).

prueba(5,
       "Prefiero trabajar en equipo",
       pref(trabajo_equipo, pos)).

prueba(6,
       "Me atrae la creatividad y el arte",
       pref(creatividad, pos)).

prueba(7,
       "No me interesa la salud y el cuerpo humano",
       pref(salud, neg)).

prueba(8,
       "Me gusta resolver problemas",
       pref(resolver_problemas, pos)).

% Frases que no deben reconocerse

prueba(9,
       "Quiero ser millonario",
       no_reconocida).

prueba(10,
       "Los perros son bonitos",
       no_reconocida).

% Respuestas cortas

prueba_corta(11,
             "si",
             tecnologia,
             pref(tecnologia, pos)).

prueba_corta(12,
             "no",
             matematicas,
             pref(matematicas, neg)).


ejecutar_pruebas :-
    writeln('--- PRUEBAS DE FRASES COMPLETAS ---'),
    forall(
        prueba(Id, Texto, Esperado),
        ejecutar_una_prueba(Id, Texto, Esperado)
    ),
    nl,
    writeln('--- PRUEBAS DE RESPUESTAS CORTAS ---'),
    forall(
        prueba_corta(Id, Texto, Interes, Esperado),
        ejecutar_una_prueba_corta(Id, Texto, Interes, Esperado)
    ).


ejecutar_una_prueba(Id, Texto, Esperado) :-
    interpretar_frase(Texto, Obtenido),
    (   Obtenido == Esperado
    ->  format('Prueba ~w: OK~n', [Id])
    ;   format('Prueba ~w: ERROR~n', [Id]),
        format('  Frase: ~w~n', [Texto]),
        format('  Esperado: ~w~n', [Esperado]),
        format('  Obtenido: ~w~n', [Obtenido])
    ).


ejecutar_una_prueba_corta(Id, Texto, Interes, Esperado) :-
    interpretar_respuesta(Texto, Interes, Obtenido),
    (   Obtenido == Esperado
    ->  format('Prueba ~w: OK~n', [Id])
cat > Pruebas_BNF.pl <<'EOF'
:- encoding(utf8).

:- consult('BNF.pl').

% ============================================================
% Casos de prueba para la gramática de OrientadorCE
% ============================================================

prueba(1,
       "Me gustan las matematicas",
       pref(matematicas, pos)).

prueba(2,
       "No me gusta la tecnologia",
       pref(tecnologia, neg)).

prueba(3,
       "Me interesa ayudar a las personas",
       pref(ayudar_personas, pos)).

prueba(4,
       "No disfruto hablar en publico",
       pref(hablar, neg)).

prueba(5,
       "Prefiero trabajar en equipo",
       pref(trabajo_equipo, pos)).

prueba(6,
       "Me atrae la creatividad y el arte",
       pref(creatividad, pos)).

prueba(7,
       "No me interesa la salud y el cuerpo humano",
       pref(salud, neg)).

prueba(8,
       "Me gusta resolver problemas",
       pref(resolver_problemas, pos)).

% Frases que no deben reconocerse

prueba(9,
       "Quiero ser millonario",
       no_reconocida).

prueba(10,
       "Los perros son bonitos",
       no_reconocida).

% Respuestas cortas

prueba_corta(11,
             "si",
             tecnologia,
             pref(tecnologia, pos)).

prueba_corta(12,
             "no",
             matematicas,
             pref(matematicas, neg)).


ejecutar_pruebas :-
    writeln('--- PRUEBAS DE FRASES COMPLETAS ---'),
    forall(
        prueba(Id, Texto, Esperado),
        ejecutar_una_prueba(Id, Texto, Esperado)
    ),
    nl,
    writeln('--- PRUEBAS DE RESPUESTAS CORTAS ---'),
    forall(
        prueba_corta(Id, Texto, Interes, Esperado),
        ejecutar_una_prueba_corta(Id, Texto, Interes, Esperado)
    ).


ejecutar_una_prueba(Id, Texto, Esperado) :-
    interpretar_frase(Texto, Obtenido),
    (   Obtenido == Esperado
    ->  format('Prueba ~w: OK~n', [Id])
    ;   format('Prueba ~w: ERROR~n', [Id]),
        format('  Frase: ~w~n', [Texto]),
        format('  Esperado: ~w~n', [Esperado]),
        format('  Obtenido: ~w~n', [Obtenido])
    ).


ejecutar_una_prueba_corta(Id, Texto, Interes, Esperado) :-
    interpretar_respuesta(Texto, Interes, Obtenido),
    (   Obtenido == Esperado
    ->  format('Prueba ~w: OK~n', [Id])
    ;   format('Prueba ~w: ERROR~n', [Id]),
        format('  Frase: ~w~n', [Texto]),
        format('  Interes: ~w~n', [Interes]),
        format('  Esperado: ~w~n', [Esperado]),
        format('  Obtenido: ~w~n', [Obtenido])
    ).
