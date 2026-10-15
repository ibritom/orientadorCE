:- encoding(utf8).
%% ==========================================================================
%%  BD.pl  --  Base de conocimientos de OrientadorCE
%%  Paradigmas de Programación (CE1106) - Tarea 3 - II Semestre 2026
%%
%%  Este archivo contiene SOLO hechos (más un verificador de consistencia).
%%  No contiene lógica de recomendación (Logic.pl) ni gramática (BNF.pl).
%%
%%  Cómo cargarlo individualmente:
%%      ?- ['BD.pl'].          (o:  swipl BD.pl)
%%      ?- verificar_bd.       % debe responder: true.
%%
%%  NOTA: las asociaciones profesión-interés son simplificaciones con fines
%%  educativos; no constituyen un diagnóstico vocacional profesional.
%% ==========================================================================

%% --------------------------------------------------------------------------
%%  CONVENCIONES (contrato con BNF.pl y Logic.pl)
%% --------------------------------------------------------------------------
%%  * Los intereses y las profesiones se identifican con ÁTOMOS en minúscula,
%%    sin tildes ni espacios (ej.: resolver_problemas, psicologia).
%%    Los textos "bonitos" para mostrar al usuario se guardan aparte
%%    (etiqueta_interes/2, nombre_profesion/2, pregunta/2).
%%  * BNF.pl debe producir, para cada frase, un par:
%%        pref(Interes, Polaridad)    con Polaridad = pos  o  neg
%%    donde Interes es un átomo que cumpla interes/1.
%%  * Un interés puede ser AFIRMADO ("me gusta la tecnología") o RECHAZADO
%%    ("no me gusta la tecnología"); el rechazo es la "preferencia negativa".

%% --------------------------------------------------------------------------
%%  1. interes(?Interes)
%%     Catálogo cerrado de intereses que el sistema reconoce (16).
%% --------------------------------------------------------------------------
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

%% --------------------------------------------------------------------------
%%  2. etiqueta_interes(?Interes, ?Texto)
%%     Texto legible del interés (para explicar la recomendación al usuario).
%% --------------------------------------------------------------------------
etiqueta_interes(matematicas,       'las matemáticas').
etiqueta_interes(tecnologia,        'la tecnología').
etiqueta_interes(resolver_problemas,'resolver problemas').
etiqueta_interes(ciencia,           'la ciencia').
etiqueta_interes(ayudar_personas,   'ayudar a las personas').
etiqueta_interes(escuchar,          'escuchar a los demás').
etiqueta_interes(hablar,            'hablar en público').
etiqueta_interes(creatividad,       'la creatividad y el arte').
etiqueta_interes(naturaleza,        'la naturaleza').
etiqueta_interes(liderazgo,         'liderar grupos').
etiqueta_interes(escribir,          'escribir').
etiqueta_interes(trabajo_manual,    'el trabajo manual y práctico').
etiqueta_interes(salud,             'la salud y el cuerpo humano').
etiqueta_interes(ensenar,           'enseñar').
etiqueta_interes(negocios,          'los negocios').
etiqueta_interes(trabajo_equipo,    'trabajar en equipo').

%% --------------------------------------------------------------------------
%%  3. pregunta(?Interes, ?Texto)
%%     Pregunta que OrientadorCE hace para explorar cada interés.
%%  4. orden_preguntas(?Lista)
%%     LISTA de intereses en el orden en que Logic.pl puede preguntarlos.
%% --------------------------------------------------------------------------
pregunta(matematicas,        '¿Te gustan las matemáticas?').
pregunta(tecnologia,         '¿Te gusta la tecnología?').
pregunta(resolver_problemas, '¿Te gusta resolver problemas?').
pregunta(ciencia,            '¿Te interesa la ciencia?').
pregunta(ayudar_personas,    '¿Te interesa ayudar a las personas?').
pregunta(escuchar,           '¿Prefieres escuchar o hablar?').
pregunta(hablar,             '¿Disfrutas hablar frente a un grupo?').
pregunta(creatividad,        '¿Te atrae la creatividad y el arte?').
pregunta(naturaleza,         '¿Te gusta la naturaleza?').
pregunta(liderazgo,          '¿Te gusta liderar grupos?').
pregunta(escribir,           '¿Disfrutas escribir?').
pregunta(trabajo_manual,     '¿Te gusta el trabajo manual y práctico?').
pregunta(salud,              '¿Te interesa la salud y el cuerpo humano?').
pregunta(ensenar,            '¿Te gustaría enseñar a otros?').
pregunta(negocios,           '¿Te interesan los negocios?').
pregunta(trabajo_equipo,     '¿Te gusta trabajar en equipo?').

