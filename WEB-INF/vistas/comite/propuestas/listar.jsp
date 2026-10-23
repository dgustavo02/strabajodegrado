<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<c:set var="modF" value="${fn:trim(param.modalidad)}"/>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM propuestas_estudiantes p JOIN users u ON u.id = p.estudiante_id
   WHERE (? = '' OR p.estado = ?) AND (? = '' OR p.modalidad = ?) AND (? = '' OR p.titulo LIKE CONCAT('%', ?, '%') OR u.nombre LIKE CONCAT('%', ?, '%') OR u.documento LIKE CONCAT('%', ?, '%'))
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT p.id, p.titulo, p.modalidad, p.estado, p.fecha_propuesta, u.nombre AS estudiante, u.documento
    FROM propuestas_estudiantes p JOIN users u ON u.id = p.estudiante_id
   WHERE (? = '' OR p.estado = ?) AND (? = '' OR p.modalidad = ?) AND (? = '' OR p.titulo LIKE CONCAT('%', ?, '%') OR u.nombre LIKE CONCAT('%', ?, '%') OR u.documento LIKE CONCAT('%', ?, '%'))
   ORDER BY (p.estado = 'Pendiente') DESC, p.fecha_propuesta DESC LIMIT ? OFFSET ?
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Propuestas de estudiantes</h1><p>${totalFilas} resultado(s). Estas propuestas nunca pasan al banco de ideas.</p></div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="propuestas/listar">
    <div class="col-md-4"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Buscar por título, estudiante o documento"></div>
    <div class="col-md-3"><select class="form-select" name="estado">
      <option value="">Todos los estados</option>
      <c:forTokens var="e" items="Pendiente,Aprobada,Rechazada" delims=","><option value="${e}" ${estF eq e ? 'selected' : ''}>${e}</option></c:forTokens>
    </select></div>
    <div class="col-md-3"><select class="form-select" name="modalidad">
      <option value="">Todas las modalidades</option>
      <c:forTokens var="m" items="Desarrollo tecnologico,Emprendimiento,Monografia,Proyecto de investigacion" delims=","><option value="${m}" ${modF eq m ? 'selected' : ''}>${m}</option></c:forTokens>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Filtrar</button></div>
  </form>
  <div class="table-responsive"><table class="table table-hover align-middle mb-3">
    <thead><tr><th>Propuesta</th><th>Estudiante</th><th>Modalidad</th><th>Fecha</th><th>Estado</th><th></th></tr></thead>
    <tbody>
      <c:forEach var="p" items="${lista.rows}"><tr>
        <td><c:out value="${p.titulo}"/></td><td><c:out value="${p.estudiante}"/><br><small class="text-muted"><c:out value="${p.documento}"/></small></td><td><c:out value="${p.modalidad}"/></td>
        <td>${fn:substring(p.fecha_propuesta, 8, 10)}/${fn:substring(p.fecha_propuesta, 5, 7)}/${fn:substring(p.fecha_propuesta, 0, 4)}</td>
        <td><span class="estado" data-estado="${p.estado}">${p.estado}</span></td>
        <td class="text-end"><a class="btn btn-sm ${p.estado eq 'Pendiente' ? 'btn-primary' : 'btn-outline-secondary'}" href="${ctx}/panel.jsp?v=propuestas/revisar&id=${p.id}">${p.estado eq 'Pendiente' ? 'Revisar' : 'Ver'}</a></td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="6" class="text-center text-muted py-4">No hay propuestas con esos filtros.</td></tr></c:if>
    </tbody></table></div>
  <c:set var="baseV" value="propuestas/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
