<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="entregas/listar"/>
<c:set var="destinoErr" value="entregas/registrar"/>
<c:set var="msgDuplicado" value="Ya existe una entrega con esa versión."/>
<sql:query var="tr">
  SELECT t.id, t.estado, t.fase_actual_id,
         (SELECT COUNT(*) FROM entregas e WHERE e.trabajo_id = t.id AND e.fase_id = t.fase_actual_id) AS previas
    FROM trabajo_estudiantes te JOIN trabajos_grado t ON t.id = te.trabajo_id WHERE te.estudiante_id = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:choose>
  <c:when test="${tr.rowCount eq 0}"><c:set var="errValidacion" value="No tienes un trabajo de grado activo."/></c:when>
  <c:when test="${tr.rows[0].previas gt 0}"><c:set var="errValidacion" value="Ya registraste la entrega de esta fase. Si fue aplazada, usa la opción de corregir."/></c:when>
  <c:when test="${tr.rows[0].fase_actual_id eq 3 and tr.rows[0].estado eq 'Pendiente'}">
    <c:set var="faseEntrega" value="3"/>
    <c:set var="tipos" value="${fn:split('Anteproyecto', ',')}"/>
  </c:when>
  <c:when test="${tr.rows[0].fase_actual_id eq 5 and tr.rows[0].estado eq 'Aprobado'}">
    <c:set var="faseEntrega" value="5"/>
    <c:set var="tipos" value="${fn:split('Documento final,Manual,Codigo fuente', ',')}"/>
  </c:when>
  <c:otherwise><c:set var="errValidacion" value="Todavía no hay una entrega habilitada para tu trabajo."/></c:otherwise>
</c:choose>
<c:if test="${empty errValidacion}">
  <c:set var="titulo" value="${fn:trim(param.titulo)}"/>
  <c:if test="${faseEntrega eq 3 and (fn:length(titulo) lt 5 or fn:length(titulo) gt 200)}"><c:set var="errValidacion" value="El título debe tener entre 5 y 200 caracteres."/></c:if>
  <c:forEach var="tp" items="${tipos}" varStatus="s">
    <c:set var="u" value="${fn:trim(paramValues.url[s.index])}"/>
    <c:if test="${empty errValidacion and (not fn:startsWith(u, 'https://') or fn:length(u) gt 1000 or fn:contains(u, ' '))}">
      <c:set var="errValidacion" value="El enlace de «${tp}» debe empezar por https:// (sin espacios, máximo 1000 caracteres)."/>
    </c:if>
  </c:forEach>
</c:if>
<c:if test="${empty errValidacion}">
  <c:set var="trabajoId" value="${tr.rows[0].id}"/>
  <c:catch var="err">
    <sql:transaction>
      <c:forEach var="tp" items="${tipos}" varStatus="s">
        <sql:update>INSERT INTO entregas (trabajo_id, fase_id, estudiante_id, titulo, tipo, url, version, estado)
          SELECT ?, ?, ?, ?, ?, ?, COALESCE(MAX(version), 0) + 1, 'Pendiente' FROM entregas WHERE trabajo_id = ? AND fase_id = ? AND tipo = ?
          <sql:param value="${trabajoId}"/><sql:param value="${faseEntrega}"/><sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${faseEntrega eq 3 ? titulo : tp}"/><sql:param value="${tp}"/><sql:param value="${fn:trim(paramValues.url[s.index])}"/>
          <sql:param value="${trabajoId}"/><sql:param value="${faseEntrega}"/><sql:param value="${tp}"/>
        </sql:update>
      </c:forEach>
      <sql:update>UPDATE trabajos_grado SET estado = 'En revision' WHERE id = ?<sql:param value="${trabajoId}"/></sql:update>
      <c:set var="nTrabajo" value="${trabajoId}"/><c:set var="nFuncion" value="Director"/>
      <c:set var="nTitulo" value="Nueva entrega por revisar"/>
      <c:set var="nMensaje" value="${sessionScope.usuarioNombre} registró ${faseEntrega eq 3 ? 'su anteproyecto' : 'el trabajo final'} para tu revisión."/>
      <c:set var="nTipo" value="Entrega"/>
      <%@ include file="/WEB-INF/vistas/comunes/notificar-docente.jspf" %>
      <c:set var="hEntidad" value="Entrega"/><c:set var="hId" value="${trabajoId}"/><c:set var="hAccion" value="Subir"/>
      <c:set var="hDesc" value="Entrega registrada (${faseEntrega eq 3 ? 'anteproyecto' : 'trabajo final'})"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Entrega registrada. Quedó pendiente de la revisión de tu Director."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
