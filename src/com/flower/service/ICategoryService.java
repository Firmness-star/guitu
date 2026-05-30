package com.flower.service;

import com.flower.entity.Category;
import java.util.List;

/**
 * 分类服务接口
 *
 * <p>定义分类模块的所有业务操作契约，Controller层依赖此接口而非具体实现，
 * 实现层与调用层的解耦，便于后续替换实现（如加入缓存、切换数据源等）。</p>
 *
 * @author FlowerShop
 * @version 1.0
 * @since 2026-04-16
 * @see com.flower.service.CategoryServiceImpl
 * @see com.flower.dao.CategoryDao
 */
public interface ICategoryService {

    /**
     * 查询所有分类（包括一级和二级分类）
     *
     * @return 分类列表，空结果返回空列表（非null）
     */
    List<Category> findAllCategories();

    /**
     * 查询所有一级分类
     *
     * <p>一级分类的 parentId = 0，用于首页顶部导航栏展示。</p>
     *
     * @return 一级分类列表
     */
    List<Category> findParentCategories();

    /**
     * 根据一级分类ID查询其下的所有二级分类
     *
     * <p>用于首页分类筛选时，点击一级分类后动态展示对应的二级分类选项。</p>
     *
     * @param parentId 一级分类ID
     * @return 二级分类列表
     */
    List<Category> findChildCategories(int parentId);

    /**
     * 根据分类ID获取分类详情
     *
     * @param id 分类ID
     * @return 分类实体，未找到返回null
     */
    Category getCategoryById(int id);
}
