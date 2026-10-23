<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="solicitudes/listar"/>
<c:set var="destinoErr" value="solicitudes/listar"/>
<c:set var="tipo" value="${fn:trim(param.tipo)}"/>
<c:set var="descripcion" value="${fn:trim(param.descripcion)}"/>
<c:set var="claveTipo" value="|${tipo}|"/>
<sql:query var="tr">
  SELECT t.id FROM trabajo_estudiantes te JOIN trabajos_grado t ON t.id = te.trabajo_id
   WHERE te.estudiante_id = ? AND t.estado NOT IN ('Rechazado','Finalizado')
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${tr.rowCount eq 0}"><c:set var="errValidacion" value="Necesitas un trabajo de grado activo para registrar solicitudes."/></c:if>
<c:if test="${empty errValidacion and not fn:contains('|Cambio de proyecto|Cambio de Director|Prorroga|Solicitud general|', claveTipo)}"><c:set var="errValidacion" value="Selecciona un tipo de solicitud válido."/></c:if>
<c:if test="${empty errValidacion and (fn:length(descripcion) lt 10 or fn:length(descripcion) gt 3000)}"><c:set var="errValidacion" value="Describe tu solicitud (entre 10 y 3000 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO solicitudes (usuario_id, trabajo_id, tipo, descripcion) VALUES (?, ?, ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${tr.rows[0].id}"/><sql:param value="${tipo}"/><sql:param value="${descripcion}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Nueva solicitud"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} registró una solicitud: ${tipo}."/>
      <c:set var="nTipo" value="Solicitud"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Solicitud"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="${tipo}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Solicitud enviada al Comité."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
