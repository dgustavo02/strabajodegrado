<sql:query var="r">
  SELECT (SELECT COUNT(*) FROM ideas WHERE docente_id = ?) AS ideas,
         (SELECT COUNT(*) FROM ideas WHERE docente_id = ? AND estado = 'Pendiente') AS pendientes,
         (SELECT COUNT(*) FROM ideas WHERE docente_id = ? AND estado = 'Aprobada') AS en_banco,
         (SELECT COUNT(*) FROM ideas WHERE docente_id = ? AND estado = 'Asignada') AS asignadas,
         (SELECT COUNT(*) FROM trabajo_docentes td JOIN trabajos_grado t ON t.id = td.trabajo_id
           WHERE td.docente_id = ? AND t.estado NOT IN ('Rechazado','Finalizado')) AS trabajos,
         (SELECT COUNT(DISTINCT e.trabajo_id) FROM entregas e JOIN trabajo_docentes td ON td.trabajo_id = e.trabajo_id
           WHERE td.docente_id = ? AND td.funcion = 'Director' AND e.estado = 'Pendiente') AS por_dirigir,
         (SELECT COUNT(DISTINCT e.trabajo_id) FROM entregas e JOIN trabajo_docentes td ON td.trabajo_id = e.trabajo_id
           WHERE td.docente_id = ? AND td.funcion = 'Evaluador' AND e.estado = 'En revision') AS por_evaluar
  <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/>
  <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:set var="d" value="${r.rows[0]}"/>
<div class="page-header"><h1>Panel del docente</h1><p>Bienvenido, <c:out value="${sessionScope.usuarioNombre}"/>.</p></div>
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3"><a class="stat-card" href="${ctx}/panel.jsp?v=ideas/mis-ideas"><div class="stat-icon"><i class="bi bi-lightbulb"></i></div><div><div class="stat-num">${d.ideas}</div><div class="stat-label">Mis ideas</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.pendientes gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=ideas/mis-ideas"><div class="stat-icon"><i class="bi bi-hourglass-split"></i></div><div><div class="stat-num">${d.pendientes}</div><div class="stat-label">Pendientes de revisión</div></div></a></div>
  <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-collection"></i></div><div><div class="stat-num">${d.en_banco}</div><div class="stat-label">Disponibles en el banco</div></div></div></div>
  <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-person-check"></i></div><div><div class="stat-num">${d.asignadas}</div><div class="stat-label">Ideas asignadas</div></div></div></div>
  <div class="col-6 col-lg-4"><a class="stat-card" href="${ctx}/panel.jsp?v=trabajos/asignados"><div class="stat-icon"><i class="bi bi-mortarboard"></i></div><div><div class="stat-num">${d.trabajos}</div><div class="stat-label">Trabajos asignados activos</div></div></a></div>
  <div class="col-6 col-lg-4"><a class="stat-card ${d.por_dirigir gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=director/revisiones"><div class="stat-icon"><i class="bi bi-person-check"></i></div><div><div class="stat-num">${d.por_dirigir}</div><div class="stat-label">Por revisar como Director</div></div></a></div>
  <div class="col-6 col-lg-4"><a class="stat-card ${d.por_evaluar gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=evaluador/proyectos"><div class="stat-icon"><i class="bi bi-clipboard-check"></i></div><div><div class="stat-num">${d.por_evaluar}</div><div class="stat-label">Por evaluar como Evaluador</div></div></a></div>
</div>
<div class="panel"><h2>Accesos rápidos</h2>
  <a class="btn btn-primary" href="${ctx}/panel.jsp?v=ideas/crear"><i class="bi bi-plus-circle"></i> Proponer una idea</a>
  <a class="btn btn-outline-secondary ms-2" href="${ctx}/panel.jsp?v=historial"><i class="bi bi-clock-history"></i> Ver historial</a>
</div>
