package com.flower.entity;

import java.io.Serializable;
import java.util.Date;

/**
 * 用户实体类
 * 用于封装系统用户的个人信息、账户状态及角色权限
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String username;
    private String pass;
    private String gender;
    private String tel;
    private String email;
    private String state;
    private String role;
    private int jf;
    private String avatar;    // 头像路径
    private Date createTime;
    private Date lastLoginTime;

    /**
     * 无参构造函数
     */
    public User() {
    }

    /**
     * 带参构造函数，初始化用户注册时的基本信息并设置默认值
     *
     * @param username 用户名
     * @param pass     密码
     * @param tel      手机号
     * @param email    邮箱地址
     */
    public User(String username, String pass, String tel, String email) {
        this.username = username;
        this.pass = pass;
        this.tel = tel;
        this.email = email;
        this.gender = "保密";
        this.state = "可用";
        this.role = "用户";
        this.jf = 0;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPass() {
        return pass;
    }

    public void setPass(String pass) {
        this.pass = pass;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getTel() {
        return tel;
    }

    public void setTel(String tel) {
        this.tel = tel;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public int getJf() {
        return jf;
    }

    public void setJf(int jf) {
        this.jf = jf;
    }

    public String getAvatar() { return avatar; }
    public void setAvatar(String avatar) { this.avatar = avatar; }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getLastLoginTime() {
        return lastLoginTime;
    }

    public void setLastLoginTime(Date lastLoginTime) {
        this.lastLoginTime = lastLoginTime;
    }

    /**
     * 判断当前用户是否为管理员
     *
     * @return 若角色为“管理员”返回 true，否则返回 false
     */
    public boolean isAdmin() {
        return "管理员".equals(this.role);
    }

    /**
     * 判断当前用户是否为商家
     *
     * @return 若角色为“商家”返回 true，否则返回 false
     */
    public boolean isMerchant() {
        return "商家".equals(this.role);
    }

    /**
     * 判断当前用户是否为普通用户
     *
     * @return 若角色为“用户”返回 true，否则返回 false
     */
    public boolean isUser() {
        return "用户".equals(this.role);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return id == user.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", tel='" + tel + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                ", state='" + state + '\'' +
                ", jf=" + jf +
                ", createTime=" + createTime +
                ", lastLoginTime=" + lastLoginTime +
                '}';
    }
}