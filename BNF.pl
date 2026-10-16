:- encoding(utf8).

%% ==========================================================================
%% BNF.pl -- Gramática e interpretación de OrientadorCE
%% Persona 2 - Paradigmas de Programación (CE1106)
%%
%% Este archivo interpreta frases del usuario y produce:
%%
%%     pref(Interes, pos).
%%     pref(Interes, neg).
%%
%% Si la frase no se reconoce, devuelve:
%%
%%     no_reconocida
%%
%% Requiere BD.pl en la misma carpeta.
%% ==========================================================================

:- consult('BD.pl').


%% --------------------------------------------------------------------------
%% GRAMÁTICA BNF USADA
%%
%% <frase> ::= <positiva> <interes>
%%           | <negativa> <interes>
%%
%% <positiva> ::= "me gusta"
%%              | "me gustan"
%%              | "me interesa"
%%              | "me interesan"
%%              | "disfruto"
%%              | "prefiero"
%%              | "me atrae"
%%              | "me atraen"
%%
%% <negativa> ::= "no me gusta"
%%              | "no me gustan"
%%              | "no me interesa"
%%              | "no me interesan"
%%              | "no disfruto"
%%              | "no prefiero"
%%              | "no me atrae"
%%              | "no me atraen"
%%
%% <interes> ::= cualquiera de los intereses definidos en BD.pl,
%%               expresado con alguna de las frases definidas abajo.
%% --------------------------------------------------------------------------


%% interpretar_frase(+Texto, -Resultado)
%%
%% Ejemplos:
%%
%% ?- interpretar_frase("Me gusta la tecnologia", R).
%% R = pref(tecnologia, pos).
%%
%% ?- interpretar_frase("No me gustan las matematicas", R).
%% R = pref(matematicas, neg).
%%
%% ?- interpretar_frase("Quiero ganar mucho dinero", R).
%% R = no_reconocida.

interpretar_frase(Texto, Resultado) :-
    normalizar_frase(Texto, Tokens),
    interpretar_tokens(Tokens, Resultado).


%% interpretar_respuesta(+Texto, +InteresActual, -Resultado)
%%
%% Permite también respuestas cortas como "si" o "no" cuando Logic.pl
%% ya conoce el interés que está preguntando.
%%
%% ?- interpretar_respuesta("si", tecnologia, R).
%% R = pref(tecnologia, pos).
%%
%% ?- interpretar_respuesta("no", matematicas, R).
%% R = pref(matematicas, neg).

interpretar_respuesta(Texto, InteresActual, Resultado) :-
    normalizar_frase(Texto, Tokens),
    (   phrase(respuesta_corta(Polaridad), Tokens)
    ->  (   interes(InteresActual)
        ->  Resultado = pref(InteresActual, Polaridad)
        ;   Resultado = no_reconocida
        )
    ;   interpretar_tokens(Tokens, Resultado)
    ).


%% interpretar_tokens(+Tokens, -Resultado)
%%
%% Se deja disponible para poder probar directamente la DCG.

interpretar_tokens(Tokens, Resultado) :-
    (   phrase(frase(Resultado), Tokens)
    ->  true
    ;   Resultado = no_reconocida
    ).


%% --------------------------------------------------------------------------
%% Normalización
%%
%% Convierte un string o átomo a una lista de palabras en minúscula.
%% También elimina signos básicos de puntuación.
%% --------------------------------------------------------------------------

normalizar_frase(Texto, Tokens) :-
    (   string(Texto)
    ->  TextoString = Texto
    ;   atom(Texto)
    ->  atom_string(Texto, TextoString)
    ),
    string_lower(TextoString, Minusculas),
    split_string(Minusculas, " \t\n", ".,;:!?¿¡", Palabras),
    maplist(atom_string, Tokens, Palabras).


%% --------------------------------------------------------------------------
%% REGLA PRINCIPAL
%%
%% La frase interpretada siempre debe producir el formato acordado:
%% pref(Interes, Polaridad)
%% --------------------------------------------------------------------------

frase(pref(Interes, pos)) -->
    inicio_positivo,
    interes_frase(Interes),
    { interes(Interes) }.

frase(pref(Interes, neg)) -->
    inicio_negativo,
    interes_frase(Interes),
    { interes(Interes) }.


%% --------------------------------------------------------------------------
%% FRASES AFIRMATIVAS
%% --------------------------------------------------------------------------

inicio_positivo --> [me, gusta].
inicio_positivo --> [me, gustan].
inicio_positivo --> [me, interesa].
inicio_positivo --> [me, interesan].
inicio_positivo --> [disfruto].
inicio_positivo --> [prefiero].
inicio_positivo --> [me, atrae].
inicio_positivo --> [me, atraen].


