<sql:query var="r">
  SELECT (SELECT COUNT(*) FROM ideas WHERE estado = 'Pendiente') AS ideas_pend,
         (SELECT COUNT(*) FROM propuestas_estudiantes WHERE estado = 'Pendiente') AS prop_pend,
         (SELECT COUNT(*) FROM asignaciones_ideas WHERE estado = 'Pendiente_validacion') AS pagos_pend,
         (SELECT COUNT(DISTINCT trabajo_id) FROM entregas WHERE estado = 'En comite') AS comite_pend,
         (SELECT COUNT(*) FROM solicitudes WHERE estado = 'Pendiente') AS sol_pend,
         (SELECT COUNT(*) FROM trabajos_grado WHERE estado NOT IN ('Rechazado','Finalizado')) AS activos,
         (SELECT COUNT(*) FROM trabajos_grado t WHERE t.estado NOT IN ('Rechazado','Finalizado')
             AND NOT EXISTS (SELECT 1 FROM trabajo_docentes td WHERE td.trabajo_id = t.id AND td.funcion = 'Director')) AS sin_director,
         (SELECT COUNT(*) FROM trabajo_fases tf JOIN trabajos_grado t ON t.id = tf.trabajo_id
           WHERE tf.fase_id = 5 AND tf.estado IN ('En proceso','Aplazada') AND tf.fecha_limite < CURDATE()
             AND t.estado NOT IN ('Rechazado','Finalizado')) AS vencidos
</sql:query>
<sql:query var="porEstado">SELECT estado, COUNT(*) AS n FROM trabajos_grado GROUP BY estado ORDER BY n DESC</sql:query>
<sql:query var="vencidos">
  SELECT t.id, COALESCE(i.titulo, pe.titulo) AS titulo, tf.fecha_limite
    FROM trabajo_fases tf JOIN trabajos_grado t ON t.id = tf.trabajo_id
    JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
   WHERE tf.fase_id = 5 AND tf.estado IN ('En proceso','Aplazada') AND tf.fecha_limite < CURDATE() AND t.estado NOT IN ('Rechazado','Finalizado')
   ORDER BY tf.fecha_limite LIMIT 5
</sql:query>
<c:set var="d" value="${r.rows[0]}"/>
<div class="page-header"><h1>Panel de Coordinación / Comité</h1><p>Pendientes y estado general de los trabajos de grado.</p></div>
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3"><a class="stat-card ${d.ideas_pend gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=ideas/listar&estado=Pendiente"><div class="stat-icon"><i class="bi bi-lightbulb"></i></div><div><div class="stat-num">${d.ideas_pend}</div><div class="stat-label">Ideas por revisar</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.prop_pend gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=propuestas/listar&estado=Pendiente"><div class="stat-icon"><i class="bi bi-journal-text"></i></div><div><div class="stat-num">${d.prop_pend}</div><div class="stat-label">Propuestas por revisar</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.pagos_pend gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=asignaciones/pagos"><div class="stat-icon"><i class="bi bi-receipt"></i></div><div><div class="stat-num">${d.pagos_pend}</div><div class="stat-label">Pagos por validar</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.comite_pend gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=trabajos/listar"><div class="stat-icon"><i class="bi bi-patch-question"></i></div><div><div class="stat-num">${d.comite_pend}</div><div class="stat-label">Trabajos para decisión</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.sol_pend gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=solicitudes/listar&estado=Pendiente"><div class="stat-icon"><i class="bi bi-inbox"></i></div><div><div class="stat-num">${d.sol_pend}</div><div class="stat-label">Solicitudes pendientes</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card" href="${ctx}/panel.jsp?v=trabajos/listar"><div class="stat-icon"><i class="bi bi-mortarboard"></i></div><div><div class="stat-num">${d.activos}</div><div class="stat-label">Trabajos activos</div></div></a></div>
  <div class="col-6 col-lg-3"><a class="stat-card ${d.sin_director gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=trabajos/listar"><div class="stat-icon"><i class="bi bi-person-exclamation"></i></div><div><div class="stat-num">${d.sin_director}</div><div class="stat-label">Sin Director asignado</div></div></a></div>
  <div class="col-6 col-lg-3"><div class="stat-card ${d.vencidos gt 0 ? 'peligro' : ''}"><div class="stat-icon"><i class="bi bi-alarm"></i></div><div><div class="stat-num">${d.vencidos}</div><div class="stat-label">Plazos vencidos</div></div></div></div>
</div>
<div class="row g-3">
  <div class="col-lg-5"><div class="panel">
    <h2>Trabajos por estado</h2>
    <c:choose>
      <c:when test="${porEstado.rowCount eq 0}"><p class="text-muted mb-0">Aún no hay trabajos de grado.</p></c:when>
      <c:otherwise><table class="table table-sm mb-0"><tbody>
        <c:forEach var="f" items="${porEstado.rows}"><tr><td><span class="estado" data-estado="${f.estado}"><c:out value="${f.estado}"/></span></td><td class="text-end fw-semibold">${f.n}</td></tr></c:forEach>
      </tbody></table></c:otherwise>
    </c:choose>
  </div></div>
  <div class="col-lg-7"><div class="panel">
    <h2>Plazos vencidos del trabajo final</h2>
    <c:choose>
      <c:when test="${vencidos.rowCount eq 0}"><p class="text-muted mb-0">No hay trabajos con plazo vencido.</p></c:when>
      <c:otherwise><table class="table table-sm align-middle mb-0"><tbody>
        <c:forEach var="f" items="${vencidos.rows}"><tr>
          <td><a href="${ctx}/panel.jsp?v=trabajos/detalle&id=${f.id}"><c:out value="${f.titulo}"/></a></td>
          <td class="text-end text-danger">${fn:substring(f.fecha_limite, 8, 10)}/${fn:substring(f.fecha_limite, 5, 7)}/${fn:substring(f.fecha_limite, 0, 4)}</td>
        </tr></c:forEach>
      </tbody></table></c:otherwise>
    </c:choose>
  </div></div>
</div>
