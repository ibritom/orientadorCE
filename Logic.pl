:- encoding(utf8).
%% ==========================================================================
%%  Logic.pl  --  Reglas de recomendación y control de la interacción
%%  OrientadorCE - Paradigmas de Programación (CE1106) - Tarea 3 - II Sem 2026
%%
%%  CÓMO EJECUTAR:
%%      $ swipl Logic.pl          (carga BD.pl y BNF.pl automáticamente)
%%      ?- iniciar.               % arranca la conversación en consola
%%
%%  Para probar solo el motor (sin gramática ni conversación):
%%      ?- probar([pref(matematicas,pos), pref(tecnologia,pos),
%%                 pref(resolver_problemas,pos)]).
%%
%%  El archivo tiene tres secciones:
%%      A. Motor de recomendación   (preferencias + reglas lógicas)
%%      B. Presentación del resultado
%%      C. Conversación en consola  (integra BNF.pl con el motor)
%% ==========================================================================

:- ensure_loaded('BD.pl').
:- ensure_loaded('BNF.pl').
:- use_module(library(readutil)).
:- use_module(library(lists)).
:- use_module(library(apply)).

%% preferencia(?Interes, ?Polaridad): preferencias YA interpretadas y
%% registradas en la sesión actual. Polaridad = pos (afinidad) o neg (rechazo).
:- dynamic preferencia/2.

%% preguntada(?Interes): intereses cuya pregunta ya se hizo (no se repite).
:- dynamic preguntada/1.

%% num_preferencias(?N): cuántas preferencias distintas se recopilan antes de
%% recomendar (los ejemplos del enunciado usan 3).
num_preferencias(3).

%% ==========================================================================
%%  A. MOTOR DE RECOMENDACIÓN
%% ==========================================================================
%%  Criterio (se explica igual en la documentación):
%%   1. Una profesión se DESCARTA si el usuario rechazó (neg) algún interés
%%      de su lista incompatibles/2.
%%   2. Las profesiones no descartadas se puntúan con el número de intereses
%%      AFIRMADOS (pos) que están en su lista afinidades/2. Un interés
%%      rechazado nunca cuenta como afinidad.
%%   3. Una profesión es CANDIDATA si su puntaje >= minimo_coincidencias/1.
%%   4. Se recomiendan las candidatas con el MAYOR puntaje (una o varias si
%%      hay empate). Si no hay candidatas, se informa que no hay coincidencias.

%% registrar_preferencia(+pref(Interes, Polaridad))
%%   Guarda la preferencia. Si el interés ya tenía una, la reemplaza (el
%%   usuario cambió de opinión). Falla si el término no es válido.
registrar_preferencia(pref(I, Pol)) :-
    interes(I),
    memberchk(Pol, [pos, neg]),
    retractall(preferencia(I, _)),
    assertz(preferencia(I, Pol)).

%% limpiar_preferencias/0: borra las preferencias de la sesión anterior.
limpiar_preferencias :-
    retractall(preferencia(_, _)),
    retractall(preguntada(_)).

%% total_preferencias(-N): cantidad de intereses ya registrados.
total_preferencias(N) :-
    findall(I, preferencia(I, _), L),
    length(L, N).

%% coincidencias(+Profesion, -Lista): intereses AFIRMADOS que están en las
%% afinidades de la profesión (en el orden de la lista de la BD).
coincidencias(P, Coinc) :-
    afinidades(P, As),
    findall(I, (member(I, As), preferencia(I, pos)), Coinc).

%% descartada(+Profesion, -Rechazos): la profesión es incompatible con las
%% preferencias negativas; Rechazos = intereses rechazados que la descartan.
descartada(P, Rechazos) :-
    profesion(P),
    findall(I, (incompatible_si_rechaza(P, I), preferencia(I, neg)), Rechazos),
    Rechazos \== [].

%% candidata(?Profesion, ?Puntaje, ?Coincidencias): no descartada y con
%% suficientes coincidencias.
candidata(P, N, Coinc) :-
    profesion(P),
    \+ descartada(P, _),
    coincidencias(P, Coinc),
    length(Coinc, N),
    minimo_coincidencias(Min),
    N >= Min.

%% recomendaciones(-Lista): Lista = [Profesion-Coincidencias, ...] con las
%% candidatas de mayor puntaje. Falla si no hay ninguna candidata.
recomendaciones(Lista) :-
    findall(N, candidata(_, N, _), Ns),
    Ns \== [],
    max_list(Ns, Max),
    findall(P-Coinc, candidata(P, Max, Coinc), Lista).

%% descartada_relevante(?Profesion, ?Rechazos): profesión que habría sido
%% candidata por sus afinidades, pero fue descartada por un rechazo.
%% Sirve para explicar al usuario cómo se usó su preferencia negativa.
descartada_relevante(P, Rechazos) :-
    descartada(P, Rechazos),
    coincidencias(P, Coinc),
    length(Coinc, N),
    minimo_coincidencias(Min),
    N >= Min.

%% probar(+ListaPrefs): prueba el motor sin conversación ni gramática.
probar(Prefs) :-
    limpiar_preferencias,
    (   forall(member(P, Prefs), registrar_preferencia(P))
    ->  mostrar_resultado
    ;   writeln('ERROR: lista con preferencias inválidas.'), fail
    ).

%% ==========================================================================
%%  B. PRESENTACIÓN DEL RESULTADO
%% ==========================================================================

%% mostrar_resultado/0: muestra la recomendación o la ausencia de ella, y
%% explica los descartes causados por preferencias negativas.
mostrar_resultado :-
    (   recomendaciones(Lista)
    ->  mostrar_recomendaciones(Lista)
    ;   mostrar_sin_coincidencias
    ),
    mostrar_descartes.

