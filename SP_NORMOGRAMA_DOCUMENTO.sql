CREATE OR REPLACE PROCEDURE SP_NORMOGRAMA_DOCUMENTO(REFCONTENIDO IN VARCHAR2, CONTADOR NUMBER)
IS
	I NUMBER := 0;
	ENCONTRADO NUMBER := 0;
	K NUMBER := 0;

  -- Definition of associative array
	TYPE T_DOCUMENTO IS RECORD(
		Id VARCHAR2(128),
		Nombre VARCHAR2(1200));
	TYPE R_DOCUMENTO IS TABLE OF T_DOCUMENTO INDEX BY BINARY_INTEGER;

	registros R_DOCUMENTO;
	r R_DOCUMENTO;
BEGIN
	K := CONTADOR;
	K := K + 1;

	dbms_output.put_line('CICLO: '||K);
	
	SELECT ID, NOMBRE 
	BULK COLLECT INTO registros
	FROM (
		SELECT DISTINCT CD.COD_CONTENIDO ID, C.NOMCONTENIDO NOMBRE 
		FROM ENLACES E 
		INNER JOIN CONTENIDODESTINOS CD ON CD.ID_DESTINO = E.COD_DESTINO 
		INNER JOIN CONTENIDO C ON C.IDCONTENIDO = CD.COD_CONTENIDO 
		WHERE E.COD_CONTENIDO = REFCONTENIDO
		AND NOT EXISTS (SELECT * FROM NORMOGRAMA_DOCUMENTOS WHERE IDCONTENIDO = CD.COD_CONTENIDO)
	);
		
	FOR I IN 1..registros.COUNT
	LOOP
		SELECT CASE 
			WHEN  EXISTS(SELECT IDCONTENIDO FROM NORMOGRAMA_DOCUMENTOS WHERE IDCONTENIDO = registros(I).Id)
			THEN 1
			ELSE 0
			END INTO ENCONTRADO
		FROM dual;
		IF ENCONTRADO = 0 THEN
			--dbms_output.put_line('REGISTRO: '||registros(I).Nombre);
			INSERT INTO NORMOGRAMA_DOCUMENTOS(IDCONTENIDO, NOMBRE, CODCONTENIDO_ORG) VALUES(registros(I).Id, registros(I).Nombre, REFCONTENIDO);
			SP_NORMOGRAMA_DOCUMENTO(registros(I).Id, K);
		END IF;
	END LOOP;
	
END SP_NORMOGRAMA_DOCUMENTO;
