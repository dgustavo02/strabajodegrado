<%@ include file="/WEB-INF/vistas/comunes/mi-trabajo.jspf" %>
<sql:query var="asigs">
  SELECT ai.id, ai.estado, ai.observaciones, i.titulo FROM asignaciones_ideas ai JOIN ideas i ON i.id = ai.idea_id
   WHERE ai.estudiante_id = ? AND ai.estado IN ('Pendiente_validacion','Rechazada') ORDER BY ai.id DESC LIMIT 3
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="props">SELECT id, titulo, estado, observaciones_comite FROM propuestas_estudiantes WHERE estudiante_id = ? ORDER BY id DESC LIMIT 3<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="cerrado">
  SELECT COALESCE(i.titulo, pe.titulo) AS titulo FROM asignaciones_ideas ai LEFT JOIN ideas i ON i.id = ai.idea_id LEFT JOIN propuestas_estudiantes pe ON pe.id = ai.propuesta_estudiante_id
   WHERE ai.estudiante_id = ? AND ai.estado = 'Cerrada' ORDER BY ai.id DESC LIMIT 1
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<sql:query var="nn">SELECT COUNT(*) AS n FROM notificaciones WHERE usuario_id = ? AND leida = 0<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="miPerfil">SELECT nombre, documento, email_institucional AS correo, telefono, nivel FROM users WHERE id = ?<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<sql:query var="misTyt">SELECT url, estado, respuesta, fecha_solicitud FROM solicitudes WHERE usuario_id = ? AND tipo = 'Prueba TyT' ORDER BY id DESC LIMIT 3<sql:param value="${sessionScope.usuarioId}"/></sql:query>
<div class="page-header d-flex flex-wrap justify-content-between align-items-center gap-2">
  <div><h1>Hola, <c:out value="${sessionScope.usuarioNombre}"/></h1><p>Resumen de tu trabajo de grado y tareas pendientes.</p></div>
  <div class="d-flex flex-wrap gap-2">
    <button class="btn btn-outline-primary" type="button" data-bs-toggle="modal" data-bs-target="#modalTyt"><i class="bi bi-link-45deg"></i> Prueba TyT</button>
    <button class="btn btn-outline-primary" type="button" data-bs-toggle="modal" data-bs-target="#modalPqrs"><i class="bi bi-chat-left-text"></i> PQRS</button>
    <button class="btn btn-outline-secondary" type="button" data-bs-toggle="modal" data-bs-target="#modalConfig"><i class="bi bi-gear"></i> Configuración</button>
  </div>