mostrar_recomendaciones([P-Coinc]) :- !,
    nombre_profesion(P, Nombre),
    etiquetas(Coinc, Txt),
    format("OrientadorCE: Según tus preferencias, te recomiendo ~w.~n", [Nombre]),
    format("              (Coincide con tu interés en ~w.)~n", [Txt]).
mostrar_recomendaciones(Lista) :-
    writeln('OrientadorCE: Según tus preferencias, te recomiendo cualquiera de estas opciones:'),
    forall(member(P-Coinc, Lista),
           (   nombre_profesion(P, Nombre),
               etiquetas(Coinc, Txt),
               format("              - ~w (coincide con ~w)~n", [Nombre, Txt])
           )).

mostrar_sin_coincidencias :-
    writeln('OrientadorCE: Lo siento, con esas preferencias no dispongo de una recomendación compatible.'),
    writeln('              Puedes volver a intentarlo con otras respuestas.').

mostrar_descartes :-
    findall(P-Rs, descartada_relevante(P, Rs), Ds),
    (   Ds == []
    ->  true
    ;   forall(member(P-Rs, Ds),
               (   nombre_profesion(P, Nombre),
                   etiquetas(Rs, Txt),
                   format("              Descarté ~w porque indicaste que no te gusta ~w.~n",
                          [Nombre, Txt])
               ))
    ).

%% etiquetas(+Intereses, -Texto): "la tecnología, las matemáticas y ...".
etiquetas(Intereses, Texto) :-
    maplist(etiqueta_interes_, Intereses, Etiquetas),
    unir_con_y(Etiquetas, Texto).

etiqueta_interes_(I, T) :- etiqueta_interes(I, T).

unir_con_y([X], X) :- !.
unir_con_y(L, Texto) :-
    append(Init, [Ult], L),
    atomic_list_concat(Init, ', ', A),
    atomic_list_concat([A, ' y ', Ult], Texto).

%% ==========================================================================
%%  C. CONVERSACIÓN EN CONSOLA E INTEGRACIÓN CON BNF.pl
%% ==========================================================================

%% iniciar/0: punto de entrada del programa.
iniciar :-
    limpiar_preferencias,
    catch(( conversar, mostrar_resultado ),
          fin_entrada,
          ( nl, writeln('OrientadorCE: Conversación finalizada.') )),
    !.

orientadorCE :- iniciar.

%% conversar/0: saluda, hace la pregunta abierta y luego pregunta por los
%% intereses de orden_preguntas/1 (BD.pl) hasta reunir num_preferencias/1.
conversar :-
    writeln('OrientadorCE: Hola. Estoy aquí para ayudarte a explorar opciones profesionales. ¿Qué te gusta?'),
    obtener_preferencia,
    orden_preguntas(Orden),
    num_preferencias(Meta),
    preguntar_hasta(Meta, Orden).

preguntar_hasta(Meta, Orden) :-
    total_preferencias(N),
    (   N >= Meta
    ->  true
    ;   member(I, Orden), \+ preferencia(I, _), \+ preguntada(I)   % siguiente pregunta pendiente
    ->  assertz(preguntada(I)),
        pregunta(I, Texto),
        format("OrientadorCE: ~w~n", [Texto]),
        obtener_preferencia,
        preguntar_hasta(Meta, Orden)
    ;   true                                       % ya no quedan preguntas
    ).

%% obtener_preferencia/0: lee una respuesta y la interpreta con la gramática.
%%   - Si se reconoce, se registra como preferencia.
%%   - Si NO se reconoce, no se registra nada y se pide reformular.
obtener_preferencia :-
    leer_respuesta(Linea),
    (   interpretar_respuesta(Linea, Pref)
    ->  registrar_preferencia(Pref)
    ;   writeln('OrientadorCE: No logré entender tu respuesta. ¿Puedes reformularla?'),
        writeln('              (Ejemplos: "Me gusta la tecnología", "No me gusta la tecnología")'),
        obtener_preferencia
    ).

%% leer_respuesta(-Linea): lee una línea de la consola. Con "salir" o fin de
%% entrada termina la conversación (excepción fin_entrada).
leer_respuesta(Linea) :-
    format("Usuario: "), flush_output,
    read_line_to_string(user_input, Cruda),
    (   Cruda == end_of_file
    ->  throw(fin_entrada)
    ;   true
    ),
    normalize_space(string(Linea), Cruda),
    (   string_lower(Linea, "salir")
    ->  throw(fin_entrada)
    ;   true
    ).

%% --------------------------------------------------------------------------
%%  ADAPTADOR CON BNF.pl  (único punto de contacto con la gramática)
%%
%%  Usa interpretar_frase(+Texto, -Resultado) de BNF.pl, que devuelve
%%  pref(Interes, pos|neg) o el átomo no_reconocida. Se usa interpretar_frase/2
%%  (y NO interpretar_respuesta/3) para exigir siempre una frase completa:
%%  el enunciado no acepta interacciones basadas solo en "sí"/"no".
%% --------------------------------------------------------------------------
interpretar_respuesta(Linea, Pref) :-
    catch(interpretar_frase(Linea, Pref), _, fail),
    pref_valida(Pref),
    !.

%% pref_valida(+Pref): descarta no_reconocida y cualquier cosa que no sea una
%% preferencia utilizable (una frase no reconocida NUNCA se registra).
pref_valida(pref(I, Pol)) :-
    atom(I), interes(I),
    memberchk(Pol, [pos, neg]).
