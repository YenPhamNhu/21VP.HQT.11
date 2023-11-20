import React from 'react';
import { Form, Button } from 'react-bootstrap';
import '../screen.css/Login.css'
const Login = () => {
  return (
    <div className="login-box">
      <div id="logo"><img src='./logicon.png' alt="Image" /></div>
      <Form>
        <Form.Group className="mb-3" controlId="telephone">
          <Form.Label>Số điện thoại:</Form.Label>
          <Form.Control type="tel" required pattern="[0-9]{10}" />
        </Form.Group>
        <Form.Group className="mb-3" controlId="password">
          <Form.Label>Mật khẩu:</Form.Label>
          <Form.Control type="password" required />
        </Form.Group>
        <Form.Group className="mb-3" controlId="rememberpass">
            <Form.Label for="rememberMeCheckbox">
            <Form.Control type="checkbox" id="rememberMeCheckbox" name="rememberMe" value="rememberMe" className="ml-2" />Nhớ mật khẩu</Form.Label>
            <Form.Text className="text-muted float-right">
                <a href="#">Quên mật khẩu?</a>
            </Form.Text>
        </Form.Group>
        <Button type="submit">Đăng nhập</Button>
      </Form>
    </div>
  );
};

export default Login;