</div>
<c:choose>
  <c:when test="${tengoTrabajo}">
    <div class="row g-3 mb-3">
      <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-flag"></i></div><div><div class="stat-num fs-6">${mt.fase}</div><div class="stat-label">Fase actual</div></div></div></div>
      <div class="col-6 col-lg-3"><div class="stat-card"><div class="stat-icon"><i class="bi bi-activity"></i></div><div><div class="stat-num fs-6"><span class="estado" data-estado="${mt.estado}">${mt.estado}</span></div><div class="stat-label">Estado</div></div></div></div>
      <div class="col-6 col-lg-3"><div class="stat-card ${mt.vencido eq 1 ? 'peligro' : ''}"><div class="stat-icon"><i class="bi bi-calendar-event"></i></div><div><div class="stat-num fs-6"><c:choose><c:when test="${empty mt.limite_final}">—</c:when><c:otherwise>${fn:substring(mt.limite_final, 8, 10)}/${fn:substring(mt.limite_final, 5, 7)}/${fn:substring(mt.limite_final, 0, 4)}</c:otherwise></c:choose></div><div class="stat-label">Fecha límite trabajo final</div></div></div></div>
      <div class="col-6 col-lg-3"><a class="stat-card ${nn.rows[0].n gt 0 ? 'alerta' : ''}" href="${ctx}/panel.jsp?v=notificaciones"><div class="stat-icon"><i class="bi bi-bell"></i></div><div><div class="stat-num">${nn.rows[0].n}</div><div class="stat-label">Notificaciones nuevas</div></div></a></div>
    </div>
    <div class="panel">
      <h2><c:out value="${mt.titulo}"/></h2>
      <p class="text-muted mb-3"><c:out value="${mt.modalidad}"/> · ${mt.n_est eq 1 ? 'Individual' : 'En pareja'}</p>
      <h3 class="h6">Tareas pendientes</h3>
      <c:choose>
        <c:when test="${puedeCorregir}"><div class="alert alert-warning mb-2">Tu entrega fue aplazada. Revisa las observaciones y vuelve a cargarla. <a class="btn btn-sm btn-warning ms-2" href="${ctx}/panel.jsp?v=entregas/corregir">Corregir entrega</a></div></c:when>
        <c:when test="${puedeAnteproyecto}"><div class="alert alert-info mb-2">Ya puedes registrar tu anteproyecto. <a class="btn btn-sm btn-primary ms-2" href="${ctx}/panel.jsp?v=entregas/registrar">Registrar anteproyecto</a></div></c:when>
        <c:when test="${puedeFinal}"><div class="alert alert-info mb-2">Registra el documento final, el manual y el código fuente antes del <strong>${fn:substring(mt.limite_final, 8, 10)}/${fn:substring(mt.limite_final, 5, 7)}/${fn:substring(mt.limite_final, 0, 4)}</strong>. <a class="btn btn-sm btn-primary ms-2" href="${ctx}/panel.jsp?v=entregas/registrar">Registrar trabajo final</a></div></c:when>
        <c:when test="${mt.estado eq 'En revision'}"><div class="alert alert-secondary mb-2">Tu entrega está en revisión. Te avisaremos cuando haya una decisión.</div></c:when>
        <c:when test="${mt.fase_actual_id eq 2}"><div class="alert alert-secondary mb-2">El Comité está asignando tu Director y Evaluador.</div></c:when>
        <c:when test="${mt.estado eq 'Finalizado'}"><div class="alert alert-success mb-2">¡Tu trabajo de grado fue aprobado y finalizado!</div></c:when>
        <c:otherwise><div class="text-muted">No tienes tareas pendientes.</div></c:otherwise>
      </c:choose>
      <c:if test="${mt.vencido eq 1 and mt.estado ne 'Finalizado'}"><div class="alert alert-danger mb-2">El plazo del trabajo final venció. Registra una solicitud de prórroga al Comité.</div></c:if>
      <a class="btn btn-outline-primary btn-sm mt-2" href="${ctx}/panel.jsp?v=trabajo/mi-trabajo">Ver mi trabajo</a>
    </div>
    <h2 class="h5 mb-3">Fases de mi proyecto</h2>
    <c:set var="fpTrabajo" value="${mt.id}"/><c:set var="fpVerEvaluador" value="0"/><c:set var="fpVerPrivados" value="1"/>
    <%@ include file="/WEB-INF/vistas/comunes/fases-proyecto.jspf" %>
  </c:when>
  <c:otherwise>
    <c:if test="${cerrado.rowCount gt 0}"><div class="alert alert-danger">Tu trabajo anterior («<c:out value="${cerrado.rows[0].titulo}"/>») fue rechazado. Puedes iniciar un nuevo proceso con una idea diferente.</div></c:if>
    <div class="panel">
      <h2>Inicia tu trabajo de grado</h2>
      <p class="text-muted">Elige una idea aprobada del banco o registra tu propia propuesta.</p>
      <a class="btn btn-primary" href="${ctx}/panel.jsp?v=ideas/banco"><i class="bi bi-lightbulb"></i> Ver banco de ideas</a>
      <a class="btn btn-outline-primary ms-2" href="${ctx}/panel.jsp?v=propuestas/crear"><i class="bi bi-journal-plus"></i> Registrar mi propuesta</a>
    </div>
    <c:if test="${asigs.rowCount gt 0}">
      <div class="panel"><h2>Mis solicitudes de idea</h2>
        <c:forEach var="a" items="${asigs.rows}"><div class="d-flex justify-content-between border-bottom py-2"><span><c:out value="${a.titulo}"/><c:if test="${a.estado eq 'Rechazada'}"><br><small class="text-danger">Motivo: <c:out value="${a.observaciones}"/></small></c:if></span><span class="estado" data-estado="${a.estado}">${a.estado eq 'Pendiente_validacion' ? 'Pago por validar' : a.estado}</span></div></c:forEach>
      </div>
    </c:if>
    <c:if test="${props.rowCount gt 0}">
      <div class="panel"><h2>Mis propuestas</h2>
        <c:forEach var="p" items="${props.rows}"><div class="d-flex justify-content-between border-bottom py-2"><span><c:out value="${p.titulo}"/><c:if test="${p.estado eq 'Rechazada'}"><br><small class="text-danger">Motivo: <c:out value="${p.observaciones_comite}"/></small></c:if></span><span class="estado" data-estado="${p.estado}">${p.estado}</span></div></c:forEach>
      </div>
    </c:if>
  </c:otherwise>
