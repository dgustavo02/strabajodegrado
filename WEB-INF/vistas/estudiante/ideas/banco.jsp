<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="q" value="${fn:trim(param.q)}"/>
<c:set var="modF" value="${fn:trim(param.modalidad)}"/>
<c:set var="condBanco">
  i.estado = 'Aprobada'
  AND NOT EXISTS (SELECT 1 FROM asignaciones_ideas ai WHERE ai.idea_id = i.id AND ai.estado IN ('Pendiente_validacion','Validada'))
  AND (? = '' OR i.modalidad = ?)
  AND (? = '' OR i.titulo LIKE CONCAT('%', ?, '%') OR i.descripcion LIKE CONCAT('%', ?, '%') OR u.nombre LIKE CONCAT('%', ?, '%'))
</c:set>
<sql:query var="tot">
  SELECT COUNT(*) AS n FROM ideas i JOIN users u ON u.id = i.docente_id WHERE ${condBanco}
  <sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
</sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT i.id, i.titulo, i.modalidad, LEFT(i.descripcion, 200) AS resumen, u.nombre AS docente
    FROM ideas i JOIN users u ON u.id = i.docente_id WHERE ${condBanco}
   ORDER BY i.fecha_decision DESC, i.id DESC LIMIT ? OFFSET ?
  <sql:param value="${modF}"/><sql:param value="${modF}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/><sql:param value="${q}"/>
  <sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Banco de ideas</h1><p>${totalFilas} idea(s) disponible(s). Elige una para solicitarla.</p></div>
<div class="panel">
  <form class="row g-2" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="ideas/banco">
    <div class="col-md-6"><input class="form-control" type="search" name="q" value="<c:out value='${q}'/>" placeholder="Buscar por título, descripción o docente"></div>
    <div class="col-md-4"><select class="form-select" name="modalidad">
      <option value="">Todas las modalidades</option>
      <c:forTokens var="m" items="Desarrollo tecnologico,Emprendimiento,Monografia,Proyecto de investigacion" delims=","><option value="${m}" ${modF eq m ? 'selected' : ''}>${m}</option></c:forTokens>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-search"></i> Buscar</button></div>
  </form>
</div>
<div class="row g-3 mb-3">
  <c:forEach var="i" items="${lista.rows}">
    <div class="col-md-6 col-xl-4"><div class="panel h-100 mb-0 d-flex flex-column">
      <span class="small text-muted"><c:out value="${i.modalidad}"/></span>
      <h2 class="h6 mt-1"><c:out value="${i.titulo}"/></h2>
      <p class="small text-muted flex-grow-1"><c:out value="${i.resumen}"/>…</p>
      <div class="d-flex justify-content-between align-items-center"><small class="text-muted"><i class="bi bi-person"></i> <c:out value="${i.docente}"/></small>
        <a class="btn btn-sm btn-primary" href="${ctx}/panel.jsp?v=ideas/detalle&id=${i.id}">Ver idea</a></div>
    </div></div>
  </c:forEach>
  <c:if test="${lista.rowCount eq 0}"><div class="col-12"><div class="panel text-center text-muted mb-0">No hay ideas disponibles con esos filtros.</div></div></c:if>
</div>
<c:set var="baseV" value="ideas/banco"/>
<%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
