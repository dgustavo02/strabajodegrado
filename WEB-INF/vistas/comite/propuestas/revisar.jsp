<sql:query var="r">
  SELECT p.id, p.estudiante_id, p.titulo, p.descripcion, p.modalidad, p.estado, p.comprobante_pago_url, p.observaciones_comite, p.fecha_propuesta, p.fecha_decision,
         u.nombre AS estudiante, u.documento, u.email_institucional AS correo, u.nivel
    FROM propuestas_estudiantes p JOIN users u ON u.id = p.estudiante_id WHERE p.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">La propuesta no existe. <a href="${ctx}/panel.jsp?v=propuestas/listar">Volver</a></div></c:when>
  <c:otherwise>
    <c:set var="p" value="${r.rows[0]}"/>
    <c:if test="${p.estado eq 'Pendiente'}">
      <sql:query var="libres">
        SELECT u.id, u.nombre, u.documento FROM users u JOIN role_user ru ON ru.user_id = u.id AND ru.role_id = 6
         WHERE u.estado = 'Activo' AND u.id <> ?
           AND NOT EXISTS (SELECT 1 FROM trabajo_estudiantes te WHERE te.estudiante_id = u.id)
           AND NOT EXISTS (SELECT 1 FROM asignaciones_ideas ai WHERE ai.estudiante_id = u.id AND ai.estado IN ('Pendiente_validacion','Validada'))
         ORDER BY u.nombre
        <sql:param value="${p.estudiante_id}"/>
      </sql:query>
    </c:if>
    <div class="page-header d-flex justify-content-between align-items-center">
      <div><h1>Revisión de propuesta</h1><p><span class="estado" data-estado="${p.estado}">${p.estado}</span></p></div>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=propuestas/listar"><i class="bi bi-arrow-left"></i> Volver</a>
    </div>
    <div class="row g-3">
      <div class="col-lg-7"><div class="panel">
        <h2><c:out value="${p.titulo}"/></h2>
        <p class="texto-largo"><c:out value="${p.descripcion}"/></p>
        <hr>
        <div class="row small g-2">
          <div class="col-sm-6"><div class="dato-etiqueta">Estudiante</div><c:out value="${p.estudiante}"/> (<c:out value="${p.documento}"/>)<br><span class="text-muted"><c:out value="${p.correo}"/> · <c:out value="${p.nivel}"/></span></div>
          <div class="col-sm-3"><div class="dato-etiqueta">Modalidad</div><c:out value="${p.modalidad}"/></div>
          <div class="col-sm-3"><div class="dato-etiqueta">Registrada</div>${fn:substring(p.fecha_propuesta, 8, 10)}/${fn:substring(p.fecha_propuesta, 5, 7)}/${fn:substring(p.fecha_propuesta, 0, 4)}</div>
          <div class="col-12"><div class="dato-etiqueta">Comprobante de pago</div><a href="<c:out value='${p.comprobante_pago_url}'/>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right"></i> Abrir comprobante</a></div>
        </div>
      </div></div>
      <div class="col-lg-5"><div class="panel">
        <h2>Decisión del Comité</h2>
        <c:choose>
          <c:when test="${p.estado eq 'Pendiente'}">
            <form method="post" action="${ctx}/acciones/propuestas/decidir.jsp" class="validar" novalidate>
              <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="id" value="${p.id}">
              <div class="mb-3"><label class="form-label" for="observaciones">Observaciones</label>
                <textarea class="form-control" id="observaciones" name="observaciones" rows="3" maxlength="2000" data-max="2000" placeholder="Obligatorias si rechazas la propuesta"></textarea></div>
              <div class="mb-3"><label class="form-label" for="estudiante2">Segundo estudiante (opcional)</label>
                <select class="form-select" id="estudiante2" name="estudiante2">
                  <option value="">Trabajo individual</option>
                  <c:forEach var="e" items="${libres.rows}"><option value="${e.id}"><c:out value="${e.nombre}"/> (<c:out value="${e.documento}"/>)</option></c:forEach>
                </select>
                <div class="form-text">Un trabajo puede ser individual o de dos estudiantes.</div></div>
              <div class="form-check mb-3"><input class="form-check-input" type="checkbox" id="condiciones" name="condiciones" value="on"><label class="form-check-label" for="condiciones">Se verificaron las condiciones académicas (Fase 0). Requerido para aprobar.</label></div>
              <div class="d-flex gap-2">
                <button class="btn btn-primary" type="submit" name="decision" value="Aprobada"><i class="bi bi-check2-circle"></i> Aprobar</button>
                <button class="btn btn-outline-danger" type="submit" name="decision" value="Rechazada"><i class="bi bi-x-circle"></i> Rechazar</button>
              </div>
            </form>
          </c:when>
          <c:otherwise>
            <p class="mb-1 dato-etiqueta">Observaciones</p><p class="texto-largo"><c:out value="${p.observaciones_comite}"/></p>
            <p class="small text-muted mb-0">Decidida el ${fn:substring(p.fecha_decision, 8, 10)}/${fn:substring(p.fecha_decision, 5, 7)}/${fn:substring(p.fecha_decision, 0, 4)}</p>
          </c:otherwise>
        </c:choose>
      </div></div>
    </div>
  </c:otherwise>
</c:choose>
