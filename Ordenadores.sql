#################################
#---GLPI-COMPUTADORAS v0.6
#################################
select 
device.id ID,
device.name "Hostname",
findDomains.domain "Domino",
device.contact "Asignado",
customer.name "Cliente",
states.name "Estado",
device.serial "Numero_de_Serie",
deviceVendor.name "Fabricante",
findOs.Tipo "Categoria",
deviceType.name "Tipo",
deviceModel.name "Modelo",
findOs.OsName "Sistema_Operativo_Nombre",
deviceAgent.last_contact "Agente_ultima_conexion",
location.completename Lugar,
findCPU.Modelo "Componentes_Procesador", 
deviceAgent.tag "Agente_Etiqueta",
findOs.OsVersionID "Sistema_Operativo_Version",
findOs.OsLicOsProdId "Id_Licencia/Id_Producto",
findDisks.Disks "Discos",
deviceAgent.version "Agente_Version",
GROUP_CONCAT(CONCAT('(Fabricante:', av.name, '/Vencimiento:', COALESCE(av.date_expiration, 'Sin Expiración'), ')') SEPARATOR ', ') AS "Antivirus",
findFirmware.name "Componentes_Firmware",
findFirmware.version "Componentes_Firmware_Version",
findFirmware.ReleaseDate "Componentes_Firmware_Fabricacion",
findMemory.MemoryType "Componentes_Tipo_de_memoria",
findMemory.TotalMemory "Componentes_Total_de_memoria",
deviceAgent.remote_addr "Agent_IP_Remota",
device.last_inventory_update "Agente_Ultima_Modif_Inventario",
device.last_boot "PC_Ultimo_Reinicio"






from glpi_computers device

left join glpi_entities customer on device.entities_id = customer.id
		
left join glpi_computertypes deviceType on device.computertypes_id = deviceType.id

left join glpi_computermodels deviceModel on device.computerModels_id = deviceModel.id

left join glpi_manufacturers deviceVendor on device.manufacturers_id = deviceVendor.id

left join glpi_agents deviceAgent on device.id = deviceAgent.items_id

left join glpi_locations location on device.locations_id = location.id

left join glpi_states states on device.states_id = states.id

left join glpi_computerantiviruses av on device.id = av.computers_id


left join ( select 
				B.id as id,
				D.name as domain
	
				from glpi_computers B

				left join glpi_domains_items C on B.id = C.items_id
				left join glpi_domains D on C.domains_id = D.id
				where C.is_deleted = "0"
			) 
		findDomains on device.id=findDomains.id
	
left join ( select 
			B.id as id,
			GROUP_CONCAT(DISTINCT D.name SEPARATOR ', ') as OsName,
		    C.itemtype as Tipo,
			GROUP_CONCAT(CONCAT('(', C.license_number, '/', C.licenseid, ')') SEPARATOR ', ') as OsLicOsProdId,
            GROUP_CONCAT(E.name SEPARATOR ', ') as OsVersionID
           		
			from glpi_computers B
		  
		    left join glpi_items_operatingsystems C on B.id=C.items_id
		  	left join glpi_operatingsystems D on C.operatingsystems_id=D.id
		  	  left join glpi_operatingsystemversions E on C.operatingsystemversions_id=E.id
		  	
		  	where C.itemtype = "Computer"
		  	  group by B.id
	

             ) 
		findOs on device.id=findOs.id
	
left join ( select 
			B.id as id,
			C.itemtype Tipo,
			  GROUP_CONCAT( DISTINCT D.designation SEPARATOR ', ') Modelo
			
			from glpi_computers B
		  
		    left join glpi_items_deviceprocessors C on B.id=C.items_id
		      left join glpi_deviceprocessors D on C.deviceprocessors_id=D.id

		  	
		  	  where C.itemtype = "Computer"
		  	  group by B.id

             ) 
		findCPU on device.id=findCPU.id
		

