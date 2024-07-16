Page({
  data: {
    sectors: [
      { color: '#FFD700', angle: 72 },  // Yellow
      { color: '#87CEEB', angle: 72 },  // SkyBlue
      { color: '#FF6347', angle: 72 },  // Tomato
      { color: '#9370DB', angle: 72 },  // MediumPurple
      { color: '#FFA07A', angle: 72 },  // LightSalmon
    ],
    activeSector: null,
    revertTimeout: null,
  },

  onLoad: function () {
    this.drawChart();
  },

  drawChart: function () {
    const ctx = wx.createCanvasContext('pieCanvas');
    let startAngle = 0;

    this.data.sectors.forEach((sector, index) => {
      ctx.beginPath();
      ctx.moveTo(150, 150);
      ctx.arc(150, 150, 150, startAngle, startAngle + (Math.PI / 180) * sector.angle);
      ctx.setFillStyle(sector.color);
      ctx.fill();
      startAngle += (Math.PI / 180) * sector.angle;
    });

    ctx.draw();
  },

  handleSectorClick: function (e) {
    const { sectorIndex } = e.currentTarget.dataset;
    if (this.data.activeSector === sectorIndex) {
      wx.navigateTo({
        url: '/pages/newPage/newPage',
      });
      return;
    }

    this.setData({ activeSector: sectorIndex });
    this.drawExpandedSector(sectorIndex);

    clearTimeout(this.data.revertTimeout);
    this.data.revertTimeout = setTimeout(() => {
      this.setData({ activeSector: null });
      this.drawChart();
    }, 500);
  },

  drawExpandedSector: function (sectorIndex) {
    const ctx = wx.createCanvasContext('pieCanvas');
    const sector = this.data.sectors[sectorIndex];

    ctx.beginPath();
    ctx.moveTo(150, 150);
    ctx.arc(150, 150, 150, 0, 2 * Math.PI);
    ctx.setFillStyle(sector.color);
    ctx.fill();

    ctx.draw();
  },
});
