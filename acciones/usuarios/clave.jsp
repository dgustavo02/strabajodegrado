<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="usuarios/detalle"/>
<c:set var="destinoErr" value="usuarios/detalle"/>
<c:set var="destinoId" value="${param.id}"/>
<c:set var="clave" value="${param.clave}"/>
<c:if test="${fn:length(clave) lt 8 or fn:length(clave) gt 100 or clave ne param.confirmar}"><c:set var="errValidacion" value="La contraseña debe tener al menos 8 caracteres y coincidir con su confirmación."/></c:if>
<c:if test="${empty errValidacion}">
  <sql:query var="fuerza">SELECT IF(? REGEXP '[A-Za-z]' AND ? REGEXP '[0-9]', 1, 0) AS ok<sql:param value="${clave}"/><sql:param value="${clave}"/></sql:query>
  <c:if test="${fuerza.rows[0].ok ne 1}"><c:set var="errValidacion" value="La contraseña debe combinar letras y números."/></c:if>
</c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:query var="sl">SELECT LOWER(HEX(RANDOM_BYTES(16))) AS s</sql:query>
    <c:set var="sal" value="${sl.rows[0].s}"/>
    <sql:transaction>
      <sql:update>UPDATE users SET password = CONCAT(?, '$', SHA2(CONCAT(?, ?), 256)), intentos_fallidos = 0, bloqueado_hasta = NULL WHERE id = ?
        <sql:param value="${sal}"/><sql:param value="${sal}"/><sql:param value="${clave}"/><sql:param value="${param.id}"/>
      </sql:update>
      <c:set var="hEntidad" value="Usuario"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="Actualizar"/>
      <c:set var="hDesc" value="Contraseña restablecida por el administrador"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Contraseña restablecida."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