</c:choose>
<%-- Ventanas emergentes del inicio --%>
<div class="modal fade" id="modalTyt" tabindex="-1" aria-labelledby="tituloTyt" aria-hidden="true">
  <div class="modal-dialog"><div class="modal-content">
    <form method="post" action="${ctx}/acciones/solicitudes/tyt.jsp" class="validar" novalidate>
      <input type="hidden" name="csrf" value="${sessionScope.csrf}">
      <div class="modal-header"><h2 class="modal-title h5" id="tituloTyt">Enlace de la prueba TyT</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button></div>
      <div class="modal-body">
        <label class="form-label" for="urlTyt">Enlace del resultado</label>
        <input class="form-control" type="url" id="urlTyt" name="url" maxlength="500" placeholder="https://..." required pattern="https://.*">
        <div class="form-text">Debe empezar por https://. Solo se guarda el enlace; el Comité lo verificará.</div>
        <c:if test="${misTyt.rowCount gt 0}">
          <hr><div class="dato-etiqueta mb-1">Enlaces enviados</div>
          <c:forEach var="y" items="${misTyt.rows}">
            <div class="d-flex justify-content-between align-items-center small border-bottom py-1">
              <a href="<c:out value='${y.url}'/>" target="_blank" rel="noopener noreferrer">${fn:substring(y.fecha_solicitud, 8, 10)}/${fn:substring(y.fecha_solicitud, 5, 7)}/${fn:substring(y.fecha_solicitud, 0, 4)} · abrir</a>
              <span class="estado" data-estado="${y.estado}">${y.estado eq 'Aprobada' ? 'Verificada' : y.estado}</span>
            </div>
          </c:forEach>
        </c:if>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-primary" type="submit">Enviar enlace</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="modalPqrs" tabindex="-1" aria-labelledby="tituloPqrs" aria-hidden="true">
  <div class="modal-dialog"><div class="modal-content">
    <form method="post" action="${ctx}/acciones/solicitudes/pqrs.jsp" class="validar" novalidate>
      <input type="hidden" name="csrf" value="${sessionScope.csrf}">
      <div class="modal-header"><h2 class="modal-title h5" id="tituloPqrs">Enviar PQRS</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label" for="tipoPqrs">Tipo</label>
          <select class="form-select" id="tipoPqrs" name="tipo" required><option value="">Selecciona…</option>
            <option value="Peticion">Petición</option><option value="Queja">Queja</option><option value="Reclamo">Reclamo</option><option value="Sugerencia">Sugerencia</option></select></div>
        <div class="mb-3"><label class="form-label" for="asuntoPqrs">Asunto</label><input class="form-control" id="asuntoPqrs" name="asunto" minlength="5" maxlength="120" required></div>
        <div class="mb-1"><label class="form-label" for="mensajePqrs">Mensaje</label><textarea class="form-control" id="mensajePqrs" name="mensaje" rows="5" minlength="10" maxlength="3000" required data-max="3000"></textarea></div>
        <div class="form-text">La respuesta del Comité aparecerá en <a href="${ctx}/panel.jsp?v=solicitudes/listar">Solicitudes</a>.</div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-primary" type="submit">Enviar</button></div>
    </form>
  </div></div>