orden_preguntas([ matematicas, tecnologia, resolver_problemas, ciencia,
                  ayudar_personas, escuchar, hablar, creatividad,
                  naturaleza, liderazgo, escribir, trabajo_manual,
                  salud, ensenar, negocios, trabajo_equipo ]).

%% --------------------------------------------------------------------------
%%  5. profesion(?Id)
%%     Catálogo de profesiones (12; el mínimo pedido es 10).
%%  6. nombre_profesion(?Id, ?Nombre)
%%     Nombre legible para mostrar en la recomendación.
%% --------------------------------------------------------------------------
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

nombre_profesion(ingenieria_en_computadores, 'Ingeniería en Computadores').
nombre_profesion(medicina,                   'Medicina').
nombre_profesion(psicologia,                 'Psicología').
nombre_profesion(administracion_de_empresas, 'Administración de Empresas').
nombre_profesion(arquitectura,               'Arquitectura').
nombre_profesion(educacion,                  'Educación').
nombre_profesion(derecho,                    'Derecho').
nombre_profesion(biologia,                   'Biología').
nombre_profesion(diseno_grafico,             'Diseño Gráfico').
nombre_profesion(enfermeria,                 'Enfermería').
nombre_profesion(ingenieria_civil,           'Ingeniería Civil').
nombre_profesion(estadistica,                'Estadística').

%% --------------------------------------------------------------------------
%%  7. afinidades(?Profesion, ?ListaIntereses)
%%     LISTA de intereses/fortalezas que favorecen a la profesión.
%%     Si el usuario AFIRMA un interés de esta lista, la profesión "suma".
%%     Cada lista tiene 4 intereses, sin repetidos, todos válidos (interes/1).
%% --------------------------------------------------------------------------
afinidades(ingenieria_en_computadores, [tecnologia, matematicas, resolver_problemas, ciencia]).
afinidades(medicina,                   [ciencia, ayudar_personas, salud, resolver_problemas]).
afinidades(psicologia,                 [ayudar_personas, escuchar, salud, escribir]).
afinidades(administracion_de_empresas, [negocios, liderazgo, hablar, trabajo_equipo]).
afinidades(arquitectura,               [creatividad, matematicas, tecnologia, trabajo_manual]).
afinidades(educacion,                  [ensenar, hablar, ayudar_personas, trabajo_equipo]).
afinidades(derecho,                    [hablar, escribir, resolver_problemas, escuchar]).
afinidades(biologia,                   [ciencia, naturaleza, resolver_problemas, escribir]).
afinidades(diseno_grafico,             [creatividad, tecnologia, trabajo_equipo, escribir]).
afinidades(enfermeria,                 [salud, ayudar_personas, trabajo_equipo, trabajo_manual]).
afinidades(ingenieria_civil,           [matematicas, trabajo_manual, liderazgo, resolver_problemas]).
afinidades(estadistica,                [matematicas, ciencia, resolver_problemas, escribir]).

