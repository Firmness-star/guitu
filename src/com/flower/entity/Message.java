package com.flower.entity;

import java.io.Serializable;
import java.util.Date;

public class Message implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String username;
    private String content;
    private String conversation;
    private int isUserRead;   // 0=用户未读 1=已读
    private int isAdminRead;   // 0=管理员未读 1=已读
    private int unreadAdminReplies;  // 该留言中用户未读的管理员回复数
    private int unreadUserReplies;   // 该留言中管理员未读的用户回复数
    private Date createTime;

    public Message() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getConversation() { return conversation; }
    public void setConversation(String conversation) { this.conversation = conversation; }
    public int getIsUserRead() { return isUserRead; }
    public void setIsUserRead(int isUserRead) { this.isUserRead = isUserRead; }
    public int getIsAdminRead() { return isAdminRead; }
    public void setIsAdminRead(int isAdminRead) { this.isAdminRead = isAdminRead; }
    public int getUnreadAdminReplies() { return unreadAdminReplies; }
    public void setUnreadAdminReplies(int v) { this.unreadAdminReplies = v; }
    public int getUnreadUserReplies() { return unreadUserReplies; }
    public void setUnreadUserReplies(int v) { this.unreadUserReplies = v; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
