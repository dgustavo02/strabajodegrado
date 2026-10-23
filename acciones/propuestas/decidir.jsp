<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="propuestas/listar"/>
<c:set var="destinoErr" value="propuestas/revisar"/>
<c:set var="destinoId" value="${param.id}"/>
<c:set var="msgDuplicado" value="El estudiante ya tiene una asignación o un trabajo en curso, o el compañero indicado ya está vinculado a otro trabajo."/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="obs" value="${fn:trim(param.observaciones)}"/>
<c:set var="segundo" value="${fn:trim(param.estudiante2)}"/>
<sql:query var="prop">SELECT id, estudiante_id, titulo, estado FROM propuestas_estudiantes WHERE id = ?<sql:param value="${param.id}"/></sql:query>
<c:if test="${prop.rowCount eq 0 or prop.rows[0].estado ne 'Pendiente'}"><c:set var="errValidacion" value="La propuesta no existe o ya fue revisada."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Aprobada' and decision ne 'Rechazada'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and decision eq 'Rechazada' and fn:length(obs) lt 5}"><c:set var="errValidacion" value="Para rechazar debes escribir el motivo (mínimo 5 caracteres)."/></c:if>
<c:if test="${empty errValidacion and fn:length(obs) gt 2000}"><c:set var="errValidacion" value="Las observaciones son demasiado largas."/></c:if>
<c:if test="${empty errValidacion and decision eq 'Aprobada' and param.condiciones ne 'on'}"><c:set var="errValidacion" value="Confirma que se verificaron las condiciones académicas (Fase 0)."/></c:if>
<c:if test="${empty errValidacion and not empty segundo and segundo eq prop.rows[0].estudiante_id}"><c:set var="errValidacion" value="El segundo estudiante debe ser diferente al autor de la propuesta."/></c:if>
<c:if test="${empty errValidacion}">
  <c:if test="${empty obs}"><c:set var="obs" value="Aprobada sin observaciones."/></c:if>
  <c:set var="tipoActa" value="${decision eq 'Aprobada' ? 'Aprobacion de propuesta' : 'Rechazo de propuesta'}"/>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE propuestas_estudiantes SET estado = ?, observaciones_comite = ?, fecha_decision = NOW() WHERE id = ? AND estado = 'Pendiente'
        <sql:param value="${decision}"/><sql:param value="${obs}"/><sql:param value="${param.id}"/>
      </sql:update>
      <sql:update>INSERT INTO actas (usuario_comite_id, propuesta_estudiante_id, tipo, decision, observaciones) VALUES (?, ?, ?, ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${param.id}"/><sql:param value="${tipoActa}"/><sql:param value="${decision}"/><sql:param value="${obs}"/>
      </sql:update>
      <c:if test="${decision eq 'Aprobada'}">
        <sql:update>INSERT INTO asignaciones_ideas (propuesta_estudiante_id, estudiante_id, comprobante_pago_url, estado, fecha_validacion) VALUES (?, ?, NULL, 'Validada', NOW())
          <sql:param value="${param.id}"/><sql:param value="${prop.rows[0].estudiante_id}"/>
        </sql:update>
        <sql:query var="asig">SELECT LAST_INSERT_ID() AS id</sql:query>
        <c:set var="ctAsignacion" value="${asig.rows[0].id}"/>
        <c:set var="ctEst1" value="${prop.rows[0].estudiante_id}"/>
        <c:set var="ctEst2" value="${segundo}"/>
        <c:set var="ctObs" value="Condiciones académicas verificadas por el Comité. ${obs}"/>
        <%@ include file="/WEB-INF/vistas/comunes/crear-trabajo.jspf" %>
      </c:if>
      <c:if test="${decision eq 'Rechazada'}">
        <c:set var="nUsuario" value="${prop.rows[0].estudiante_id}"/>
        <c:set var="nTitulo" value="Propuesta rechazada"/>
        <c:set var="nMensaje" value="Tu propuesta «${prop.rows[0].titulo}» fue rechazada. Observaciones: ${obs} Puedes registrar una nueva propuesta o elegir una idea del banco."/>
        <c:set var="nTipo" value="Idea"/>
        <%@ include file="/WEB-INF/vistas/comunes/notificar.jspf" %>
      </c:if>
      <c:set var="hEntidad" value="Propuesta"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="${decision eq 'Aprobada' ? 'Aprobar' : 'Rechazar'}"/>
      <c:set var="hDesc" value="${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Decisión registrada: propuesta ${fn:toLowerCase(decision)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
