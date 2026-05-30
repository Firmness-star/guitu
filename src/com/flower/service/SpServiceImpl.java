package com.flower.service;

import com.flower.dao.SpDao;
import com.flower.entity.Sp;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 商品服务实现类
 * 负责处理商品相关的业务逻辑，包括查询、搜索及库存管理
 */
public class SpServiceImpl implements ISpService {

    private SpDao spDao;

    SpServiceImpl() {
        this.spDao = new SpDao();
    }

    /**
     * 获取所有上架商品列表
     *
     * @return 商品列表，若不存在则返回空列表
     */
    @Override
    public List<Sp> findAllProducts() {
        List<Sp> productList = spDao.findAll();
        return productList != null ? productList : new ArrayList<>();
    }

    /**
     * 根据关键词搜索商品
     *
     * @param keyword 搜索关键词
     * @return 匹配的商品列表，若参数无效或无结果则返回空列表
     */
    @Override
    public List<Sp> searchProducts(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }

        List<Sp> result = spDao.search(keyword.trim());
        return result != null ? result : new ArrayList<>();
    }

    /**
     * 根据二级分类 ID 查询商品
     *
     * @param categoryId 二级分类 ID
     * @return 对应的商品列表，若参数无效则返回空列表
     */
    @Override
    public List<Sp> findProductsByCategory(int categoryId) {
        if (categoryId <= 0) {
            return new ArrayList<>();
        }

        List<Sp> result = spDao.findByCategory(categoryId);
        return result != null ? result : new ArrayList<>();
    }

    /**
     * 根据一级分类 ID 查询其下所有子分类的商品
     *
     * @param parentCategoryId 一级分类 ID
     * @return 对应的商品列表，若参数无效则返回空列表
     */
    @Override
    public List<Sp> findProductsByParentCategory(int parentCategoryId) {
        if (parentCategoryId <= 0) {
            return new ArrayList<>();
        }

        List<Sp> result = spDao.findByParentCategory(parentCategoryId);
        return result != null ? result : new ArrayList<>();
    }

    /**
     * 获取指定商品的详细信息
     *
     * @param productId 商品 ID
     * @return 商品实体对象，若参数无效或不存在则返回 null
     */
    @Override
    public Sp getProductDetail(int productId) {
        if (productId <= 0) {
            return null;
        }

        return spDao.findById(productId);
    }

    /**
     * 检查指定商品的库存是否满足购买数量
     *
     * @param productId 商品 ID
     * @param quantity  购买数量
     * @return 库存充足返回 true，否则返回 false
     */
    @Override
    public boolean checkStock(int productId, int quantity) {
        if (productId <= 0 || quantity <= 0) {
            return false;
        }

        Sp product = spDao.findById(productId);
        if (product == null) {
            throw new RuntimeException("商品不存在，ID：" + productId);
        }

        return product.getStock() >= quantity;
    }

    /**
     * 扣减商品库存（需在事务环境中调用）
     *
     * @param productId 商品 ID
     * @param quantity  扣减数量
     * @return 扣减成功返回 true，否则返回 false
     * @throws SQLException SQL 异常
     */
    @Override
    public boolean decreaseStock(int productId, int quantity) throws SQLException {
        if (productId <= 0 || quantity <= 0) {
            return false;
        }

        Sp product = spDao.findById(productId);
        if (product == null) {
            throw new RuntimeException("扣减库存失败，商品不存在：" + productId);
        }

        int currentStock = product.getStock();
        if (currentStock < quantity) {
            return false;
        }

        int newStock = currentStock - quantity;
        return spDao.updateStock(productId, newStock);
    }

    /**
     * 获取按销量排序的热销商品推荐列表
     *
     * @param limit 返回的商品数量上限
     * @return 热销商品列表
     */
    @Override
    public List<Sp> getHotProducts(int limit) {
        if (limit <= 0) {
            return new ArrayList<>();
        }

        List<Sp> all = spDao.findAll();
        if (all == null || all.isEmpty()) {
            return new ArrayList<>();
        }

        // 按销量降序排列
        all.sort((p1, p2) -> Integer.compare(p2.getSales(), p1.getSales()));

        int actualLimit = Math.min(limit, all.size());
        return new ArrayList<>(all.subList(0, actualLimit));
    }
}