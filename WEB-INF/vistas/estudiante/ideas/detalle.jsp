<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<sql:query var="r">
  SELECT i.id, i.titulo, i.descripcion, i.modalidad, i.estado, u.nombre AS docente,
         (SELECT COUNT(*) FROM asignaciones_ideas ai WHERE ai.idea_id = i.id AND ai.estado IN ('Pendiente_validacion','Validada')) AS tomada
    FROM ideas i JOIN users u ON u.id = i.docente_id WHERE i.id = ? AND i.estado IN ('Aprobada','Asignada')
  <sql:param value="${param.id}"/>
</sql:query>
<sql:query var="activa">SELECT COUNT(*) AS n FROM asignaciones_ideas WHERE estudiante_id = ? AND estado IN ('Pendiente_validacion','Validada')<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:choose>
  <c:when test="${r.rowCount eq 0}"><div class="alert alert-warning">La idea no está disponible. <a href="${ctx}/panel.jsp?v=ideas/banco">Volver al banco</a></div></c:when>
  <c:otherwise>
    <c:set var="i" value="${r.rows[0]}"/>
    <div class="page-header d-flex justify-content-between align-items-center">
      <div><h1><c:out value="${i.titulo}"/></h1><p><c:out value="${i.modalidad}"/> · Propuesta por <c:out value="${i.docente}"/></p></div>
      <a class="btn btn-outline-secondary" href="${ctx}/panel.jsp?v=ideas/banco"><i class="bi bi-arrow-left"></i> Banco de ideas</a>
    </div>
    <div class="panel">
      <p class="texto-largo"><c:out value="${i.descripcion}"/></p>
      <hr>
      <c:choose>
        <c:when test="${i.estado ne 'Aprobada' or i.tomada gt 0}"><div class="alert alert-secondary mb-0">Esta idea ya no está disponible.</div></c:when>
        <c:when test="${tengoTrabajo or activa.rows[0].n gt 0}"><div class="alert alert-info mb-0">Ya tienes un trabajo de grado o una solicitud de idea en curso.</div></c:when>
        <c:otherwise><a class="btn btn-primary" href="${ctx}/panel.jsp?v=asignaciones/solicitar&id=${i.id}"><i class="bi bi-check2-circle"></i> Solicitar esta idea</a></c:otherwise>
      </c:choose>
    </div>
  </c:otherwise>
</c:choose>
