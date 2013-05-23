<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=Windows-31J" %>
<% request.setCharacterEncoding("Windows-31J"); %>
<%!
  class User {
    private String id;
    private String name;

    User(String id, String name) {
      this.id = id;
      this.name = name;
    }

    String getId() {
      return id;
    }

    String getName() {
      return name;
    }
  }

  /**
   * DB�̃R�l�N�V�������擾���܂��B
   */
  Connection getConnection() {
    try {
      Class.forName("com.mysql.jdbc.Driver");
      String url = "jdbc:mysql://ec2-50-19-213-178.compute-1.amazonaws.com/kuso-champ";
      String user="kusource";
      String pass ="kusource";
      Connection connection = DriverManager.getConnection(url, user, pass);
      connection.setAutoCommit(false);
      return connection;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * ���[�U�[��Ԃ�ۑ����܂��B
   */
  boolean saveUser(String id, String name) {
    Connection connection = null;
    Statement statement = null;
    try {
      connection = getConnection();
      statement = connection.createStatement();
      final String sql = "INSERT INTO USER(id, name) values('" + id + "','" + name + "')";
      statement.executeUpdate(sql);
      connection.commit();
      return true;
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    } finally {
      try {
        if(connection != null) connection.close();
      } catch (SQLException e) {
        e.printStackTrace();
      }
      try {
        if(statement != null) statement.close();
      } catch (SQLException e) {
        e.printStackTrace();
      }
    }
  }

  /**
   * ���[�U�[�ꗗ���擾���܂��B
   */
  List<User> allUser() {
    Connection connection = null;
    Statement statement = null;
    List<User> result = new ArrayList<User>();
    try {
      connection = getConnection();
      statement = connection.createStatement();
      final String sql = "SELECT * FROM USER";
      ResultSet resultSet = statement.executeQuery(sql);

      while (resultSet.next()) {
        result.add(new User(resultSet.getString("id"), resultSet.getString("name")));
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      try {
        if(connection != null) connection.close();
      } catch (SQLException e) {
        e.printStackTrace();
      }
      try {
        if(statement != null) statement.close();
      } catch (SQLException e) {
        e.printStackTrace();
      }
    }
    return result;
  }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
  <meta http-equiv="content-language" content="ja" />
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <meta http-equiv="content-style-type" content="text/css" />
  <meta http-equiv="content-script-type" content="text/javascript" />
  <title>Kusource-Championship</title>
  <link href="http://twitter.github.io/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
  <link href="http://twitter.github.io/bootstrap/assets/css/bootstrap-responsive.css" rel="stylesheet">
  <script type="text/javascript" src="http://code.jquery.com/jquery.min.js"></script>
  <script type="text/javascript" src="http://twitter.github.io/bootstrap/assets/js/bootstrap.js"></script>
</head>
<body>
<div class="navbar">
  <div class="navbar-inner">
    <a class="brand" href="/">Kusource-Championship</a>
    <ul class="nav">
      <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">���j���[</a>
        <ul class="dropdown-menu">
          <li><a href="/?path=accountList">���[�U�[�ꗗ</a></li>
          <li><a href="/?path=accountAdd">���[�U�[�o�^</a></li>
        </ul>
      </li>
    </ul>
  </div>
</div>
<%
String path = request.getParameter("path");
if(path == null || path.isEmpty() || path.equals("index")) {
%>
<h3>�悤�����A�N�\�[�X�̐��E�ցI</h3>
<%
} else if(path.equals("accountList")) {
  List<User> users = allUser();
%>
<div class="span10">
<legend>���[�U�[�ꗗ</legend>
<table class="table table-striped">
  <thead>
    <tr>
      <th>id</th>
      <th>name</th>
    </tr>
  </thead>
  <tbody>
<%
for (User user : users) {
%>
    <tr>
      <td><%=user.getId()%></td>
      <td><%=user.getName()%></td>
    </tr>
<%
}
%>
  </tbody>
</table>
</div>
<%
} else if(path.equals("accountAdd")) {
  String id = request.getParameter("id");
  String name = request.getParameter("name");
  String message = "";
  if(id != null && !id.isEmpty() && name != null && !name.isEmpty()) {
    // ���[�U�[��o�^����
    if(saveUser(id, name)) {
      message = "�o�^�ɐ������܂����B";
    } else {
      message = "�o�^�Ɏ��s���܂����B";
    }
  }
%>
<%
if(!message.isEmpty()) {
%>
<div class="alert alert-info">
    <a class="close" data-dismiss="alert">&#215;</a>
	<%=message%>
</div>
<%
}
%>
<div class="span10">
  <div id="panel_profile" class="panel">
  <form action="/?path=accountAdd" method="post">
	<legend>���[�U�[�o�^</legend>
	<dl>
	  <dt><label>id</label></dt>
	  <dd><input type="text" name="id" id="id" /></dd>
	  <dt><label>name</label></dt>
	  <dd><input type="text" name="name" id="name" /></dd>
	</dl>
	<button type="submit" class="btn btn-primary">�o�^</button>
  </form>
  </div><!--/panel-->
</div>
<%
}
%>
</body>