%% --------------------------------------------------------------------------
%% FRASES NEGATIVAS
%% --------------------------------------------------------------------------

inicio_negativo --> [no, me, gusta].
inicio_negativo --> [no, me, gustan].
inicio_negativo --> [no, me, interesa].
inicio_negativo --> [no, me, interesan].
inicio_negativo --> [no, disfruto].
inicio_negativo --> [no, prefiero].
inicio_negativo --> [no, me, atrae].
inicio_negativo --> [no, me, atraen].


%% --------------------------------------------------------------------------
%% RESPUESTAS CORTAS
%%
%% Se usan únicamente mediante interpretar_respuesta/3 porque necesitan
%% conocer cuál era el interés de la pregunta actual.
%% --------------------------------------------------------------------------

respuesta_corta(pos) --> [si].
respuesta_corta(pos) --> ['sí'].
respuesta_corta(neg) --> [no].


%% --------------------------------------------------------------------------
%% INTERESES
%%
%% Cada regla convierte una expresión del usuario al átomo que utiliza BD.pl.
%% Se incluyen algunas variantes con y sin tildes para facilitar las pruebas.
%% --------------------------------------------------------------------------

%% matematicas
interes_frase(matematicas) --> [matematicas].
interes_frase(matematicas) --> ['matemáticas'].
interes_frase(matematicas) --> [las, matematicas].
interes_frase(matematicas) --> [las, 'matemáticas'].

%% tecnologia
interes_frase(tecnologia) --> [tecnologia].
interes_frase(tecnologia) --> ['tecnología'].
interes_frase(tecnologia) --> [la, tecnologia].
interes_frase(tecnologia) --> [la, 'tecnología'].

%% resolver_problemas
interes_frase(resolver_problemas) --> [resolver, problemas].

%% ciencia
interes_frase(ciencia) --> [ciencia].
interes_frase(ciencia) --> [la, ciencia].

%% ayudar_personas
interes_frase(ayudar_personas) --> [ayudar, personas].
interes_frase(ayudar_personas) --> [ayudar, a, personas].
interes_frase(ayudar_personas) --> [ayudar, a, las, personas].

%% escuchar
interes_frase(escuchar) --> [escuchar].
interes_frase(escuchar) --> [escuchar, a, los, demas].
interes_frase(escuchar) --> [escuchar, a, los, 'demás'].

%% hablar
interes_frase(hablar) --> [hablar].
interes_frase(hablar) --> [hablar, en, publico].
interes_frase(hablar) --> [hablar, en, 'público'].

%% creatividad
interes_frase(creatividad) --> [creatividad].
interes_frase(creatividad) --> [la, creatividad].
interes_frase(creatividad) --> [creatividad, y, arte].
interes_frase(creatividad) --> [la, creatividad, y, el, arte].

%% naturaleza
interes_frase(naturaleza) --> [naturaleza].
interes_frase(naturaleza) --> [la, naturaleza].

%% liderazgo
interes_frase(liderazgo) --> [liderazgo].
interes_frase(liderazgo) --> [el, liderazgo].
interes_frase(liderazgo) --> [liderar, grupos].

%% escribir
interes_frase(escribir) --> [escribir].

%% trabajo_manual
interes_frase(trabajo_manual) --> [trabajo, manual].
interes_frase(trabajo_manual) --> [el, trabajo, manual].
interes_frase(trabajo_manual) --> [trabajo, manual, y, practico].
interes_frase(trabajo_manual) --> [trabajo, manual, y, 'práctico'].
interes_frase(trabajo_manual) --> [el, trabajo, manual, y, practico].
interes_frase(trabajo_manual) --> [el, trabajo, manual, y, 'práctico'].

%% salud
interes_frase(salud) --> [salud].
interes_frase(salud) --> [la, salud].
interes_frase(salud) --> [salud, y, cuerpo, humano].
interes_frase(salud) --> [la, salud, y, el, cuerpo, humano].

%% ensenar
interes_frase(ensenar) --> [ensenar].
interes_frase(ensenar) --> ['enseñar'].
interes_frase(ensenar) --> [ensenar, a, otros].
interes_frase(ensenar) --> ['enseñar', a, otros].

%% negocios
interes_frase(negocios) --> [negocios].
interes_frase(negocios) --> [los, negocios].

%% trabajo_equipo
interes_frase(trabajo_equipo) --> [trabajar, en, equipo].
interes_frase(trabajo_equipo) --> [trabajo, en, equipo].
interes_frase(trabajo_equipo) --> [el, trabajo, en, equipo].
