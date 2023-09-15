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

/* Seleccionando a partir de un arreglo específuci */

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
WHERE (DATE_PART('YEAR',fecha_incorporacion) < 2018);


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
