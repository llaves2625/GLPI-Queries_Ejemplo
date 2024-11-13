#GLPI-TICKETS-CERRADOS-RESUELTOS
select distinct
case ticket.status 
	when 1 then 'nuevo' 
	when 2 then 'Asignado' 
    when 3 then 'Planificado'
    when 4 then 'Pendiente'
    when 5 then 'Resuelto'
    else 'cerrado'
    end as "Estatus",
    
case ticket.type
	when 1 then 'incidente'
    else 'solicitud'
    end as Tipo,   

case ticket.priority
	when 1 then 'Muy Baja' 
	when 2 then 'Baja' 
    when 3 then 'Media'
    when 4 then 'Alta'
    when 5 then 'Muy Alta'
    else 'Critica'
    end as "Prioridad",
ticketCategory.name Categoria,
ticket.id TicketID,
ticketCustomer.name Cliente,
ticket.date_mod "FModificacion",
ticket.date "FApertura",
left(ticket.name,100)Titulo,
find1.solicitante,
find2.observador,
find3.tecnico,
#left(ticket.content,100) Descr,
Tiempo.TiempoTotal Horas


FROM glpi_tickets ticket
	left join glpi_entities ticketCustomer 
		on ticket.entities_id = ticketCustomer.id
        
	left join glpi_itilcategories ticketCategory
		on ticket.itilcategories_id = ticketCategory.id
        
	#left join glpi_tickettasks task
	#	on ticket.id = task.tickets_id 
        
     left join ( select 
			B.tickets_id as id,
			GROUP_CONCAT(B.alternative_email  SEPARATOR ' + ') as 'solicitante'
		from
		  glpi_tickets_users B
			left join glpi_users C
				on B.users_id=C.id
				where B.type=1
			group by B.tickets_id
	) 
		find1 on ticket.id=find1.id
  
  	left join ( select 
			B.tickets_id as id,
			GROUP_CONCAT(B.alternative_email  SEPARATOR ' + ') as 'observador'
		from
		  glpi_tickets_users B
			left join glpi_users C
				on B.users_id=C.id
				where B.type=3
                group by B.tickets_id
	) 
		find2 on ticket.id=find2.id
    
	left join ( select 
			B.tickets_id as id,
			GROUP_CONCAT(B.alternative_email  SEPARATOR ' + ') as 'tecnico'
		from
		  glpi_tickets_users B
			left join glpi_users C
				on B.users_id=C.id
				where B.type=2
                group by B.tickets_id
	) 
		find3 on ticket.id=find3.id
	
    left join ( select 
					tkttask.tickets_id TicketId,
					sum(tkttask.actiontime) TiempoTotal
				from 
					glpi_tickettasks tkttask
				group by tkttask.tickets_id 
	) 
	Tiempo on ticket.id = Tiempo.TicketId
			
where ticket.status between 5 and 6
#where ticket.id = 427
#group by ticket.id
#order by ticketCustomer.name 
;