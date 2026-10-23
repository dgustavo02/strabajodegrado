<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="ignorar" value="${pageContext.response.setStatus(404)}"/>
<c:set var="tituloPagina" value="Página no encontrada | Trabajos de Grado UTS"/>
<c:set var="bodyClass" value="pagina-error-body"/>
<%@ include file="/WEB-INF/vistas/comunes/cabecera.jspf" %>
<main class="pagina-error">
  <div class="card tarjeta-error">
    <div class="card-body p-4">
      <div class="codigo-error">404</div>
      <h1 class="h4 mt-3">Página no encontrada</h1>
      <p class="text-muted">La página que buscas no existe o fue movida.</p>
      <a class="btn btn-primary" href="${ctx}/">Volver al inicio</a>
    </div>
  </div>
</main>
<%@ include file="/WEB-INF/vistas/comunes/pie.jspf" %>
