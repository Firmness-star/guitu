package com.flower.service;

import com.flower.entity.Sp;
import java.sql.SQLException;
import java.util.List;

/**
 * 商品服务接口
 * 定义商品模块的业务操作契约，包括查询、搜索及库存管理等功能
 */
public interface ISpService {

    /**
     * 查询全部上架商品
     *
     * @return 商品列表，空结果返回空列表（非null）
     */
    List<Sp> findAllProducts();

    /**
     * 模糊搜索商品
     *
     * @param keyword 搜索关键词
     * @return 搜索结果列表
     */
    List<Sp> searchProducts(String keyword);

    /**
     * 根据二级分类ID查询商品
     *
     * @param categoryId 二级分类ID
     * @return 商品列表
     */
    List<Sp> findProductsByCategory(int categoryId);

    /**
     * 根据一级分类ID查询该分类下所有子分类的商品
     *
     * @param parentCategoryId 一级分类ID
     * @return 商品列表
     */
    List<Sp> findProductsByParentCategory(int parentCategoryId);

    /**
     * 获取商品详情
     *
     * @param productId 商品ID
     * @return 商品实体，未找到返回null
     */
    Sp getProductDetail(int productId);

    /**
     * 检查库存是否满足购买需求
     *
     * @param productId 商品ID
     * @param quantity  购买数量
     * @return 库存充足返回true
     */
    boolean checkStock(int productId, int quantity);

    /**
     * 扣减商品库存（事务操作）
     *
     * <p>注意：此方法应在事务上下文中调用，确保与订单保存的原子性。</p>
     *
     * @param productId 商品ID
     * @param quantity  扣减数量
     * @return 扣减成功返回true
     * @throws SQLException 数据库异常
     */
    boolean decreaseStock(int productId, int quantity) throws SQLException;

    /**
     * 获取热销商品推荐
     *
     * <p>按销量降序排列，返回前N个商品。</p>
     *
     * @param limit 返回数量
     * @return 热销商品列表
     */
    List<Sp> getHotProducts(int limit);
}