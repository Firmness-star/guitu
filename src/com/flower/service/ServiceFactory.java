package com.flower.service;

/**
 * 服务层单例工厂
 *
 * <p>统一管理所有Service实例的创建和生命周期，确保：
 * <ul>
 *   <li>全局唯一实例（单例模式）</li>
 *   <li>延迟初始化（首次使用时创建）</li>
 *   <li>线程安全（静态内部类实现）</li>
 *   <li>Controller层解耦（不直接new实现类）</li>
 * </ul>
 *
 * <p>使用方式：
 * <pre>
 *   ISpService spService = ServiceFactory.getSpService();
 * </pre>
 *
 * @author FlowerShop
 * @version 1.0
 * @since 2026-04-16
 */
public class ServiceFactory {

    /**
     * 私有构造函数，防止外部通过 new 关键字创建实例
     */
    private ServiceFactory() {
    }

    /**
     * 商品服务持有者，利用静态内部类特性实现线程安全的懒加载
     */
    private static class SpServiceHolder {
        private static final ISpService INSTANCE = new SpServiceImpl();
    }

    /**
     * 分类服务持有者，利用静态内部类特性实现线程安全的懒加载
     */
    private static class CategoryServiceHolder {
        private static final ICategoryService INSTANCE = new CategoryServiceImpl();
    }

    /**
     * 获取商品服务单例实例
     *
     * @return ISpService 实例
     */
    public static ISpService getSpService() {
        return SpServiceHolder.INSTANCE;
    }

    /**
     * 获取分类服务单例实例
     *
     * @return ICategoryService 实例
     */
    public static ICategoryService getCategoryService() {
        return CategoryServiceHolder.INSTANCE;
    }

    /**
     * 测试工厂是否正常工作
     *
     * @param args 命令行参数
     */
    public static void main(String[] args) {
        ISpService s1 = ServiceFactory.getSpService();
        ISpService s2 = ServiceFactory.getSpService();

        System.out.println("实例1：" + s1);
        System.out.println("实例2：" + s2);
        System.out.println("是否为同一实例：" + (s1 == s2));
    }
}