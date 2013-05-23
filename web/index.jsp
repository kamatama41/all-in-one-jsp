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
   * DBのコネクションを取得します。
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
   * ユーザー状態を保存します。
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
   * ユーザー一覧を取得します。
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
        <a href="#" class="dropdown-toggle" data-toggle="dropdown">メニュー</a>
        <ul class="dropdown-menu">
          <li><a href="/?path=accountList">ユーザー一覧</a></li>
          <li><a href="/?path=accountAdd">ユーザー登録</a></li>
        </ul>
      </li>
    </ul>
  </div>
</div>
<%
String path = request.getParameter("path");
if(path == null || path.isEmpty() || path.equals("index")) {
%>
<h3>ようこそ、クソースの世界へ！</h3>
<%
} else if(path.equals("accountList")) {
  List<User> users = allUser();
%>
<div class="span10">
<legend>ユーザー一覧</legend>
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
    // ユーザーを登録する
    if(saveUser(id, name)) {
      message = "登録に成功しました。";
    } else {
      message = "登録に失敗しました。";
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
	<legend>ユーザー登録</legend>
	<dl>
	  <dt><label>id</label></dt>
	  <dd><input type="text" name="id" id="id" /></dd>
	  <dt><label>name</label></dt>
	  <dd><input type="text" name="name" id="name" /></dd>
	</dl>
	<button type="submit" class="btn btn-primary">登録</button>
  </form>
  </div><!--/panel-->
</div>
<%
}
%>
</body>