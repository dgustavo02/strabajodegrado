<sql:query var="r">
  SELECT t.id, t.estado, t.fase_actual_id, t.fecha_inicio, t.fecha_finalizacion, f.nombre AS fase,
         COALESCE(i.titulo, pe.titulo) AS titulo, COALESCE(i.descripcion, pe.descripcion) AS descripcion,
         COALESCE(i.modalidad, pe.modalidad) AS modalidad, IF(ai.idea_id IS NULL, 'Propuesta del estudiante', 'Banco de ideas') AS origen,
         sol.nombre AS solicitante,
         (SELECT COUNT(*) FROM entregas e WHERE e.trabajo_id = t.id AND e.estado = 'En comite') AS en_comite,
         (SELECT fase_id FROM entregas e WHERE e.trabajo_id = t.id AND e.estado = 'En comite' ORDER BY e.id DESC LIMIT 1) AS fase_comite,
         (SELECT IF(tf.fecha_limite < CURDATE(), 1, 0) FROM trabajo_fases tf WHERE tf.trabajo_id = t.id AND tf.fase_id = 5 AND tf.estado IN ('En proceso','Aplazada')) AS vencido
    FROM trabajos_grado t JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id JOIN users sol ON sol.id = ai.estudiante_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
    LEFT JOIN fases f ON f.id = t.fase_actual_id
   WHERE t.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">El trabajo no existe. <a href="${ctx}/panel.jsp?v=trabajos/listar">Volver</a></div></c:when>
  <c:otherwise>
    <c:set var="t" value="${r.rows[0]}"/>
    <c:set var="cerrado" value="${t.estado eq 'Rechazado' or t.estado eq 'Finalizado'}"/>
    <sql:query var="est">SELECT u.nombre, u.documento, u.email_institucional AS correo, u.nivel FROM trabajo_estudiantes te JOIN users u ON u.id = te.estudiante_id WHERE te.trabajo_id = ?<sql:param value="${t.id}"/></sql:query>
    <sql:query var="docs">SELECT td.funcion, td.fecha_asignacion, u.nombre, u.email_institucional AS correo FROM trabajo_docentes td JOIN users u ON u.id = td.docente_id WHERE td.trabajo_id = ? ORDER BY td.funcion<sql:param value="${t.id}"/></sql:query>

    <div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
      <div><h1><c:out value="${t.titulo}"/></h1>
        <p><span class="estado" data-estado="${t.estado}">${t.estado}</span> · Fase: <c:out value="${empty t.fase ? '—' : t.fase}"/>
          <c:if test="${t.vencido eq 1}"> · <span class="text-danger fw-semibold">Plazo del trabajo final vencido</span></c:if></p></div>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=trabajos/listar"><i class="bi bi-arrow-left"></i> Volver</a>
    </div>

    <div class="row g-3">
      <div class="col-lg-7">
        <div class="panel">
          <h2>Información</h2>
          <p class="texto-largo"><c:out value="${t.descripcion}"/></p>
          <div class="row small g-2">
            <div class="col-sm-4"><div class="dato-etiqueta">Modalidad</div><c:out value="${t.modalidad}"/></div>
            <div class="col-sm-4"><div class="dato-etiqueta">Origen</div><c:out value="${t.origen}"/></div>
            <div class="col-sm-4"><div class="dato-etiqueta">Inicio</div><fmt:formatDate value="${t.fecha_inicio}" pattern="dd/MM/yyyy"/></div>
          </div>
        </div>
        <div class="panel">
          <h2>Estudiantes</h2>
          <c:choose>
            <c:when test="${est.rowCount eq 0}"><p class="text-muted mb-0">Sin estudiantes vinculados (solicitante: <c:out value="${t.solicitante}"/>).</p></c:when>
            <c:otherwise><table class="table table-sm mb-0"><tbody>
              <c:forEach var="e" items="${est.rows}"><tr><td><c:out value="${e.nombre}"/></td><td><c:out value="${e.documento}"/></td><td><c:out value="${e.correo}"/></td><td><c:out value="${e.nivel}"/></td></tr></c:forEach>
            </tbody></table><p class="small text-muted mt-2 mb-0">${est.rowCount eq 1 ? 'Trabajo individual' : 'Trabajo de dos estudiantes'}</p></c:otherwise>
          </c:choose>
        </div>
        <h2 class="h5 mb-3">Fases del proyecto</h2>
        <c:set var="fpTrabajo" value="${t.id}"/><c:set var="fpVerEvaluador" value="1"/><c:set var="fpVerPrivados" value="1"/>
        <%@ include file="/WEB-INF/vistas/comunes/fases-proyecto.jspf" %>
      </div>

      <div class="col-lg-5">
        <div class="panel">
          <h2>Director y Evaluador</h2>
          <c:forEach var="d" items="${docs.rows}">
            <div class="mb-2"><span class="estado" data-estado="${d.funcion}">${d.funcion}</span> <strong><c:out value="${d.nombre}"/></strong><br><small class="text-muted"><c:out value="${d.correo}"/></small></div>
          </c:forEach>
          <c:if test="${docs.rowCount eq 0}"><p class="text-muted">Aún no hay docentes asignados.</p></c:if>
          <c:if test="${not cerrado}">
            <div class="d-flex flex-wrap gap-2 mt-2">
              <a class="btn btn-sm btn-outline-primary" href="${ctx}/panel.jsp?v=asignaciones/director&id=${t.id}"><i class="bi bi-person-check"></i> Asignar/cambiar Director</a>
              <a class="btn btn-sm btn-outline-primary" href="${ctx}/panel.jsp?v=asignaciones/evaluador&id=${t.id}"><i class="bi bi-person-check"></i> Asignar/cambiar Evaluador</a>
            </div>
          </c:if>
        </div>

        <c:if test="${t.en_comite gt 0 and not cerrado}">
          <div class="panel border border-warning">
            <h2>Decisión del Comité</h2>
            <p class="small text-muted">El trabajo pasó por Director y Evaluador y espera tu decisión (${t.fase_comite eq 3 ? 'anteproyecto' : 'trabajo final'}).</p>
            <form method="post" action="${ctx}/acciones/trabajos/decidir.jsp" class="validar" novalidate>
              <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="trabajo" value="${t.id}">
              <div class="mb-3"><label class="form-label" for="obsC">Observaciones</label><textarea class="form-control" id="obsC" name="observaciones" rows="3" maxlength="3000" required minlength="5" data-max="3000"></textarea></div>
              <c:if test="${t.fase_comite eq 3}">
                <div class="mb-3"><label class="form-label" for="plazo">Plazo para el trabajo final (días)</label>
                  <input class="form-control" type="number" id="plazo" name="plazo" min="90" max="180" value="120">
                  <div class="form-text">Entre 90 y 180 días. Solo aplica si apruebas el anteproyecto.</div></div>
              </c:if>
              <div class="d-flex flex-wrap gap-2">
                <button class="btn btn-primary btn-sm" type="submit" name="decision" value="Aprobada"><i class="bi bi-check2-circle"></i> Aprobar</button>
                <button class="btn btn-outline-warning btn-sm" type="submit" name="decision" value="Aplazada"><i class="bi bi-arrow-counterclockwise"></i> Aplazar</button>
                <button class="btn btn-outline-danger btn-sm" type="submit" name="decision" value="Rechazada"><i class="bi bi-x-circle"></i> Rechazar</button>
              </div>
            </form>
          </div>
        </c:if>

        <c:if test="${not cerrado}">
          <div class="panel">
            <details class="revision">
              <summary class="text-danger">Rechazar trabajo (cierre definitivo)</summary>
              <form class="mt-3 validar" method="post" action="${ctx}/acciones/trabajos/rechazar.jsp" data-confirm="Los estudiantes quedarán desvinculados del trabajo. ¿Continuar?" novalidate>
                <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="trabajo" value="${t.id}">
                <div class="mb-3"><label class="form-label" for="motivo">Motivo</label><textarea class="form-control" id="motivo" name="motivo" rows="3" maxlength="3000" required minlength="5"></textarea>
                  <div class="form-text">Úsalo, por ejemplo, cuando vence el plazo sin entrega.</div></div>
                <button class="btn btn-outline-danger btn-sm" type="submit">Rechazar trabajo</button>
              </form>
            </details>
          </div>
        </c:if>
      </div>
    </div>
  </c:otherwise>
</c:choose>