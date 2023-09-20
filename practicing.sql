/* EJERCICIOS BÁSICOS */ 

SELECT *
FROM platzi.alumnos
OFFSET 0
LIMIT 5;

SELECT *
FROM platzi.alumnos
FETCH FIRST 5 ROWS ONLY;


SELECT *
FROM(
	SELECT ROW_NUMBER() OVER() AS id_user, * 
	FROM platzi.alumnos
) AS sleccionandoConVentana
WHERE id_user BETWEEN 0 AND 5;


SELECT *
FROM platzi.alumnos
FETCH FIRST 5 ROWS ONLY;


/* Seleccionando el segundo más alto */
SELECT DISTINCT colegiatura
FROM platzi.alumnos AS a1
WHERE 2 = (
	SELECT COUNT (DISTINCT colegiatura)
	FROM platzi.alumnos a2
	WHERE a1.colegiatura <= a2.colegiatura
);

/* Seleccionando el segundo más alto  + condición de tutor */
SELECT DISTINCT colegiatura, tutor_id
FROM platzi.alumnos
WHERE tutor_id = 20
ORDER BY colegiatura DESC
OFFSET 1
LIMIT 1;

/* Seleccionando TODOS los de colegiatura más alta + condición de tutor */
SELECT *
FROM platzi.alumnos AS datos_alumnos
INNER JOIN (
	SELECT DISTINCT colegiatura
	FROM platzi.alumnos
	WHERE tutor_id = 20
	ORDER BY colegiatura DESC 
	LIMIT 1 OFFSET 1
) AS segunda_mayor_colegiatura
ON datos_alumnos.colegiatura = segunda_mayor_colegiatura.colegiatura;


/* Lo mismo que el anterior, pero de forma diferente */
SELECT * 
FROM platzi.alumnos AS datos_alumnos
WHERE colegiatura = (
	SELECT DISTINCT colegiatura
	FROM platzi.alumnos
	WHERE tutor_id =  20
	ORDER BY colegiatura DESC
	LIMIT 1 OFFSET 1
);


/* Seleccionando la segunda mitad de la tabla*/

SELECT  *
FROM platzi.alumnos
WHERE id BETWEEN 501 AND 1000

SELECT *
FROM platzi.alumnos
OFFSET 500
LIMIT 500


SELECT *
FROM platzi.alumnos
WHERE id >=501 AND id<=1000

/* Lo siguiente, prevee que posiblemente no esten los ID correctamente registrados, 
   y por ello, primero se le asigna un registro tipo ID a cada fila */ 
 

SELECT ROW_NUMBER() OVER () AS IDordenado, * 
FROM platzi.alumnos
OFFSET (
	SELECT COUNT(*)/2
	FROM platzi.alumnos
);

/* Seleccionando a partir de un arreglo específico */

SELECT *
FROM(
	SELECT ROW_NUMBER() OVER() row_id, * 
	FROM platzi.alumnos
) AS  rowsNumeradas
WHERE row_id IN (1,5,10,15,20,25,30);


SELECT*
FROM platzi.alumnos
WHERE id IN (
	SELECT id
	FROM platzi.alumnos
	WHERE tutor_id = 30
);


/*Seleccionando lo que no esta en la lista*/
SELECT *
FROM(
	SELECT ROW_NUMBER() OVER( ) AS id_user, * 
	FROM platzi.alumnos
)AS a1
WHERE id_user NOT IN (2,3,6, 1,5,10,15,20);1


/* Manejando datos tipo date*/
SELECT EXTRACT(YEAR FROM fecha_incorporacion) AS anio_incorporacion 
FROM platzi.alumnos;

SELECT DATE_PART('YEAR', fecha_incorporacion) AS anio_incorporacion,
	   DATE_PART('MONTH', fecha_incorporacion) AS mes_incorporacion,
	   DATE_PART('DAY', fecha_incorporacion) AS dia_incorporacion
FROM platzi.alumnos
WHERE (DATE_PART('YEAR',fecha_incorporacion) < 2020);


/* Manejando datos tipo time*/

SELECT EXTRACT(HOUR FROM fecha_incorporacion) AS hora_incorporacion 
FROM platzi.alumnos;

SELECT EXTRACT(MINUTE FROM fecha_incorporacion) AS minuto_incorporacion 
FROM platzi.alumnos;

SELECT EXTRACT(SECOND FROM fecha_incorporacion) AS segundo_incorporacion 
FROM platzi.alumnos;

SELECT DATE_PART('HOUR', fecha_incorporacion) AS hora_incorporacion,
	   DATE_PART('MINUTE', fecha_incorporacion) AS minuto_incorporacion,
	   DATE_PART('SECOND', fecha_incorporacion) AS segundo_incorporacion
FROM platzi.alumnos
WHERE (DATE_PART('HOUR',fecha_incorporacion) < 20);




/* Lo anterior era un poco reduntante, a continuación se presenta una mejor propues */
/* Que ademas, trae el resto de información, anteriormente solo se traia el dato de fehca*/

SELECT *
FROM platzi.alumnos 
WHERE(
	DATE_PART('YEAR', fecha_incorporacion) < 2020);

SELECT * 
FROM(
	SELECT *, EXTRACT(YEAR FROM fecha_incorporacion) AS yearColumn
	FROM platzi.alumnos
) AS alumnos_anio
WHERE yearColumn < 2020;



