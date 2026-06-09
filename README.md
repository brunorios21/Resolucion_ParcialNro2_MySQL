# Resolucion de Parcial - Base de Datos Pampero

![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![Data Analysis](https://img.shields.io/badge/Data_Analysis-20232A?style=for-the-badge&logo=databricks&logoColor=white)

## Contexto del Proyecto

Este repositorio contiene la resolucion analitica de practicas y evaluaciones de bases de datos basadas en el modelo relacional Pampero. El objetivo principal es demostrar el dominio del lenguaje de manipulacion de datos (DML) mediante el motor SQL, aplicando buenas practicas de consulta, optimizacion de filtros y resolucion de problemas comunes de agrupacion y sintaxis cruzada entre entornos MySQL y SQL Server.

## Analisis Tecnico de las Consultas

A continuacion se detalla el analisis de las tecnicas aplicadas en cada requerimiento de la evaluacion, desglosando la logica subyacente para consolidar los conceptos avanzados de diseño de consultas.

### Relacion compleja con valores nulos
El escenario exigia buscar clientes y proveedores que residan en la misma region, incluyendo aquellos casos excepcionales donde la region no estaba definida en absoluto.
Se utilizo una cadena de multiples cruces internos (JOIN) navegando a traves de las entidades intermedias (Pedidos, Detalles y Productos). La clave logica de este problema radica en la clausula WHERE. Dado que la igualdad estandar en bases de datos relacionales excluye los valores nulos, se implemento una condicion agrupada con el operador logico OR para contemplar explicitamente que ambas regiones sean nulas de manera simultanea. 
En entornos exclusivos de MySQL, esta logica detallada puede simplificarse radicalmente utilizando el operador de igualdad segura frente a nulos (<=>).

### Optimizacion de filtros temporales y agregacion
Para calcular los totales solicitados por categoria de producto durante un año especifico, la instruccion requerida combinaba sumatorias y calculos matematicos.
El nucleo de esta resolucion reside en evitar el uso de la funcion YEAR() directamente sobre la columna de fecha dentro de la clausula WHERE. Al extraer el año con una funcion escalar, el motor de la base de datos se ve forzado a ignorar los indices establecidos, ejecutando una lectura secuencial completa de la tabla. La practica optima aplicada consiste en establecer un rango estricto mediante cadenas de texto comparativas (mayor o igual al primer dia del año y menor al primer dia del año siguiente). Posteriormente, se aplican funciones de agregacion como SUM(), multiplicando la cantidad por el precio unitario y agrupando estrictamente por el nombre de la categoria.

### Comparacion de registros dentro de una misma tabla
Se requeria identificar clientes que realizaron pedidos exactamente en el mismo dia y mes, pero en distintos años.
Esta situacion se resuelve mediante un patron de autocombinacion (Self-Join). Se instancian dos alias distintos para la misma tabla de pedidos. La condicion de cruce primaria asegura que se trate de pedidos diferentes correspondientes al mismo cliente. Luego, mediante funciones de extraccion temporal como MONTH() y DAY(), se exige una coincidencia exacta, mientras que con la funcion YEAR() se impone una diferencia obligatoria para cumplir con el salto interanual.

### Subconsultas correlacionadas para busqueda de maximos
Se solicito listar a cada proveedor junto a su producto de mayor costo.
Aunque es posible resolver esta necesidad estructurando tablas derivadas o CTEs (Common Table Expressions), la arquitectura elegida aplica una subconsulta correlacionada directamente en la condicion WHERE. Por cada fila de la consulta principal, la subconsulta calcula el precio maximo de la tabla productos filtrando especificamente por el identificador del proveedor iterado en ese momento. Esto garantiza que el producto devuelto pertenece de forma inequivoca a ese proveedor exacto y ostenta su valor tope.

### Preservacion de registros en cruces externos
El requerimiento demandaba mostrar un registro de clientes pertenecientes a un pais especifico, indicando el mes de su ultimo pedido en un año dado, o arrojando una cadena de texto indicando la ausencia de pedidos.
La dificultad arquitectonica principal recae en el comportamiento del cruce externo (LEFT JOIN). Si la restriccion limitante del año se ubica en la clausula WHERE principal, el cruce externo colapsa y se comporta como un cruce interno estricto, descartando a los clientes inactivos. La solucion tecnica implementada traslada la validacion de las fechas del pedido directamente al cuerpo de la condicion ON del cruce, permitiendo que la tabla base de clientes conserve su integridad, y delegando exclusivamente el filtro de localizacion geografica a la clausula WHERE.

### Estructuras condicionales y mitigacion del modo estricto de agrupacion
Para el reporte final, se debian desglosar las ventas mensuales de los representantes durante el ultimo año registrado en el historial del sistema.
Se desarrollo una instruccion de control de flujo CASE para traducir los valores numericos de los meses a cadenas de texto descriptivas legibles. Para definir dinamicamente el limite del "ultimo año", se recurrio a una subconsulta anidada que escanea y retorna el valor temporal maximo global.
El desafio mas riguroso de esta consulta se presento al lidiar con el modo estricto de agrupacion propio de MySQL (only_full_group_by). Al agrupar los resultados por el mes extraido, el analizador sintactico del motor rechaza el uso de la columna de fecha base dentro del bloque CASE argumentando dependencia funcional indefinida. Para mitigar esta incompatibilidad sin alterar la configuracion global del servidor, se encapsulo la extraccion del mes dentro de un agregador MAX(). Al estar operando ya sobre datos agrupados, este encapsulamiento no altera el valor real, pero legitima la operacion ante el motor, logrando que el agrupamiento sea sintacticamente valido y semanticamente preciso.

## Consideraciones de Entorno y Sintaxis

El codigo desarrollado es compatible en su nucleo con la sintaxis ANSI SQL estandar. No obstante, se debe contemplar la delimitacion de identificadores para tablas que poseen espacios en su nomenclatura:
- Para despliegues en Microsoft SQL Server se deben utilizar caracteres de corchete cerrado y abierto.
- Para despliegues en MySQL o MariaDB se deben implementar estrictamente caracteres de comilla invertida (backticks).
