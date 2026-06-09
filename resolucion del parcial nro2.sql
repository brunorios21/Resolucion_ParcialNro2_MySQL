-- 1 ¿Qué clientes compraron productos que son suministrados por proveedores que residen en la misma región que ellos? 
-- Mostrar ID, Nombre de la empresa, nombre del contacto y región. 
-- Incluir en el resultado aquellos cuya región es NULL si la región del proveedor también es NULL. 
-- Ordenar por región.

-- Este ejercicio es parecido al de la practica Q45
select distinct c.IDCliente, c.NombreEmpresa, c.NombreContacto, c.Region
from clientes C
join Pedidos P on c.IDCliente = p.IDCliente
join `Detalles Pedido` DP on p.IDPedido = DP.IDPedido
join Productos PR on DP.IDProducto = PR.IDProducto
join Proveedores PV on PR.IDProveedor = PV.IDProveedor
-- La condición agrupa el caso de igualdad normal y el caso donde AMBOS son nulos [cite: 405]
where (c.Region = PV.Region or (c.Region is null and PV.Region is null ))
order by c.Region;
-- 2. Calcular el total solicitado (en cantidades, y en importe total) en 2020,
-- agrupado por categoría de producto (mostrar el nombre de la categoría).
-- Calcular el importe total multiplicando Cantidad por el precio unitario
select c.NombreCategoria,
	sum(dp.cantidad) as cantidad,
    sum(dp.cantidad * dp.PrecioUnitario) as importeTotal
from categorias c
join Productos p on c.IDCategoria = p.IDCategoria
join `detalles pedido` dp on p.IDProducto = dp.IDProducto
join pedidos pd on dp.IDPedido = pd.IDPedido
where pd.FechaPedido >= '20200101' and pd.FechaPedido < '20210101'
group by c.NombreCategoria;

-- 3. Listar los clientes (ID y Nombre) que hayan realizado pedidos en la misma fecha, pero en diferentes años.

select distinct c.IDCliente, c.NombreEmpresa
from clientes c
join pedidos p1 on c.IDCliente = p1.IDCliente
join pedidos p2 on c.IDCliente = p2.IDCliente
-- Verificamos que no este comparando el mismo pedido exacto
where p1.IDPedido <> p2.IDPedido
	-- Comparamos que coincidan en mes y dia
    and month (p1.FechaPedido) = month(p2.FechaPedido)
	and day (p1.FechaPedido) = day(p2.FechaPedido)
    -- Aseguramos que los años sean diferentes
    and year (p1.FechaPedido) <> year (p2.FechaPedido);

-- 4. Listar los proveedores junto con el producto más caro que suministran.
-- Mostrar ID del proveedor, nombre de la empresa y nombre del producto.
-- Ordenar por nombre de producto
select pv.IDProveedor, pv.NombreEmpresa, p.IDProducto, P.NombreProducto
from proveedores pv
join productos p on pv.IDProveedor = p.IDProveedor
-- comparamos el precio del producto actual con el precio maximo
where p.PrecioUnitario = (
	-- obtenido en esta subconsulta
    select max(p2.PrecioUnitario)
    from productos p2
    
    where p2.IDProveedor = pv.IDProveedor
)
order by pv.NombreEmpresa;

-- 5. Listar los clientes de Francia que realizaron pedidos durante el año 2021.
-- Tener en cuenta que se deben mostrar TODOS los clientes de Francia. 
-- Para los que hayan realizado pedidos durante el año 2021, 
-- se deberá mostrar el último mes en el que realizaron un pedido, indicando el nombre del mes.
-- Para los que no realizaron pedidos en el año 2021 se deberá mostrar "Sin Pedidos". 
-- Los resultados deberán estar ordenados por el nombre de la empresa cliente.
select c.NombreEmpresa,
	case max(month (p.FechaPedido))
		when 1 then  'enero'
        when 2 then 'febrero'
        when 3 then 'marzo'
        when 4 then 'abril'
        when 5 then 'mayo'
        when 6 then 'junio'
        when 7 then 'julio'
        when 8 then 'agosto'
        when 9 then 'septiembre'
        when 10 then 'noviembre'
        when 11 then 'diciembre'
        else 'sin pedidos'
	end as MesUltimaOrden
from Clientes as c
left join Pedidos as p on c.IDCliente = p.IDCliente
	and p.FechaPedido >= '20210101' and p.FechaPedido < '20220101'
where c.pais = 'Francia'
group by  c.NombreEmpresa
order by c.NombreEmpresa;
    
-- 6. Realizar un reporte de las ventas realizadas por los representantes de ventas durante el ultimo año
-- en que se registraron ventas en la base. los totales de ventas deberan estar agrupadas y mostradas por mes
-- en orden cronologico. Los empleados deberan mostrar ordenados por apellido y luego por nombre.
-- las columnas a mostrar son: Nombre, Apellido, mes VentasTotales.
select e.Nombre, e.Apellido,
    -- EL TRUCO DEL PROFE! Le agregamos MAX() acá para engañar al modo estricto de MySQL
	Case MAX(month(p.FechaPedido))
		when 1 then 'Enero' when 2 then 'Febrero' when 3 then 'Marzo'
        when 4 then 'Abril' when 5 then 'Mayo' when 6 then 'Junio'
        when 7 then 'Julio' when 8 then 'Agosto' when 9 then 'Septiembre'
		when 10 then 'Octubre' when 11 then 'Noviembre' when 12 then 'Diciembre'
        end as mes,
        sum(dp.Cantidad * dp.PrecioUnitario * (1 - dp.Descuento)) as VentasTotales
from Empleados e
join Pedidos p on e.IDEmpleado = p.IDEmpleado 
join `Detalles Pedido` dp on p.IDPedido = dp.IDPedido
where e.Puesto = 'Representante de ventas'
	and year(p.FechaPedido) = (select max(year(p2.FechaPedido)) from Pedidos p2)
group by e.Nombre, e.Apellido, month(p.FechaPedido)
order by e.Apellido, e.Nombre, month(p.FechaPedido);