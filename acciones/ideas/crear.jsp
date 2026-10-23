<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="docente"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="ideas/mis-ideas"/>
<c:set var="destinoErr" value="ideas/crear"/>
<c:set var="titulo" value="${fn:trim(param.titulo)}"/>
<c:set var="descripcion" value="${fn:trim(param.descripcion)}"/>
<c:set var="modalidad" value="${fn:trim(param.modalidad)}"/>
<c:set var="claveMod" value="|${modalidad}|"/>
<c:if test="${fn:length(titulo) lt 5 or fn:length(titulo) gt 200}"><c:set var="errValidacion" value="El título debe tener entre 5 y 200 caracteres."/></c:if>
<c:if test="${empty errValidacion and (fn:length(descripcion) lt 20 or fn:length(descripcion) gt 5000)}"><c:set var="errValidacion" value="La descripción debe tener entre 20 y 5000 caracteres."/></c:if>
<c:if test="${empty errValidacion and not fn:contains('|Desarrollo tecnologico|Emprendimiento|Monografia|Proyecto de investigacion|', claveMod)}"><c:set var="errValidacion" value="Selecciona una modalidad válida."/></c:if>
<c:if test="${empty errValidacion}">
  <c:catch var="err">
    <sql:transaction>
      <sql:update>INSERT INTO ideas (docente_id, titulo, descripcion, modalidad) VALUES (?, ?, ?, ?)
        <sql:param value="${sessionScope.usuarioId}"/><sql:param value="${titulo}"/><sql:param value="${descripcion}"/><sql:param value="${modalidad}"/>
      </sql:update>
      <sql:query var="nueva">SELECT LAST_INSERT_ID() AS id</sql:query>
      <c:set var="nTitulo" value="Nueva idea por revisar"/>
      <c:set var="nMensaje" value="El docente ${sessionScope.usuarioNombre} propuso la idea: ${titulo}"/>
      <c:set var="nTipo" value="Idea"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
      <c:set var="hEntidad" value="Idea"/><c:set var="hId" value="${nueva.rows[0].id}"/><c:set var="hAccion" value="Crear"/>
      <c:set var="hDesc" value="Idea registrada: ${titulo}"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Idea registrada. Quedó pendiente de revisión del Comité."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
