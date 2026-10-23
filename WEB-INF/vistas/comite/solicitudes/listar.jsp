<%@ include file="/WEB-INF/vistas/comunes/paginacion.jspf" %>
<c:set var="estF" value="${fn:trim(param.estado)}"/>
<sql:query var="tot">SELECT COUNT(*) AS n FROM solicitudes WHERE (? = '' OR estado = ?)<sql:param value="${estF}"/><sql:param value="${estF}"/></sql:query>
<c:set var="totalFilas" value="${tot.rows[0].n}"/>
<sql:query var="lista">
  SELECT s.id, s.tipo, s.descripcion, s.url, s.estado, s.respuesta, s.fecha_solicitud, s.fecha_respuesta, s.trabajo_id, u.nombre AS solicitante,
         (SELECT COALESCE(i.titulo, pe.titulo) FROM trabajos_grado t JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
            LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id WHERE t.id = s.trabajo_id) AS trabajo
    FROM solicitudes s JOIN users u ON u.id = s.usuario_id
   WHERE (? = '' OR s.estado = ?)
   ORDER BY (s.estado = 'Pendiente') DESC, s.fecha_solicitud DESC LIMIT ? OFFSET ?
  <sql:param value="${estF}"/><sql:param value="${estF}"/><sql:param value="${porPag}"/><sql:param value="${offset}"/>
</sql:query>
<div class="page-header"><h1>Solicitudes</h1><p>${totalFilas} resultado(s). Las aprobaciones de cambio de Director o de proyecto se ejecutan desde el trabajo correspondiente.</p></div>
<div class="panel">
  <form class="row g-2 mb-3" method="get" action="${ctx}/panel.jsp">
    <input type="hidden" name="v" value="solicitudes/listar">
    <div class="col-md-4"><select class="form-select" name="estado">
      <option value="">Todas</option>
      <c:forTokens var="e" items="Pendiente,Aprobada,Rechazada" delims=","><option value="${e}" ${estF eq e ? 'selected' : ''}>${e}</option></c:forTokens>
    </select></div>
    <div class="col-md-2 d-grid"><button class="btn btn-outline-primary" type="submit"><i class="bi bi-funnel"></i> Filtrar</button></div>
  </form>
  <c:forEach var="s" items="${lista.rows}">
    <div class="border rounded p-3 mb-3">
      <div class="d-flex flex-wrap justify-content-between gap-2">
        <div><strong><c:out value="${s.tipo}"/></strong> · <c:out value="${s.solicitante}"/><br>
          <small class="text-muted"><c:out value="${empty s.trabajo ? 'Sin trabajo asociado' : s.trabajo}"/> · ${fn:substring(s.fecha_solicitud, 8, 10)}/${fn:substring(s.fecha_solicitud, 5, 7)}/${fn:substring(s.fecha_solicitud, 0, 4)}</small></div>
        <div><span class="estado" data-estado="${s.estado}">${s.estado}</span>
          <c:if test="${not empty s.trabajo_id}"><a class="btn btn-sm btn-outline-secondary ms-2" href="${ctx}/panel.jsp?v=trabajos/detalle&id=${s.trabajo_id}">Ver trabajo</a></c:if></div>
      </div>
      <p class="texto-largo mt-2 mb-2"><c:out value="${s.descripcion}"/></p>
      <c:if test="${not empty s.url}"><p class="mb-2"><a href="<c:out value='${s.url}'/>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right"></i> Abrir enlace</a></p></c:if>
      <c:choose>
        <c:when test="${s.estado eq 'Pendiente'}">
          <details class="revision">
            <summary>Responder</summary>
            <form class="mt-3 validar" method="post" action="${ctx}/acciones/solicitudes/resolver.jsp" novalidate>
              <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="id" value="${s.id}">
              <div class="mb-3"><label class="form-label" for="r${s.id}">Respuesta</label><textarea class="form-control" id="r${s.id}" name="respuesta" rows="2" maxlength="3000" required minlength="5"></textarea></div>
              <c:if test="${s.tipo eq 'Prorroga'}">
                <div class="mb-3"><label class="form-label" for="p${s.id}">Nuevo plazo total del trabajo final (días)</label><input class="form-control" type="number" id="p${s.id}" name="plazo" min="90" max="180" value="180"><div class="form-text">Obligatorio si apruebas la prórroga (90 a 180 días contados desde el inicio de la fase).</div></div>
              </c:if>
              <div class="d-flex gap-2">
                <button class="btn btn-primary btn-sm" type="submit" name="decision" value="Aprobada">Aprobar</button>
                <button class="btn btn-outline-danger btn-sm" type="submit" name="decision" value="Rechazada">Rechazar</button>
              </div>
            </form>
          </details>
        </c:when>
        <c:otherwise><div class="small"><span class="dato-etiqueta">Respuesta</span><div class="texto-largo"><c:out value="${s.respuesta}"/></div></div></c:otherwise>
      </c:choose>
    </div>
  </c:forEach>
  <c:if test="${lista.rowCount eq 0}"><p class="text-muted text-center py-3 mb-0">No hay solicitudes.</p></c:if>
  <c:set var="baseV" value="solicitudes/listar"/>
  <%@ include file="/WEB-INF/vistas/comunes/paginador.jspf" %>
</div>
