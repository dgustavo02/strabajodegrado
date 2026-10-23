<sql:query var="r">
  SELECT i.id, i.titulo, i.modalidad, i.estado,
         (SELECT COUNT(*) FROM asignaciones_ideas ai WHERE ai.idea_id = i.id AND ai.estado IN ('Pendiente_validacion','Validada')) AS tomada
    FROM ideas i WHERE i.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<sql:query var="mias">
  SELECT ai.estado, ai.observaciones, ai.fecha_asignacion, ai.fecha_validacion, i.titulo
    FROM asignaciones_ideas ai JOIN ideas i ON i.id = ai.idea_id WHERE ai.estudiante_id = ? ORDER BY ai.id DESC LIMIT 5
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<div class="page-header"><h1>Solicitar idea</h1><p>Registra el enlace de tu comprobante de pago. El Comité lo validará y reservará la idea para ti.</p></div>
<c:choose>
  <c:when test="${r.rowCount eq 0 or r.rows[0].estado ne 'Aprobada' or r.rows[0].tomada gt 0}">
    <div class="alert alert-warning">La idea no está disponible. <a href="${ctx}/panel.jsp?v=ideas/banco">Volver al banco de ideas</a></div>
  </c:when>
  <c:otherwise>
    <div class="panel">
      <h2><c:out value="${r.rows[0].titulo}"/></h2><p class="text-muted"><c:out value="${r.rows[0].modalidad}"/></p>
      <form method="post" action="${ctx}/acciones/asignaciones/solicitar.jsp" class="validar" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="idea" value="${r.rows[0].id}">
        <div class="mb-3"><label class="form-label" for="url">Enlace del comprobante de pago</label>
          <input class="form-control" type="url" id="url" name="url" maxlength="500" placeholder="https://..." required pattern="https://.*">
          <div class="form-text">Debe empezar por https://. El archivo no se guarda en el sistema: solo el enlace.</div></div>
        <div class="d-flex gap-2"><button class="btn btn-primary" type="submit"><i class="bi bi-send"></i> Enviar solicitud</button>
          <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=ideas/detalle&id=${r.rows[0].id}">Cancelar</a></div>
      </form>
    </div>
  </c:otherwise>
</c:choose>
<c:if test="${mias.rowCount gt 0}">
  <div class="panel"><h2>Mis solicitudes recientes</h2>
    <table class="table table-sm align-middle mb-0"><thead><tr><th>Idea</th><th>Estado</th><th>Observaciones</th></tr></thead><tbody>
      <c:forEach var="m" items="${mias.rows}"><tr><td><c:out value="${m.titulo}"/></td><td><span class="estado" data-estado="${m.estado}">${m.estado eq 'Pendiente_validacion' ? 'Pago por validar' : m.estado}</span></td><td class="small"><c:out value="${empty m.observaciones ? '—' : m.observaciones}"/></td></tr></c:forEach>
    </tbody></table>
  </div>
</c:if>