</div>

<div class="modal fade" id="modalConfig" tabindex="-1" aria-labelledby="tituloConfig" aria-hidden="true">
  <div class="modal-dialog"><div class="modal-content">
    <div class="modal-header"><h2 class="modal-title h5" id="tituloConfig">Configuración de la cuenta</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button></div>
    <div class="modal-body">
      <ul class="nav nav-tabs mb-3" role="tablist">
        <li class="nav-item" role="presentation"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#cfgDatos" type="button" role="tab">Mis datos</button></li>
        <li class="nav-item" role="presentation"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#cfgClave" type="button" role="tab">Contraseña</button></li>
      </ul>
      <div class="tab-content">
        <div class="tab-pane fade show active" id="cfgDatos" role="tabpanel">
          <c:set var="pf" value="${miPerfil.rows[0]}"/>
          <dl class="row small mb-3">
            <dt class="col-4 dato-etiqueta">Nombre</dt><dd class="col-8"><c:out value="${pf.nombre}"/></dd>
            <dt class="col-4 dato-etiqueta">Documento</dt><dd class="col-8"><c:out value="${pf.documento}"/></dd>
            <dt class="col-4 dato-etiqueta">Correo</dt><dd class="col-8"><c:out value="${pf.correo}"/></dd>
            <dt class="col-4 dato-etiqueta">Nivel</dt><dd class="col-8"><c:out value="${empty pf.nivel ? '—' : pf.nivel}"/></dd>
          </dl>
          <form method="post" action="${ctx}/acciones/usuarios/configuracion.jsp" class="validar" novalidate>
            <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="telefono">
            <label class="form-label" for="telCfg">Teléfono</label>
            <div class="input-group"><input class="form-control" id="telCfg" name="telefono" maxlength="20" value="<c:out value='${pf.telefono}'/>"><button class="btn btn-primary" type="submit">Guardar</button></div>
            <div class="form-text">Para cambiar tu nombre, documento o correo, comunícate con el administrador.</div>
          </form>
        </div>
        <div class="tab-pane fade" id="cfgClave" role="tabpanel">
          <form method="post" action="${ctx}/acciones/usuarios/configuracion.jsp" class="validar" novalidate autocomplete="off">
            <input type="hidden" name="csrf" value="${sessionScope.csrf}"><input type="hidden" name="accion" value="clave">
            <div class="mb-3"><label class="form-label" for="claveActual">Contraseña actual</label><input class="form-control" type="password" id="claveActual" name="actual" maxlength="100" required autocomplete="current-password"></div>
            <div class="mb-3"><label class="form-label" for="claveNueva">Nueva contraseña</label><input class="form-control" type="password" id="claveNueva" name="nueva" minlength="8" maxlength="100" required autocomplete="new-password"><div class="form-text">Mínimo 8 caracteres, con letras y números.</div></div>
            <div class="mb-3"><label class="form-label" for="claveConf">Confirmar nueva contraseña</label><input class="form-control" type="password" id="claveConf" name="confirmar" minlength="8" maxlength="100" required autocomplete="new-password"></div>
            <button class="btn btn-primary" type="submit">Cambiar contraseña</button>
          </form>
        </div>
      </div>
    </div>
  </div></div>
</div>
