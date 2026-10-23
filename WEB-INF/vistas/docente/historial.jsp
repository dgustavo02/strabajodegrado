<sql:query var="evs">
  SELECT ev.calificacion, ev.estado, ev.observaciones, ev.fecha_evaluacion, f.nombre AS fase, COALESCE(i.titulo, pe.titulo) AS titulo, t.id AS trabajo_id,
         (SELECT td.funcion FROM trabajo_docentes td WHERE td.trabajo_id = ev.trabajo_id AND td.docente_id = ev.docente_id) AS funcion
    FROM evaluaciones ev JOIN trabajos_grado t ON t.id = ev.trabajo_id JOIN fases f ON f.id = ev.fase_id
    JOIN asignaciones_ideas ai ON ai.id = t.asignacion_idea_id
    LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
   WHERE ev.docente_id = ? ORDER BY ev.id DESC LIMIT 50
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="hist">SELECT entidad, accion, descripcion, fecha FROM historial WHERE usuario_id = ? ORDER BY id DESC LIMIT 30<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<div class="page-header"><h1>Historial</h1><p>Tus revisiones, calificaciones y acciones recientes.</p></div>
<div class="panel">
  <h2>Revisiones realizadas</h2>
  <div class="table-responsive"><table class="table table-sm align-middle mb-0">
    <thead><tr><th>Trabajo</th><th>Función</th><th>Fase</th><th>Decisión</th><th>Nota</th><th>Observaciones</th><th>Fecha</th></tr></thead>
    <tbody>
      <c:forEach var="v" items="${evs.rows}"><tr>
        <td><c:out value="${v.titulo}"/></td><td><c:out value="${empty v.funcion ? '—' : v.funcion}"/></td><td><c:out value="${v.fase}"/></td>
        <td><span class="estado" data-estado="${v.estado}">${v.estado}</span></td><td><c:out value="${empty v.calificacion ? '—' : v.calificacion}"/></td>
        <td class="texto-largo small"><c:out value="${v.observaciones}"/></td><td>${fn:substring(v.fecha_evaluacion, 8, 10)}/${fn:substring(v.fecha_evaluacion, 5, 7)}/${fn:substring(v.fecha_evaluacion, 0, 4)}</td>
      </tr></c:forEach>
      <c:if test="${evs.rowCount eq 0}"><tr><td colspan="7" class="text-center text-muted py-3">Aún no has registrado evaluaciones.</td></tr></c:if>
    </tbody></table></div>
</div>
<div class="panel">
  <h2>Actividad reciente</h2>
  <div class="table-responsive"><table class="table table-sm mb-0">
    <thead><tr><th>Fecha</th><th>Entidad</th><th>Acción</th><th>Detalle</th></tr></thead>
    <tbody>
      <c:forEach var="h" items="${hist.rows}"><tr>
        <td class="text-nowrap">${fn:substring(h.fecha, 8, 10)}/${fn:substring(h.fecha, 5, 7)}/${fn:substring(h.fecha, 0, 4)} ${fn:substring(h.fecha, 11, 16)}</td><td><c:out value="${h.entidad}"/></td><td><c:out value="${h.accion}"/></td>
        <td class="small"><c:out value="${h.descripcion}"/></td>
      </tr></c:forEach>
      <c:if test="${hist.rowCount eq 0}"><tr><td colspan="4" class="text-center text-muted py-3">Sin actividad.</td></tr></c:if>
    </tbody></table></div>
</div>
