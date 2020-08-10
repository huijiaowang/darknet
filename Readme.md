# Human Detector Based on YOLOV4 训练记录
[TOC]

## 0、To-Do-List
  - 基于 Yolov4 系列模型训练 Human Detector
    - [x] 跑通源码 
    - [x] 将源码配置为 Human Detector 并训练
    - [ ] 评估源码 + Human Detector 对于 human 类检测的精度和速度
    - [ ] 进一步优化 Detection 精度
    - [ ] 尝试 Yoluv4 系列其他模型


## 1、复现代码
[源码参考](https://github.com/AlexeyAB/darknet)
[我的复现](https://github.com/huijiaowang/darknet)

## 2、使用步骤
1. 下载 [我的复现](https://github.com/huijiaowang/darknet) **HD01分支**
> git clone https://github.com/huijiaowang/darknet  

2. 文件准备
  - 准备 **csdarnet53-omega.conv.105** -这是在ImageNet上预训练过的 darknet53 网络前105层：
  - 从[这]( https://drive.google.com/open?id=18jCwaL4SJ-jOvXrZNGHJ5yz44g9zi8Hm)下载 csdarknet53-omega_final.weights
  - 取前105层
  > ./darknet partial cfg/csdarknet53-omega.cfg csdarknet53-omega_final.weights csdarknet53-omega.conv.105 105

3. 开启训练

* 单GPU训练
> ./train_human.sh  

* 多GPU训练,需要先用单gpu训练一段时间，例如1000个iteration后，在进行多gpu训练
> ./train_human_mgpu.sh human_detector_yolov4_1000.weights  

4. 测试图片
> ./test_human.sh data/person.jpg

5. 验证在 COCO 数据集上的精度
待做

## 3、修改源码
* 参考自[源码](https://github.com/AlexeyAB/darknet)中：
[How to train (to detect your custom objects)](https://github.com/AlexeyAB/darknet#how-to-train-to-detect-your-custom-objects)
[Training and Evaluation of speed and accuracy on MS COCO](https://github.com/AlexeyAB/darknet/wiki/Train-Detector-on-MS-COCO-(trainvalno5k-2014)-dataset)
* GPU：Tesla V100-32GB 4卡 

* 准备文件
1. 修改 [yolov4.cfg](https://raw.githubusercontent.com/AlexeyAB/darknet/master/cfg/yolov4.cfg)，新文件命名为 **human_detector_yolov4.cfg**，修改以下行：
> width=512 （需被32整除）
> height=512（需被32整除）> subdivisions=8 (若 run time error，则改成16)  
> max_batches=6000（=2000*检测类别数，注意：该数需不少于6000，且不少于训练图像数量）
> steps=4800,5400 (max_batches的80%，90%)

 - 修改 3 个 [yolo] 层的 classes=1
 - 修改 3 个 [yolo] 层前 3 个 [convolutional] 层的 filters=255 为 filters=(classes+5)*3=18 

2. **csdarnet53-omega.conv.105** -这是在ImageNet上预训练过的 darknet53 网络前105层：
  - 从[这]( https://drive.google.com/open?id=18jCwaL4SJ-jOvXrZNGHJ5yz44g9zi8Hm)下载 csdarknet53-omega_final.weights
  - 取前105层
  > ./darknet partial cfg/csdarknet53-omega.cfg csdarknet53-omega_final.weights csdarknet53-omega.conv.105 105

3. 修改 [data/coco.name]( https://raw.githubusercontent.com/AlexeyAB/darknet/master/data/coco.names)，新文件命名为 **human_detector.names**，删除除person之外的其他 79 类标签，最终 obj.name 文件内容为：
   > person  

4. 修改 cfg/coco.data 为 **cfg/human_detector.data**：
> classes= 1
> train  = data/trainvalno5k.txt
> valid = data/testdev2017.txt
> names = data/human_detector.names
> backup = backup
> eval = coco

5. 准备数据, 为 /hdd02/zhangyiyang/data/coco/train2014 和 /hdd02/zhangyiyang/data/coco/val2014 建立软连接软链接：
> ln -s /hdd02/zhangyiyang/data/coco/train2014 /hdd01/wanghuijiao/darknet/coco/cocoMetadata/images
> ln -s /hdd02/zhangyiyang/data/coco/val2014  /hdd01/wanghuijiao/darknet/coco/cocoMetadata/images

  - 为数据生成规定输入格式：
  - 为每张 .jpg 图片生成单独的 .txt 文件，图片中每个目标对象占一行，格式为 \<object-class\>  \<x_center\>  \<y_center\>  \<width\>  \<height\>   
      - \<object-class\>：从标号为 0 到 (classes-1) 的整数，表示类别标签序号         
      - \<x_center\> \<y_center\>  \<width\>  \<height\>: 是与图像标签框宽和高有关的浮点数，例如： 
        > x_center = absolute_x_center / image_width 
        > height = absolute_height / image_height

      - 注意：\<x_center\>, \<y_center\> 是矩形框的中心并非左上角。  
      - .txt 文件名和 .jpg 图片名保持一致
      - txt 内容示例如：
        > 1 0.716797 0.395833 0.216406 0.147222
        > 0 0.687109 0.379167 0.255469 0.158333
        > 1 0.420312 0.395833 0.140625 0.166667  
              
 -  在 \data 文件夹下创建 train.txt 文件，输入图片的绝对路径，每张图片占一行，内容如下：
    >   /hdd01/wanghuijiao/darknet/coco/train2017/img1.jpg
    >   /hdd01/wanghuijiao/darknet/coco/train2017/img2.jpg
    >   /hdd01/wanghuijiao/darknet/coco/train2017/img3.jpg
 
 -  val.txt 准备同上

6. (忽略，已放弃这种改法) 修改 src/data.c，限制只读入 human 检测标注框，对应将 L225-239 改为：
>         if (id==0){
>            boxes = (box_label*)xrealloc(boxes, (count + 1) * sizeof(box_label));
>            boxes[count].track_id = count + img_hash;
>            //printf(" boxes[count].track_id = %d, count = %d \n", boxes[count].track_id, count);
>            boxes[count].id = id;
>            boxes[count].x = x;
>            boxes[count].y = y;
>            boxes[count].h = h;
>            boxes[count].w = w;
>            boxes[count].left   = x - w/2;
>            boxes[count].right  = x + w/2;
>            boxes[count].top    = y - h/2;
>            boxes[count].bottom = y + h/2;
>            ++count;
>        }  
相较于源代码，仅在 while 循环内添加条件if(id==0)语句。

7. 训练命令
  - 先编译一下（一次就好，重复开启训练时不需要编译）
  > ./build.sh  

  - 开启训练（-map 是训练同时计算 mAP)
  > ./darknet detector train cfg/human_detector.data cfg/human_detector_yolov4.cfg csdarknet53-omega.conv.105 -dont_show -map  


8. 测试单张图片命令
  > ./darknet detector test cfg/obj.data cfg/whj_yolov4.cfg backup/human_detector_yolov4_final.weights -thresh 0.25 -ext_output data/person.jpg  

  - 训练好的权重文件在backup文件内，每1000次迭代存储一个权重文件，例如：backup/whj_yolov4_l000.weights，最后会有 backup/whj_yolov4_last.weights 和 backup/whj_yolov4_final.weights。backup/whj_yolov4_final.weights 是最终的权重文件。backup/whj_yolov4_last.weights 是最近一次100次迭代的权重文件.  


9. 评估 AP 和速度
 - 参考 [How to evaluate accuracy and speed of YOLOv4](https://github.com/AlexeyAB/darknet/wiki/How-to-evaluate-accuracy-and-speed-of-YOLOv4)
 - 步骤
   1）
  待做


## 4、实验记录

| 实验序号 | 参数  | 描述  | 状态  | 精度  | 备注  |
|:--------:|:-----:|:-----:|:-----:|:-----:|:-----:|
| HD01     |  训练集：coco2014     |       |    done   |       |       |
| HD02     | ||||


## 5、复现效果
1. 单张图片测试

  - 用 YoloV4 自带的 weights 测试 data/person.jpg ：
  > ./darknet detector test cfg/coco.data cfg/yolov4.cfg yolov4.weights -thresh 0.25 -ext_output data/person.jpg  

  人类检测结果为：
  person: 100% (left_x:  194   top_y:   98   width:   79   height:  281)

  - 用复现的 weights 测试 data/person.jpg:
  > ./darknet detector test cfg/obj.data cfg/whj_yolov4.cfg backup_0803/whj_yolov4_2000.weights -thresh 0.25 -ext_output data/person.jpg  

  人类检测结果为：
  person: 71%     (left_x:  183   top_y:   94   width:   93   height:  274) 

2. mAP + AP 精度  

 class_id = 0, name = person, ap = 58.68%         (TP = 5496, FP = 2076) 

 for conf_thresh = 0.25, precision = 0.73, recall = 0.50, F1-score = 0.60 
 for conf_thresh = 0.25, TP = 5496, FP = 2076, FN = 5392, average IoU = 55.55 % 

 IoU threshold = 50 %, used Area-Under-Curve for each unique Recall 
 mean average precision (mAP@0.50) = 0.586805, or 58.68 % 




