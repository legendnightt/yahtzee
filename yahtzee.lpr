PROGRAM yahtzee (input, output);
USES
  CRT;
CONST
  INI = 1;
  FIN = 5;
  FIN2 = 14;
  FIN3 = 13;
  TIRADAS = 3;
  TOPE = 6;
  DIM = 50;
  RUTA = 'fichero\scoreboard.bin';
TYPE
  TCadena = STRING [DIM];
  TJugador = RECORD
    nombre: TCadena;
    score: integer;
    victoria: boolean;
  END;
  TDado = RECORD
    numero: integer;
    seleccionado: boolean;
  END;
  TDados = ARRAY [INI..FIN] OF TDado;
  TCasilla = RECORD
    punt_j,  punt_m: integer;
    ocupado: boolean;
  END;
  TCasillas = ARRAY [INI..FIN2] OF TCasilla;
  TEleccion = ARRAY [INI..FIN] OF integer;
  TFichero = FILE OF TJugador;

FUNCTION Aleatorio: integer;
BEGIN
  Aleatorio:= RANDOM (TOPE) + 1;
END;

PROCEDURE TirarDados (VAR d: TDados);
VAR
  i: integer;
BEGIN
  FOR i:= INI TO FIN DO BEGIN
    IF (NOT d[i].seleccionado) THEN
      d[i].numero:= Aleatorio;
  END;
END;

PROCEDURE MostrarDados (d: TDados);
VAR
  i: integer;
BEGIN
  FOR i:= INI TO FIN DO
    WRITE (d[i].numero, ' ');
  WRITELN;
END;

PROCEDURE InicializarC (VAR c: TCasillas);
VAR
  i: integer;
BEGIN
  FOR i:= INI TO FIN2 DO BEGIN
    c[i].punt_j:= 0;
    c[i].punt_m:= 0;
    c[i].ocupado:= FALSE;
  END;
END;

PROCEDURE InicializarD (VAR d: TDados);
VAR
  i: integer;
BEGIN
  FOR i:= INI TO FIN DO
    d[i].seleccionado:= FALSE;
END;

FUNCTION Sumar (d: TDados; n: integer): integer;
VAR
  i, aux: integer;
BEGIN
  aux:= 0;
  FOR i:= INI TO FIN DO
    IF (d[i].numero = n) THEN
      aux:= aux + n;
  Sumar:= aux;
END;

FUNCTION Sumatorio (d: TDados): integer;
VAR
  i, aux: integer;
BEGIN
  aux:= 0;
  FOR i:= INI TO FIN DO
    aux:= aux + d[i].numero;
  Sumatorio:= aux;
END;

FUNCTION Triplete_Poker (d: TDados; n: integer): integer;
VAR
  i, j, cont: integer;
BEGIN
  i:= INI;
  REPEAT
    j:= SUCC (i);
    cont:= INI;
    REPEAT
      IF (d[i].numero = d[j].numero) THEN
        cont:= SUCC (cont);
      j:= SUCC (j);
    UNTIL ((cont = n) OR (j = SUCC (FIN)));
    i:= SUCC (i);
  UNTIL ((i = PRED (FIN)) OR (cont = n));

  IF (cont = n) THEN
    Triplete_Poker:= Sumatorio (d)
  ELSE
    Triplete_Poker:= 0;
END;

FUNCTION Full (d: TDados): integer;
BEGIN
  Full:= 0;
END;

PROCEDURE Ordenar (d: TDados);
VAR
  i, j, aux: integer;
BEGIN
  FOR i:= INI TO (FIN - 1) DO
    FOR j:= INI TO (FIN - i) DO
      IF (d[j].numero > d[j + 1].numero) THEN BEGIN
        aux:= d[j].numero;
        d[j].numero:= d[j + 1].numero;
        d[j + 1].numero:= aux;
      END;
END;

FUNCTION Escalera (d: TDados; n: integer): integer;
VAR
  i, cont: integer;
