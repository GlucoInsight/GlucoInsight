// pages/monitor/monitor.js
Page({
  data: {
    expandedSector: null, // 控制动画
    animationData: {} // 存储动画数据
  },
  onTapSector(e) {
    const sectorId = e.currentTarget.dataset.sector;
    if (this.data.expandedSector === sectorId) {
      // 如果已经放大，再次点击跳转到新界面
      wx.navigateTo({
        url: e.currentTarget.dataset.url
      });
      return;
    }

    const animation = wx.createAnimation({
      duration: 500,
      timingFunction: 'ease'
    });

    // 扇形放大动画
    animation.scale(3).step(); // 扇形放大

    this.setData({
      [`animation${sectorId}`]: animation.export(),
      expandedSector: sectorId
    });

    // 设置延时以恢复扇形到原始状态
    setTimeout(() => {
      if (this.data.expandedSector === sectorId) {
        animation.scale(1).step(); // 恢复动画
        this.setData({
          [`animation${sectorId}`]: animation.export(),
          expandedSector: null
        });
      }
    }, 500); // 0.5秒后无操作自动恢复
  }
});