/* FILTRADO POR AÑO Y MES */
SELECT *
FROM(
	SELECT *, DATE_PART('YEAR',fecha_incorporacion) AS yearColumn, 
	DATE_PART('MONTH',fecha_incorporacion) AS monthColumn
	FROM platzi.alumnos
) AS alumnosAnioMonth
WHERE ( yearColumn = 2018 AND monthColumn = 08 ); 


SELECT *
FROM(
	SELECT *, EXTRACT(YEAR FROM fecha_incorporacion) AS yearColumn, 
	EXTRACT(MONTH FROM fecha_incorporacion) AS monthColumn
	FROM platzi.alumnos
) AS alumnosAnioMonth
WHERE ( yearColumn = 2018 AND monthColumn = 5 ); 


/* Looking for duplicate records*/ 
SELECT *
FROM platzi.alumnos AS ou
WHERE (
	SELECT COUNT (*)
	FROM platzi.alumnos AS inr
	WHERE ou.id = inr.id
) > 1;


/* Commonly, id is a consecutive number, it doesn't matter whether it be a duplicated value,
   the id will change. Which is why is suggested to do this process using another column */
   
   
SELECT (
	platzi.alumnos.nombre,
	platzi.alumnos.apellido,
	platzi.alumnos.email,
	platzi.alumnos.colegiatura,
	platzi.alumnos.fecha_incorporacion,
	platzi.alumnos.carrera_id,
	platzi.alumnos.tutor_id
	)::text, COUNT(*)
FROM platzi.alumnos
GROUP BY 	platzi.alumnos.nombre,
	platzi.alumnos.apellido,
	platzi.alumnos.email,
	platzi.alumnos.colegiatura,
	platzi.alumnos.fecha_incorporacion,
	platzi.alumnos.carrera_id,
	platzi.alumnos.tutor_id
HAVING COUNT(*) >1;


/* By a different way */

SELECT *
FROM (
	SELECT id,
	ROW_NUMBER() OVER(
		PARTITION BY 
			nombre,
			apellido,
			email,
			colegiatura,
		    fecha_incorporacion,
			carrera_id,
			tutor_id
		/*ORDER BY id ASC*/
	) AS row, *
	FROM platzi.alumnos
) AS duplicados
WHERE duplicados.row > 1;



DELETE FROM platzi.alumnos
WHERE id IN (
    SELECT id
    FROM (
        SELECT id,
        ROW_NUMBER() OVER (
        	PARTITION BY 
            	nombre,
                apellido,
                email,
                colegiatura,
                fecha_incorporacion,
                carrera_id,
                tutor_id
        ) AS duplicados
        FROM platzi.alumnos
    ) AS subquery
    WHERE subquery.duplicados > 1
);

SELECT*
FROM platzi.alumnos
WHERE tutor_id BETWEEN 1 AND 10;

SELECT int4range(1, 20) @>3; /* @>3 it means "is 3 in the range from 1 to 20 ? "*/

SELECT numrange(11.1, 20.9) && numrange(20.0, 30.0);

SELECT UPPER(int8range(15,25));

SELECT LOWER(int8range(15,25));

SELECT int4range(10,20) * int4range(15,25);

SELECT ISEMPTY(numrange(30,100));


SELECT *
FROM platzi.alumnos
WHERE(
	int4range(10,20) @> tutor_id
);


SELECT *
FROM platzi.alumnos
WHERE( tutor_id = carrera_id );

SELECT int8range(MIN(carrera_id),MAX(carrera_id)) *
	   int8range(MIN(tutor_id),MAX(tutor_id))
FROM platzi.alumnos;


SELECT carrera_id, MAX(fecha_incorporacion)
FROM platzi.alumnos
GROUP BY carrera_id
ORDER BY carrera_id  DESC; 


SELECT *
FROM platzi.alumnos
WHERE id IN (
	SELECT id
	FROM platzi.alumnos
	WHERE (carrera_id, fecha_incorporacion) IN (
		SELECT carrera_id, MAX(fecha_incorporacion)
		FROM platzi.alumnos
		GROUP BY carrera_id
	) 
);

SELECT * 
FROM platzi.alumnos
ORDER BY nombre
LIMIT 1;

SELECT tutor_id, MIN(nombre)
FROM platzi.alumnos
GROUP BY tutor_id
ORDER BY tutor_id;


SELECT a.nombre,
	   a.apellido,
	   t.nombre,
	   t.apellido
FROM platzi.alumnos AS a
INNER JOIN platzi.alumnos AS t ON a.tutor_id = t.id;


SELECT CONCAT(a.nombre,' ', a.apellido) AS alumno,
	   CONCAT( t.nombre,' ',  t.apellido) AS tutor
FROM platzi.alumnos AS a
INNER JOIN platzi.alumnos AS t ON a.tutor_id = t.id;



SELECT CONCAT( t.nombre,' ',  t.apellido) AS tutor,	
	   COUNT(*) AS alumnos_por_tutor
FROM platzi.alumnos AS a
INNER JOIN platzi.alumnos AS t ON a.tutor_id = t.id
GROUP BY tutor
ORDER BY alumnos_por_tutor DESC
LIMIT 10;


SELECT AVG(alumnos_por_tutor) AS alumnosPorTutor
FROM (
	SELECT CONCAT( t.nombre,' ',  t.apellido) AS tutor,	
		   COUNT(*) AS alumnos_por_tutor
	FROM platzi.alumnos AS a
	INNER JOIN platzi.alumnos AS t ON a.tutor_id = t.id
	GROUP BY tutor
) AS alumnosTutor;





