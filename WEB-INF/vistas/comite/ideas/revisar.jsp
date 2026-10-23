<sql:query var="r">
  SELECT i.id, i.titulo, i.descripcion, i.modalidad, i.estado, i.observaciones_comite, i.fecha_propuesta, i.fecha_decision, u.nombre AS docente, u.email_institucional AS correo
    FROM ideas i JOIN users u ON u.id = i.docente_id WHERE i.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">La idea no existe. <a href="${ctx}/panel.jsp?v=ideas/listar">Volver</a></div></c:when>
  <c:otherwise>
    <c:set var="i" value="${r.rows[0]}"/>
    <div class="page-header d-flex justify-content-between align-items-center">
      <div><h1>Revisión de idea</h1><p><span class="estado" data-estado="${i.estado}">${i.estado}</span></p></div>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=ideas/listar"><i class="bi bi-arrow-left"></i> Volver</a>
    </div>
    <div class="row g-3">
      <div class="col-lg-7"><div class="panel">
        <h2><c:out value="${i.titulo}"/></h2>
        <p class="texto-largo"><c:out value="${i.descripcion}"/></p>
        <hr>
        <div class="row small">
          <div class="col-sm-6"><div class="dato-etiqueta">Docente</div><c:out value="${i.docente}"/><br><span class="text-muted"><c:out value="${i.correo}"/></span></div>
          <div class="col-sm-3"><div class="dato-etiqueta">Modalidad</div><c:out value="${i.modalidad}"/></div>
          <div class="col-sm-3"><div class="dato-etiqueta">Propuesta</div>${fn:substring(i.fecha_propuesta, 8, 10)}/${fn:substring(i.fecha_propuesta, 5, 7)}/${fn:substring(i.fecha_propuesta, 0, 4)}</div>
        </div>
      </div></div>
      <div class="col-lg-5"><div class="panel">
        <h2>Decisión del Comité</h2>
        <c:choose>
          <c:when test="${i.estado eq 'Pendiente'}">
            <form method="post" action="${ctx}/acciones/ideas/decidir.jsp" class="validar" novalidate>
              <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="id" value="${i.id}">
              <div class="mb-3"><label class="form-label" for="observaciones">Observaciones</label>
                <textarea class="form-control" id="observaciones" name="observaciones" rows="4" maxlength="2000" data-max="2000" placeholder="Obligatorias si rechazas la idea"></textarea></div>
              <div class="d-flex gap-2">
                <button class="btn btn-primary" type="submit" name="decision" value="Aprobada"><i class="bi bi-check2-circle"></i> Aprobar</button>
                <button class="btn btn-outline-danger" type="submit" name="decision" value="Rechazada"><i class="bi bi-x-circle"></i> Rechazar</button>
              </div>
            </form>
          </c:when>
          <c:otherwise>
            <p class="mb-1 dato-etiqueta">Observaciones</p><p class="texto-largo"><c:out value="${i.observaciones_comite}"/></p>
            <p class="small text-muted mb-0">Decidida el ${fn:substring(i.fecha_decision, 8, 10)}/${fn:substring(i.fecha_decision, 5, 7)}/${fn:substring(i.fecha_decision, 0, 4)}</p>
          </c:otherwise>
        </c:choose>
      </div></div>
    </div>
  </c:otherwise>
</c:choose>