%% --------------------------------------------------------------------------
%%  8. incompatibles(?Profesion, ?ListaIntereses)
%%     LISTA de intereses que son ESENCIALES para la profesión. Si el usuario
%%     RECHAZA alguno ("no me gusta ..."), la profesión queda DESCARTADA.
%%     Siempre es un subconjunto de afinidades/2 (el núcleo de la carrera).
%% --------------------------------------------------------------------------
incompatibles(ingenieria_en_computadores, [tecnologia, resolver_problemas]).
incompatibles(medicina,                   [ayudar_personas, salud]).
incompatibles(psicologia,                 [ayudar_personas, escuchar]).
incompatibles(administracion_de_empresas, [negocios, liderazgo]).
incompatibles(arquitectura,               [creatividad, matematicas]).
incompatibles(educacion,                  [ensenar, ayudar_personas]).
incompatibles(derecho,                    [hablar, escribir]).
incompatibles(biologia,                   [ciencia, naturaleza]).
incompatibles(diseno_grafico,             [creatividad]).
incompatibles(enfermeria,                 [salud, ayudar_personas]).
incompatibles(ingenieria_civil,           [matematicas, trabajo_manual]).
incompatibles(estadistica,                [matematicas]).

%% --------------------------------------------------------------------------
%%  9. minimo_coincidencias(?N)
%%     Parámetro de la base: número mínimo de afinidades afirmadas que una
%%     profesión necesita para poder recomendarse. Evita recomendar por una
%%     única coincidencia débil (permite el caso "sin coincidencias").
%% --------------------------------------------------------------------------
minimo_coincidencias(2).

%% --------------------------------------------------------------------------
%%  Predicados auxiliares de consulta (azúcar sintáctico sobre los hechos)
%% --------------------------------------------------------------------------

%% afinidad(?Profesion, ?Interes): el interés está en las afinidades.
afinidad(P, I) :- afinidades(P, L), member(I, L).

%% incompatible_si_rechaza(?Profesion, ?Interes): rechazar I descarta a P.
incompatible_si_rechaza(P, I) :- incompatibles(P, L), member(I, L).

%% --------------------------------------------------------------------------
%%  verificar_bd/0
%%  Revisa la consistencia de la base. Falla (con mensaje) si hay un error:
%%    - >= 10 profesiones, cada una con nombre, afinidades e incompatibles;
%%    - listas sin repetidos y con intereses válidos;
%%    - incompatibles contenidos en afinidades;
%%    - todo interés se pregunta y es usado por al menos una profesión.
%% --------------------------------------------------------------------------
verificar_bd :-
    findall(P, profesion(P), Ps),
    length(Ps, N),
    (   N >= 10 -> true
    ;   format("ERROR: solo hay ~w profesiones (mínimo 10).~n", [N]), fail ),
    forall(profesion(P), verificar_profesion(P)),
    forall(interes(I), verificar_interes(I)),
    orden_preguntas(Orden),
    findall(I, interes(I), Is),
    (   msort(Orden, S), msort(Is, S) -> true
    ;   writeln('ERROR: orden_preguntas/1 no coincide con interes/1.'), fail ),
    format("BD correcta: ~w profesiones, ~w intereses.~n", [N, 16]).

verificar_profesion(P) :-
    (   nombre_profesion(P, _) -> true
    ;   format("ERROR: ~w sin nombre_profesion/2.~n", [P]), fail ),
    (   afinidades(P, A) -> true
    ;   format("ERROR: ~w sin afinidades/2.~n", [P]), fail ),
    (   incompatibles(P, X) -> true
    ;   format("ERROR: ~w sin incompatibles/2.~n", [P]), fail ),
    (   lista_valida(A), lista_valida(X) -> true
    ;   format("ERROR: ~w tiene listas con repetidos o intereses inválidos.~n", [P]), fail ),
    (   subtract(X, A, []) -> true
    ;   format("ERROR: incompatibles de ~w no están en sus afinidades.~n", [P]), fail ).

verificar_interes(I) :-
    (   pregunta(I, _), etiqueta_interes(I, _) -> true
    ;   format("ERROR: ~w sin pregunta o etiqueta.~n", [I]), fail ),
    (   afinidad(_, I) -> true
    ;   format("ERROR: ~w no lo usa ninguna profesión.~n", [I]), fail ).

lista_valida(L) :-
    L \== [],
    forall(member(E, L), interes(E)),
    sort(L, S), length(L, N), length(S, N).   % sin repetidos
