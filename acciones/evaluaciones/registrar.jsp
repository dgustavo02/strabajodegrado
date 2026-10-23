<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="docente"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoId" value="${param.trabajo}"/>
<c:set var="decision" value="${param.decision}"/>
<c:set var="obs" value="${fn:trim(param.observaciones)}"/>
<c:set var="notaTxt" value="${fn:trim(param.calificacion)}"/>
<sql:query var="fun">SELECT funcion FROM trabajo_docentes WHERE trabajo_id = ? AND docente_id = ?<sql:param value="${param.trabajo}"/><sql:param value="${sessionScope.usuarioId}"/></sql:query>
<c:set var="funcion" value="${fun.rowCount gt 0 ? fun.rows[0].funcion : ''}"/>
<c:set var="destinoOk" value="${funcion eq 'Evaluador' ? 'evaluador/proyectos' : 'director/revisiones'}"/>
<c:set var="destinoErr" value="${funcion eq 'Evaluador' ? 'evaluador/registrar-evaluacion' : 'director/evaluar-entregas'}"/>
<sql:query var="ab">SELECT fase_id, estado FROM entregas WHERE trabajo_id = ? AND estado IN ('Pendiente','En revision','En comite') ORDER BY id DESC LIMIT 1<sql:param value="${param.trabajo}"/></sql:query>
<c:if test="${empty funcion}"><c:set var="errValidacion" value="No tienes una función asignada en este trabajo."/></c:if>
<c:if test="${empty errValidacion and ab.rowCount eq 0}"><c:set var="errValidacion" value="No hay entregas pendientes de revisión."/></c:if>
<c:if test="${empty errValidacion and not ((funcion eq 'Director' and ab.rows[0].estado eq 'Pendiente') or (funcion eq 'Evaluador' and ab.rows[0].estado eq 'En revision'))}"><c:set var="errValidacion" value="Todavía no es tu turno de revisar este trabajo."/></c:if>
<c:if test="${empty errValidacion and decision ne 'Aprobado' and decision ne 'Aplazado' and decision ne 'Rechazado'}"><c:set var="errValidacion" value="Decisión no válida."/></c:if>
<c:if test="${empty errValidacion and (fn:length(obs) lt 5 or fn:length(obs) gt 3000)}"><c:set var="errValidacion" value="Las observaciones son obligatorias (entre 5 y 3000 caracteres)."/></c:if>
<c:if test="${empty errValidacion and not empty notaTxt}">
  <c:set var="notaOk" value="false"/>
  <c:catch var="ignorar">
    <c:set var="nota" value="${notaTxt + 0}"/>
    <c:if test="${nota ge 0 and nota le 5}"><c:set var="notaOk" value="true"/></c:if>
  </c:catch>
  <c:if test="${notaOk ne 'true'}"><c:set var="errValidacion" value="La calificación debe ser un número entre 0 y 5 (usa punto decimal)."/></c:if>
</c:if>
<c:if test="${empty errValidacion}">
  <c:set var="faseId" value="${ab.rows[0].fase_id}"/>
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO evaluaciones (trabajo_id, fase_id, docente_id, calificacion, estado, observaciones) VALUES (?, ?, ?, NULLIF(?, ''), ?, ?)
        <sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${notaTxt}"/><sql:param value="${decision}"/><sql:param value="${obs}"/>
      </sql:update>
      <c:set var="nTrabajo" value="${param.trabajo}"/>
      <c:choose>
        <c:when test="${decision eq 'Aprobado' and funcion eq 'Director'}">
          <sql:update>UPDATE entregas SET estado = 'En revision' WHERE trabajo_id = ? AND fase_id = ? AND estado = 'Pendiente'<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <c:set var="nFuncion" value="Evaluador"/>
          <c:set var="nTitulo" value="Entrega lista para evaluar"/>
          <c:set var="nMensaje" value="El Director aprobó una entrega y quedó pendiente de tu evaluación."/>
          <c:set var="nTipo" value="Evaluacion"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-docente.jspf" %>
          <c:set var="nTitulo" value="Tu Director aprobó la entrega"/>
          <c:set var="nMensaje" value="Tu entrega fue aprobada por el Director y continúa en revisión."/>
          <c:set var="nTipo" value="Evaluacion"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
        </c:when>
        <c:when test="${decision eq 'Aprobado' and funcion eq 'Evaluador'}">
          <sql:update>UPDATE entregas SET estado = 'En comite' WHERE trabajo_id = ? AND fase_id = ? AND estado = 'En revision'<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <c:if test="${faseId eq 3}">
            <sql:update>INSERT INTO trabajo_fases (trabajo_id, fase_id, estado, fecha_inicio) VALUES (?, 4, 'En proceso', CURDATE()) ON DUPLICATE KEY UPDATE estado = 'En proceso'<sql:param value="${param.trabajo}"/></sql:update>
            <sql:update>UPDATE trabajos_grado SET fase_actual_id = 4 WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
          </c:if>
          <c:set var="nTitulo" value="Trabajo pendiente de decisión del Comité"/>
          <c:set var="nMensaje" value="Un trabajo fue aprobado por el Evaluador y espera la decisión del Comité."/>
          <c:set var="nTipo" value="Evaluacion"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
          <c:set var="nTitulo" value="Tu entrega pasó al Comité"/>
          <c:set var="nMensaje" value="Tu entrega fue aprobada en la revisión y pasó a decisión del Comité."/>
          <c:set var="nTipo" value="Evaluacion"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
        </c:when>
        <c:when test="${decision eq 'Aplazado'}">
          <sql:update>UPDATE entregas SET estado = 'Aplazada' WHERE trabajo_id = ? AND fase_id = ? AND estado IN ('Pendiente','En revision')<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajo_fases SET estado = 'Aplazada' WHERE trabajo_id = ? AND fase_id = ?<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajos_grado SET estado = 'Aplazado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
          <c:set var="nTitulo" value="Entrega aplazada"/>
          <c:set var="nMensaje" value="Tu entrega fue aplazada. Revisa las observaciones y vuelve a cargarla corregida."/>
          <c:set var="nTipo" value="Evaluacion"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
        </c:when>
        <c:otherwise>
          <c:set var="nTitulo" value="Trabajo rechazado"/>
          <c:set var="nMensaje" value="Tu trabajo de grado fue rechazado. Revisa las observaciones; puedes iniciar un nuevo proceso con una idea diferente."/>
          <c:set var="nTipo" value="Trabajo"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-estudiantes.jspf" %>
          <sql:update>UPDATE entregas SET estado = 'Rechazada' WHERE trabajo_id = ? AND fase_id = ? AND estado IN ('Pendiente','En revision')<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajo_fases SET estado = 'Rechazada' WHERE trabajo_id = ? AND fase_id = ?<sql:param value="${param.trabajo}"/><sql:param value="${faseId}"/></sql:update>
          <sql:update>UPDATE trabajos_grado SET estado = 'Rechazado' WHERE id = ?<sql:param value="${param.trabajo}"/></sql:update>
        </c:otherwise>
      </c:choose>
      <c:set var="hEntidad" value="Evaluacion"/><c:set var="hId" value="${param.trabajo}"/><c:set var="hAccion" value="Evaluar"/>
      <c:set var="hDesc" value="${funcion}: ${decision}. ${obs}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Evaluación registrada: ${fn:toLowerCase(decision)}."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
