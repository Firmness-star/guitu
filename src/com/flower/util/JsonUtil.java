package com.flower.util;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.*;

/**
 * 轻量级 JSON 序列化工具类
 * 用于将 Java 对象转换为 JSON 格式字符串，实现零依赖的 JSON 支持
 */
public class JsonUtil {
    
    /**
     * 将任意 Java 对象转换为 JSON 字符串
     *
     * @param obj 待转换的对象（支持 String, Number, Boolean, Map, Collection 及普通 JavaBean）
     * @return JSON 格式的字符串表示
     */
    public static String toJson(Object obj) {
        if (obj == null) {
            return "null";
        }
        
        if (obj instanceof String) {
            return "\"" + escapeJson((String) obj) + "\"";
        }
        
        if (obj instanceof Number || obj instanceof Boolean) {
            return obj.toString();
        }
        
        if (obj instanceof Map) {
            return mapToJson((Map<?, ?>) obj);
        }
        
        if (obj instanceof Collection) {
            return collectionToJson((Collection<?>) obj);
        }
        
        return objectToJson(obj);
    }
    
    /**
     * 将 Map 集合转换为 JSON 对象字符串
     *
     * @param map 待转换的 Map 对象
     * @return JSON 对象字符串
     */
    private static String mapToJson(Map<?, ?> map) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        boolean first = true;
        
        for (Map.Entry<?, ?> entry : map.entrySet()) {
            if (!first) {
                sb.append(",");
            }
            sb.append("\"").append(escapeJson(entry.getKey().toString())).append("\":");
            sb.append(toJson(entry.getValue()));
            first = false;
        }
        
        sb.append("}");
        return sb.toString();
    }
    
    /**
     * 将 Collection 集合转换为 JSON 数组字符串
     *
     * @param collection 待转换的集合对象
     * @return JSON 数组字符串
     */
    private static String collectionToJson(Collection<?> collection) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        boolean first = true;
        
        for (Object item : collection) {
            if (!first) {
                sb.append(",");
            }
            sb.append(toJson(item));
            first = false;
        }
        
        sb.append("]");
        return sb.toString();
    }
    
    /**
     * 利用反射机制将普通 Java 对象转换为 JSON 对象字符串
     *
     * @param obj 待转换的 JavaBean 对象
     * @return JSON 对象字符串
     */
    private static String objectToJson(Object obj) {
        // Handle Date/Timestamp types specially to avoid reflection issues
        if (obj instanceof java.util.Date) {
            return "\"" + obj.toString() + "\"";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        boolean first = true;

        Class<?> clazz = obj.getClass();

        // Try getter methods first (safer, avoids module access issues)
        Method[] methods = clazz.getMethods();
        Map<String, Object> values = new LinkedHashMap<>();
        for (Method m : methods) {
            String name = m.getName();
            if (m.getParameterCount() == 0 && name.startsWith("get") && name.length() > 3
                && !name.equals("getClass")) {
                try {
                    values.put(lowerFirst(name.substring(3)), m.invoke(obj));
                } catch (Exception ignored) {}
            } else if (m.getParameterCount() == 0 && name.startsWith("is") && name.length() > 2
                && (m.getReturnType() == boolean.class || m.getReturnType() == Boolean.class)) {
                try {
                    values.put(lowerFirst(name.substring(2)), m.invoke(obj));
                } catch (Exception ignored) {}
            }
        }

        for (Map.Entry<String, Object> entry : values.entrySet()) {
            if (entry.getValue() == null && !first) continue;
            if ("serialVersionUID".equals(entry.getKey())) continue;
            if ("class".equals(entry.getKey())) continue;
            if (!first) sb.append(",");
            sb.append("\"").append(escapeJson(entry.getKey())).append("\":");
            sb.append(toJson(entry.getValue()));
            first = false;
        }

        sb.append("}");
        return sb.toString();
    }

    private static String lowerFirst(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toLowerCase(s.charAt(0)) + s.substring(1);
    }
    
    /**
     * 对字符串中的特殊字符进行转义处理，确保生成的 JSON 格式合法
     *
     * @param str 待转义的原始字符串
     * @return 转义后的字符串
     */
    private static String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