BEGIN
  i:= INI;
  cont:= INI;
  Ordenar (d);
  REPEAT
    IF (d[i].numero = PRED (d[i + 1].numero)) THEN
      cont:= SUCC (cont);
    i:= SUCC (i);
  UNTIL ((i = FIN) OR (cont = n));

  IF (cont = 4) THEN
    Escalera:= 30
  ELSE
    IF (cont = 5) THEN
      Escalera:= 40
    ELSE
      Escalera:= 0;
END;

FUNCTION Yahtzee (d: TDados): integer;
VAR
  i: integer;
  aux: boolean;
BEGIN
  i:= INI;
  REPEAT
    aux:= d[i].numero = d[i + 1].numero;
    i:= SUCC (i);
  UNTIL ((NOT aux) OR (i = FIN));

  IF (aux) THEN
    Yahtzee:= 50
  ELSE
    Yahtzee:= 0;
END;

FUNCTION SumaPuntos (c: TCasillas; a: integer): integer;
VAR
  i, aux: integer;
BEGIN
  i:= a;
  aux:= 0;
  REPEAT
    IF (c[i].ocupado) THEN
      aux:= aux + c[i].punt_j;
    i:= i + 2;
  UNTIL (i > FIN2);
  SumaPuntos:= aux;
END;

FUNCTION Bonus (c: TCasillas): integer;
BEGIN
  IF (SumaPuntos (c, INI) > 63) THEN
    Bonus:= 50
  ELSE
    Bonus:= 0;
END;

