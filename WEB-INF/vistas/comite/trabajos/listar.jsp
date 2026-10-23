<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<c:set var="fasF" value="${fn:trim(param.fase)}"/>
<c:set var="cond">
  (? = '' OR COALESCE(i.titulo, pe.titulo) LIKE CONCAT('%', ?, '%')
     OR EXISTS (SELECT 1 FROM users s WHERE s.id = ai.estudiante_id AND (s.nombre LIKE CONCAT('%', ?, '%') OR s.documento LIKE CONCAT('%', ?, '%')))
     OR EXISTS (SELECT 1 FROM trabajo_estudiantes te2 JOIN users s2 ON s2.id = te2.estudiante_id WHERE te2.trabajo_id = t.id AND (s2.nombre LIKE CONCAT('%', ?, '%') OR s2.documento LIKE CONCAT('%', ?, '%')))
     OR EXISTS (SELECT 1 FROM trabajo_docentes td2 JOIN users d2 ON d2.id = td2.docente_id WHERE td2.trabajo_id = t.id AND d2.nombre LIKE CONCAT('%', ?, '%')))
  AND (? = '' OR t.estado = ?) AND (? = '' OR t.fase_actual_id = ?)
</c:set>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM trabajos_grado t JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
   WHERE ${cond}
  <sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${fasF}"/><sql:param value="${fasF}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT t.id, t.estado, f.nombre AS fase, COALESCE(i.titulo, pe.titulo) AS titulo, COALESCE(i.modalidad, pe.modalidad) AS modalidad,
         sol.nombre AS solicitante,
         (SELECT GROUP_CONCAT(u.nombre SEPARATOR ', ') FROM trabajo_estudiantes te JOIN users u ON u.id = te.estudiante_id WHERE te.trabajo_id = t.id) AS estudiantes,
         (SELECT u.nombre FROM trabajo_docentes td JOIN users u ON u.id = td.docente_id WHERE td.trabajo_id = t.id AND td.funcion = 'Director') AS director,
         (SELECT u.nombre FROM trabajo_docentes td JOIN users u ON u.id = td.docente_id WHERE td.trabajo_id = t.id AND td.funcion = 'Evaluador') AS evaluador,
         (SELECT COUNT(*) FROM entregas e WHERE e.trabajo_id = t.id AND e.estado = 'En comite') AS en_comite
    FROM trabajos_grado t JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id JOIN users sol ON sol.id = ai.estudiante_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
    LEFT JOIN fases f ON f.id = t.fase_actual_id
   WHERE ${cond}
   ORDER BY (en_comite > 0) DESC, t.updated_at DESC LIMIT ? OFFSET ?
  <sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${fasF}"/><sql:param value="${fasF}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Trabajos de grado</h1><p>${totalFilas} resultado(s). Busca por estudiante, Director, Evaluador o título.</p></div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="trabajos/listar">
    <div class="col-md-4"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Estudiante, documento, docente o título"></div>
    <div class="col-md-3"><select class="form-select" name="estado">
      <option value="">Todos los estados</option>
      <c:forTokens var="e" items="Pendiente,En revision,Aprobado,Aplazado,Rechazado,Finalizado" delims=","><option value="${e}" ${estF eq e ? 'selected' : ''}>${e}</option></c:forTokens>
    </select></div>
    <div class="col-md-3"><select class="form-select" name="fase">
      <option value="">Todas las fases</option>
      <option value="2" ${fasF eq '2' ? 'selected' : ''}>Idea y asignación</option>
      <option value="3" ${fasF eq '3' ? 'selected' : ''}>Anteproyecto</option>
      <option value="4" ${fasF eq '4' ? 'selected' : ''}>Evaluación y Comité</option>
      <option value="5" ${fasF eq '5' ? 'selected' : ''}>Trabajo final</option>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Filtrar</button></div>
  </form>
  <div class="table-responsive"><table class="table table-hover align-middle mb-3">
    <thead><tr><th>Trabajo</th><th>Estudiante(s)</th><th>Director</th><th>Evaluador</th><th>Fase</th><th>Estado</th><th></th></tr></thead>
    <tbody>
      <c:forEach var="t" items="${lista.rows}"><tr>
        <td><c:out value="${t.titulo}"/><br><small class="text-muted"><c:out value="${t.modalidad}"/></small></td>
        <td><c:out value="${empty t.estudiantes ? t.solicitante : t.estudiantes}"/></td>
        <td><c:out value="${empty t.director ? '—' : t.director}"/></td>
        <td><c:out value="${empty t.evaluador ? '—' : t.evaluador}"/></td>
        <td><c:out value="${empty t.fase ? '—' : t.fase}"/></td>
        <td><span class="estado" data-estado="${t.estado}">${t.estado}</span><c:if test="${t.en_comite gt 0}"> <span class="estado" data-estado="En comite">Para decisión</span></c:if></td>
        <td class="text-end"><a class="btn btn-sm btn-outline-secondary" href="${ctx}/panel.jsp?v=trabajos/detalle&id=${t.id}">Ver</a></td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="7" class="text-center text-muted py-4">No hay trabajos con esos filtros.</td></tr></c:if>
    </tbody></table></div>
  <c:set var="baseV" value="trabajos/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
