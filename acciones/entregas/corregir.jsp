<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="rolRequerido" value="estudiante"/>
<%@ include file="/WEB-INF/vistas/comunes/guardia-accion.jspf" %>
<c:set var="destinoOk" value="entregas/listar"/>
<c:set var="destinoErr" value="entregas/corregir"/>
<c:set var="msgDuplicado" value="Ya existe una entrega con esa versión."/>
<sql:query var="tr">
  SELECT t.id, t.estado FROM trabajo_estudiantes te JOIN trabajos_grado t ON t.id = te.trabajo_id WHERE te.estudiante_id = ?
  <sql:param value="${sessionScope.usuarioId}"/>
</sql:query>
<c:if test="${tr.rowCount eq 0 or tr.rows[0].estado ne 'Aplazado'}"><c:set var="errValidacion" value="Tu trabajo no tiene correcciones pendientes."/></c:if>
<c:if test="${empty errValidacion}">
  <c:set var="trabajoId" value="${tr.rows[0].id}"/>
  <sql:query var="ap">SELECT fase_id FROM entregas WHERE trabajo_id = ? AND estado = 'Aplazada' ORDER BY id DESC LIMIT 1<sql:param value="${trabajoId}"/></sql:query>
  <%-- Quién aplazó por última vez define a quién vuelve la entrega corregida: al Comité si fue el Comité;
       si fue el Director o el Evaluador, al Director, porque la base (trg_evaluaciones_bi) solo deja
       evaluar al Evaluador después de que el Director apruebe la última versión entregada --%>
  <sql:query var="orig">
    SELECT origen FROM (
      SELECT td.funcion AS origen, ev.fecha_evaluacion AS f, 1 AS ord, ev.id AS rid
        FROM evaluaciones ev JOIN trabajo_docentes td ON td.trabajo_id = ev.trabajo_id AND td.docente_id = ev.docente_id
       WHERE ev.trabajo_id = ?
      UNION ALL
      SELECT 'Comite', a.fecha_acta, 2, a.id FROM actas a WHERE a.trabajo_id = ?
    ) x ORDER BY f DESC, ord DESC, rid DESC LIMIT 1
    <sql:param value="${trabajoId}"/><sql:param value="${trabajoId}"/>
  </sql:query>
  <c:if test="${ap.rowCount eq 0}"><c:set var="errValidacion" value="No se encontró la entrega aplazada."/></c:if>
</c:if>
<c:if test="${empty errValidacion}">
  <c:set var="faseEntrega" value="${ap.rows[0].fase_id}"/>
  <c:set var="origen" value="${orig.rowCount eq 0 ? 'Director' : orig.rows[0].origen}"/>
  <c:choose>
    <c:when test="${origen eq 'Comite'}"><c:set var="estadoNuevo" value="En comite"/><c:set var="funcionNotif" value=""/></c:when>
    <c:otherwise><c:set var="estadoNuevo" value="Pendiente"/><c:set var="funcionNotif" value="Director"/></c:otherwise>
  </c:choose>
  <c:choose>
    <c:when test="${faseEntrega eq 3}"><c:set var="tipos" value="${fn:split('Anteproyecto', ',')}"/></c:when>
    <c:otherwise><c:set var="tipos" value="${fn:split('Documento final,Manual,Codigo fuente', ',')}"/></c:otherwise>
  </c:choose>
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
  <c:catch var="err">
    <sql:transaction>
      <sql:update>UPDATE trabajo_fases SET estado = 'En proceso' WHERE trabajo_id = ? AND fase_id = ?<sql:param value="${trabajoId}"/><sql:param value="${faseEntrega}"/></sql:update>
      <c:forEach var="tp" items="${tipos}" varStatus="s">
        <sql:update>INSERT INTO entregas (trabajo_id, fase_id, estudiante_id, titulo, tipo, url, version, estado)
          SELECT ?, ?, ?, ?, ?, ?, COALESCE(MAX(version), 0) + 1, ? FROM entregas WHERE trabajo_id = ? AND fase_id = ? AND tipo = ?
          <sql:param value="${trabajoId}"/><sql:param value="${faseEntrega}"/><sql:param value="${sessionScope.usuarioId}"/>
          <sql:param value="${faseEntrega eq 3 ? titulo : tp}"/><sql:param value="${tp}"/><sql:param value="${fn:trim(paramValues.url[s.index])}"/><sql:param value="${estadoNuevo}"/>
          <sql:param value="${trabajoId}"/><sql:param value="${faseEntrega}"/><sql:param value="${tp}"/>
        </sql:update>
      </c:forEach>
      <sql:update>UPDATE trabajos_grado SET estado = 'En revision' WHERE id = ?<sql:param value="${trabajoId}"/></sql:update>
      <c:choose>
        <c:when test="${not empty funcionNotif}">
          <c:set var="nTrabajo" value="${trabajoId}"/><c:set var="nFuncion" value="${funcionNotif}"/>
          <c:set var="nTitulo" value="Entrega corregida"/>
          <c:set var="nMensaje" value="${sessionScope.usuarioNombre} reenvió su entrega corregida para tu revisión."/>
          <c:set var="nTipo" value="Entrega"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-docente.jspf" %>
        </c:when>
        <c:otherwise>
          <c:set var="nTitulo" value="Entrega corregida por revisar"/>
          <c:set var="nMensaje" value="${sessionScope.usuarioNombre} reenvió su entrega corregida para decisión del Comité."/>
          <c:set var="nTipo" value="Entrega"/>
          <%@ include file="/WEB-INF/vistas/comunes/notificar-comite.jspf" %>
        </c:otherwise>
      </c:choose>
      <c:set var="hEntidad" value="Entrega"/><c:set var="hId" value="${trabajoId}"/><c:set var="hAccion" value="Subir"/>
      <c:set var="hDesc" value="Entrega corregida (vuelve a ${empty funcionNotif ? 'Comite' : funcionNotif})"/>
      <%@ include file="/WEB-INF/vistas/comunes/historial.jspf" %>
    </sql:transaction>
  </c:catch>
</c:if>
<c:set var="okMsg" value="Corrección enviada. Tu trabajo volvió a revisión."/>
<%@ include file="/WEB-INF/vistas/comunes/finalizar.jspf" %>
