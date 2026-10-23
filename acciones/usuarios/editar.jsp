<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="administrador"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="usuarios/detalle"/>
<c:set var="destinoErr" value="usuarios/editar"/>
<c:set var="destinoId" value="${param.id}"/>
<c:set var="msgDuplicado" value="Ya existe otro usuario con ese documento o correo institucional."/>
<c:set var="nombre" value="${fn:trim(param.nombre)}"/>
<c:set var="documento" value="${fn:trim(param.documento)}"/>
<c:set var="correo" value="${fn:toLowerCase(fn:trim(param.correo))}"/>
<c:set var="telefono" value="${fn:trim(param.telefono)}"/>
<c:set var="nivel" value="${fn:trim(param.nivel)}"/>
<c:set var="claveNivel" value="|${nivel}|"/>
<sql:query var="rolActual">SELECT role_id FROM role_user WHERE user_id = ?<sql:param value="${param.id}"/></sql:query>

<c:if test="${rolActual.rowCount eq 0}"><c:set var="errValidacion" value="El usuario no existe."/></c:if>
<c:if test="${empty errValidacion and (fn:length(nombre) lt 3 or fn:length(nombre) gt 100)}"><c:set var="errValidacion" value="El nombre debe tener entre 3 y 100 caracteres."/></c:if>
<c:if test="${empty errValidacion and (fn:length(documento) lt 5 or fn:length(documento) gt 30 or fn:contains(documento, ' '))}"><c:set var="errValidacion" value="El documento debe tener entre 5 y 30 caracteres, sin espacios."/></c:if>
<c:if test="${empty errValidacion and (fn:length(correo) gt 150 or fn:indexOf(correo, '@') lt 1 or not fn:contains(correo, '.') or fn:contains(correo, ' '))}"><c:set var="errValidacion" value="Ingresa un correo institucional válido."/></c:if>
<c:if test="${empty errValidacion and not empty nivel and not fn:contains('|Tecnologico|Profesional|', claveNivel)}"><c:set var="errValidacion" value="Nivel académico no válido."/></c:if>
<c:if test="${empty errValidacion and rolActual.rows[0].role_id eq 6 and empty nivel}"><c:set var="errValidacion" value="El estudiante debe tener nivel académico."/></c:if>
<c:if test="${empty errValidacion and fn:length(telefono) gt 20}"><c:set var="errValidacion" value="El teléfono no puede superar 20 caracteres."/></c:if>

<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE users SET nombre = ?, documento = ?, nivel = NULLIF(?, ''), telefono = NULLIF(?, ''), email_institucional = ? WHERE id = ?
        <sql:param value="${nombre}"/><sql:param value="${documento}"/><sql:param value="${nivel}"/><sql:param value="${telefono}"/><sql:param value="${correo}"/><sql:param value="${param.id}"/>
      </sql:update>
      <c:set var="hEntidad" value="Usuario"/><c:set var="hId" value="${param.id}"/><c:set var="hAccion" value="Actualizar"/>
      <c:set var="hDesc" value="Datos del usuario actualizados"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Datos del usuario actualizados."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
