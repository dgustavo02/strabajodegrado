<%@ page contentType="text/html;charset=UTF-8" %>
<c:if test="${not empty sessionScope.usuarioId}"><c:redirect url="/panel.jsp"/></c:if>
<c:if test="${empty sessionScope.csrf}">
  <sql:query var="tk">SELECT LOWER(HEX(RANDOM_BYTES(16))) AS t</sql:query>
  <c:set var="csrf" value="${tk.rows[0].t}" scope="session"/>
</c:if>
<c:set var="tituloPagina" value="Iniciar sesión | Trabajos de Grado UTS"/>
<c:set var="cssExtra" value="login"/>
<c:set var="jsExtra" value="login"/>
<c:set var="bodyClass" value="login-page"/>
<%@ include file="/WEB-INF/vistas/comunes/cabecera.jspf" %>

<main class="login-wrap">
  
  <!-- Botón flotante anclado a la esquina superior izquierda -->
  <a href="${ctx}/" class="btn-volver">
    <i class="bi bi-arrow-left-short fs-5"></i> Volver al inicio
  </a>

  <!-- Panel Izquierdo (Branding y beneficios) -->
  <section class="login-panel-info d-none d-lg-flex">
    <div>
      <span class="brand-mark brand-mark-lg" style="background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: white; backdrop-filter: blur(10px); font-weight: 800;">UTS</span>
      <h1 class="mt-4">Tu trabajo de grado,<br>en un solo lugar.</h1>
      <p class="lead">Sistema de Gestión de Trabajos de Grado de las Unidades Tecnológicas de Santander.</p>
      
      <ul class="list-unstyled login-points">
        <li><i class="bi bi-lightbulb"></i> Propón o elige tu idea de proyecto</li>
        <li><i class="bi bi-file-earmark-check"></i> Entrega y recibe observaciones en línea</li>
        <li><i class="bi bi-graph-up-arrow"></i> Consulta el estado de tu proceso en tiempo real</li>
      </ul>
    </div>
  </section>
  
  <!-- Panel Derecho (Formulario) -->
  <section class="login-panel-form">
    <div class="login-card">
      
      <div class="text-center mb-4">
        <h2 class="h3 fw-bold" style="color: var(--uts-verde-oscuro);">Bienvenido</h2>
        <p class="text-muted">Ingresa tus credenciales para continuar.</p>
      </div>
      
      <%@ include file="/WEB-INF/vistas/comunes/mensajes.jspf" %>
      
      <form method="post" action="${ctx}/acciones/login.jsp" id="formLogin" novalidate>
        <input type="hidden" name="csrf" value="${sessionScope.csrf}">
        
        <div class="mb-4">
          <label for="correo" class="form-label fw-bold text-muted small">Correo institucional</label>
          <div class="custom-input-group">
            <i class="bi bi-envelope input-icon"></i>
            <input type="email" class="form-control form-control-lg" id="correo" name="correo" maxlength="150" autocomplete="username" required autofocus placeholder="ejemplo@uts.edu.co">
          </div>
          <div class="invalid-feedback d-block mt-1" id="errCorreo" style="display:none;">Ingresa un correo válido.</div>
        </div>
        
        <div class="mb-4">
          <label for="clave" class="form-label fw-bold text-muted small">Contraseña</label>
          <div class="custom-input-group">
            <i class="bi bi-lock input-icon"></i>
            <input type="password" class="form-control form-control-lg" id="clave" name="clave" maxlength="100" autocomplete="current-password" required placeholder="••••••••">
            <button class="btn btn-link text-muted px-3" type="button" id="verClave" aria-label="Mostrar contraseña" style="text-decoration:none;"><i class="bi bi-eye"></i></button>
          </div>
          <div class="invalid-feedback d-block mt-1" id="errClave" style="display:none;">Ingresa tu contraseña.</div>
        </div>
        
        <button class="btn btn-primary btn-ingresar w-100 mt-2" type="submit">Ingresar</button>
      </form>
      
      <p class="small text-muted mt-4 mb-0 text-center">
        Las cuentas las crea el administrador.<br>Si no tienes acceso, comunícate con la coordinación.
      </p>
    </div>
  </section>
</main>
<%@ include file="/WEB-INF/vistas/comunes/pie.jspf" %>