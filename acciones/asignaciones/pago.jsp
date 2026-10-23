<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="comite"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="asignaciones/pagos"/>
<c:set var="destinoErr" value="asignaciones/pagos"/>
<c:set var="msgDuplicado" value="El compañero indicado ya está vinculado a otro trabajo o el estudiante ya tiene un trabajo."/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="obs" value="${fn:trim(param.observaciones)}"/>
<c:set var="segundo" value="${fn:trim(param.estudiante2)}"/>
<sql:query var="asig">
  SELECT ai.id, ai.estado, ai.estudiante_id, ai.idea_id, i.titulo
    FROM asignaciones_ideas ai JOIN ideas i ON i.id = ai.idea_id WHERE ai.id = ?
  <sql:param value="${param.id}"/>
</sql:query>
<c:if test="${asig.rowCount eq 0 or asig.rows[0].estado ne 'Pendiente_validacion'}"><c:set var="errValidacion" value="La solicitud no existe o ya fue procesada."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Validada' and decision ne 'Rechazada'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and decision eq 'Rechazada' and fn:length(obs) lt 5}"><c:set var="errValidacion" value="Para rechazar el pago debes escribir el motivo (mínimo 5 caracteres)."/></c:if>
<c:if test="${empty errValidacion and fn:length(obs) gt 500}"><c:set var="errValidacion" value="Las observaciones no pueden superar 500 caracteres."/></c:if>
<c:if test="${empty errValidacion and decision eq 'Validada' and param.condiciones ne 'on'}"><c:set var="errValidacion" value="Confirma que se verificaron las condiciones académicas (Fase 0)."/></c:if>
<c:if test="${empty errValidacion and not empty segundo and segundo eq asig.rows[0].estudiante_id}"><c:set var="errValidacion" value="El segundo estudiante debe ser diferente al solicitante."/></c:if>
<c:if test="${empty errValidacion}">
  <c:if test="${empty obs}"><c:set var="obs" value="Pago validado."/></c:if>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE asignaciones_ideas SET estado = ?, observaciones = ?, fecha_validacion = NOW() WHERE id = ? AND estado = 'Pendiente_validacion'
        <sql:param value="${decision}"/><sql:param value="${obs}"/><sql:param value="${param.id}"/>
      </sql:update>
      <c:choose>
        <c:when test="${decision eq 'Validada'}">
          <c:set var="ctAsignacion" value="${param.id}"/>
          <c:set var="ctEst1" value="${asig.rows[0].estudiante_id}"/>
          <c:set var="ctEst2" value="${segundo}"/>
          <c:set var="ctObs" value="Condiciones académicas verificadas por el Comité. ${obs}"/>
          <%@ include file="/WEB-INF/vistas/comunes/crear-trabajo.jspf" %>
        </c:when>
        <c:otherwise>
          <c:set var="nUsuario" value="${asig.rows[0].estudiante_id}"/>
          <c:set var="nTitulo" value="Pago rechazado"/>
          <c:set var="nMensaje" value="El comprobante de pago de la idea «${asig.rows[0].titulo}» fue rechazado. Motivo: ${obs}"/>
          <c:set var="nTipo" value="Idea"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar.jspf" %>
        </c:otherwise>
      </c:choose>
      <c:set var="hEntidad" value="Asignacion"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="${decision eq 'Validada' ? 'Aprobar' : 'Rechazar'}"/>
      <c:set var="hDesc" value="${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="${decision eq 'Validada' ? 'Pago validado: la idea quedó reservada y se creó el trabajo de grado.' : 'Pago rechazado: la idea volvió al banco de ideas.'}"/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
