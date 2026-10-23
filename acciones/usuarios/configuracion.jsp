<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="dashboard"/>
<c:set var="destinoErr" value="dashboard"/>
<c:set var="accion" value="${param.accion}"/>
<c:choose>
  <c:when test="${accion eq 'telefono'}">
    <c:set var="telefono" value="${fn:trim(param.telefono)}"/>
    <c:if test="${fn:length(telefono) gt 20 or fn:contains(telefono, '<') or fn:contains(telefono, '>')}"><c:set var="errValidacion" value="El teléfono no es válido (máximo 20 caracteres)."/></c:if>
    <c:if test="${empty errValidacion}">
      <c:catch var="err">
        <sql:transaction>
          <sql:update>UPDATE users SET telefono = NULLIF(?, '') WHERE id = ?<sql:param value="${telefono}"/><sql:param value="${sessionScope.usuarioId}"/></sql:update>
          <c:set var="hEntidad" value="Usuario"/><c:set var="hId" value="${sessionScope.usuarioId}"/><c:set var="hAccion" value="Actualizar"/>
          <c:set var="hDesc" value="El usuario actualizó su teléfono"/>
          <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
        </sql:transaction>
      </c:catch>
    </c:if>
    <c:set var="okMsg" value="Teléfono actualizado."/>
  </c:when>
  <c:when test="${accion eq 'clave'}">
    <c:set var="actual" value="${param.actual}"/>
    <c:set var="nueva" value="${param.nueva}"/>
    <sql:query var="verif">
      SELECT IF(password = CONCAT(SUBSTRING_INDEX(password, '$', 1), '$', SHA2(CONCAT(SUBSTRING_INDEX(password, '$', 1), ?), 256)), 1, 0) AS ok
        FROM users WHERE id = ?
      <sql:param value="${actual}"/><sql:param value="${sessionScope.usuarioId}"/>
    </sql:query>
    <c:if test="${verif.rowCount eq 0 or verif.rows[0].ok ne 1}"><c:set var="errValidacion" value="La contraseña actual no es correcta."/></c:if>
    <c:if test="${empty errValidacion and (fn:length(nueva) lt 8 or fn:length(nueva) gt 100 or nueva ne param.confirmar)}"><c:set var="errValidacion" value="La nueva contraseña debe tener al menos 8 caracteres y coincidir con su confirmación."/></c:if>
    <c:if test="${empty errValidacion and nueva eq actual}"><c:set var="errValidacion" value="La nueva contraseña debe ser diferente a la actual."/></c:if>
    <c:if test="${empty errValidacion}">
      <sql:query var="fuerza">SELECT IF(? REGEXP '[A-Za-z]' AND ? REGEXP '[0-9]', 1, 0) AS ok<sql:param value="${nueva}"/><sql:param value="${nueva}"/></sql:query>
      <c:if test="${fuerza.rows[0].ok ne 1}"><c:set var="errValidacion" value="La nueva contraseña debe combinar letras y números."/></c:if>
    </c:if>
    <c:if test="${empty errValidacion}">
      <c:catch var="err">
        <sql:query var="sl">SELECT LOWER(HEX(RANDOM_BYTES(16))) AS s</sql:query>
        <c:set var="sal" value="${sl.rows[0].s}"/>
        <sql:transaction>
          <sql:update>UPDATE users SET password = CONCAT(?, '$', SHA2(CONCAT(?, ?), 256)) WHERE id = ?
            <sql:param value="${sal}"/><sql:param value="${sal}"/><sql:param value="${nueva}"/><sql:param value="${sessionScope.usuarioId}"/>
          </sql:update>
          <c:set var="hEntidad" value="Usuario"/><c:set var="hId" value="${sessionScope.usuarioId}"/><c:set var="hAccion" value="Actualizar"/>
          <c:set var="hDesc" value="El usuario cambió su contraseña"/>
          <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
        </sql:transaction>
      </c:catch>
    </c:if>
    <c:set var="okMsg" value="Contraseña actualizada."/>
  </c:when>
  <c:otherwise><c:set var="errValidacion" value="Acción no válida."/></c:otherwise>
</c:choose>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>