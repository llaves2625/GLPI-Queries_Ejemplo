#########################################
#GLPI-CONTROLDEHORAS
#########################################
select 
tkt.id TicketID,
task.id TaskID,
task.date_creation TareasFecha,
ticketCustomer.name Cliente,
concat(user.realname," ",user.firstname,"(",user.name,")" ) Tecnico,
taskcat.completename Categoria,
category.name Servicio,
sum(task.actiontime) Segundos
from
glpi_tickettasks task
   left join glpi_tickets tkt 
		on task.tickets_id = tkt.id 
   left join glpi_tickets ticket 
		on task.tickets_id = ticket.id 
   left join glpi_entities ticketCustomer 
		on ticket.entities_id = ticketCustomer.id
   left join glpi_users user 
		on task.users_id = user.id
   left join glpi_taskcategories taskcat 
		on task.taskcategories_id = taskcat.id
   left join glpi_itilcategories category
		on ticket.itilcategories_id = category.id
group by task.id
;