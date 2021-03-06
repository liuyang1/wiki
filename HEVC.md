# HEVC
auth: liuyang1
mtime: 2013-01-10 11:37:35
----
HEVC是视频编码标准草案.领先于H.264/AVC算法.目前由JCT-VC开发HEVC标准.
HEVC据说增强了视频质量,压缩效率2倍于H.264.支持8K UHD??,分辨率支持到8192x4320.

## 历史
2004年,ITU-T VCEG开始研究新的视频标准标准,或者H.264 AVC的增强标准.2005年1月,VCEG开始设计KTA(关键技术区域,专利池?)为进一步研究.KTA代码库用于进行诸上研究. KTA软件基于JM参考软件,(JM参考软件用于开发H.264 AVC).之后4年,新的技术集成到KTA软件中.

标准化增强压缩技术有两个途径:
建立新的标准,建立标准的扩展.

项目曾经命名为H.265,H.NGVC.以及VCEG的主要部分,直到2010年命名为HEVC联合项目.

NGVC的主要要求就是比特率减少到H.264 AVC High Profile 的一半,计算复杂度则保持在其1/2到3倍之间.NGVC可以提供更好的压缩效率,同时增加复杂度.

MPEG在2007年开始了类似的项目,命名为High preformance Video Coding.2007年7月,目标定位减少比特率50%.KTA软件进一步增强.2009年7月,试验结果表明平均码率减少了20%,相比与AVC High Profile.于是推进了MPEG开始标准化VCEG.

Call for Proposals(Cfp)视频压缩技术,在2010年开始,草案是MPEG和VCEG联合集体团队.JCT-VC.召开于2010年4月.共有27个方案提交.部分方案可以达到AVC的质量,同时比特率为AVC一般,计算复杂度则为2x~10x,部分方案有很好的客观质量和比特率,同时有着较低的计算复杂度.会议提出了HEVC.之后JCT-VC基础了最好的方案到一个软件库和一个测试集中.以期进一步研究.HEVC的地一个草案在第3次JCT-VC会议,2010年10月召开.编码工具有很多改变.

HEVC草案,经过6次草案,2012年2月发布.

2012-5-25,JCT-VC宣布SVC将会在2012年10月召开.修正的HEVC将支持SVC.

2012-6-26,MPEG LA宣布发布HEVC的专利.

HEVC,8次草案于2012-7部分.同时商业产品将于2013年发布.

## 规划
1. 2012-2,草案完成.
1. 2012-7,国际i标准草案.
1. 2013-1,最终国际i保证草案.

## 实现
## 编码效率
## 特性
## 视频编码层
## 编码工具
## 预测块大小
## 内部位深增加
## 并行处理工具
## 熵编码
## 帧内预测
## 运动压缩
## 运行向量预测
## 反向变换
## 滤波回路
## 层级
H.264有profile和level两级结构,用于说明编码的级别.
H.265则有profile, level, tier的三层结构用于说明编码的级别. 例如:Main 10@L5.1@Main

```mediainfo
ID                                       : 1001 (0x3E9)
菜单ID                                     : 257 (0x101)
文件格式                                     : HEVC
文件格式/信息                                  : High Efficiency Video Coding
格式简介                                     : Main 10@L5.1@Main
编码设置ID                                   : 36
长度                                       : 1分 23秒
画面宽度                                     : 3 840像素
画面高度                                     : 2 160像素
画面比例                                     : 16:9
帧率                                       : 59.940 (60000/1001) fps
色彩空间                                     : YUV
色度抽样                                     : 4:2:0
位深度                                      : 10位
colour_range                             : Limited
颜色初选                                     : BT.709
传输特质                                     : BT.709
矩阵系数                                     : BT.709
```
H.264的流信息分为两层结构SPS和PPS信息.
H.265则分为三层结构VPS,SPS,PPS.

### profile
 Version 1 profile::
- Main

Main profile, 采用8bit,YUV420采样.

- Main10

8bit或者10bit,YUV420采样

- MainStillPicture

 Version 2 prifile::

- 21个range extension profile
- 2个scable extension profile
- 1个multiview extension profile

 Version 3 profile::
 TODO

### Level 和 Tier
13种level和两种Tire(Main或者High)

### VPS
### SPS
- conference_window_flag
conference window flag, use for cropping window flag

H264, named `frame_cropping_flag` ...
### PPS

### TSA
temporal sub-layer access

H.264 SVC also support this.

![TSA](img/tsa.png)

### Slice

HEVC support dependent or independent slice.

With independent slice, could achieve low delay transmit as pack data when not
to end of this
frame.

### Tile
### WPP

> cannot use Tile or WPP same time as complexity.

= Tool =
- Elecard StreamEye Analyser
- Zond 265
- CodecVisa
- Video Pro Analyser(Intel)
- http://www.parabolaresearch.com/index.html

# rbsp

## nal type
| group     | nal type | meaning |
|-----------|----------|---------|
| param set | 32       | VPS     |
|           | 33       | SPS     |
|           | 34       | PPS |
|           | 35       | AUD     |
| SEI | 39 | prefix sei |
| | 40 | suffix sei |
| slice | 0..9 | TRAIL, TSA, STSA, RADL, RASL |
| | 16..21 | BLA, IDR, CRA |

## slice_segment_header

`first_slice_segment_in_pic_flag` first bit
