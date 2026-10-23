<sql:query var="lista">
  SELECT id, titulo, modalidad, estado, observaciones_comite, fecha_propuesta, fecha_decision
    FROM ideas WHERE docente_id = ? ORDER BY fecha_propuesta DESC
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<div class="page-header d-flex justify-content-between align-items-center">
  <div><h1>Mis ideas</h1><p>Estado de las ideas que propusiste.</p></div>
  <a class="btn btn-primary" href="${ctx}/panel.jsp?v=ideas/crear"><i class="bi bi-plus-circle"></i> Proponer idea</a>
</div>
<div class="panel">
  <div class="table-responsive"><table class="table align-middle mb-0">
    <thead><tr><th>Idea</th><th>Modalidad</th><th>Estado</th><th>Observaciones del Comité</th><th>Propuesta</th></tr></thead>
    <tbody>
      <c:forEach var="i" items="${lista.rows}"><tr>
        <td><c:out value="${i.titulo}"/></td><td><c:out value="${i.modalidad}"/></td>
        <td><span class="estado" data-estado="${i.estado}">${i.estado}</span></td>
        <td class="texto-largo small"><c:out value="${empty i.observaciones_comite ? '—' : i.observaciones_comite}"/></td>
        <td>${fn:substring(i.fecha_propuesta, 8, 10)}/${fn:substring(i.fecha_propuesta, 5, 7)}/${fn:substring(i.fecha_propuesta, 0, 4)}</td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="5" class="text-center text-muted py-4">Aún no has propuesto ideas.</td></tr></c:if>
    </tbody></table></div>
</div>
