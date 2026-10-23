<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<c:set var="modF" value="${fn:trim(param.modalidad)}"/>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM ideas i JOIN users u ON u.id = i.docente_id
   WHERE (? = '' OR i.estado = ?) AND (? = '' OR i.modalidad = ?) AND (? = '' OR i.titulo LIKE CONCAT('%', ?, '%') OR u.nombre LIKE CONCAT('%', ?, '%'))
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT i.id, i.titulo, i.modalidad, i.estado, i.fecha_propuesta, u.nombre AS docente
    FROM ideas i JOIN users u ON u.id = i.docente_id
   WHERE (? = '' OR i.estado = ?) AND (? = '' OR i.modalidad = ?) AND (? = '' OR i.titulo LIKE CONCAT('%', ?, '%') OR u.nombre LIKE CONCAT('%', ?, '%'))
   ORDER BY (i.estado = 'Pendiente') DESC, i.fecha_propuesta DESC LIMIT ? OFFSET ?
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Ideas propuestas por docentes</h1><p>${totalFilas} resultado(s). Las ideas aprobadas pasan al banco de ideas.</p></div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="ideas/listar">
    <div class="col-md-4"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Buscar por título o docente"></div>
    <div class="col-md-3"><select class="form-select" name="estado">
      <option value="">Todos los estados</option>
      <c:forTokens var="e" items="Pendiente,Aprobada,Rechazada,Asignada" delims=","><option value="${e}" ${estF eq e ? 'selected' : ''}>${e}</option></c:forTokens>
    </select></div>
    <div class="col-md-3"><select class="form-select" name="modalidad">
      <option value="">Todas las modalidades</option>
      <c:forTokens var="m" items="Desarrollo tecnologico,Emprendimiento,Monografia,Proyecto de investigacion" delims=","><option value="${m}" ${modF eq m ? 'selected' : ''}>${m}</option></c:forTokens>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Filtrar</button></div>
  </form>
  <div class="table-responsive"><table class="table table-hover align-middle mb-3">
    <thead><tr><th>Idea</th><th>Docente</th><th>Modalidad</th><th>Propuesta</th><th>Estado</th><th></th></tr></thead>
    <tbody>
      <c:forEach var="i" items="${lista.rows}"><tr>
        <td><c:out value="${i.titulo}"/></td><td><c:out value="${i.docente}"/></td><td><c:out value="${i.modalidad}"/></td>
        <td>${fn:substring(i.fecha_propuesta, 8, 10)}/${fn:substring(i.fecha_propuesta, 5, 7)}/${fn:substring(i.fecha_propuesta, 0, 4)}</td>
        <td><span class="estado" data-estado="${i.estado}">${i.estado}</span></td>
        <td class="text-end"><a class="btn btn-sm ${i.estado eq 'Pendiente' ? 'btn-primary' : 'btn-outline-secondary'}" href="${ctx}/panel.jsp?v=ideas/revisar&id=${i.id}">${i.estado eq 'Pendiente' ? 'Revisar' : 'Ver'}</a></td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="6" class="text-center text-muted py-4">No hay ideas con esos filtros.</td></tr></c:if>
    </tbody></table></div>
  <c:set var="baseV" value="ideas/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
