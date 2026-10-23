<sql:query var="pend">
  SELECT ai.id, ai.fecha_asignacion, ai.comprobante_pago_url, ai.estudiante_id, i.titulo, i.modalidad, u.nombre AS estudiante, u.documento, u.nivel
    FROM asignaciones_ideas ai JOIN ideas i ON i.id = ai.idea_id JOIN users u ON u.id = ai.estudiante_id
   WHERE ai.estado = 'Pendiente_validacion' ORDER BY ai.fecha_asignacion
</sql:query>
<sql:query var="libres">
  SELECT u.id, u.nombre, u.documento FROM users u JOIN role_user ru ON ru.user_id = u.id AND ru.role_id = 6
   WHERE u.estado = 'Activo'
     AND NOT EXISTS (SELECT 1 FROM trabajo_estudiantes te WHERE te.estudiante_id = u.id)
     AND NOT EXISTS (SELECT 1 FROM asignaciones_ideas ai WHERE ai.estudiante_id = u.id AND ai.estado IN ('Pendiente_validacion','Validada'))
   ORDER BY u.nombre
</sql:query>
<sql:query var="hist">
  SELECT ai.id, ai.estado, ai.observaciones, ai.fecha_validacion, i.titulo, u.nombre AS estudiante
    FROM asignaciones_ideas ai JOIN ideas i ON i.id = ai.idea_id JOIN users u ON u.id = ai.estudiante_id
   WHERE ai.estado <> 'Pendiente_validacion' AND ai.idea_id IS NOT NULL ORDER BY ai.fecha_validacion DESC LIMIT 10
</sql:query>
<div class="page-header"><h1>Pagos y asignaciones de ideas</h1><p>Valida el comprobante de pago. Al validar, la idea sale del banco y se crea el trabajo de grado.</p></div>
<div class="panel">
  <h2>Pendientes de validación (${pend.rowCount})</h2>
  <c:if test="${pend.rowCount eq 0}"><p class="text-muted mb-0">No hay pagos por validar.</p></c:if>
  <c:forEach var="a" items="${pend.rows}">
    <div class="border rounded p-3 mb-3">
      <div class="d-flex flex-wrap justify-content-between gap-2">
        <div>
          <strong><c:out value="${a.titulo}"/></strong> <span class="text-muted">· <c:out value="${a.modalidad}"/></span><br>
          <span class="small">Estudiante: <c:out value="${a.estudiante}"/> (<c:out value="${a.documento}"/>) · <c:out value="${a.nivel}"/></span><br>
          <span class="small text-muted">Solicitada el ${fn:substring(a.fecha_asignacion, 8, 10)}/${fn:substring(a.fecha_asignacion, 5, 7)}/${fn:substring(a.fecha_asignacion, 0, 4)}</span>
        </div>
        <div><a class="btn btn-sm btn-outline-secondary" href="<c:out value='${a.comprobante_pago_url}'/>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right"></i> Ver comprobante</a></div>
      </div>
      <details class="revision mt-3">
        <summary>Registrar decisión</summary>
        <form class="mt-3 validar" method="post" action="${ctx}/acciones/asignaciones/pago.jsp" novalidate>
          <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="id" value="${a.id}">
          <div class="row g-3">
            <div class="col-md-6"><label class="form-label" for="obs${a.id}">Observaciones</label><textarea class="form-control" id="obs${a.id}" name="observaciones" rows="2" maxlength="500" placeholder="Obligatorias si rechazas el pago"></textarea></div>
            <div class="col-md-6"><label class="form-label" for="e2${a.id}">Segundo estudiante (opcional)</label>
              <select class="form-select" id="e2${a.id}" name="estudiante2"><option value="">Trabajo individual</option>
                <c:forEach var="e" items="${libres.rows}"><c:if test="${e.id ne a.estudiante_id}"><option value="${e.id}"><c:out value="${e.nombre}"/> (<c:out value="${e.documento}"/>)</option></c:if></c:forEach>
              </select></div>
            <div class="col-12"><div class="form-check"><input class="form-check-input" type="checkbox" id="c${a.id}" name="condiciones" value="on"><label class="form-check-label" for="c${a.id}">Se verificaron las condiciones académicas (Fase 0). Requerido para validar.</label></div></div>
          </div>
          <div class="d-flex gap-2 mt-3">
            <button class="btn btn-primary btn-sm" type="submit" name="decision" value="Validada"><i class="bi bi-check2-circle"></i> Validar pago</button>
            <button class="btn btn-outline-danger btn-sm" type="submit" name="decision" value="Rechazada"><i class="bi bi-x-circle"></i> Rechazar pago</button>
          </div>
        </form>
      </details>
    </div>
  </c:forEach>
</div>
<div class="panel">
  <h2>Últimas decisiones</h2>
  <div class="table-responsive"><table class="table table-sm align-middle mb-0">
    <thead><tr><th>Idea</th><th>Estudiante</th><th>Resultado</th><th>Fecha</th></tr></thead>
    <tbody>
      <c:forEach var="h" items="${hist.rows}"><tr>
        <td><c:out value="${h.titulo}"/></td><td><c:out value="${h.estudiante}"/></td>
        <td><span class="estado" data-estado="${h.estado}">${h.estado}</span></td>
        <td><c:if test="${not empty h.fecha_validacion}">${fn:substring(h.fecha_validacion, 8, 10)}/${fn:substring(h.fecha_validacion, 5, 7)}/${fn:substring(h.fecha_validacion, 0, 4)}</c:if></td>
      </tr></c:forEach>
      <c:if test="${hist.rowCount eq 0}"><tr><td colspan="4" class="text-muted text-center">Sin registros.</td></tr></c:if>
    </tbody></table></div>
</div>