left join ( select 
			B.id as id,
        GROUP_CONCAT(
            CONCAT(
                C.mountpoint,
                '(', 
                'Libre: ', -- Agrega "Libre:" delante de C.freesize
                IF(C.freesize >= 1048576, -- Convierte a TiB si es igual o mayor a 1024 GiB
                   CONCAT(ROUND(C.freesize / 1048576, 2), ' TiB'),
                   IF(C.freesize >= 1024, -- Convierte a GiB si es igual o mayor a 1024 MiB
                      CONCAT(ROUND(C.freesize / 1024, 2), ' GiB'),
                      CONCAT(ROUND(C.freesize, 2), ' MiB')
                   )
                ), ' / ',
                'Total: ', -- Agrega "Total:" delante de C.totalsize
                IF(C.totalsize >= 1048576, -- Convierte a TiB si es igual o mayor a 1024 GiB
                   CONCAT(ROUND(C.totalsize / 1048576, 2), ' TiB'),
                   IF(C.totalsize >= 1024, -- Convierte a GiB si es igual o mayor a 1024 MiB
                      CONCAT(ROUND(C.totalsize / 1024, 2), ' GiB'),
                      CONCAT(ROUND(C.totalsize, 2), ' MiB')
                   )
                ), ')'
            ) SEPARATOR ', '
        ) AS Disks            	
			from glpi_computers B
		  
		    left join glpi_items_disks C on B.id=C.items_id

		  	
		  	 where C.itemtype = "Computer"
		  	   group by B.id

             ) 
		findDisks on device.id=findDisks.id	


left join ( select 
			B.id as id,
			  C.itemtype Tipo,
			E.name,
			  D.version,
			  D.date as ReleaseDate
			
			from glpi_computers B
		  
		    left join glpi_items_devicefirmwares C on B.id=C.items_id
		    left join glpi_devicefirmwares D on C.devicefirmwares_id=D.id
		     left join glpi_manufacturers E on D.manufacturers_id=E.id

		  	
		  	  where C.itemtype = "Computer"
		  	  #group by B.id

             ) 
		findFirmware on device.id=findFirmware.id
		

left join ( select 
			B.id as id,
			C.itemtype Tipo,
			GROUP_CONCAT(DISTINCT  E.name SEPARATOR ', ') as MemoryType,
			  #GROUP_CONCAT(C.size SEPARATOR ', ') as TotalMemory
			  IF(SUM(C.size) >= 1024, 
           CONCAT(ROUND(SUM(C.size) / 1024, 2), ' GB'), 
           CONCAT(SUM(C.size), ' MB')
        ) AS TotalMemory -- Condicional para mostrar GB o MB
			
			from glpi_computers B
		  
		    left join glpi_items_devicememories C on B.id=C.items_id
		    left join glpi_devicememories D on C.devicememories_id=D.id
		    left join glpi_devicememorytypes E on D.devicememorytypes_id=E.id

		  	
		  	  where C.itemtype = "Computer"
		  	  group by B.id

             ) 
		findMemory on device.id=findMemory.id

#where device.name = 'PC-UV'

		
GROUP BY 
    device.id,
    customer.name,
    device.name,
    device.serial,
    device.contact,
    states.name,
    findOs.Tipo,
    findOs.OsName,
    findOs.OsVersionID,
    findOs.OsLicOsProdId,
    findDomains.domain,
    findCPU.Modelo,
    findDisks.Disks,
    deviceAgent.remote_addr,
    deviceAgent.tag,
    deviceAgent.version,
    deviceAgent.last_contact,
    deviceType.name,
    deviceVendor.name,
    deviceModel.name,
    location.completename,
    device.last_inventory_update,
    device.last_boot,
    findFirmware.name,
	findFirmware.version,
	findFirmware.ReleaseDate,
	findMemory.MemoryType,
   findMemory.TotalMemory
	
;	