PROCEDURE Puntuaciones (d: TDados; VAR c: TCasillas; maquinajugador : boolean);
BEGIN
  IF (NOT c[1].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[1].punt_j:= Sumar (d, 1)
    ELSE
       c[1].punt_m:= Sumar (d, 1);

  IF (NOT c[2].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[2].punt_j:= Triplete_Poker (d, 3)
    ELSE
       c[2].punt_m:= Triplete_Poker (d, 3);

  IF (NOT c[3].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[3].punt_j:= Sumar (d, 2)
    ELSE
       c[3].punt_m:= Sumar (d, 2);

  IF (NOT c[4].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[4].punt_j:= Triplete_Poker (d, 4)
    ELSE
       c[4].punt_m:= Triplete_Poker (d, 4);

  IF (NOT c[5].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[5].punt_j:= Sumar (d, 3)
    ELSE
       c[5].punt_m:= Sumar (d, 3);

  IF (NOT c[6].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[6].punt_j:= Full (d)
    ELSE
       c[6].punt_m:= Full (d);

  IF (NOT c[7].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[7].punt_j:= Sumar (d, 4)
    ELSE
       c[7].punt_m:= Sumar (d, 4);

  IF (NOT c[8].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[8].punt_j:= Escalera (d, 4)
    ELSE
       c[8].punt_m:= Escalera (d, 4);

  IF (NOT c[9].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[9].punt_j:= Sumar (d, 5)
    ELSE
       c[9].punt_m:= Sumar (d, 5);

  IF (NOT c[10].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[10].punt_j:= Escalera (d, 5)
    ELSE
       c[10].punt_m:= Escalera (d, 5);

  IF (NOT c[11].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[11].punt_j:= Sumar (d, 6)
    ELSE
       c[11].punt_m:= Sumar (d, 6);

  IF (NOT c[12].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[12].punt_j:= Yahtzee (d)
    ELSE
       c[12].punt_m:= Yahtzee (d);

  IF (NOT c[14].ocupado) THEN
    IF maquinajugador = TRUE THEN
       c[14].punt_j:= Sumatorio (d)
    ELSE
       c[14].punt_m:= Sumatorio (d);
END;

FUNCTION Buscar (l: TCadena; o: char): boolean;
VAR
  i: integer;
  aux: boolean;
BEGIN
  i:= INI;
  REPEAT
    aux:= l[i] = o;
    i:= SUCC (i);
  UNTIL ((aux) OR (i = SUCC (length (l))));
  Buscar:= aux;
END;

PROCEDURE MenuOpciones (VAR c: TCasillas; VAR l: TCadena; maquinajugador: boolean);
VAR
  opcion: char;
  aux: boolean;
  aux2: integer;
BEGIN
  IF maquinajugador = TRUE THEN BEGIN
    REPEAT
      WRITELN ('Elige la casilla que quieras');
      WRITELN ('Opciones: UNOS (U), DOSES (D), TRESES (T), CUATROS (Q), CINCOS (C), SEISES (S)');
      WRITELN ('TRIPLETE (R), POKER (P), FULL (F), ESCALERA MENOR (E), ESCALERA MAYOR (M), YAHTZEE (Y), SUMATORIO (A)');
      READLN (opcion);
      opcion:= UPCASE (opcion);
      aux:= Buscar (l, opcion);

      IF (NOT aux) THEN BEGIN
        CASE opcion OF
          'U': c[1].ocupado:= TRUE;
          'D': c[3].ocupado:= TRUE;
          'T': c[5].ocupado:= TRUE;
          'Q': c[7].ocupado:= TRUE;
          'C': c[9].ocupado:= TRUE;
          'S': c[11].ocupado:= TRUE;
          'R': c[2].ocupado:= TRUE;
          'P': c[4].ocupado:= TRUE;
          'F': c[6].ocupado:= TRUE;
          'E': c[8].ocupado:= TRUE;
          'M': c[10].ocupado:= TRUE;
          'Y': c[12].ocupado:= TRUE;
          'A': c[14].ocupado:= TRUE;
        ELSE
          WRITELN ('Esa opcion no es valida');
        END; {CASE}

        l[length (l) + 1]:= opcion;
      END
      ELSE
        WRITELN ('Esa casilla ya esta ocupada');
    UNTIL (((opcion = 'U') OR (opcion = 'D') OR (opcion = 'T') OR (opcion = 'Q') OR (opcion = 'C') OR (opcion = 'S')
    OR (opcion = 'R') OR (opcion = 'P') OR (opcion = 'F') OR (opcion = 'E') OR (opcion = 'M')
    OR (opcion = 'Y') OR (opcion = 'A')) AND (NOT aux));

    IF (Bonus (c) = 50) THEN BEGIN
      c[13].ocupado:= TRUE;
      c[13].punt_j:= Bonus (c);
    END;
  END
  ELSE BEGIN
      aux2 := RANDOM(FIN3) + INI;
      c[aux2].ocupado := TRUE;
  END;
END;

PROCEDURE MostrarMenu (c: TCasillas);
BEGIN
  WRITELN;
  WRITELN ('J1':14, 'J2':4, ' | ', 'J1':21, 'J2':4);
  WRITELN ('UNOS (U)', c[1].punt_j:6, c[1].punt_m:4, ' | ', 'TRIPLETE (R)', c[2].punt_j:9, c[2].punt_m:4);
  WRITELN ('DOSES (D)', c[3].punt_j:5, c[3].punt_m:4, ' | ', 'POKER (P)', c[4].punt_j:12, c[4].punt_m:4);
  WRITELN ('TRESES (T)', c[5].punt_j:4, c[1].punt_m:4, ' | ', 'FULL (F)', c[6].punt_j:13, c[6].punt_m:4);
  WRITELN ('CUATROS (Q)', c[7].punt_j:3, c[1].punt_m:4, ' | ', 'ESCALERA MENOR (E)', c[8].punt_j:3, c[8].punt_m:4);
  WRITELN ('CINCOS (C)', c[9].punt_j:4, c[1].punt_m:4, ' | ', 'ESCALERA MAYOR (M)', c[10].punt_j:3, c[10].punt_m:4);
  WRITELN ('SEISES (S)', c[11].punt_j:4, c[1].punt_m:4, ' | ', 'YAHTZEE (Y)', c[12].punt_j:10, c[12].punt_m:4);
  WRITELN ('BONUS (>63)', c[13].punt_j:3, c[1].punt_m:4, ' | ', 'SUMATORIO (A)', c[14].punt_j:8, c[14].punt_m:4);
  WRITELN ('PUNTOS', SumaPuntos (c, INI):8, SumaPuntos (c, INI):4, ' | ', 'PUNTOS', SumaPuntos (c, SUCC (INI)):15, SumaPuntos (c, SUCC (INI)):4);
  WRITELN;
END;

PROCEDURE MostrarSeleccionador;
BEGIN
  WRITELN;
  WRITELN('Opciones');
  WRITELN('1. Seleccionar que posicion(es) quieres guardar');
  WRITELN('2. Volver a lanzar los dados no guardados');
  WRITELN('3. Volver a lanzar todos los dados');
  WRITELN('4. Mostrar dados guardados ');
  WRITELN('5. Finalizar turno');
  WRITELN;
END;

PROCEDURE MostrarSeleccionadorFinal;
BEGIN
  WRITELN;
  WRITELN('Opciones');
  WRITELN('1. Guardar la partida');
  WRITELN('2. Mostrar el scoreboard');
  WRITELN('3. Volver a jugar');
  WRITELN('4. Salir del juego');
  WRITELN;
END;

PROCEDURE InicializarGuardados (VAR eleccion: TEleccion);
VAR
  i : integer;
BEGIN
     FOR i := INI TO FIN DO
       eleccion[i] := 0;
END;

PROCEDURE MostrarGuardados (eleccion: TEleccion);
VAR
  i : integer;
BEGIN
     WRITE ('Guardados: ');
     FOR i := INI TO FIN DO
         WRITE (eleccion[i]);
     WRITELN;
END;

PROCEDURE LeerE (VAR d: TDados; VAR eleccion: TEleccion);
VAR
  i, aux2: integer;
  aux: boolean;
BEGIN
     aux := FALSE;
     i := 1;
     WHILE aux = FALSE DO BEGIN
       WRITELN ('Introduce un dado que quieras guardar');
       REPEAT
             READLN(i);
             IF (i < INI) OR (i > FIN) THEN
                WRITELN ('Opcion introducida fuera del rango de los dados');
       UNTIL (i >= INI) AND (i <= FIN);
       d[i].seleccionado:= TRUE;
       eleccion[i] := d[i].numero;
       WRITELN ('Has guardado el dado ', i,' con el valor de: ', d[i].numero);
       MostrarGuardados(eleccion);
       REPEAT
             WRITELN;
             WRITELN ('Opciones Finales');
             WRITELN('1. Guardar otro dado');
             WRITELN('2. Continuar jugando');
             WRITELN;
             READLN (aux2);
             IF aux2 = 2 THEN
               aux := TRUE;
             IF (aux2 < 1) OR (aux2 > 2) THEN
               WRITELN ('Opcion introducida no valida');
       UNTIL ((aux2 = 1) OR (aux2 = 2));
     END;
END;

PROCEDURE GuardarJugador (VAR j: TJugador; c: TCasillas);
BEGIN
  WRITELN ('Introduzca su nombre o alias');
  READLN (j.nombre);
  j.score := SumaPuntos (c, SUCC (INI));
END;

PROCEDURE CrearFichero (VAR f: TFichero; j: TJugador);
BEGIN
  ASSIGN (f, RUTA); {fichero\scoreboard.bin}
  RESET(f);
  WRITE(f, j);
  CLOSE(f);
END;

PROCEDURE MostrarFichero (VAR f: TFichero; j: TJugador);
BEGIN
  ASSIGN (f, RUTA);
  RESET(f);
  WHILE NOT EOF(f) DO BEGIN
        READ(f, j);
        WRITELN ; WRITELN('SCOREBOARD:'); WRITELN;
        WRITELN('Nombre: ', j.nombre);
        WRITELN('Puntuacion: ', j.score);
        IF j.victoria = TRUE THEN
           WRITE('Partida Ganada')
        ELSE
           WRITE('Partida Perdida');
        WRITELN;
  END;
  CLOSE(f);
END;

PROCEDURE Menu;
VAR
  dados: TDados;
  casillas: TCasillas;
  lista: TCadena;
  a, b, rondas, cont, salir, pjugador, pmaquina, tirada: integer;
  e : TEleccion;
  mj : boolean;
  fichero : TFichero;
  jugador : TJugador;
BEGIN
  salir := 0;
  WHILE salir = 0 DO BEGIN
    WRITELN ('Bienvenido a Yahtzee!');
    InicializarC (casillas);
    InicializarD (dados);
    lista:= ' ';
    rondas:= INI;
      REPEAT
        tirada := INI;
        WRITELN ('Pulsa intro para tirar los dados');
        READKEY;
        CLRSCR;

        cont:= 0;
        mj:= TRUE;
        TirarDados (dados);
        InicializarD(dados);
        Puntuaciones (dados, casillas, mj);
        MostrarMenu (casillas);
        WRITELN ('Tirada: ', tirada);
        MostrarDados (dados);
            InicializarGuardados(e);
            REPEAT
              MostrarSeleccionador;
              READLN (a);
              CASE a OF
                1: BEGIN
                   LeerE(dados, e);
                   MostrarGuardados(e);
                END;
                2: BEGIN
                   IF tirada < TIRADAS THEN BEGIN
                      TirarDados (dados);
                      Puntuaciones (dados, casillas, mj);
                      MostrarMenu (casillas);
                      WRITELN;
                      Tirada := SUCC(Tirada);
                      WRITELN ('Tirada: ', tirada);
                      MostrarDados (dados);
                      WRITELN;
                   END
                   ELSE
                     WRITELN ('Numero de tiradas excedido'); WRITELN;
                END;
                3: BEGIN
                   IF tirada < TIRADAS THEN BEGIN
                     CLRSCR;
                     InicializarD (dados);
                     TirarDados (dados);
                     Puntuaciones (dados, casillas, mj);
                     MostrarMenu (casillas);
                     WRITELN;
                     Tirada := SUCC(Tirada);
                     WRITELN ('Tirada: ', tirada);
                     MostrarDados (dados);
                     WRITELN;
                   END
                   ELSE
                     WRITELN ('Numero de tiradas excedido'); WRITELN;
                END;
                4: BEGIN
                   MostrarGuardados (e);
                END;
                5: BEGIN
                   MenuOpciones (casillas, lista, mj);
                   cont:= SUCC(cont);
                   IF rondas = PRED (FIN2) THEN
                     pjugador := SumaPuntos (casillas, SUCC (INI));
                END;
              ELSE
                WRITELN ('Opcion introducida no valida');
              END;
            UNTIL (((a = 1) OR (a = 2) OR (a = 3) OR (a = 4) OR (a = 5)) AND (cont = INI));
        CLRSCR;
        {Maquina}
        WRITELN ('Turno de la maquina');
        WRITELN;
        mj:= FALSE;
        TirarDados (dados);
        InicializarD (dados);
        Puntuaciones (dados, casillas, mj);
        MostrarMenu (casillas);
        WRITELN;
        MostrarDados (dados);
        MenuOpciones (casillas, lista, mj);
        WRITELN;
        WRITELN ('Pulsa Intro para continuar');
        READKEY;
        IF rondas = PRED (FIN2) THEN
           pmaquina := SumaPuntos (casillas, SUCC (INI));
        CLRSCR;
        rondas:= SUCC (rondas);
    UNTIL (rondas = PRED (FIN2));
    IF pjugador >= pmaquina THEN BEGIN
      jugador.victoria := TRUE;
      WRITELN ('Has ganado, felicidades!');
    END
    ELSE BEGIN
      WRITELN ('Has perdido');
      jugador.victoria := FALSE;
    END;
    REPEAT
      MostrarSeleccionadorFinal;
      READLN (b);
      CASE b OF
           1: BEGIN
             GuardarJugador(jugador, casillas);
             CrearFichero(fichero, jugador);
           END;
           2: MostrarFichero(fichero, jugador);
           {3: volver a jugar // no es necesario ponerlo}
           4: salir := 1;
           ELSE
               WRITELN ('Opcion introducida no valida');
      END;
    UNTIL ((b = 3) OR (b = 4)); {volver a jugar // salir}
  END;
END;

BEGIN {PP}
  RANDOMIZE;
  Menu;
  READKEY;
END.
