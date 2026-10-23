<sql:query var="lista">
  SELECT id, titulo, mensaje, tipo, IF(leida, 1, 0) AS leida, fecha_creacion
    FROM notificaciones WHERE usuario_id = ? ORDER BY id DESC LIMIT 50
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
  <div><h1>Notificaciones</h1><p>Avisos sobre cambios relevantes en tu proceso.</p></div>
  <form method="post" action="${ctx}/acciones/notificaciones/leer.jsp">
    <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="todas" value="1">
    <button class="btn btn-outline-primary btn-sm" type="submit"><i class="bi bi-check2-all"></i> Marcar todas como leídas</button>
  </form>
</div>
<div class="panel">
  <c:forEach var="n" items="${lista.rows}">
    <div class="d-flex justify-content-between align-items-start gap-3 border-bottom py-3 ${n.leida eq 0 ? 'bg-light' : ''}">
      <div>
        <div class="fw-semibold"><c:if test="${n.leida eq 0}"><span class="badge bg-success me-2">Nueva</span></c:if><c:out value="${n.titulo}"/></div>
        <div class="texto-largo small"><c:out value="${n.mensaje}"/></div>
        <div class="small text-muted"><c:out value="${n.tipo}"/> · ${fn:substring(n.fecha_creacion, 8, 10)}/${fn:substring(n.fecha_creacion, 5, 7)}/${fn:substring(n.fecha_creacion, 0, 4)}</div>
      </div>
      <c:if test="${n.leida eq 0}">
        <form method="post" action="${ctx}/acciones/notificaciones/leer.jsp">
          <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="id" value="${n.id}">
          <button class="btn btn-sm btn-outline-secondary" type="submit" title="Marcar como leída"><i class="bi bi-check2"></i></button>
        </form>
      </c:if>
    </div>
  </c:forEach>
  <c:if test="${lista.rowCount eq 0}"><p class="text-muted text-center py-4 mb-0">No tienes notificaciones.</p></c:if>
</div>
