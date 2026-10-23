<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<sql:query var="lista">SELECT tipo, descripcion, url, estado, respuesta, fecha_solicitud, fecha_respuesta FROM solicitudes WHERE usuario_id = ? ORDER BY id DESC<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<div class="page-header"><h1>Mis solicitudes</h1><p>Cambios de proyecto o Director, prórrogas y otras solicitudes al Comité.</p></div>
<c:choose>
  <c:when test="${tengoTrabajo and mt.estado ne 'Finalizado'}">
    <div class="panel"><h2>Nueva solicitud</h2>
      <form method="post" action="${ctx}/acciones/solicitudes/crear.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        <div class="row g-3">
          <div class="col-md-4"><label class="form-label" for="tipo">Tipo</label>
            <select class="form-select" id="tipo" name="tipo" required><option value="">Selecciona…</option>
              <option value="Prorroga">Prórroga</option><option value="Cambio de Director">Cambio de Director</option>
              <option value="Cambio de proyecto">Cambio de proyecto</option><option value="Solicitud general">Solicitud general</option></select></div>
          <div class="col-md-8"><label class="form-label" for="descripcion">Descripción</label><textarea class="form-control" id="descripcion" name="descripcion" rows="3" minlength="10" maxlength="3000" required data-max="3000"></textarea></div>
        </div>
        <button class="btn btn-primary mt-3" type="submit"><i class="bi bi-send"></i> Enviar al Comité</button>
      </form>
    </div>
  </c:when>
  <c:otherwise><div class="alert alert-info">Las solicitudes se habilitan cuando tienes un trabajo de grado en curso.</div></c:otherwise>
</c:choose>
<div class="panel"><h2>Historial</h2>
  <c:forEach var="s" items="${lista.rows}">
    <div class="border-bottom pb-2 mb-2">
      <div class="d-flex justify-content-between flex-wrap"><strong><c:out value="${s.tipo}"/></strong><span class="estado" data-estado="${s.estado}">${s.estado}</span></div>
      <div class="texto-largo small"><c:out value="${s.descripcion}"/></div>
      <c:if test="${not empty s.respuesta}"><div class="small mt-1"><span class="dato-etiqueta">Respuesta del Comité</span><div class="texto-largo"><c:out value="${s.respuesta}"/></div></div></c:if>
      <div class="small text-muted">${fn:substring(s.fecha_solicitud, 8, 10)}/${fn:substring(s.fecha_solicitud, 5, 7)}/${fn:substring(s.fecha_solicitud, 0, 4)}</div>
    </div>
  </c:forEach>
  <c:if test="${lista.rowCount eq 0}"><p class="text-muted mb-0">No has registrado solicitudes.</p></c:if>
</div>
