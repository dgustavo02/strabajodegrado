<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<sql:query var="mias">SELECT id, titulo, modalidad, estado, observaciones_comite, fecha_propuesta FROM propuestas_estudiantes WHERE estudiante_id = ? ORDER BY id DESC<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="pend">SELECT COUNT(*) AS n FROM propuestas_estudiantes WHERE estudiante_id = ? AND estado = 'Pendiente'<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="activa">SELECT COUNT(*) AS n FROM asignaciones_ideas WHERE estudiante_id = ? AND estado IN ('Pendiente_validacion','Validada')<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<div class="page-header"><h1>Mi propuesta de trabajo de grado</h1><p>Las propuestas propias no entran al banco de ideas: el Comité las revisa y, si las aprueba, quedan asignadas a ti.</p></div>
<c:choose>
  <c:when test="${tengoTrabajo or activa.rows[0].n gt 0}"><div class="alert alert-info">Ya tienes un trabajo de grado o una solicitud de idea en curso.</div></c:when>
  <c:when test="${pend.rows[0].n gt 0}"><div class="alert alert-info">Tu propuesta está pendiente de revisión del Comité.</div></c:when>
  <c:otherwise>
    <div class="panel">
      <form method="post" action="${ctx}/acciones/propuestas/crear.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        <div class="row g-3">
          <div class="col-md-8"><label class="form-label" for="titulo">Título</label><input class="form-control" id="titulo" name="titulo" maxlength="200" minlength="5" required></div>
          <div class="col-md-4"><label class="form-label" for="modalidad">Modalidad</label>
            <select class="form-select" id="modalidad" name="modalidad" required><option value="">Selecciona…</option>
              <option value="Desarrollo tecnologico">Desarrollo tecnológico</option><option value="Emprendimiento">Emprendimiento</option>
              <option value="Monografia">Monografía</option><option value="Proyecto de investigacion">Proyecto de investigación</option></select></div>
          <div class="col-12"><label class="form-label" for="descripcion">Descripción</label><textarea class="form-control" id="descripcion" name="descripcion" rows="6" maxlength="5000" minlength="20" required data-max="5000"></textarea></div>
          <div class="col-12"><label class="form-label" for="url">Enlace del comprobante de pago</label><input class="form-control" type="url" id="url" name="url" maxlength="500" placeholder="https://..." required pattern="https://.*"><div class="form-text">Debe empezar por https://.</div></div>
        </div>
        <div class="mt-4"><button class="btn btn-primary" type="submit"><i class="bi bi-send"></i> Enviar al Comité</button></div>
      </form>
    </div>
  </c:otherwise>
</c:choose>
<c:if test="${mias.rowCount gt 0}">
  <div class="panel"><h2>Mis propuestas</h2>
    <div class="table-responsive"><table class="table table-sm align-middle mb-0"><thead><tr><th>Propuesta</th><th>Modalidad</th><th>Estado</th><th>Observaciones del Comité</th><th>Fecha</th></tr></thead><tbody>
      <c:forEach var="p" items="${mias.rows}"><tr><td><c:out value="${p.titulo}"/></td><td><c:out value="${p.modalidad}"/></td><td><span class="estado" data-estado="${p.estado}">${p.estado}</span></td><td class="small texto-largo"><c:out value="${empty p.observaciones_comite ? '—' : p.observaciones_comite}"/></td><td>${fn:substring(p.fecha_propuesta, 8, 10)}/${fn:substring(p.fecha_propuesta, 5, 7)}/${fn:substring(p.fecha_propuesta, 0, 4)}</td></tr></c:forEach>
    </tbody></table></div>
  </div>
</c:if>
