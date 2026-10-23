<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="propuestas/crear"/>
<c:set var="destinoErr" value="propuestas/crear"/>
<c:set var="titulo" value="${fn:trim(param.titulo)}"/>
<c:set var="descripcion" value="${fn:trim(param.descripcion)}"/>
<c:set var="modalidad" value="${fn:trim(param.modalidad)}"/>
<c:set var="url" value="${fn:trim(param.url)}"/>
<c:set var="claveMod" value="|${modalidad}|"/>
<sql:query var="yaTiene">SELECT
    (SELECT COUNT(*) FROM trabajo_estudiantes WHERE estudiante_id = ?) AS trabajos,
    (SELECT COUNT(*) FROM asignaciones_ideas WHERE estudiante_id = ? AND estado IN ('Pendiente_validacion','Validada')) AS asignaciones,
    (SELECT COUNT(*) FROM propuestas_estudiantes WHERE estudiante_id = ? AND estado = 'Pendiente') AS propuestas
  <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/><sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${yaTiene.rows[0].trabajos gt 0 or yaTiene.rows[0].asignaciones gt 0}"><c:set var="errValidacion" value="Ya tienes un trabajo de grado o una asignación en curso."/></c:if>
<c:if test="${empty errValidacion and yaTiene.rows[0].propuestas gt 0}"><c:set var="errValidacion" value="Ya tienes una propuesta pendiente de revisión."/></c:if>
<c:if test="${empty errValidacion and (fn:length(titulo) lt 5 or fn:length(titulo) gt 200)}"><c:set var="errValidacion" value="El título debe tener entre 5 y 200 caracteres."/></c:if>
<c:if test="${empty errValidacion and (fn:length(descripcion) lt 20 or fn:length(descripcion) gt 5000)}"><c:set var="errValidacion" value="La descripción debe tener entre 20 y 5000 caracteres."/></c:if>
<c:if test="${empty errValidacion and not fn:contains('|Desarrollo tecnologico|Emprendimiento|Monografia|Proyecto de investigacion|', claveMod)}"><c:set var="errValidacion" value="Selecciona una modalidad válida."/></c:if>
<c:if test="${empty errValidacion and (not fn:startsWith(url, 'https://') or fn:length(url) gt 500 or fn:contains(url, ' '))}"><c:set var="errValidacion" value="El comprobante de pago debe ser un enlace que empiece por https:// (sin espacios, máximo 500 caracteres)."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO propuestas_estudiantes (estudiante_id, titulo, descripcion, modalidad, comprobante_pago_url) VALUES (?, ?, ?, ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${titulo}"/><sql:param value="${descripcion}"/><sql:param value="${modalidad}"/><sql:param value="${url}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Nueva propuesta de estudiante"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} registró la propuesta: ${titulo}"/>
      <c:set var="nTipo" value="Idea"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Propuesta"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="Propuesta registrada: ${titulo}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Propuesta enviada al Comité para su revisión."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
