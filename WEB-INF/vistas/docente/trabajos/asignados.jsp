<sql:query var="lista">
  SELECT t.id, t.estado, td.funcion, f.nombre AS fase, COALESCE(i.titulo, pe.titulo) AS titulo, COALESCE(i.modalidad, pe.modalidad) AS modalidad,
         (SELECT GROUP_CONCAT(u.nombre SEPARATOR ', ') FROM trabajo_estudiantes te JOIN users u ON u.id = te.estudiante_id WHERE te.trabajo_id = t.id) AS estudiantes
    FROM trabajo_docentes td JOIN trabajos_grado t ON t.id = td.trabajo_id JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
    LEFT JOIN fases f ON f.id = t.fase_actual_id
   WHERE td.docente_id = ? ORDER BY t.updated_at DESC
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<div class="page-header"><h1>Trabajos asignados</h1><p>Un mismo trabajo nunca te asigna como Director y Evaluador a la vez.</p></div>
<div class="panel">
  <div class="table-responsive"><table class="table table-hover align-middle mb-0">
    <thead><tr><th>Trabajo</th><th>Mi función</th><th>Estudiante(s)</th><th>Fase</th><th>Estado</th><th></th></tr></thead>
    <tbody>
      <c:forEach var="t" items="${lista.rows}"><tr>
        <td><c:out value="${t.titulo}"/><br><small class="text-muted"><c:out value="${t.modalidad}"/></small></td>
        <td><span class="estado" data-estado="${t.funcion}">${t.funcion}</span></td>
        <td><c:out value="${empty t.estudiantes ? '—' : t.estudiantes}"/></td>
        <td><c:out value="${empty t.fase ? '—' : t.fase}"/></td>
        <td><span class="estado" data-estado="${t.estado}">${t.estado}</span></td>
        <td class="text-end"><a class="btn btn-sm btn-outline-secondary" href="${ctx}/panel.jsp?v=${t.funcion eq 'Director' ? 'director/evaluar-entregas' : 'evaluador/registrar-evaluacion'}&id=${t.id}">Abrir</a></td>
      </tr></c:forEach>
      <c:if test="${lista.rowCount eq 0}"><tr><td colspan="6" class="text-center text-muted py-4">No tienes trabajos asignados.</td></tr></c:if>
    </tbody></table></div>
</div>
