<%@ page contentType="text/html;charset=UTF-8" %>
<c:set var="ignorar" value="${pageContext.session.invalidate()}"/>
<c:redirect url="/login.jsp"/>
