<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM actas a WHERE (? = '' OR a.decision = ?) AND (? = '' OR a.observaciones LIKE CONCAT('%', ?, '%') OR a.tipo LIKE CONCAT('%', ?, '%'))
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT a.id, a.tipo, a.decision, a.observaciones, a.fecha_acta, a.trabajo_id, u.nombre AS comite,
         COALESCE(i.titulo, pe.titulo,
                  (SELECT COALESCE(i2.titulo, pe2.titulo) FROM trabajos_grado t2 JOIN asignaciones_ideas ai2 ON ai2.id = t2.asignacion_idea_id
                     LEFT JOIN ideas i2 ON i2.id = ai2.idea_id LEFT JOIN propuestas_estudiantes pe2 ON pe2.id = ai2.propuesta_estudiante_id WHERE t2.id = a.trabajo_id)) AS asunto
    FROM actas a JOIN users u ON u.id = a.usuario_comite_id
    LEFT JOIN ideas i ON i.id = a.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = a.propuesta_estudiante_id
   WHERE (? = '' OR a.decision = ?) AND (? = '' OR a.observaciones LIKE CONCAT('%', ?, '%') OR a.tipo LIKE CONCAT('%', ?, '%'))
   ORDER BY a.id DESC LIMIT ? OFFSET ?
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Actas del Comité</h1><p>${totalFilas} decisión(es) registrada(s). Cada decisión sobre ideas, propuestas y trabajos genera un acta.</p></div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="actas/listar">
    <div class="col-md-5"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Buscar en tipo u observaciones"></div>
    <div class="col-md-3"><select class="form-select" name="estado">
      <option value="">Todas las decisiones</option>
      <c:forTokens var="e" items="Aprobada,Aplazada,Rechazada" delims=","><option value="${e}" ${estF eq e ? 'selected' : ''}>${e}</option></c:forTokens>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Filtrar</button></div>
  </form>
  <div class="table-responsive"><table class="table table-hover align-middle mb-3">
    <thead><tr><th>N.º</th><th>Tipo</th><th>Asunto</th><th>Decisión</th><th>Observaciones</th><th>Registró</th><th>Fecha</th></tr></thead>
    <tbody>
      <c:forEach var="a" items="${lista.rows}"><tr>
        <td>${a.id}</td><td><c:out value="${a.tipo}"/></td>
        <td><c:choose><c:when test="${not empty a.trabajo_id}"><a href="${ctx}/panel.jsp?v=trabajos/detalle&id=${a.trabajo_id}"><c:out value="${a.asunto}"/></a></c:when><c:otherwise><c:out value="${a.asunto}"/></c:otherwise></c:choose></td>
        <td><span class="estado" data-estado="${a.decision}">${a.decision}</span></td>
        <td class="texto-largo small"><c:out value="${a.observaciones}"/></td><td><c:out value="${a.comite}"/></td>
        <td>${fn:substring(a.fecha_acta, 8, 10)}/${fn:substring(a.fecha_acta, 5, 7)}/${fn:substring(a.fecha_acta, 0, 4)}</td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="7" class="text-center text-muted py-4">No hay actas.</td></tr></c:if>
    </tbody></table></div>
  <c:set var="baseV" value="actas/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
