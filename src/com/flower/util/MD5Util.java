package com.flower.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;

/**
 * MD5 加密工具类
 * 用于对用户密码等敏感信息进行不可逆的哈希处理，保障数据安全
 */
public class MD5Util {

    private static final String SALT = "";

    /**
     * 使用默认盐值对输入字符串进行 MD5 加密
     *
     * @param input 待加密的原始字符串
     * @return 加密后的 32 位十六进制字符串，若输入为空则返回 null
     */
    public static String encrypt(String input) {
        if (input == null || input.isEmpty()) {
            return null;
        }

        try {
            String saltedInput = input + SALT;
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(saltedInput.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder(32);
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5加密算法不可用", e);
        }
    }

    /**
     * 使用指定盐值对输入字符串进行 MD5 加密
     *
     * @param input 待加密的原始字符串
     * @param salt  自定义盐值，若为空则使用默认加密逻辑
     * @return 加密后的 32 位十六进制字符串，若输入为空则返回 null
     */
    public static String encryptWithSalt(String input, String salt) {
        if (input == null || input.isEmpty()) {
            return null;
        }
        if (salt == null || salt.isEmpty()) {
            return encrypt(input);
        }

        try {
            String saltedInput = input + salt;
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(saltedInput.getBytes(StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder(32);
            for (byte b : digest) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("MD5加密算法不可用", e);
        }
    }
}