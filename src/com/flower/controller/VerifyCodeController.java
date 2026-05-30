package com.flower.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Random;
import javax.imageio.ImageIO;

@WebServlet("/verifyCode")
public class VerifyCodeController extends HttpServlet {

    private static final String CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int WIDTH = 120;
    private static final int HEIGHT = 40;
    private static final int LENGTH = 4;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();

        // 背景
        g.setColor(new Color(245, 248, 250));
        g.fillRect(0, 0, WIDTH, HEIGHT);

        // 干扰线
        Random rand = new Random();
        g.setColor(new Color(220, 224, 230));
        for (int i = 0; i < 6; i++) {
            g.drawLine(rand.nextInt(WIDTH), rand.nextInt(HEIGHT),
                       rand.nextInt(WIDTH), rand.nextInt(HEIGHT));
        }

        // 生成验证码
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < LENGTH; i++) {
            String ch = String.valueOf(CHARS.charAt(rand.nextInt(CHARS.length())));
            code.append(ch);
            g.setColor(new Color(40 + rand.nextInt(80), 100 + rand.nextInt(80), 40 + rand.nextInt(100)));
            g.setFont(new Font("Arial", Font.BOLD, 22 + rand.nextInt(6)));
            g.drawString(ch, 22 + i * 24, 28 + rand.nextInt(6));
        }

        // 干扰点
        g.setColor(new Color(180, 190, 200));
        for (int i = 0; i < 30; i++) {
            g.fillOval(rand.nextInt(WIDTH), rand.nextInt(HEIGHT), 2, 2);
        }

        g.dispose();

        // 存 session
        HttpSession session = req.getSession();
        session.setAttribute("verifyCode", code.toString());

        // 输出图片
        resp.setContentType("image/png");
        resp.setHeader("Cache-Control", "no-cache");
        ImageIO.write(image, "PNG", resp.getOutputStream());
    }
}
