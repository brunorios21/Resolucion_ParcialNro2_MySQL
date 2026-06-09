# Preparacion Teorica: Fundamentos de Bases de Datos y Motores SQL

[![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![SQL Server](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)
[![Teoria Relacional](https://img.shields.io/badge/Teoria_Relacional-20232A?style=for-the-badge&logo=databricks&logoColor=white)](#)

## Analisis Estructural del Examen Teorico

Este documento recopila los fundamentos teoricos evaluados en la administracion y consulta de bases de datos relacionales. El examen exige diferenciar entre los estandares ANSI SQL y las implementaciones especificas de cada motor (Transact-SQL para SQL Server vs. dialecto MySQL).

Los ejes principales a dominar incluyen:
* **Algebra Relacional:** Comprension de operaciones conjuntistas frente a operaciones unarias (como la proyeccion).
* **Categorizacion de Lenguajes:** Distincion exacta entre DML (Manipulacion), DDL (Definicion), TCL (Transacciones) y DCL (Control).
* **Manejo de Nulos:** Regla estricta del uso de la clausula `IS NULL` para evaluaciones de logica trivaluada.
* **Funciones Nativas:** Diferenciacion de funciones propietarias como `STUFF()` o `NEWID()` en SQL Server frente a `INSERT()` o `UUID()` en MySQL.
* **Transaccionalidad (OLTP):** Comandos de control de flujo transaccional.

---

## Cuestionario Detallado y Justificaciones

### Pregunta 1: ¿Cual de estas operaciones de algebra relacional NO es una operacion conjuntista?
* [INCORRECTA] Union
* [INCORRECTA] Producto Cartesiano
* [INCORRECTA] Interseccion
* **[CORRECTA] Proyeccion**

**Justificacion:** Las operaciones conjuntistas trabajan con conjuntos completos de tuplas (filas), como Union e Interseccion. La Proyeccion selecciona columnas de una relacion, por lo que no pertenece al grupo de operaciones conjuntistas.

### Pregunta 2: ¿Cuales de estas instrucciones corresponden a DML?
* [INCORRECTA] COMMIT
* [INCORRECTA] GRANT
* [INCORRECTA] CREATE
* **[CORRECTA] SELECT**
* **[CORRECTA] UPDATE**
* **[CORRECTA] TRUNCATE**

**Justificacion:** DML (Data Manipulation Language) se utiliza para manipular datos. SELECT consulta datos, UPDATE modifica datos y TRUNCATE elimina registros de una tabla (nota: en algunos estandares TRUNCATE es DDL, pero en este contexto se agrupa con la manipulacion masiva). No pertenecen a DML: CREATE (DDL), GRANT (DCL), COMMIT (TCL).

### Pregunta 3: En SQL, la obtencion de valores nulos se realiza mediante:
* [INCORRECTA] SELECT WHERE LIKE NULL
* [INCORRECTA] SELECT WHERE = NULL
* [INCORRECTA] SELECT WHERE == NULL
* **[CORRECTA] SELECT WHERE IS NULL**

**Justificacion:** NULL no puede compararse con el signo igual debido a la logica trivaluada. Siempre se utiliza IS NULL o IS NOT NULL.

### Pregunta 4: En SQL, la sigla DML refiere a:
* [INCORRECTA] Data Model Level
* [INCORRECTA] Data Model Language
* [INCORRECTA] Ninguna es correcta
* **[CORRECTA] Database Manipulation Language**

**Justificacion:** DML significa Database Manipulation Language, el sublenguaje utilizado para manipular la informacion dentro de las estructuras de datos.

### Pregunta 5: Relacione el comando con el SGBD que lo soporta
* **TOP:** **[CORRECTA] SQL Server** | [INCORRECTA] MySQL | [INCORRECTA] Ambos | [INCORRECTA] Ninguno
* **LIMIT:** **[CORRECTA] MySQL** | [INCORRECTA] SQL Server | [INCORRECTA] Ambos | [INCORRECTA] Ninguno
* **STDDEV_POP:** **[CORRECTA] MySQL** | [INCORRECTA] SQL Server | [INCORRECTA] Ambos | [INCORRECTA] Ninguno
* **STDEVP:** **[CORRECTA] SQL Server** | [INCORRECTA] MySQL | [INCORRECTA] Ambos | [INCORRECTA] Ninguno

**Justificacion:** TOP limita resultados en la sintaxis de SQL Server, mientras que LIMIT cumple esa funcion en MySQL. STDDEV_POP y STDEVP son funciones estadisticas equivalentes para MySQL y SQL Server respectivamente.

### Pregunta 6: ¿Que sucede si una subconsulta devuelve mas de un valor y se utiliza con el operador igual?
* [INCORRECTA] Se toma el primer valor
* [INCORRECTA] Se toma el ultimo valor
* [INCORRECTA] Resultado impredecible
* **[CORRECTA] Se produce un error y la consulta falla**

**Justificacion:** El operador logico de igualdad espera recibir un unico valor escalar. Si la subconsulta devuelve un conjunto de registros, el motor detiene la ejecucion y devuelve un error de cardinalidad.

### Pregunta 7: En MySQL, ¿como se inicia, confirma y revierte una transaccion?
* [INCORRECTA] BEGIN TRANSACTION, COMMIT, ROLLBACK
* [INCORRECTA] OPEN TRANSACTION, FINALIZE, REVERT
* [INCORRECTA] BEGIN WORK, SAVE, UNDO
* [INCORRECTA] BEGIN TRANSACTION, CONFIRM, CANCEL
* **[CORRECTA] START TRANSACTION, COMMIT, ROLLBACK**

**Justificacion:** La sintaxis oficial en MySQL para el control transaccional es START TRANSACTION, seguido de COMMIT para asentar cambios o ROLLBACK para revertirlos.

### Pregunta 8: Funcion equivalente a NEWID() de SQL Server en MySQL
* [INCORRECTA] AUTO_INCREMENT
* [INCORRECTA] GETDATE()
* [INCORRECTA] RAND()
* **[CORRECTA] UUID()**

**Justificacion:** La funcion UUID() genera identificadores unicos universales estandarizados, equivalente al comportamiento de NEWID().

### Pregunta 9: En una vista, ¿cual afirmacion es verdadera?
* **[CORRECTA] Una vista es una consulta almacenada que se puede utilizar como una tabla virtual.**
* [INCORRECTA] Una vista no puede contener funciones de agregacion.
* [INCORRECTA] Una vista siempre contiene datos almacenados fisicamente.
* [INCORRECTA] Una vista solo puede ser modificada por el administrador.

**Justificacion:** Las vistas no almacenan datos fisicamente (a menos que sean vistas indexadas/materializadas); almacenan la estructura de la consulta en el diccionario de datos.

### Pregunta 10: ¿Cual NO es un tipo valido de fecha y hora en MySQL?
* **[CORRECTA] Todos son tipos validos**
* [INCORRECTA] YEAR
* [INCORRECTA] DATE
* [INCORRECTA] TIME
* [INCORRECTA] TIMESTAMP

**Justificacion:** MySQL soporta nativamente todos estos tipos de datos temporales.

### Pregunta 11: Cuando se obtiene NULL como resultado en una clausula WHERE
* **[CORRECTA] La fila no forma parte del resultado**
* [INCORRECTA] La consulta da error
* [INCORRECTA] La fila forma parte del resultado

**Justificacion:** La clausula WHERE aplica un filtro estricto. Al evaluar un valor como NULL, el resultado de la proposicion logica es "desconocido", por lo que no cumple con el estado TRUE requerido para incluir la tupla.

### Pregunta 12: Palabra clave para eliminar duplicados
* [INCORRECTA] TOP
* [INCORRECTA] ALL
* [INCORRECTA] UNIQUE
* **[CORRECTA] DISTINCT**

**Justificacion:** La clausula SELECT DISTINCT instruye al motor de base de datos a colapsar las filas resultantes que poseen valores identicos en las columnas proyectadas.

### Pregunta 13: La sigla OLTP refiere a
* **[CORRECTA] OnLine Transactional Processing**
* [INCORRECTA] OnLine Analytic Processing
* [INCORRECTA] OnLine Tables Processing
* [INCORRECTA] Ninguna es correcta

**Justificacion:** OLTP define la arquitectura de sistemas enfocados en la ejecucion rapida, segura y recurrente de transacciones diarias, como bancos o sistemas de ventas.

### Pregunta 14: ¿En que año se lanzo SQL Server 1.0?
* [INCORRECTA] 1986
* [INCORRECTA] 1990
* [INCORRECTA] 1992
* **[CORRECTA] 1989**

**Justificacion:** La primera iteracion comercial de SQL Server fue lanzada al mercado en el año 1989.

### Pregunta 15: ¿En que año se definio el primer estandar ANSI/ISO SQL?
* [INCORRECTA] 1980
* [INCORRECTA] 1984
* [INCORRECTA] 1990
* **[CORRECTA] 1986**

**Justificacion:** El Instituto Nacional Estadounidense de Estandares (ANSI) publico el primer estandar oficial para SQL en 1986.

### Pregunta 16: ¿En que sistema funciona la expresion SELECT STUFF('lmn',2,1,'def')?
* **[CORRECTA] SQL Server**
* [INCORRECTA] MySQL
* [INCORRECTA] Ambos
* [INCORRECTA] Ninguno

**Justificacion:** STUFF es una funcion nativa y exclusiva del lenguaje Transact-SQL de Microsoft para la manipulacion y reemplazo de subcadenas.

### Pregunta 17: En SQL Server, ¿en que tipo NO puede aplicarse Identity?
* [INCORRECTA] Decimal
* [INCORRECTA] Numeric
* [INCORRECTA] Integer
* **[CORRECTA] Varchar**

**Justificacion:** La propiedad IDENTITY genera secuencias incrementales automaticas, por lo tanto, requiere tipos de datos estrictamente numericos. VARCHAR almacena caracteres alfanumericos.

### Pregunta 18: Ultima version de MySQL
* **[CORRECTA] 8.4**
* **[CORRECTA] 9.0**
* [INCORRECTA] 5.7
* [INCORRECTA] 5.6

**Justificacion:** Segun las consideraciones del marco de la materia, tanto la rama 8.4 LTS como la rama de innovacion 9.0 son respuestas admitidas como actualizadas.

### Pregunta 19: Puerto TCP por defecto de MySQL
* [INCORRECTA] 1433
* [INCORRECTA] 6446
* [INCORRECTA] 33060
* **[CORRECTA] 3306**

**Justificacion:** El protocolo de comunicacion cliente-servidor de MySQL utiliza estandarizadamente el puerto 3306 para las conexiones entrantes.

### Pregunta 20: ¿Como emular FULL OUTER JOIN en MySQL?
* [INCORRECTA] INNER JOIN + CROSS JOIN
* [INCORRECTA] Seleccion y Proyeccion
* [INCORRECTA] Subconsulta correlacionada
* **[CORRECTA] LEFT JOIN + RIGHT JOIN + UNION**

**Justificacion:** Al carecer de una implementacion nativa para el cruce externo completo, se requiere combinar un cruce por izquierda, un cruce por derecha y unificar los conjuntos de resultados mediante el comando UNION para suprimir duplicados.

### Pregunta 21: ¿Cuales son operadores de condicion?
* **[CORRECTA] LIKE**
* **[CORRECTA] BETWEEN**
* **[CORRECTA] NOT**
* **[CORRECTA] Todos**

**Justificacion:** Todos los listados son operadores logicos y comparativos validos dentro del estandar SQL para establecer condiciones en clausulas WHERE y HAVING.

### Pregunta 22: Instruccion para eliminar filas
* [INCORRECTA] ELIMINATE FROM
* [INCORRECTA] DROP FROM
* [INCORRECTA] ERASE FROM
* **[CORRECTA] DELETE FROM table WHERE condition;**

**Justificacion:** DELETE es la palabra reservada del bloque DML para remover registros especificos a nivel de fila segun el criterio establecido en la condicion.

### Pregunta 23: Sintaxis para eliminar una tabla
* [INCORRECTA] REMOVE TABLE
* [INCORRECTA] TRUNCATE TABLE
* [INCORRECTA] DELETE TABLE
* [INCORRECTA] ERASE TABLE
* **[CORRECTA] DROP TABLE**

**Justificacion:** DROP TABLE es la instruccion DDL destructiva que elimina tanto el esquema fisico de la tabla como los datos alojados en ella.

### Pregunta 24: ¿En que sistema funciona la expresion SELECT INSERT('lmn',2,1,'def')?
* **[CORRECTA] MySQL**
* [INCORRECTA] SQL Server
* [INCORRECTA] Ambos
* [INCORRECTA] Ninguno

**Justificacion:** A diferencia del comando INSERT INTO, la funcion escalar INSERT() es especifica de MySQL para operaciones de reemplazo de texto a nivel de cadena, actuando de forma analoga a STUFF en SQL Server.

### Pregunta 25: Tipo de dato entero exacto que almacena valores entre -32.768 y 32.767
* [INCORRECTA] BIGINT
* [INCORRECTA] INT
* [INCORRECTA] TINYINT
* **[CORRECTA] SMALLINT**

**Justificacion:** SMALLINT reserva 2 bytes en almacenamiento, determinando un rango exacto de -32,768 a 32,767 con signo.

---

## Tabla de Resumen y Referencia Rapida

| Categoria | Concepto Solicitado | Respuesta Correcta |
| :--- | :--- | :--- |
| **Algebra** | No conjuntista | Proyeccion |
| **DML** | Instrucciones DML validas | SELECT, UPDATE, TRUNCATE |
| **Logica** | Obtencion de nulos | IS NULL |
| **Aronimos** | Significado de DML | Database Manipulation Language |
| **Sintaxis** | LIMITADOR (MySQL / SQL Server) | LIMIT / TOP |
| **Errores** | Subconsulta con '=' y multiples filas | Produce un error |
| **TCL** | Transacciones en MySQL | START TRANSACTION, COMMIT, ROLLBACK |
| **Funciones** | Equivalente a NEWID() en MySQL | UUID() |
| **Vistas** | Definicion estandar | Consulta almacenada / Tabla virtual |
| **Tipos** | Tipos de fecha/hora en MySQL | Todos son validos |
| **Logica** | Resolucion de NULL en WHERE | La fila no forma parte del resultado |
| **DDL/DML** | Eliminar datos duplicados | DISTINCT |
| **Conceptos**| Sigla OLTP | OnLine Transactional Processing |
| **Historia** | Lanzamiento SQL Server 1.0 | 1989 |
| **Historia** | Primer estandar ANSI SQL | 1986 |
| **Funciones** | Expresion `STUFF()` | SQL Server |
| **Funciones** | Expresion `INSERT()` | MySQL |
| **Restricciones** | Propiedad IDENTITY no aplica en | VARCHAR |
| **Entorno** | Ultima version MySQL | 8.4 y 9.0 |
| **Entorno** | Puerto TCP MySQL | 3306 |
| **Sintaxis** | Emular FULL OUTER JOIN (MySQL) | LEFT JOIN + RIGHT JOIN + UNION |
| **Logica** | Operadores de condicion validos | LIKE, BETWEEN, NOT (Todos) |
| **DML** | Eliminar registros (filas) | DELETE FROM table WHERE condition |
| **DDL** | Eliminar estructura (tabla) | DROP TABLE |
| **Tipos** | Rango numerico de 2 bytes | SMALLINT |
