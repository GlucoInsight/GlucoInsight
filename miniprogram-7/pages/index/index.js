const defaultAvatarUrl = 'https://mmbiz.qpic.cn/mmbiz/icTdbqWNOwNRna42FI242Lcia07jQodd2FJGIYQfG0LAJGFxM4FbnQP6yfMxBgJ0F3YRqJCJ1aPAK2dQagdusBZg/0'

Page({
  data: {
    motto: 'GlucoInsight',
    userInfo: {
      avatarUrl: defaultAvatarUrl,
      nickName: '',
    },
    data: {
      user_id: ""
    },
    hasUserInfo: false,
    canIUseGetUserProfile: wx.canIUse('getUserProfile'),
    canIUseNicknameComp: wx.canIUse('input.type.nickname'),
  },
  
  onChooseAvatar(e) {
    const { avatarUrl } = e.detail
    const { nickName } = this.data.userInfo
    this.setData({
      "userInfo.avatarUrl": avatarUrl,
      hasUserInfo: nickName && avatarUrl && avatarUrl !== defaultAvatarUrl,
    })
  },
  onInputChange(e) {
    wx.navigateTo({
      url: '../monitor/monitor'
    })
  },
  getUserProfile(e) {
    // 推荐使用wx.getUserProfile获取用户信息，开发者每次通过该接口获取用户个人信息均需用户确认，开发者妥善保管用户快速填写的头像昵称，避免重复弹窗
    wx.getUserProfile({
      desc: '展示用户信息', // 声明获取用户个人信息后的用途，后续会展示在弹窗中，请谨慎填写
      success: (res) => {
        console.log(res)
        this.setData({
          userInfo: res.userInfo,
          hasUserInfo: true
        })

        // 成功获取用户信息后发送请求到后端
        wx.login({
          success (res) {
            if (res.code) {
              // 发起网络请求
              wx.request({
                url:Url + '/user',
                data: {
                  appid: 'wx1f712aad95cc08d4',
                  secret:'5d80303319dfda8413a8ce0e64b83274',
                  js_code: res.code,
                  grant_type: 'authorization_code'
                },
                success: res => {
                  if (res.data.openid) {
                    console.log('成功获取openid:', res.data.openid); // 成功获取到openid
                  } else {
                    console.error('获取openid失败:', res.data.errmsg); // 没有获取到openid，返回错误信息
                  }
                },
                fail: err => {
                  console.error('请求失败:', err.errMsg); // 请求失败，返回错误信息
                }
              })
            } else {
                console.log('登录失败！' + res.errMsg)
            }
          }
        })
      }
    })
  }
})
